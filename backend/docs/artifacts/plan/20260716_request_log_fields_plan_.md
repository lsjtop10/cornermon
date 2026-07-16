# 요청 로그 필드 개선 계획

## 목표

`Logger`/`ErrorHandler` 미들웨어가 남기는 요청 로그를 실제 운영 디버깅에 쓸 수 있는 수준으로 개선한다: `trace_id` 중복 제거, `user_agent` 추가, 에러 로그에 사람이 읽을 수 있는 `error_msg` 노출, `duration`을 밀리초 단위(`duration_ms`)로 통일.

## 현재 문제

- **[버그] `trace_id` 중복**: `logger_middleware.go:47`의 `Logger`가 성공 로그에 `slog.String("trace_id", traceID)`를 명시적으로 찍는데, `errs.SlogWrappedHandler.Handle`(`error.go:130-136`)이 AppError가 없는 모든 레코드에 대해 컨텍스트의 `trace_id`를 자동으로 한 번 더 추가한다. 그 결과 성공 요청 로그 한 줄에 `trace_id` 필드가 두 번 찍힌다. (에러 로그는 `error_handler_middleware.go`가 명시적으로 찍지 않으므로 자동 주입 1회만 발생 — 정상.)
- **`user_agent` 부재**: `logger_middleware.go`, `error_handler_middleware.go` 모두 `c.Request().UserAgent()`를 로깅하지 않는다. `auth_handler.go:95`처럼 이미 코드베이스에 `UserAgent()` 사용 관례가 있다.
- **[버그] 에러 로그의 `error` 필드가 사실상 비어 보임**: `error_handler_middleware.go:69,76`이 `slog.Any("error", err)`로 에러 객체를 통째로 넘기는데, 대부분의 에러(`errors.New`, 도메인 sentinel 에러, `errs.AppError`)는 내보낼 수 있는(exported) 필드가 없어 JSON 핸들러가 `{}`로 직렬화한다. 401/500 등 실패 로그에서 정작 원인 메시지(`err.Error()`)가 안 보이는 원인이 이것이다.
- **`duration` 단위 문제**: `logger_middleware.go:51`이 `slog.Duration("duration", duration)`을 쓰는데, 표준 slog JSON 핸들러는 `time.Duration`을 나노초 정수로 직렬화한다. 가독성이 떨어지고 필드명도 단위를 알 수 없다. 또한 `error_handler_middleware.go`는 아예 `duration`을 로깅하지 않는다(에러 발생 시 처리 시간 자체가 로그에 없음).
- **에러 로그에 `ip` 부재**: `logger_middleware.go`는 `c.RealIP()`를 찍지만 `error_handler_middleware.go`는 찍지 않아, 성공/실패 로그의 필드 구성이 서로 다르다.

## 유즈케이스

| 우선순위 | 유즈케이스 | 설명 | 용도 |
|---|---|---|---|
| **P0** | UC-1 `trace_id` 중복 제거 | 성공 요청 로그(`Logger`)에서 `trace_id`가 정확히 1회만 출력 | **버그 수정** |
| **P0** | UC-2 에러 로그에 사람이 읽을 수 있는 원인 노출 | `ErrorHandler`가 남기는 4xx/5xx 로그에 `error_msg`(문자열, `err.Error()`)가 항상 채워짐 | **버그 수정, 디버깅 필수** |
| **P0** | UC-3 성공/에러 로그 필드 셋 일치 | 두 미들웨어 모두 `user_agent`, `duration_ms`, `ip`를 동일한 이름·타입으로 출력 | **운영 디버깅 필수** |
| P1 | UC-4 AppError 스택 트레이스 보존 | 필드 구조를 바꿔도 5xx 에러의 `stack_trace` 자동 첨부 기능(`errs.SlogWrappedHandler`)은 그대로 동작 | 회귀 방지 |

## 객체 변경

### `backend/internal/infrastructure/web/logger_middleware.go`

