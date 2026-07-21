# Plan: 유즈케이스 오류 컨텍스트 보존

> 진행 현황 (2026-07-21): Phase A 완료 — `OperationError`, 민감 속성 차단,
> 감사 metadata/HTTP 구조화 로그 투영과 회귀 테스트를 구현했다. 유즈케이스 전수 전환은
> PR 크기 제한에 맞춰 후속 의존 PR로 분할 진행한다.

## 0. 조사 결과 및 작업 범위

### 전수조사 기준

- 대상: `backend/internal/usecase`의 프로덕션 Go 파일 전체(테스트·mock 제외)와 이 오류를 소비하는 `web`/`errs` 계층.
- 결과: 서비스 receiver 메서드 86개, `err`를 가공 없이 반환하는 경로 226개, `domain.Err...` sentinel을 직접 반환하는 지점 최소 80개를 확인했다.
- 조사 시점 작업 트리에는 인증 핸들러·관련 계획/테스트의 기존 변경이 있었으며, 본 조사는 이를 수정하지 않았다. 이번 작업은 백엔드 내부 관측성 개선이다. HTTP 성공/실패 계약과 OpenAPI를 바꾸지 않으므로 API 변경 절차는 적용하지 않는다.

### 확인된 문제

1. `domain` sentinel은 HTTP 분류에 필요한 원인만 표현하고, 유즈케이스명·실패 단계·관련 ID·실제 상태·기대 조건을 보존하지 않는다. 예를 들어 `ErrCampInvalidTransition`은 캠프가 없었는지, `PENDING`/`ACTIVE`/`ENDED` 중 무엇이었는지 알 수 없다.
2. 유즈케이스가 리포지토리/도메인 오류를 `return err`로 전파한다. Postgres 오류는 `errs.Wrap`이 스택과 trace ID를 확보하지만, 그 오류가 어떤 유즈케이스의 어떤 포트 호출에서 발생했는지는 구조화돼 있지 않다. 정상적인 4xx 도메인 오류는 `AppError`가 아니어서 발생 위치도 남지 않는다.
3. 실패 감사 로그는 38개 지점에서 사실상 `{"error": err.Error()}`만 저장한다. 대상 ID가 비어 있거나(예: 메시지 발송), 트랜잭션 내부에서 실패한 세부 단계 및 관련 엔티티 ID가 누락된다.
4. `web.ErrorHandler`는 `error_msg`와 raw error만 로그에 넘긴다. `SlogWrappedHandler`는 raw error를 제거하므로, 현재는 trace ID/스택 외에 구조화된 유즈케이스 컨텍스트가 JSON 로그에 남지 않는다.

### 우선 보강 대상

| 우선순위 | 유즈케이스 묶음 | 조사에서 확인한 대표 손실 조건 | 용도 |
| --- | --- | --- | --- |
| **P0** | 방문 시작·완료, 캠프 종료 | track/group/badge/visit/camp 조회·상태검사 및 다중 Save 중 어느 단계가 실패했는지 알 수 없음 | **프로덕션 핵심 운영 흐름** |
| **P0** | 트랙 생성·삭제·교체·PIN, 조/배지 등록 | camp/corner 범위, 기존 트랙·배지 배정 상태, PIN 보호기 실패 조건이 사라짐 | **프로덕션 핵심 관리 흐름** |
| P1 | 진행자/관리자 인증, 기기 신뢰, 공지·메시지 | 세션·기기·권한·수신확인 조건 및 저장 포트 실패의 식별자가 부족함 | 보안·운영 지원 흐름 |
| P2 | 조회·리포트·스냅샷·정리 | camp/track/corner 조회와 query port 실패의 호출 맥락이 없음 | 조회·배치 관측성 |

### 파일별 조사 요약

