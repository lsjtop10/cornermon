# 로깅 및 에러 추적 통합 구현 계획 (Logging Implementation Plan)

이 문서는 `workflow/plan.md` 지침에 따라 작성된 로깅 전략 및 에러 전파 기능 구현 계획입니다.

---

## 1. 유즈케이스 우선 정의

| 우선순위 | 유즈케이스 | 설명 | 용도 |
| :--- | :--- | :--- | :--- |
| **P0** (최우선) | UC-1: 시스템 에러 인터셉터 로깅 | 인프라 레이어에서 올라온 에러(`StackError`)의 Trace ID 및 콜스택 추출 후 단 1회 JSON 로깅 | **프로덕션 핵심 예외 추적** |
| **P0** (최우선) | UC-2: HTTP 성공/경고 로그 기록 | 정상 응답(2xx, 3xx) 및 도메인 에러(4xx) 요청 처리 소요시간과 컨텍스트 JSON 로깅 | **프로덕션 성능 통계 분석** |
| **P0** (최우선) | UC-3: Context 기반 에러 스택 래핑 | 에러 발생 시점의 스택 프레임과 `trace_id`를 보존하는 커스텀 `errs` 유틸리티 적용 | **프로덕션 공통 디버깅 인프라** |
| **P1** (중요) | UC-4: 중요 도메인 감사 로그 기록 | 보안 및 비즈니스 핵심 위반 이벤트(예: 핀번호 5회 실패) 발생 시 영구 저장소에 기록 | **프로덕션 보안 감사 이력** |
| **P1** (중요) | UC-5: 개발자 가이드라인 업데이트 | 로깅 원칙(하위 계층 로깅 배제, 5xx 에러 래핑)을 개발 표준 문서에 요약 명시 | **팀 내 개발 표준화** |

---

## 2. 객체 중심 설계 (Object-Oriented Design)

### 2.1 에러 스택 래핑 도메인 (`internal/errs`)

```go
type AppError struct {
    Err     error
    TraceID string
    Stack   []uintptr
}

// 책임: 표준 에러 메시지 반환
func (e *AppError) Error() string

// 책임: 표준 errors.Is/As 지원을 위한 원본 에러 언랩
func (e *AppError) Unwrap() error

// 책임: 스택 포인터 배열을 읽기 쉬운 파일:라인 문자열 슬라이스로 변환
func (e *AppError) FormatStack() []string

// 책임: 현재 발생 시점의 콜 스택과 주어진 컨텍스트의 trace_id를 추출하여 AppError로 래핑
func Wrap(ctx context.Context, err error) error
```

### 2.2 HTTP 인터셉터

```go
// 책임: 전체 HTTP 요청 소요 시간 및 결과(성공/도메인 에러)를 slog를 통해 JSON 구조화 단일 로깅
func Logger() echo.MiddlewareFunc

// 책임: 캐치되지 않은 5xx 인프라 에러에서 AppError 스택을 추출하여 ERROR 레벨로 단일 로깅 및 응답
func ErrorHandler() echo.HTTPErrorHandler
```

---

## 3. 아키텍처 원칙 명시

### 3.1 헥사고날 아키텍처 및 의존성 규칙 준수
- **Domain Layer**: 외부 의존성(Echo, slog 등) 없음.
- **Service Layer (Usecase)**: 로거를 직접 호출하지 않음. 필요 시 `AuditRepository` 인터페이스만 의존하여 감사 이력 저장.
- **Infrastructure Layer**: DB 어댑터 에러 발생 시 `errs.Wrap` 사용. Web 어댑터에서 최종 `slog` 호출.

### 3.2 Context 전달 습관화 (Context Propagation)
- 프레임워크 수준에서 전달받은 `context.Context`를 **Usecase -> Repository -> DB/HTTP Client**까지 인자로 중단 없이 전파합니다.
- 이는 분산 트레이싱(Trace ID), 타임아웃 제어, 그리고 에러 발생 시점의 컨텍스트 추적을 비즈니스 코드 수정 없이 인프라 설정만으로 고도화하기 위한 필수 조건입니다.

