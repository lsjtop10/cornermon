# GitHub Issue #47 — 캠프 정보·병목 기준 수정 API 구현 계획

> 이슈: https://github.com/lsjtop10/cornermon/issues/47

## 구현 현황

- [x] pointer web DTO와 `domain.Optional[T]` patch 값 객체 구현
- [x] 이름·예정 기간·최소 표본·비율 불변식 구현
- [x] ENDED 캠프 전용 conflict sentinel 및 HTTP 409 매핑
- [x] 기존 `CampRepository.Save`를 사용한 트랜잭션 저장
- [x] 성공/실패 감사 로그와 성공 커밋 후 `camp_updated` SSE 구현
- [x] `PATCH /camps/{id}` 라우트·handler·Swagger/OpenAPI 계약 동기화
- [x] 부분 수정, lifecycle 시각 보존, 범위, 없음/ENDED, 감사/SSE 테스트

## 자체 리뷰

- patch 검증은 로컬 복사본에서 끝난 뒤 엔티티에 반영되어 잘못된 patch가 부분 적용되지 않는다.
- `StartAt`/`EndAt`만 수정하며 `ActivatedAt`/`EndedAt`은 변경하지 않는다.
- DB schema 변경 없이 기존 Save 쿼리를 재사용한다.
- SSE는 트랜잭션 성공 후에만 발생하고 실패 시 실패 감사 로그만 남긴다.

## 검증

- `go test ./...`
- `go test -race ./internal/domain ./internal/usecase ./internal/infrastructure/web`