| 서비스 파일 | 주요 실패 경로 | 보강 우선순위 |
| --- | --- | --- |
| `/home/lsjtop10/projects/cornermon/backend/internal/usecase/visit.go` | 세션, track, badge, group, camp 상태와 visit/track/group 저장 | P0 |
| `/home/lsjtop10/projects/cornermon/backend/internal/usecase/camp.go` | 캠프 활성화/종료, 기기·세션 회수, 진행 중 visit 최종화 | P0 |
| `/home/lsjtop10/projects/cornermon/backend/internal/usecase/track.go` | 생성/삭제/교체/PIN 재생성·내보내기, corner-camp 일치 | P0 |
| `/home/lsjtop10/projects/cornermon/backend/internal/usecase/group.go`, `badge.go`, `corner.go` | 등록 캠프/배지/코너/순회표 조건 및 bulk 저장 | P0 |
| `/home/lsjtop10/projects/cornermon/backend/internal/usecase/auth_facilitator.go`, `auth_admin.go`, `device_trust.go` | 장치 승인·잠금, 세션, 권한, 관리자 계정 상태 | P1 |
| `/home/lsjtop10/projects/cornermon/backend/internal/usecase/announcement.go`, `message.go` | track 범위, 공지 receipt, unread counter 및 저장 | P1 |
| `/home/lsjtop10/projects/cornermon/backend/internal/usecase/report.go`, `snapshot.go`, `corner_cleanup.go`, `admin_bootstrap.go` | 캠프 상태, query port, 환경·정리 작업 실패 | P2 |

## 1. 유즈케이스 우선 정의

| 우선순위 | 유즈케이스 | 설명 | 용도 |
| --- | --- | --- | --- |
| **P0** | UC-1: 오류 컨텍스트 생성·전파 | 모든 유즈케이스 오류를 원인 보존(`errors.Is`/`errors.As`) 상태로 operation, stage, 안전한 속성과 함께 반환 | **프로덕션 공통 기반** |
| **P0** | UC-2: 핵심 명령 흐름 보강 | visit/camp/track/group/badge/corner의 모든 실패 반환점에 식별자·조건·상태를 부여 | **프로덕션 핵심 로직** |
| P1 | UC-3: 인증·메시징·기기 흐름 보강 | 인증/권한/공지/메시지/기기 신뢰 흐름을 같은 규약으로 전환 | **프로덕션 운영·보안 로직** |
| P2 | UC-4: 조회·배치 흐름 보강 | report/snapshot/cleanup/bootstrap의 포트·조건 오류를 규약에 편입 | 조회·운영 작업 |
| **P0** | UC-5: 로그·감사 기록 투영 | HTTP 오류 로그와 실패 감사 메타데이터에 구조화된 컨텍스트를 출력하되, 클라이언트 오류 계약은 보존 | **프로덕션 관측성** |

예상 공개 시그니처(도메인 sentinel을 감싸되 원인은 유지):

```go
// backend/internal/usecase/error_context.go
type OperationError struct {
    Operation string
    Stage     string
    Attributes map[string]any
    Cause     error
}

// Error는 Cause.Error()를 그대로 반환해 기존 HTTP message 계약을 보존한다.
func (e *OperationError) Error() string
func (e *OperationError) Unwrap() error

// attrs에는 ID, 상태, boolean/정수처럼 로그에 안전한 값만 허용한다.
func withErrorContext(operation, stage string, cause error, attrs map[string]any) error
func errorAuditMetadata(err error, attrs map[string]any) map[string]any
```

## 2. 설계 원칙 및 오류 규약

