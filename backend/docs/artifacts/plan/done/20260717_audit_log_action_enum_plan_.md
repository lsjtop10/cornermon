# 감사 로그 Action Enum화 (compact)

Issue: #118

## 요구사항
`GET /audit-logs`의 `action` 쿼리 파라미터가 정확 일치 필터인데 API 계약에 유효값 목록이 없고,
11개 usecase 파일에 33개 action 문자열 리터럴이 흩어져 하드코딩돼 있던 문제 정리.

## 왜 이렇게 했는가
- `usecase.AuditAction` 상수 레지스트리 신설 — 새 리포지토리/포트를 만들지 않고 기존
  `usecase.NotificationEvent`(port.go)와 동일한 "usecase 계층 상수 레지스트리" 패턴을 재사용.
- `domain.AuditLog.action`은 그대로 `string` 유지 — DB 필터로 그대로 흘러가는 값이라 도메인
  타입으로 승격할 이유가 없다고 판단.
- 알 수 없는 action 값에 대한 런타임 400 검증은 사용자 확인 후 포함하기로 결정(처음엔 범위
  불확실했음) — 기존 `result` 파라미터 검증과 동일 패턴 적용.