`Logger()`의 성공 로그 블록만 수정한다 (요청 시작 시각을 에러 핸들러와 공유하도록 컨텍스트에 저장하는 부분 추가).

```go
// 다음 체인 실행 전, 에러 핸들러가 동일한 시작 시각으로 duration_ms를 계산할 수 있도록 공유
c.Set(requestStartKey, start) // requestStartKey: 패키지 비공개 상수, "request_start"

...

slog.InfoContext(ctx, "Request completed",
    // trace_id 필드 제거 — errs.SlogWrappedHandler가 ctx 기반으로 자동 1회 주입
    slog.String("method", c.Request().Method),
    slog.String("path", c.Request().URL.Path),
    slog.Int("status", status),
    slog.Float64("duration_ms", float64(duration.Microseconds())/1000.0),
    slog.String("ip", c.RealIP()),
    slog.String("user_agent", c.Request().UserAgent()),
)
```

### `backend/internal/infrastructure/web/error_handler_middleware.go`

`ErrorHandler()` 내부 두 로깅 분기(5xx/`WarnContext`) 모두 동일하게 필드를 추가한다. `duration_ms`는 `Logger`가 `c.Set(requestStartKey, start)`로 남겨둔 값을 읽어 계산한다.

```go
requestStart, _ := c.Get(requestStartKey).(time.Time) // Logger가 항상 먼저 실행되므로 정상 케이스에서 zero-value 없음
durationMs := float64(time.Since(requestStart).Microseconds()) / 1000.0

commonAttrs := []any{
    slog.String("method", c.Request().Method),
    slog.String("path", c.Request().URL.Path),
    slog.Int("status", code),
    slog.Float64("duration_ms", durationMs),
    slog.String("ip", c.RealIP()),
    slog.String("user_agent", c.Request().UserAgent()),
    slog.String("error_msg", err.Error()),
    slog.Any("error", err), // errs.SlogWrappedHandler의 AppError/stack_trace 추출용 — 최종 출력에는 노출되지 않음(아래 참고)
}
```

`requestStartKey`는 `logger_middleware.go`에 비공개 상수로 선언하고 두 파일이 같은 패키지(`web`)이므로 그대로 공유한다.

### `backend/internal/errs/error.go` — `SlogWrappedHandler.Handle`

책임을 하나 더 추가한다: AppError 추출(`stack_trace`, `trace_id` 첨부)은 기존과 동일하되, 레코드에 `slog.Any("error", ...)`로 담긴 원본 에러 속성은 **최종 출력 레코드에서 제거**한다 — 이 속성은 unexported 필드만 가진 에러 타입이 대부분이라 JSON 직렬화 시 `{}`로 나와 정보 가치가 없고, 호출부가 이미 `error_msg` 문자열 속성으로 동일한 메시지를 명시적으로 남기기 때문이다.

```go
// Handle은 로그를 가로채 AppError 및 Context 정보 전처리를 수행한 뒤,
// 'error' Any 속성(내부 스택 추출 전용, JSON 직렬화 시 빈 객체가 됨)을 제거하고 원본 핸들러에 위임한다.
func (h *SlogWrappedHandler) Handle(ctx context.Context, r slog.Record) error
```

- 구현 방식: `r.Attrs`로 순회하며 `attr.Key == "error"`이고 `Kind() == slog.KindAny`이며 값이 `error`를 구현하는 속성은 건너뛰고, 나머지 속성만 담아 새 `slog.Record`(`r.Clone()` 후 속성 재구성, 또는 `slog.NewRecord` + `AddAttrs`)를 구성한다.
- 기존 동작(AppError 있으면 `trace_id`/`stack_trace` 첨부, 없으면 ctx의 `trace_id` 첨부)은 그대로 유지.

## 최종 로그 형태 (예시)