1. `domain`은 계속 순수 sentinel 및 상태 전이만 책임진다. 유즈케이스의 operation/stage/ID를 도메인 오류 타입에 추가하지 않는다.
2. `OperationError.Unwrap()`으로 원인을 보존한다. 기존 핸들러의 `errors.Is(err, domain.ErrXxx)`와 `errors.As` 기반의 `InvalidPinError`/`DeviceLockedError` 처리는 계속 동작해야 한다.
3. `Error()`는 반드시 `Cause.Error()`를 그대로 반환한다. 진행 중인 handler-local 매핑에는 `Message: err.Error()`인 호출부가 있으므로 operation/stage/ID를 Error 문자열에 넣으면 내부 문맥이 클라이언트에 노출될 수 있다. 운영 분석의 기준은 구조화된 `operation`, `stage`, `attributes`, `cause` 필드이며, HTTP `ErrorResponse`의 code/status/message는 현재와 동일하게 유지한다.
4. 속성 allowlist를 둔다. opaque token, raw PIN, password, bcrypt hash, registration code, QR 원문, 암호화 PIN 및 전체 요청 body는 `Attributes`·감사 메타데이터·로그에 절대 넣지 않는다. 토큰 관련 오류에는 기존처럼 `token_hash_prefix`조차 기본적으로 남기지 않고, 안전한 track/camp/session ID를 확인할 수 있을 때만 사용한다.
5. 속성 map은 생성 시 복사하고, audit log와 slog에는 JSON 직렬화 가능한 scalar/ID/상태만 전달한다. 호출자 map 변경으로 오류 내용이 바뀌지 않게 한다.
6. 예상된 도메인 조건 오류에는 스택 캡처를 강제하지 않는다. 예상 밖의 포트/암호화/트랜잭션 오류는 기존 `errs.AppError`를 보존하며, 필요 시 최초 유즈케이스 경계에서만 `errs.Wrap(ctx, ...)`를 적용해 중복 wrap을 피한다.
7. `/home/lsjtop10/projects/cornermon/backend/docs/artifacts/plan/20260721_handler_local_error_mapping_workflow_plan_.md`의 handler-local helper는 `errors.Is(err, domain.ErrXxx)`로 분기한다. `OperationError.Unwrap()`과 Echo `HTTPError.Unwrap()`이 모두 원인을 노출하므로 두 작업은 호환된다. 유즈케이스 컨텍스트 투영은 helper가 `.SetInternal(err)`로 원인을 보존한 뒤에도 `errors.As`로 읽을 수 있다.

## 3. 구현 단계

### Phase A: 공통 오류 컨텍스트와 안전한 투영 (예상 소요: 3시간)

| 순서 | 작업 | 파일 |
| --- | --- | --- |
| A-1 | `OperationError`, 원인 unwrap, 속성 복사·정규화, `errors.As` 추출 헬퍼를 추가한다. operation/stage 명명 규칙(`visit.start_qr`, `track.replace`, `repository.save_visit` 등)을 상수 또는 문서화된 규약으로 고정한다. | `/home/lsjtop10/projects/cornermon/backend/internal/usecase/error_context.go` **(신규)** |
| A-2 | 실패 감사 로그용 메타데이터 병합 헬퍼를 추가한다. 기존 `error` 키는 호환성을 위해 유지하고 `operation`, `stage`, `error_type`, 안전 속성을 추가한다. | `/home/lsjtop10/projects/cornermon/backend/internal/usecase/error_context.go` **(신규)**, 각 서비스의 `recordAuditLog` 호출부 **(기존 파일 확장)** |
| A-3 | HTTP 오류 처리 시 `OperationError`를 `errors.As`로 읽어 slog 속성으로 기록한다. 4xx/5xx 응답 body와 `SetInternal` 원인 연결은 바꾸지 않는다. | `/home/lsjtop10/projects/cornermon/backend/internal/infrastructure/web/error_handler_middleware.go` **(기존 파일 확장)** |
| A-4 | 오류 wrapper, HTTP 로그 속성, 민감정보 제외 및 기존 domain 매핑 호환성 테스트를 작성한다. | `/home/lsjtop10/projects/cornermon/backend/internal/usecase/error_context_test.go` **(신규)**, `/home/lsjtop10/projects/cornermon/backend/internal/infrastructure/web/error_handler_middleware_test.go` **(기존 파일 확장)** |

### Phase B: P0 명령 유즈케이스 전수 전환 (예상 소요: 6시간)

