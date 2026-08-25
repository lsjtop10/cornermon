# SSE unread 중복 무효화 정리 (compact)

## 요구사항
`messages_changed` 수신 시 coordinator가 summary provider를 직접 무효화하는 경로와, 원본 메시지
목록 provider 의존성을 통한 재계산 경로가 중복으로 존재. 직접 무효화를 제거하고 provider 의존성
재계산 경로 하나로 단일화.

## 왜 이렇게 했는가
직접 무효화(`20260723_admin_sse_unread_refresh_plan_.md`에서 시도)는 반복 SSE payload가 listener에서
누락되는 근본 원인을 해결하지 못해 폐기 — 대신 `20260723_admin_repeated_sse_event_plan_.md`의 수신
receipt로 모든 이벤트가 전달되게 하고, 원본 목록 provider 의존성이 summary를 재계산하게 함.
