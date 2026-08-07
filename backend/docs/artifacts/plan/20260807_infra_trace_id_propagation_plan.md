# 인프라 로그 trace ID 전파 (Issue #187)

## 배경

`web.Logger()` 미들웨어는 요청 context에 `trace_id`를 심고, `errs.SlogWrappedHandler`가
context 기반(`*Context` 계열) slog 호출에서 자동으로 `trace_id`를 로그 속성에 주입한다.
하지만 `postgres.SlogQueryTracer`는 `slog.Error/Warn/Debug` 전역 호출을 사용해 이 context를
버리고, `sse.BroadcasterImpl`은 특정 이벤트(#184 진단용)에만 임시로 `DebugContext`를 쓰고
있어 일반적인 운영 로그 지점이 없다. 결과적으로 같은 요청에서 발생한 DB 쿼리 로그와
SSE fan-out 로그를 `trace_id`로 상관 분석할 수 없다.

## 유즈케이스

| 우선순위 | 유즈케이스 | 설명 | 용도 |
|---|---|---|---|
| **P0** | UC-1: DB 쿼리 에러/느린 쿼리 로그에 trace_id 포함 | `SlogQueryTracer`가 `ctx`를 사용해 `*Context` slog 호출로 전환 | 프로덕션 장애 분석 |
| **P0** | UC-2: SSE broadcast fan-out 로그 상시화 | `#184` 임시 디버그 로그를 제거하고 모든 이벤트에 적용되는 상시 로그로 대체 | 프로덕션 운영 모니터링 |
| P1 | UC-3: SSE 연결 write 실패 로그 | `streamEvents`에서 클라이언트 write 실패 시 구조화 로그 | 장애 진단 |
| P1 | UC-4: 요청 trace_id ↔ SSE 연결 trace_id 상관관계 한계 문서화 | 코드 주석 + 개발자 가이드에 명시 | 온보딩/운영 지식 |

## 설계

### UC-1: `internal/infrastructure/postgres/tracer.go`

- `TraceQueryEnd(ctx, ...)`는 이미 `ctx`를 받고 있으므로, `slog.Error/Warn/Debug` →
  `slog.ErrorContext(ctx, ...)/WarnContext(ctx, ...)/DebugContext(ctx, ...)`로 교체.
- `LogParameterValues` 게이트(민감 파라미터 마스킹)는 기존 동작 유지 — 변경하지 않음.

### UC-2: `internal/infrastructure/sse/broadcaster.go`

- `Broadcast`의 `#184` 전용 임시 로그(`if event == usecase.EventMessagesChanged`)를 제거하고,
  모든 이벤트에 대해 `DebugContext`로 동일한 필드(delivered/full subscriber 수)를 로그.
- 버퍼가 가득 차 구독자를 제거하는 경로(`len(fullAdminSubs) > 0 || len(fullTrackSubs) > 0`)는
  클라이언트가 뒤처지고 있다는 신호이므로 `WarnContext`로 별도 로그 추가.
- `Broadcast(ctx, ...)`는 커밋 이후 요청 흐름의 `ctx`를 그대로 받으므로 trace_id가 자동 전파됨
  (usecase 계층 규약, DEVELOPER_GUIDE.md §3.2 참고).

### UC-3: `internal/infrastructure/web/event_handler.go`

- `streamEvents`에서 `#184` 임시 로그를 제거.
- `c.Response().Write` 실패(클라이언트 연결 끊김 등)는 이미 `return err`로 상위 echo 에러
  처리로 넘어가지만, SSE 스트림은 `ErrorHandler` 미들웨어가 잡지 못하는 경로(스트리밍 도중
  에러)이므로 반환 직전 `WarnContext`로 1회 로그를 남긴다. (클라이언트가 그냥 연결을 끊는
  정상 케이스와 실제 네트워크 에러를 구분할 필요는 없음 — 어차피 재연결 유도가 목적.)

### UC-4: 문서화

- `backend/docs/DEVELOPER_GUIDE.md` §4.3(SSE Broadcaster)에 아래 내용 추가:
  - 요청 `trace_id`(HTTP 요청 1건 단위)와 SSE 연결의 `ctx`(연결 수명 전체, 여러 요청에 걸침)는
    서로 다른 수명을 가지므로 하나의 `trace_id`로 상관 분석할 수 없다.
  - `Broadcast` 호출 시점의 trace_id는 "무엇이 이 알림을 유발했는가"를, `streamEvents`의 로그는
    "이 연결이 무엇을 언제 받았는가"를 각각 나타내며 두 로그를 연결하려면 `scope`/`event`/시간을
    함께 봐야 한다.

## 검증

### 자동화 테스트

- `internal/infrastructure/postgres/tracer_test.go`에 회귀 테스트 추가:
  `ShouldLogTraceIDWhenQueryErrors` — context에 trace_id를 심고 에러 쿼리를 트레이스,
  캡처된 slog 출력에 trace_id가 포함되는지 확인.
- `internal/infrastructure/sse/broadcaster_test.go`(신규) 또는 기존 테스트 파일에
  `ShouldLogTraceIDWhenBroadcastDispatched` 추가.
- `internal/infrastructure/web/event_handler_test.go`에 write 실패 시 경고 로그 회귀 테스트
  추가(선택, 구현 난이도에 따라 P2로 낮출 수 있음).

### 체크리스트

- [x] `postgres.SlogQueryTracer`가 에러/느린쿼리/디버그 로그 모두 `*Context` 계열로 전환됨
- [x] `sse.BroadcasterImpl.Broadcast`가 모든 이벤트에 대해 상시 구조화 로그를 남김 (임시 진단 로그 제거)
- [x] `EventHandler.streamEvents`가 write 실패 시 trace_id 포함 경고 로그를 남김
- [x] DEVELOPER_GUIDE.md에 trace_id 상관관계 한계 문서화
- [x] 토큰/헤더/메시지 본문 등 민감 정보가 새로 로그에 노출되지 않음
- [x] `go test ./...`, `gofmt -w .`, `go vet ./...` 통과

## Addendum 1: connection_id / cause_trace_id 분리 (PR 리뷰 피드백)

최초 구현은 요청 trace_id와 SSE 연결 trace_id의 수명이 다르다는 점을 **문서로만** 경고했다.
리뷰 중 "결국 남는 건 로그뿐이니 어떤 요청이 이벤트를 발행했는지 로그만으로 추적 가능해야
한다"는 피드백을 받아, 필드 자체를 명시적으로 분리했다.

- `usecase.SSEMessage`에 `CauseTraceID string` 필드 추가 — `BroadcasterImpl.Broadcast`가
  `ctx`에서 추출해 채운다. 클라이언트에 노출되는 `SSENotification` payload에는 포함하지
  않는다(`formatSSEMessage`가 별도 DTO를 구성하므로 자동으로 격리됨).
- `errs.TraceIDFromContext(ctx)` 헬퍼 추가 — 기존 `Wrap`의 중복 타입 단언 로직도 이걸로
  정리.
- `EventHandler.streamEvents`가 연결 시점의 trace_id를 `connection_id`로, 메시지에 실려온
  `CauseTraceID`를 `cause_trace_id`로 명시적으로 로그. `SSE event delivered`(신규, 성공
  경로) / `SSE event write failed`(기존) 모두 두 필드를 함께 남긴다.
- `Broadcast`도 자신의 로그에 `cause_trace_id`를 명시적으로 추가해, 두 계층의 로그를
  `cause_trace_id`로 조인할 수 있게 했다(자동 주입되는 `trace_id`와 값은 같지만, 필드명을
  통일해 검색 가능하게 하는 것이 목적).
- DEVELOPER_GUIDE.md §4.3.1 갱신: `trace_id`/`connection_id`/`cause_trace_id` 세 필드의
  의미와 조인 방법을 명시.

### 추가 검증
- [x] `errs.TraceIDFromContext` 단위 테스트 추가
- [x] `broadcaster_test.go`: `message.CauseTraceID`가 채워지는지, 로그에 `cause_trace_id`가
      남는지 검증
- [x] `event_handler_test.go`: `connection_id`와 `cause_trace_id`가 서로 다른 값으로
      로그에 남는지(write 실패/정상 delivered 양쪽) 검증
- [x] `go test ./...`, `gofmt -w .`, `go vet ./...` 재통과

## Addendum 2: CauseTraceID → CausationID 리네이밍 (레이어링 논의)

Addendum 1에서 `usecase.SSEMessage`에 로깅 전용 필드를 얹은 게 "usecase 포트가 옵저버빌리티
관심사를 안다"는 레이어링 위반 아니냐는 논의가 있었다. 결론은 위반이 아니라는 쪽이었지만
(usecase는 이 값을 생성·해석하지 않고 그냥 통과시킬 뿐이며, `sse` ↔ `web` 두 infra 패키지가
공유하는 채널 타입이 이 필드가 지나갈 유일한 통로다), 이름이 `*TraceID`라서 "trace_id를
로깅용으로 복붙한 것"처럼 읽히는 게 문제였다.

이를 CQRS/이벤트 소싱의 **Causation ID** 패턴("이 이벤트가 왜 존재하는가"를 나타내는, 이벤트
자신의 정상적인 계보 메타데이터 — `CorrelationID`의 자매 개념)으로 명시적으로 재프레이밍했다.

- `SSEMessage.CauseTraceID` → `SSEMessage.CausationID`로 리네이밍.
- 필드 주석에 "왜 이 정보가 usecase까지 넘어오는가"(위 레이어링 논의 요약)와 "지금은 HTTP
  요청의 trace_id를 우연히 재사용하는 구현 디테일일 뿐, CausationID의 정의 자체가 trace_id는
  아니다"를 명시.
- 로그 필드명도 `cause_trace_id` → `causation_id`로 통일.
- DEVELOPER_GUIDE.md §4.3.1 제목/본문을 causation_id 기준으로 갱신.
- 관련 테스트/plan 문서 전부 리네이밍 반영.

### 추가 검증
- [x] `CauseTraceID`/`cause_trace_id` 잔존 참조 없음 (`grep -rl` 확인)
- [x] `go test ./...`, `gofmt -w .`, `go vet ./...` 재통과