| 순서 | 작업 | 파일 |
| --- | --- | --- |
| B-1 | QR/수동 시작과 완료의 session 조회, track 상태, badge 배정, group itinerary, camp ACTIVE 조건, 각 Save를 stage별로 감싼다. `track_id`, `group_id`, `badge_id`(확인 후), `camp_id`, `corner_id`, `track_status`, `camp_status`, `current_visit_set`을 조건에 맞게 기록한다. | `/home/lsjtop10/projects/cornermon/backend/internal/usecase/visit.go` **(기존 파일 확장)** |
| B-2 | 캠프 생성/설정/활성화/종료와 종료 중 기기·세션·진행 방문 finalization을 감싼다. 누락된 group/track은 어떤 `visit_id`에서 발견됐는지, 상태 전이는 실제 camp 상태와 기대 상태를 기록한다. | `/home/lsjtop10/projects/cornermon/backend/internal/usecase/camp.go` **(기존 파일 확장)** |
| B-3 | track 생성/삭제/교체/PIN 재생성·내보내기의 camp/corner/track 조건, PIN protector, repository/transaction 단계를 감싼다. PIN 값·ciphertext를 속성에 넣지 않는다. | `/home/lsjtop10/projects/cornermon/backend/internal/usecase/track.go` **(기존 파일 확장)** |
| B-4 | group 등록·순회표 조회, badge 지정/스캔 지정, corner 생성·수정·삭제·순회표 동기화의 엔티티 조회/상태/저장 실패를 감싼다. 기존의 잘못된 sentinel 선택 또는 모호한 주석(`group not found`에 `ErrCornerNotInItinerary` 등)은 이번 단계에서 계약 변경 없이 별도 `stage`로 구분하고, sentinel 정정 필요성은 후속 이슈로 기록한다. | `/home/lsjtop10/projects/cornermon/backend/internal/usecase/group.go`, `badge.go`, `corner.go` **(기존 파일 확장)** |
| B-5 | 각 P0 서비스 테스트에 원인 sentinel 보존, stage/attributes, 실패 audit metadata를 추가한다. | `/home/lsjtop10/projects/cornermon/backend/internal/usecase/visit_test.go`, `camp_test.go`, `track_test.go`, `group_test.go`, `badge_test.go`, `corner_test.go` **(기존 파일 확장)** |

### Phase C: P1/P2 유즈케이스 전수 전환 (예상 소요: 5시간)

| 순서 | 작업 | 파일 |
| --- | --- | --- |
| C-1 | 진행자/관리자 인증 및 기기 신뢰의 session/device/admin/camp 조회, 권한·잠금·상태전이, 토큰 생성/암호화/저장 실패를 감싼다. credential 값은 기록하지 않는다. | `/home/lsjtop10/projects/cornermon/backend/internal/usecase/auth_facilitator.go`, `auth_admin.go`, `device_trust.go` **(기존 파일 확장)** |
| C-2 | 공지·메시지의 track scope, receipt, unread counter 및 저장 실패를 감싸고 audit metadata에 track/camp/notice/message 식별자를 남긴다. | `/home/lsjtop10/projects/cornermon/backend/internal/usecase/announcement.go`, `message.go` **(기존 파일 확장)** |
| C-3 | report/snapshot/cleanup/bootstrap의 camp 상태와 query/repository 실패에 operation/stage를 부여한다. 단, 주기 작업의 개별 레코드 오류에는 해당 레코드 ID만 남긴다. | `/home/lsjtop10/projects/cornermon/backend/internal/usecase/report.go`, `snapshot.go`, `corner_cleanup.go`, `admin_bootstrap.go`, `utils.go` **(기존 파일 확장)** |
| C-4 | 각 파일의 기존 단위 테스트에 sentinel/typed domain error 호환성과 민감정보 비노출을 추가한다. | `/home/lsjtop10/projects/cornermon/backend/internal/usecase/*_test.go` **(기존 파일 확장)** |

### Phase D: 회귀 검증·자체 리뷰 (예상 소요: 2시간)

| 순서 | 작업 | 파일 |
| --- | --- | --- |
| D-1 | `errors.Is` 기반 핸들러 분기가 wrapper 후에도 기존 HTTP 상태·코드를 유지하는 대표 통합 테스트를 추가한다. | `/home/lsjtop10/projects/cornermon/backend/internal/infrastructure/web/*_handler_test.go` **(기존 파일 확장)** |
| D-2 | wrapper 없는 직접 sentinel 반환 및 `return err` 잔존 지점을 재검색한다. 허용된 예외(단순 private helper/이미 맥락화된 오류)는 코드 주석 또는 테스트로 근거를 남긴다. | `/home/lsjtop10/projects/cornermon/backend/internal/usecase/` **(전수 점검)** |
| D-3 | 포맷, 전체 테스트, vet, diff 자체 리뷰와 로그 샘플 검토를 수행한다. | `/home/lsjtop10/projects/cornermon/backend/` |

