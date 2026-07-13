# Backend Developer Guide

이 문서는 `backend/` 코드베이스의 실제 구현을 기준으로 정리한 개발 가이드라인입니다.
설계 의도는 `docs/technical-design.md`, `docs/domain-model.md`를 따르되, 이 문서는 "실제 코드가
어떻게 그 의도를 구현하고 있는지"를 다룹니다. 새 유스케이스/리포지토리/핸들러를 추가할 때
이 문서의 패턴을 따르세요.

## 1. 레이어 구조

```
cmd/server/main.go                      # 의존성 조립(wiring)만 담당
internal/
  domain/                                # 순수 Go. 외부 패키지 import 금지
  usecase/                               # 애플리케이션 서비스 + 포트(interface) 정의
  infrastructure/
    postgres/                            # 리포지토리 구현체 (pgx + sqlc)
    web/                                 # echo 핸들러, 미들웨어, DTO
    sse/                                 # Broadcaster 구현체
  config/                                # 환경설정 로딩
docs/                                    # sqlc/swag 생성 산출물 포함
db/                                      # 마이그레이션, sqlc 쿼리 소스
```

> CLAUDE.md에는 `adapter/postgres`, `adapter/http`라는 이름이 나오지만 실제 패키지 경로는
> `infrastructure/postgres`, `infrastructure/web`입니다. 이 문서에서는 실제 경로를 기준으로 설명합니다.

**의존 방향은 항상 안쪽을 향합니다**: `web`/`postgres`/`sse` → `usecase` → `domain`.
`domain`은 `errors`, `time` 등 표준 라이브러리 외에는 아무것도 import하지 않습니다
(`internal/domain/errors.go`, `optional.go` 참고). `usecase`는 리포지토리/브로드캐스터를
인터페이스(`internal/usecase/port.go`)로만 알고, 구현은 `infrastructure/*`에서 주입됩니다.

## 2. Domain 계층

### 2.1 ID 타입

모든 엔티티 ID는 `string` 기반 named type (`internal/domain/id.go`)입니다.
`uuid.NewString()`으로 생성하고 캐스팅해서 사용합니다 (`domain.VisitID(s.uuidFn())`).
새 엔티티를 추가할 때 `string` 원시 타입을 그대로 노출하지 말고 여기에 named type을 추가하세요.

### 2.2 Optional[T]

"필드가 없음"을 포인터의 암묵적 관례 대신 `domain.Optional[T]` (`internal/domain/optional.go`)로
명시적으로 표현합니다.

```go
badge.AssignedGroupID Optional[GroupID]

groupID, ok := badge.AssignedGroupID.Value()  // 읽기
badge.AssignedGroupID = domain.Some(groupID)  // 설정
badge.AssignedGroupID = domain.None[domain.GroupID]()  // 미지정
```

Postgres 매핑 시 `pgtype.Text{Valid: bool}` ↔ `Optional[T]` 변환은 리포지토리 계층
(`mapBadge` 같은 헬퍼)에서 담당합니다. `domain` 패키지가 `pgtype`을 알아서는 안 됩니다.

### 2.3 불변식은 도메인 메서드에

상태 전이 로직은 구조체 메서드로 구현하고, 실패 시 `errors.go`에 정의된 sentinel error를
반환합니다.

```go
func (t *Track) StartVisit(visitID VisitID) error
func (g *Group) MarkVisitStarted(cornerID CornerID) error
func (v *Visit) Complete(now time.Time) error
```

usecase 계층은 이 메서드들을 호출만 하고, 상태를 직접 조작하지 않습니다
(`internal/usecase/visit.go` 참고).

### 2.4 Sentinel error 컨벤션

- 모든 도메인 에러는 `internal/domain/errors.go`에 `var Err... = errors.New(...)`로 선언합니다.
- 문자열 비교(`err.Error() == "..."`) 금지. 항상 `errors.Is(err, domain.ErrXxx)` 사용.
- 추가 데이터(락 해제 시각 등)가 필요한 에러는 별도 struct로 감싸고 `Is(target error) bool`을
  구현해 `errors.Is`와 호환되게 합니다 (`DeviceLockedError`, `InvalidPinError` 참고).
- 새 도메인 에러를 추가하면 **반드시** `internal/infrastructure/web/error_handler_middleware.go`의
  `mapDomainError`에 HTTP 상태코드/에러코드 매핑을 추가해야 합니다. 매핑이 없으면 500으로
  떨어집니다.

