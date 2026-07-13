# GitHub Issue #45 — 컬렉션·집계 API 캠프 범위 명시화 구현 계획

> 이슈: https://github.com/lsjtop10/cornermon/issues/45

## 구현 현황

- [x] 코너·트랙·조 및 리포트 경로를 `/camps/{campId}/...`로 변경
- [x] query/활성 캠프 자동 탐색을 제거하고 path의 camp ID 전달
- [x] 모든 리포트 조회를 `ReportService.GetCampReport` 경계로 집중
- [x] 캠프 존재 여부 및 최종 리포트 생성 상태 규칙 검증
- [x] 동시 캠프 A/B 리포트 조회 격리 race 테스트
- [x] 라우터·Swagger annotation·Swagger 산출물·OpenAPI 경로 일치 확인
- [ ] Flutter 생성 클라이언트 및 호출부 변경 — 사용자 지시에 따라 `frontend/` 수정 범위 제외

## 자체 리뷰

- 컬렉션 repository 포트는 모두 `context.Context`와 명시적 `campID`를 받는다.
- 개별 엔티티 경로는 변경하지 않았다.
- PENDING/ACTIVE/ENDED 캠프 리포트 읽기는 허용하고, 최종 생성은 ENDED만 허용한다.
- 없는 캠프는 `ErrCampNotFound`로 중앙 HTTP 매핑된다.
- `domain`에서 infrastructure import가 없음을 확인했다.

## 검증

- `go test ./...`
- `go test -race ./internal/infrastructure/web ./internal/usecase`
- 프론트 생성물 검증은 사용자 지시에 따라 수행하지 않음