## 4. 대표 적용 예시

```go
// VisitService.StartVisitManual 내부: domain sentinel과 호출 조건을 함께 보존한다.
if track == nil || track.Status() != domain.TrackActive {
    return withErrorContext("visit.start_manual", "validate_track_active",
        domain.ErrTrackNotActive,
        map[string]any{
            "track_id": string(session.TrackID()),
            "track_found": track != nil,
            "track_status": trackStatus(track),
            "group_id": string(groupID),
        },
    )
}

if err := s.groups.Save(ctx, group); err != nil {
    return withErrorContext("visit.start_manual", "repository.save_group", err,
        map[string]any{"group_id": string(group.ID()), "camp_id": string(group.CampID())},
    )
}
```

웹 계층은 클라이언트 계약을 확장하지 않고 로그에서만 컨텍스트를 투영한다.

```go
var operationErr *usecase.OperationError
if errors.As(err, &operationErr) {
    commonAttrs = append(commonAttrs,
        slog.String("operation", operationErr.Operation),
        slog.String("stage", operationErr.Stage),
        slog.Any("error_context", operationErr.Attributes),
    )
}
```

## 5. 검증 체크리스트

### 아키텍처·보안

- [ ] `domain`이 `usecase`, `errs`, `infrastructure`를 import하지 않는다.
- [ ] 유즈케이스는 기존 port interface만 사용하며 새 인프라 의존성을 만들지 않는다.
- [ ] 오류 wrapper의 `Unwrap`으로 모든 기존 `errors.Is`/`errors.As` 매핑이 유지된다.
- [ ] `OperationError.Error()`는 원인 메시지만 반환하며 operation/stage/속성은 HTTP response message에 노출되지 않는다.
- [ ] token, PIN, password, hash, registration code, QR 원문, ciphertext가 오류 문자열·slog·감사 metadata에 없다.
- [ ] `OperationError` 속성 map을 호출자가 변경해도 반환된 오류의 컨텍스트가 변하지 않는다.

### 유즈케이스 전수성

- [ ] P0 파일 6개와 P1/P2 파일 10개에 대해 모든 repository/transaction/domain 실패 반환점을 stage로 분류했다.
- [ ] `rg` 재점검으로 맥락 없는 `return domain.Err...` 및 `return err`를 제거하거나 허용 근거를 남겼다.
- [ ] 38개 실패 감사 로그가 `error` 문자열 외 operation/stage/안전 속성을 보존한다.
- [ ] visit/camp/track 복합 트랜잭션 실패 시 관련 엔티티 ID와 실패 저장 단계가 감사 로그와 요청 로그에서 확인된다.

### 자동 검증

- [ ] `cd /home/lsjtop10/projects/cornermon/backend && go test ./...`
- [ ] `cd /home/lsjtop10/projects/cornermon/backend && go vet ./...`
- [ ] `cd /home/lsjtop10/projects/cornermon/backend && gofmt -w internal/usecase internal/infrastructure/web`
- [ ] wrapper된 `ErrCampInvalidTransition`, `ErrTrackScopeForbidden`, `InvalidPinError`, `DeviceLockedError`의 HTTP 상태/코드 회귀 테스트 통과.
- [ ] 4xx 도메인 조건 오류 로그와 5xx 포트 오류 로그 각각에서 `trace_id`, `operation`, `stage`, 안전 속성을 검증한다.

## 6. 구현 전 결정이 필요한 사항

- 감사 로그 metadata는 장기 보관 데이터이므로, operation/stage와 ID만 영구 저장하고 실제 상태·상세 속성은 요청 구조화 로그에만 둘지, 모두 저장할지 보존 정책을 확정한다. 본 계획의 기본안은 운영 재현에 필요한 상태 값도 저장하되 민감정보 allowlist를 적용하는 것이다.
- 기존에 의미와 다른 sentinel을 재사용한 지점은 오류 컨텍스트 도입과 별개로 HTTP 계약 영향을 가질 수 있다. 본 작업에서는 관측성만 보강하고 sentinel/API 정정은 후속 이슈로 분리한다.