## 3. Usecase 계층

### 3.1 서비스 구조

기능 단위(Visit, Camp, Badge, ...)별로 `XxxService` struct를 두고, 생성자에서 필요한
포트(리포지토리, `TxManager`, `Broadcaster`, `AuditLogRepository`)를 주입받습니다
(`internal/usecase/visit.go`의 `VisitService` 참고).

테스트 결정성을 위해 시간/UUID 생성은 필드로 주입 가능하게 만듭니다:

```go
nowFn  func() time.Time  // 기본값: func() time.Time { return time.Now().UTC() }
uuidFn func() string     // 기본값: uuid.NewString
```

새 서비스를 만들 때도 이 패턴을 따라 테스트에서 `nowFn`/`uuidFn`을 오버라이드할 수 있게 하세요.

### 3.2 유스케이스 메서드의 표준 흐름

각 메서드는 대체로 이 순서를 따릅니다:

1. 인증/세션 검증 (토큰 해시 조회 → `IsActive()` 체크)
2. `tx.RunInTx(ctx, func(ctx) error { ... })` 안에서:
   - 필요한 엔티티 로드 (`Get`)
   - nil 체크 → 적절한 sentinel error 반환
   - 도메인 메서드 호출로 상태 전이
   - 변경된 엔티티들을 `Save`
3. 트랜잭션 커밋 **이후**에만:
   - `recordAuditLog` 호출 (성공/실패 모두 기록)
   - `broadcaster.Broadcast` 호출

```go
err = s.tx.RunInTx(ctx, func(ctx context.Context) error {
    // 로드 → 검증 → 도메인 메서드 → Save
})
if err != nil {
    s.recordAuditLog(ctx, actor, "VISIT_START", ..., false, map[string]any{"error": err.Error()})
    return nil, err
}
s.recordAuditLog(ctx, actor, "VISIT_START", ..., true, map[string]any{...})
_ = s.broadcaster.Broadcast(ctx, campID, EventXxxUpdated, "camp")
return result, nil
```

**절대 트랜잭션 함수 내부에서 `Broadcast`를 호출하지 마세요.** 롤백된 변경이 클라이언트에
푸시되면 안 됩니다 (기술설계 §SSE 원칙). `Broadcast` 에러는 `_ =`로 무시합니다 — 실시간 알림
실패가 비즈니스 트랜잭션 자체를 실패시켜서는 안 되기 때문입니다.

### 3.3 포트(인터페이스) 정의 위치

모든 리포지토리/브로드캐스터/쿼리어 인터페이스는 `internal/usecase/port.go` 한 곳에 모아
정의합니다. 새 엔티티를 추가하면 여기에 `XxxRepository` 인터페이스를 추가하고, 구현체는
`internal/infrastructure/postgres/xxx_repo.go`에 작성합니다.

리포지토리 메서드는 최소 집합만 정의합니다 (`Get`, `Save`, 필요한 `ListXxx`류). 범용
`Update`/`Delete`를 미리 만들어두지 않고, 실제로 필요한 usecase가 생겼을 때 추가합니다.

### 3.4 이벤트/브로드캐스트

`NotificationEvent` 상수와 scope 문자열(`"camp"`, `"track:"+id`)은 `port.go`에 정의되어
있습니다. 새 이벤트를 추가할 때:
- SSE 페이로드는 항상 **풀 스냅샷**이지 델타가 아닙니다 (CLAUDE.md, 기술설계 원칙).
- scope는 `"camp"`(캠프 전체 구독자) 또는 `"track:{id}"`(특정 트랙 구독자) 형태를 따릅니다.

## 4. Infrastructure 계층

### 4.1 Postgres 리포지토리

