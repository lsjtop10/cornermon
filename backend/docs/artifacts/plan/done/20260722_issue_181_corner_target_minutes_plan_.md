# Issue #181 코너 목표시간(targetMinutes) 미반영 버그 수정 (compact)

Issue: #181

## 요구사항
코너 생성/수정 시 입력한 `targetMinutes`가 실제로 반영되지 않는 버그. 핸들러가 요청의
`targetMinutes`를 파싱만 하고 usecase(`AddLearningCorner`/`ModifyCornerSpecification`)로
전달하지 않아 항상 0이거나 기존 값이 유지됨. 프론트/OpenAPI 계약은 이미 정확해 변경 불필요.

## 왜 이렇게 했는가
- 핸들러→usecase 파라미터 전달 누락이 근본 원인이므로 새 인터페이스/DTO 없이 파라미터 배관만
  고치는 최소 변경으로 접근.
- `targetMinutes <= 0` 검증은 도메인/usecase가 아니라 **핸들러 계층**에 둠 (사용자 확인 결과) —
  `audit_handler.go`의 기존 `limit` 검증과 동일 패턴, 도메인은 순수 상태 전이만 담당.
- `Corner.SetTargetMinutes` setter는 기존 `SetName`과 동일 패턴으로 추가(도메인 상태 변경은
  항상 도메인 메서드를 통한다는 원칙 준수).
