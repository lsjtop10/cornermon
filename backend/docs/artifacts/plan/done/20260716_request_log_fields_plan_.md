# 요청 로그 필드 개선 (compact)

## 요구사항
`Logger`/`ErrorHandler` 미들웨어 로그를 운영 디버깅 가능한 수준으로 개선: `trace_id` 중복 출력
버그, `user_agent` 누락, 에러 로그의 `error` 필드가 unexported 필드뿐이라 `{}`로 직렬화돼 원인이
안 보이는 문제, `duration`이 나노초 정수로 나와 가독성이 떨어지는 문제 수정.

## 왜 이렇게 했는가
- `error_msg`(문자열, `err.Error()`)를 명시적으로 추가하고, `SlogWrappedHandler.Handle`이 최종
  출력에서 `slog.Any("error", err)` 원본 속성을 제거 — 대부분의 에러 타입이 exported 필드가 없어
  JSON 직렬화 시 `{}`가 되는 근본 원인을 없앰(AppError의 stack_trace 첨부 기능은 그대로 유지).
- 핸들러 계층 전반(100곳 이상)이 `c.Error(err)`를 거치지 않고 `c.JSON`으로 직접 반환해 중앙
  `ErrorHandler`를 우회하는 문제는 **범위에서 의도적으로 제외** — 손대면 100곳 이상을 건드리는
  별도 리팩터링이 되므로 이번 로깅 필드 개선과 분리.
