# Issue #47 — 캠프 정보·병목 기준 수정 API (compact)

Issue: #47 (https://github.com/lsjtop10/cornermon/issues/47)

## 요구사항
`PATCH /camps/{id}`로 캠프 이름·예정 기간·병목 최소 표본·비율 기준을 부분 수정할 수 있도록 구현.
ENDED 캠프는 수정 거부(409).

## 왜 이렇게 했는가
- pointer web DTO + `domain.Optional[T]` patch 값 객체로 부분 수정 표현 — patch 검증을 로컬
  복사본에서 끝낸 뒤에만 엔티티에 반영해, 잘못된 patch가 일부만 적용되는 상태를 방지.
- `StartAt`/`EndAt`만 수정 대상이고 `ActivatedAt`/`EndedAt`(lifecycle 시각)은 보존 — patch가
  라이프사이클 자체를 건드리지 않도록 분리.