### 3.3 기존 포트 활용 우선
- 기존 `audit_log_repo.go`의 영속화 포트를 그대로 활용하여 도메인 감사 이벤트를 저장합니다.

### 3.4 의존성 규칙 검증
**검증 항목**:
- [ ] `domain` 패키지에서 `infrastructure` 또는 `slog` import 없음
- [ ] 모든 메서드 첫 번째 인자로 `context.Context`를 빠짐없이 전달함 (특히 `errs.Wrap`)
- [ ] Service 계층이 구체적 로거 구현체를 알지 못함

---

## 4. 계층별 책임 분리

### Domain Layer
```go
// 도메인 에러 정의 (Sentinel Errors)
var (
    ErrInvalidPin = errors.New("invalid pin")
    ErrGroupBusy  = errors.New("group is busy")
)
```

### Service Layer (Usecase)
```go
// 비즈니스 로직 흐름 제어 및 감사 로그 영속화 조율
type AuthUsecase struct {
    authRepo  domain.AuthRepository
    auditRepo domain.AuditLogRepository
}

// Usecase는 자체 재시도 없이 즉시 실패 처리하며 상위로 에러를 버블링함.
func (u *AuthUsecase) TrackLogin(ctx context.Context, pin string) (*domain.Session, error)
```

### Infrastructure Layer (DB & Web/HTTP Adapter)
```go
// DB 레포지토리 구체적 구현 (5xx 유발 인프라 장애 시 스택 래핑 적용)
type PostgresCampRepository struct {
    db *pgxpool.Pool
}

func (r *PostgresCampRepository) UpdateStatus(ctx context.Context, id domain.CampID, status domain.CampStatus) error

// Web 미들웨어 구현 (1회 JSON 로깅 담당)
func ErrorHandler() echo.HTTPErrorHandler
func Logger() echo.MiddlewareFunc
```

---

## 5. 재시도 전략 (Dual-Layer Retry)

재시도 메커니즘은 데이터 정합성 보장을 위해 **DB 트랜잭션과 엮여 있지 않은 외부 인프라 통신 계층**에 국한하여 선택적으로 적용합니다.

| 계층 | 대상 에러 | 전략 | 최대 횟수 / 룰 |
| :--- | :--- | :--- | :--- |
| **Infra (외부 API)** | 외부 API(결제, 인증 등) 호출 타임아웃, 일시적 네트워크 5xx | 가벼운 for 루프 기반 즉시 재시도 (DB 트랜잭션 비연동 필수) | 2~3회 |
| **Usecase** | DB 데드락, 락 충돌, 비즈니스 검증 실패 | **재시도 없음**. 에러 발생 즉시 상위로 버블링하여 즉시 실패(500/4xx) 처리 | 즉시 실패 |

---

## 6. 로깅 전략 (Dual Logging)

### 6.1 도메인 감사 이력 (Audit Log, 영속성)
- **목적**: 보안 위협 방어, 비즈니스 흐름 추적, 관리자 증적 자료
- **저장 대상**: 비밀번호 연속 실패, 캠프 강제 종료, 권한 없는 상태 변경 시도 등
- **저장소**: `audit_logs` 테이블 (Postgres)

### 6.2 시스템 로그 (Syslog, 휘발성)
- **목적**: 실시간 모니터링, 시스템 장애(5xx) 및 성능 통계 디버깅
- **저장 대상**: INFO(모든 API 처리 완료), WARN(4xx 도메인 에러), ERROR(스택 트레이스 포함 5xx 에러)
- **저장소**: Stdout (JSON 구조화 - `slog`)

---

## 7. 구현 단계 (Implementation Phases)

### Phase A: 공통 에러 유틸 및 문서/환경 구성 (예상 소요: 1.5시간)

