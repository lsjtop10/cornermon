# 인프라 로그 trace ID 전파 (compact)

Issue: #187

## 요구사항
`postgres.SlogQueryTracer`가 전역 `slog.Error/Warn/Debug`를 써서 요청 context를 버리고,
`sse.BroadcasterImpl`도 상시 로그 지점이 없어 같은 요청의 DB 쿼리 로그와 SSE fan-out 로그를
`trace_id`로 상관 분석할 수 없던 문제 수정.

## 왜 이렇게 했는가
- 요청 `trace_id`(HTTP 요청 단위)와 SSE 연결 `ctx`(연결 수명 전체)는 서로 다른 수명을 가져 하나의
  trace_id로 상관분석이 안 됨 — 처음엔 문서로만 경고했으나, PR 리뷰에서 "로그만으로 추적 가능해야
  한다"는 피드백을 받아 필드를 명시적으로 분리(`connection_id` vs `cause_trace_id`).
- 이후 `usecase.SSEMessage`에 로깅 전용 필드를 얹은 게 "usecase가 옵저버빌리티 관심사를 안다"는
  레이어링 위반 아니냐는 논의가 있었음 — 결론은 위반 아님(usecase는 값을 생성·해석하지 않고 통과만
  시킴). 다만 이름이 `*TraceID`라 오해를 사서, CQRS의 **Causation ID** 패턴으로 재프레이밍해
  `CauseTraceID` → `CausationID`로 리네이밍(지금은 trace_id를 재사용하는 구현 디테일일 뿐,
  정의상 trace_id는 아님을 필드 주석에 명시).