```json
{
  "time": "2026-07-16T17:26:01.192969+09:00",
  "level": "WARN",
  "msg": "Request warning",
  "trace_id": "e79d1ab8-0f70-4e41-badf-f6c367957f22",
  "method": "GET",
  "path": "/api/v1/camps",
  "status": 401,
  "error_msg": "session revoked",
  "duration_ms": 0.032,
  "ip": "100.86.251.2",
  "user_agent": "Mozilla/5.0..."
}
```

## 범위 제외 (별도 확인 필요)

핸들러 계층 전반(auth/camp/corner/track/message/device/admin_management 등, 최소 100곳 이상)이 `c.Bind` 실패나 usecase 에러를 `c.Error(err)`로 넘기지 않고 `return c.JSON(http.StatusXXX, ErrorResponse{...})`로 직접 반환하고 있어, 중앙 `ErrorHandler`(및 그 안의 `trace_id`/`error_msg`/`duration_ms`/`user_agent` 로깅)를 완전히 우회한다. 예: `auth_handler.go:90-93`(Bind 실패), `auth_handler.go:97-99`(로그인 실패). 이번 로깅 필드 개선 작업 범위에서는 **의도적으로 제외**하며, 손댈 경우 핸들러 100곳 이상을 건드리는 별도 리팩터링 계획으로 분리해야 한다.

## 검증 계획

1. **단위 테스트 (`logger_middleware_test.go`, 신규 또는 확장)**: `slog.NewJSONHandler`를 `bytes.Buffer`에 연결해 `Logger()` 실행 후 출력 JSON을 파싱, `trace_id` 키가 정확히 1개인지, `duration_ms`가 숫자 타입인지, `user_agent`가 요청 헤더 값과 일치하는지 검증.
2. **단위 테스트 (`error_handler_middleware_test.go` 확장)**: 기존 3개 테스트에 로그 캡처를 추가해 `error_msg`가 `err.Error()`와 동일한 문자열인지, `user_agent`/`duration_ms`가 채워지는지 검증.
3. **회귀 테스트 (`errs/error_test.go` 확장)**: `SlogWrappedHandler.Handle`에 `AppError`를 담아 호출했을 때 출력 레코드에 `stack_trace`가 여전히 존재하고, `error` 키(Any 원본)는 사라졌는지 검증.
4. **수동 확인**: `go run ./cmd/server/main.go` 기동 후 만료/누락 토큰으로 보호된 엔드포인트 호출 → stdout JSON 로그에서 `trace_id` 1회, `error_msg`에 실제 사유 문자열, `duration_ms`가 소수점 포함 밀리초로 출력되는지 육안 확인.

## 검증 체크리스트

- [x] 성공 요청 로그(`Logger`)에 `trace_id`가 정확히 1회만 출력됨 — `TestLoggerShouldLogTraceIDExactlyOnceWhenRequestSucceeds`
- [x] 성공/에러 로그 모두 `user_agent`, `duration_ms`(float, 밀리초), `ip` 필드를 동일한 이름으로 포함 — `TestLoggerShouldIncludeUserAgentAndDurationMsWhenRequestSucceeds`, `TestErrorHandlerShouldLogErrorMsgUserAgentAndDurationMsWhenSystemErrorOccurs`
- [x] 에러 로그의 `error_msg`가 `err.Error()`와 동일한 실제 사유 문자열 — 위 테스트에서 검증
- [x] `errs.SlogWrappedHandler`의 5xx `AppError` 스택 트레이스(`stack_trace`) 첨부 기능 회귀 없음 — `TestSlogWrappedHandlerShouldStripRawErrorAttrButKeepStackTraceWhenAppErrorLogged`
- [x] `domain` 패키지 변경 없음 (본 작업은 `infrastructure/web`, `errs` 패키지에 국한) — `git diff --stat` 확인 완료
- [x] 기존 테스트(`go test ./...`) 통과 + 신규/확장 테스트 추가 — 전체 통과 확인