- SQL은 직접 작성하지 않고 [sqlc](https://sqlc.dev)로 생성된 `internal/infrastructure/postgres/db`
  패키지(`Queries`, `*Params`, 모델 struct)를 사용합니다. 쿼리 소스는 `backend/db/`에 있습니다.
- 리포지토리 struct는 `*pgxpool.Pool`을 들고, `queries(ctx)` 헬퍼로 트랜잭션 유무에 따라
  `db.New(tx)` 또는 `db.New(pool)`을 선택합니다:

```go
func (r *pgBadgeRepository) queries(ctx context.Context) *db.Queries {
    if tx := ExtractTx(ctx); tx != nil {
        return db.New(tx)
    }
    return db.New(r.pool)
}
```

  새 리포지토리를 추가할 때 이 헬퍼를 그대로 복사해서 씁니다. `ExtractTx`
  (`tx_manager.go`)는 `TxManager.RunInTx`가 context에 심어둔 `pgx.Tx`를 꺼냅니다.

- `pgx.ErrNoRows`는 항상 `(nil, nil)`로 변환합니다 — "존재하지 않음"을 에러가 아니라 nil
  반환으로 표현하고, usecase 계층에서 nil 체크로 sentinel error를 던집니다.
- DB row ↔ domain 구조체 매핑은 `mapXxx(row db.Xxx) *domain.Xxx` 형태의 비공개 함수로
  분리합니다 (`mapBadge` 참고). `pgtype.Text` 등 DB 전용 타입은 이 매핑 함수 밖으로 나가지
  않습니다.
- 벌크 저장(`SaveBulk`)은 이미 트랜잭션 안이면 그 트랜잭션을 재사용하고, 아니면 자체
  트랜잭션을 새로 열어 원자성을 보장합니다 (`badge_repo.go`의 `SaveBulk` 참고).

### 4.2 Web (echo) 핸들러

- 라우트는 `internal/infrastructure/web/router.go` 한 곳에서 등록합니다. 핸들러 그룹은
  `Handlers` struct 필드로 관리하고, `nil` 체크(`if h.Camp != nil`)로 옵션 등록 — 이는 통합
  테스트에서 일부 핸들러만 wiring할 때 nil panic을 피하기 위함입니다.
- 인증 요구 수준별로 라우트 그룹을 나눕니다: 공개(`v1`), 관리자(`admin` — `AdminAuthMiddleware`),
  트랙/진행자(`track` — `TrackAuthMiddleware`).
- 에러 처리는 핸들러가 아니라 `ErrorHandler()` 미들웨어(`error_handler_middleware.go`)가
  중앙에서 담당합니다. 핸들러는 usecase 에러를 그대로 리턴하면 됩니다 — 직접 `c.JSON`으로
  에러 응답을 만들지 마세요. `echo.HTTPError`(바인딩/검증 실패)와 domain sentinel error를
  구분해서 처리합니다.
- 응답 DTO는 `api_dtos.go`, `auth_dtos.go`, `report_dtos.go` 등 기능별 파일에 모읍니다.
  API 계약(`api/openapi.yaml`)과 필드명이 1:1로 대응해야 합니다 — 이름이 어긋나면
  `workflow/Collaborate.md` 프로토콜 위반입니다.

### 4.3 SSE Broadcaster

`internal/infrastructure/sse/broadcaster.go`가 `usecase.Broadcaster` 인터페이스를 구현합니다.
usecase는 이 구현을 모르고 인터페이스로만 호출하므로, 브로드캐스터 구현을 교체해도(예: Redis
pub/sub로 전환) usecase 코드는 변경되지 않습니다.

## 5. 인증

- 모든 토큰(진행자 트랙 PIN 세션, 기기 신뢰 토큰, 관리자 access/refresh)은 **opaque token**이며
  JWT가 아닙니다. DB에는 해시(`hashSHA256`, `internal/usecase/utils.go`)만 저장합니다. 이는
  확정된 설계 결정이며 재검토 대상이 아닙니다.
- 리포지토리 조회는 항상 `GetByTokenHash`/`GetByAccessTokenHash` 형태 — 평문 토큰을 저장하거나
  DB에서 평문으로 비교하지 않습니다.

## 6. 테스트

- Domain 계층 테스트는 `domain_test` 외부 패키지로 작성하고(`camp_test.go`,
  `group_test.go` 등), `t.Run`으로 서브테스트를 나눕니다. 외부 의존성 없이 순수 struct/메서드
  호출만으로 작성 가능해야 합니다 — 이게 안 되면 도메인 로직이 usecase로 새어나간 신호입니다.
- Usecase 테스트는 `port.go`의 인터페이스를 in-memory/mock 구현으로 만족시키고,
  `nowFn`/`uuidFn`을 고정값으로 주입해 결정적으로 만듭니다.
- 실행:

```bash
cd backend
go test ./...                                   # 전체
go test ./internal/domain/...                   # 패키지 단위
go test ./internal/domain/... -run TestCampActivate  # 단일 테스트
gofmt -w . && go vet ./...                       # 커밋 전
```

## 7. 새 유스케이스 추가 체크리스트

1. `docs/domain-model.md`에 도메인 개념이 이미 있는지 확인 (없으면 도메인 모델 먼저 갱신).
2. `internal/domain/`에 필요한 ID 타입(`id.go`), 상태 전이 메서드, sentinel error(`errors.go`) 추가.
3. `internal/usecase/port.go`에 리포지토리 인터페이스 추가/확장.
4. `internal/infrastructure/postgres/`에 sqlc 쿼리 + 리포지토리 구현체 + `mapXxx` 매핑 함수 추가.
5. `internal/usecase/xxx.go`에 서비스 메서드 추가 — 트랜잭션 내부 로드/검증/도메인호출/Save,
   트랜잭션 밖에서 audit log + broadcast.
6. `internal/infrastructure/web/error_handler_middleware.go`의 `mapDomainError`에 새 에러 매핑 추가.
7. `internal/infrastructure/web/`에 핸들러 + DTO 추가, `router.go`에 라우트 등록.
8. `api/openapi.yaml` 갱신 (`workflow/Collaborate.md` 프로토콜).
9. domain 단위 테스트 + usecase 테스트 작성, `go test ./...` 통과 확인.

## 8. 객체 캡슐화 원칙

특별한 이유가 없으면 객체의 필드는 private로 합니다.

### 5. 재시도 전략 (Dual-Layer Retry)

재시도 로직은 **발생 계층**에 따라 분리합니다.

| 계층        | 대상 에러                 | 전략                | 최대 횟수 |
| ----------- | ------------------------- | ------------------- | --------- |
| **Infra**   | HTTP 5xx, 429, Timeout    | Exponential Backoff | 3회       |
| **Service** | JSON 파싱 실패, 필드 누락 | Immediate Retry     | 2회       |

### 6. 로깅 전략 (Dual Logging)

#### 6.1 DB 서비스 이력 (History, 영속성)

- **목적**: 비즈니스 분석, 디버깅, 프롬프트 튜닝
- **저장 대상**: Job 시작/완료, Phase 결과, `<thinking>` 내용
- **저장소**: `generation_history` 테이블

#### 6.2 시스템 로그 (Log, 휘발성)

- **목적**: 실시간 모니터링, 에러 추적
- **저장 대상**: INFO, WARN, ERROR 레벨 로그
- **저장소**: Stdout (JSON 구조화)
- **중앙 집중식 로깅 및 에러 래핑 원칙**:
  - `domain`, `usecase`, `repository` 등 하위 계층에서는 직접 로그(slog 등)를 출력하지 않습니다.
  - 쿼리 실패, 네트워크 오류 등 예기치 못한 인프라 장애(5xx 유발) 시에만 최초 발생 지점에서 `errs.Wrap(ctx, err)`을 호출해 스택 트레이스와 Trace ID를 래핑하여 전파합니다.
  - 비즈니스 도메인 규칙 위반 에러(4xx 유발)는 스택 추적 비용(`runtime.Callers`)을 방지하기 위해 `errs.Wrap` 없이 Sentinel 에러를 그대로 리턴합니다.
  - 모든 로그는 최상위 미들웨어/인터셉터에서 단 1회 JSON 구조화 로그로 통합 로깅합니다.

- **Context 전달 습관화**:
  - 추후 분산 트레이싱 및 타임아웃 고도화를 위해 `Usecase -> Repository -> DB/HTTP Client` 경로 상의 모든 메서드는 `context.Context`를 첫 번째 인자로 빠짐없이 전달해야 합니다.

- **외부 API 재시도 원칙**:
  - 데이터베이스 트랜잭션과 무관한 외부 API 호출 지점(예: 외부 인증, 결제 통신 등)은 일시적인 네트워크 오류에 대응하기 위해 2~3회 가벼운 루프 기반의 재시도를 자체 구현하여 넣습니다.
  - 단, 비즈니스 유즈케이스 계층에서는 복잡성과 사이드 이펙트를 방지하기 위해 자체 재시도를 전면 배제하고 즉시 에러를 상위로 전파하십시오.

