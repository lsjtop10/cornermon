# Issue #154 코너 soft-delete 및 좀비 코너 정리 Plan

## 1. 유즈케이스

| 우선순위 | 유즈케이스 | 설명 | 용도 |
| --- | --- | --- | --- |
| **P0** | UC-1: 코너 삭제 | 관리자 삭제 요청은 API 계약(204)을 유지한 채 코너를 숨긴다. | **프로덕션 핵심 로직** |
| **P0** | UC-2: 활성 코너 조회 | 목록·상세·캠프 스냅샷 및 캠프 범위 트랙 조회에서 숨겨진 코너를 노출하지 않는다. | **프로덕션 핵심 로직** |
| **P0** | UC-3: 코너 정리 | soft-delete된 지 7일이 지난 코너만 트랙·방문 이력이 없을 때 물리 삭제한다. 활성 코너는 정리하지 않는다. | 운영 CLI |

```go
// 삭제 시각을 저장해 일반 조회에서 제외한다.
func (r *pgCornerRepository) SoftDelete(ctx context.Context, id domain.CornerID, deletedAt time.Time) error

// 운영 명령이 soft-delete 보존 기간과 이력 보호 조건을 충족한 대상만 물리 삭제한다.
func (r *pgCornerRepository) PurgeDeletedBefore(ctx context.Context, deletedBefore time.Time) (int64, error)
```

## 2. 설계 및 경계

- `deleted_at TIMESTAMPTZ NULL`은 persistence 상태이며 domain `Corner`에 노출하지 않는다. `NULL`만 활성 코너다.
- `DELETE /corners/{id}`의 경로, 상태 코드, 요청·응답 본문은 변경하지 않는다. 성공하면 `deleted_at`을 UTC 현재 시각으로 설정하고 기존 감사 로그·커밋 후 SSE 이벤트를 유지한다.
- 활성 코너를 읽거나 그 코너를 캠프 범위로 조인하는 SQL에는 `c.deleted_at IS NULL` 조건을 둔다. 과거 참조가 필요한 정리 검증은 해당 조건과 분리한다.
- 정리 CLI는 `cmd/cleanup-corners`에 둔다. 활성 상태에서 트랙·방문 이력이 없다는 사실만으로는 정상적으로 막 생성된 코너와 좀비를 구분할 수 없으므로, `deleted_at <= now - 7일`인 soft-delete 코너만 삭제한다. 트랙 또는 방문 이력이 있으면 보존한다.
- 기존 배포 DB를 위해 additive migration SQL을 제공하고, 새 DB 초기화용 `schema.sql`에도 같은 컬럼·인덱스를 반영한다.

## 3. 구현 단계

### Phase A: 데이터 모델 및 SQL (예상 1시간)

| 순서 | 작업 | 파일 |
| --- | --- | --- |
| A-1 | 삭제 시각 컬럼과 활성 조회 인덱스를 초기 스키마에 추가 | `/home/lsjtop10/projects/cornermon-issue-154/backend/db/schema.sql` (기존 파일 확장) |
| A-2 | 기존 DB용 additive migration을 추가 | `/home/lsjtop10/projects/cornermon-issue-154/backend/db/migrations/20260721_add_corner_deleted_at.sql` (신규) |
| A-3 | 활성 코너 조회·soft delete·이력 없는 purge SQL을 추가하고 sqlc 산출물을 동기화 | `/home/lsjtop10/projects/cornermon-issue-154/backend/db/query.sql`, `/home/lsjtop10/projects/cornermon-issue-154/backend/internal/infrastructure/postgres/db/` (기존 파일 확장) |

### Phase B: 애플리케이션 및 운영 명령 (예상 1시간)

| 순서 | 작업 | 파일 |
| --- | --- | --- |
| B-1 | `CornerRepository`의 물리 삭제 포트를 soft-delete로 교체하고 `CornerService`가 UTC 시각을 전달 | `/home/lsjtop10/projects/cornermon-issue-154/backend/internal/usecase/port.go`, `/home/lsjtop10/projects/cornermon-issue-154/backend/internal/usecase/corner.go` (기존 파일 확장) |
| B-2 | Postgres 구현에서 SQLC 쿼리를 사용해 soft-delete하며 활성 조회를 보장 | `/home/lsjtop10/projects/cornermon-issue-154/backend/internal/infrastructure/postgres/corner_repo.go` (기존 파일 확장) |
| B-3 | DB 설정을 재사용하는 7일 보존 정리 CLI를 추가 | `/home/lsjtop10/projects/cornermon-issue-154/backend/cmd/cleanup-corners/main.go` (신규) |

### Phase C: 검증 및 문서 (예상 1시간)

| 순서 | 작업 | 파일 |
| --- | --- | --- |
| C-1 | soft-delete 시각, 재삭제 idempotency, 감사 로그 및 SSE를 usecase 테스트로 검증 | `/home/lsjtop10/projects/cornermon-issue-154/backend/internal/usecase/corner_test.go`, `/home/lsjtop10/projects/cornermon-issue-154/backend/internal/usecase/mock_test.go` (기존 파일 확장) |
| C-2 | SQL 원본과 생성 코드의 활성 조회·purge 보호 조건을 테스트 | `/home/lsjtop10/projects/cornermon-issue-154/backend/internal/infrastructure/postgres/` (기존 파일 확장) |
| C-3 | API 계약을 그대로 유지한다는 설명을 OpenAPI 산출물에 반영하고 전체 테스트·vet·자체 리뷰 수행 | `/home/lsjtop10/projects/cornermon-issue-154/api/swagger.yaml` (기존 파일 확장) |

## 4. 검증 체크리스트

- [x] `DELETE /corners/{id}`는 204를 유지하며 행을 물리 삭제하지 않고 UTC `deleted_at`만 설정한다.
- [x] `GetCorner`, `ListCornersByCamp`, 코너 view 목록·상세, 캠프 범위 조인 조회가 soft-delete 코너를 반환하지 않는다.
- [x] 정리 CLI는 활성 코너를 절대 삭제하지 않고, soft-delete 코너가 7일 전이면서 트랙·방문 이력이 모두 없을 때만 삭제한다.
- [x] 트랙 또는 방문 이력이 있는 코너는 soft-delete 여부와 무관하게 purge하지 않는다.
- [x] 성공 감사 로그와 커밋 뒤 `corners_updated` SSE가 기존과 동일하게 동작하며, 실패 경로는 기존 구현을 유지한다.
- [x] `domain`이 infrastructure를 import하지 않고, usecase는 repository 포트에만 의존한다.
- [x] `cd backend && go test ./... && go vet ./...`를 통과한다.
- [x] API 요청·응답 계약이 변경되지 않는다. 코드 변경 LOC은 커밋 직전에 확인한다.
