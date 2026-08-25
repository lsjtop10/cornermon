# 배지 등록 유즈케이스 경계 정리 (compact)

## 요구사항
`badge_handler.go`가 캠프 repository 조회·배지 목록 순회 등 유즈케이스 책임을 핸들러에서 직접
수행하고 있던 것을 `GroupService`(`AssignBadge`/`ScanAssignBadge`)로 이동. 핸들러는 요청 파싱·
유즈케이스 호출·응답 변환만 담당하도록 경계 정리.