| 순서 | 작업 | 파일 |
| :--- | :--- | :--- |
| A-1 | 로깅 원칙(하위계층 로깅금지, 5xx 래핑, Context 전파) 요약 추가 | `/home/lsjtop10/projects/cornermon/workflow/implement.md` **(기존 파일 확장)** |
| A-2 | `AppError` 구조체 및 `Wrap` 헬퍼 생성 | `/home/lsjtop10/projects/cornermon/backend/internal/errs/error.go` **(신규)** |
| A-3 | `slog.JSONHandler` 기본 설정 추가 | `/home/lsjtop10/projects/cornermon/backend/cmd/server/main.go` **(기존 파일 확장)** |

### Phase B: 인터셉터 및 미들웨어 통합 (예상 소요: 2.5시간)

| 순서 | 작업 | 파일 |
| :--- | :--- | :--- |
| B-1 | `Logger()` 미들웨어 `slog` JSON 변경 및 trace_id 주입 | `/home/lsjtop10/projects/cornermon/backend/internal/infrastructure/web/logger_middleware.go` **(기존 파일 확장)** |
| B-2 | `ErrorHandler()` 스택 추출 및 로깅 로직 개편 | `/home/lsjtop10/projects/cornermon/backend/internal/infrastructure/web/error_handler_middleware.go` **(기존 파일 확장)** |

### Phase C: 인프라 계층 컨텍스트 전파 및 예외 처리 고도화 (예상 소요: 2.5시간)

| 순서 | 작업 | 파일 |
| :--- | :--- | :--- |
| C-1 | 주요 Postgres Repository 및 트랜잭션 매니저 내부 함수에 `context.Context`가 누락된 곳이 있다면 보강하고, 쿼리 에러 지점에 `errs.Wrap(ctx, err)` 적용 | `/home/lsjtop10/projects/cornermon/backend/internal/infrastructure/postgres/...` **(기존 파일 확장)** |
| C-2 | 트랜잭션 미포함 외부 API 호출 부에 가벼운 for 루프 재시도 2~3회 보강 | `/home/lsjtop10/projects/cornermon/backend/internal/infrastructure/...` **(기존 파일 확장)** |

---

## 8. 검증 체크리스트

### 8.1 아키텍처 검증
- [ ] `domain` 및 `usecase` 패키지에서 로깅 프레임워크(`slog`) import 없음
- [ ] 에러 생성 시 `runtime.Callers` 비용 오버헤드를 막기 위해, 도메인 에러(4xx)에는 `errs.Wrap`이 사용되지 않음
- [ ] `workflow/implement.md` 가이드라인에 새로운 로깅 및 Context 전파 원칙이 명시됨
- [ ] Usecase -> Repository -> DB/HTTP Client 로 이어지는 경로 상 모든 메서드에 `context.Context`가 첫 번째 인자로 완전하게 전달됨

### 8.2 기능 및 유즈케이스 검증
- [ ] UC-1: 인프라 DB 장애 유발 시, 콘솔에 `stack_trace` 배열 필드가 포함된 `ERROR` 레벨 JSON 로그가 단 1회 정상 출력됨
- [ ] UC-2: 모든 정상 API 요청 처리 시, 소요 시간(`duration_ms`)을 포함한 `INFO` 레벨 JSON 로그가 단 1회 정상 출력됨
- [ ] UC-3: 고루틴 내부에서 에러가 발생하여 반환되었을 때도 JSON 로그에 요청 원본의 `trace_id`가 정확히 매핑됨
- [ ] UC-4: 권한 부족이나 비밀번호 다회 실패 시 시스템 로그와 분리되어 DB Audit 테이블에 이력이 정상 적재됨
- [ ] UC-5: 외부 API 호출 실패(트랙킹용) 가상 모킹 테스트 시 2~3회 재시도(for 루프) 후 최종 실패 여부를 출력함
