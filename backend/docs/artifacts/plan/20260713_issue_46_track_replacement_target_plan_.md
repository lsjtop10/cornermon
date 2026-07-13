# GitHub Issue #46 — 대상 코너를 지정하는 트랙 교체 API 구현 계획

> 이슈: https://github.com/lsjtop10/cornermon/issues/46

## 구현 현황

- [x] `PUT /tracks/{id}/replace`의 필수 `newCornerId` body 구현
- [x] handler가 서비스에 old track/new corner ID를 전달
- [x] 새 트랙과 6자리 평문 PIN 응답 구현
- [x] 기존 코너와 대상 코너의 캠프 일치 검증
- [x] 대상 코너 없음 404, 캠프 불일치/BUSY 409 중앙 매핑
- [x] 삭제·재생성·migration target 저장을 단일 트랜잭션에서 수행
- [x] 커밋 후 `tracks_updated`/`track_replaced` SSE 발행 확인
- [x] 입력 누락, 캠프 불일치, BUSY 보존, 세션 migration, PIN/SSE 테스트
- [x] Swagger annotation/산출물 및 OpenAPI 계약 일치

## 자체 리뷰

- 캠프 불일치 검사는 트랙 삭제나 PIN 생성 전 수행되어 원본 상태를 보존한다.
- 기존 세션은 revoke하지 않고 새 트랙 ID를 migration target으로 저장한다.
- SSE와 성공 감사 로그는 트랜잭션 성공 이후에만 발생한다.
- 평문 PIN은 repository나 감사 metadata에 저장하지 않는다.

## 검증

- `go test ./...`
- `go test -race ./internal/usecase ./internal/infrastructure/web`
