# Issue #154 코너 soft-delete 및 좀비 코너 정리 (compact)

Issue: #154

## 요구사항
코너 삭제가 물리 삭제라 관련 이력이 함께 사라지는 문제. `DELETE /corners/{id}`의 API 계약(204)은
유지한 채 soft-delete로 전환하고, 트랙·방문 이력 없는 좀비 코너만 별도 CLI로 물리 정리.

## 왜 이렇게 했는가
- `deleted_at`은 persistence 상태로만 두고 domain `Corner`에 노출하지 않음 — `NULL`만 활성 코너로
  취급, 활성 조회 SQL마다 `deleted_at IS NULL` 조건을 명시.
- 정리 CLI가 soft-delete **7일 경과** + 트랙·방문 이력 없음을 모두 만족할 때만 삭제 — 활성 상태에서
  이력 없음만으로는 막 생성된 정상 코너와 좀비를 구분할 수 없어서, 보존 기간을 추가 조건으로 둠.
- `cmd/cleanup-corners`로 별도 CLI 분리 — 기존 `cmd/` 원샷 배치 커맨드 관례를 따름.
