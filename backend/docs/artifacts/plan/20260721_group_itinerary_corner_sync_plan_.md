# 코너 추가/삭제 시 조 순회표(Itinerary) 동기화 계획

## 배경

`Group.itinerary`(`CornerProgress[]`)는 배지 등록(`GroupService.RegisterBadge`,
`backend/internal/usecase/group.go:76-96`) 시점에 그 캠프의 코너 목록을 1회
스냅샷해서 만들어지고, 이후 코너가 추가/삭제돼도 갱신되지 않는다.

- `CornerService.AddLearningCorner`(`corner.go:45-73`)와
  `RemoveCornerFromCamp`(`corner.go:142-164`)는 캠프 상태 검사도 없어 캠프가
  ACTIVE(=조 등록 및 방문 처리가 실시간으로 진행 중)여도 언제든 호출 가능하다.
- 즉 캠프 진행 중 코너를 추가/삭제하면, 이미 등록된 조들의 순회표는 실제
  코너 목록과 어긋난다(추가된 코너가 순회표에 없거나, 삭제된 코너의 유령
  항목이 남음).

`Group.itinerary`는 자체 ID가 없는 Value Object 컬렉션이고 `groups.itinerary`
JSONB 컬럼 하나로 통째로 직렬화/역직렬화되므로(`group_repo.go:29-46,90-107`),
컬렉션 diff(추가/삭제 원소 추적)는 필요 없다 — 메모리에서 슬라이스를 고치고
`Save`로 전체 덮어쓰면 된다.

다만 `GetGroup`/`SaveGroup` 쿼리(`db/query.sql:152-167`)는 잠금이나 버전
체크가 전혀 없는 read-modify-write라, 코너 동기화 트랜잭션과 기존 방문
시작/종료 트랜잭션이 같은 Group 행을 동시에 건드리면 lost update가 발생한다.
캠프 규모(조 20개, 관리자 최대 2명)를 고려해 낙관적 락 대신 **비관적 락
(`SELECT ... FOR UPDATE`)** 으로 막는다.

## 유즈케이스

| 우선순위 | 유즈케이스 | 설명 | 용도 |
| --- | --- | --- | --- |
| **P0** | UC-1: 코너 추가 시 순회표 반영 | `AddLearningCorner`가 커밋되기 전, 같은 트랜잭션에서 해당 캠프의 모든 조 itinerary에 `NOT_VISITED` 상태로 새 코너 항목을 추가한다. | **프로덕션 핵심** |
| **P0** | UC-2: 코너 삭제 시 순회표 반영 | `RemoveCornerFromCamp`가 커밋되기 전, 같은 트랜잭션에서 해당 캠프의 모든 조 itinerary에서 그 코너 항목을 제거한다. | **프로덕션 핵심** |
| **P0** | UC-3: 방문 시작/완료 경로의 Group 행 잠금 | 코너 동기화와 레이스가 나는 기존 4개 지점(`VisitService.StartVisitByQR/StartVisitManual/CompleteVisit`, `CampService`의 캠프 종료 일괄완료)이 Group을 읽을 때 `FOR UPDATE`로 잠근다. UC-1/2만 잠그고 이 경로들을 안 잠그면 락이 무의미하므로 반드시 함께 간다. | **프로덕션 핵심(기존 기능 안정성 보강)** |

## 변경 설계

### Domain Layer (`backend/internal/domain/group.go`)

```go
// 책임: 코너 추가에 맞춰 순회표에 NOT_VISITED 항목을 반영한다. 이미 있으면 무시(멱등).
func (g *Group) AddCornerToItinerary(cornerID CornerID)

// 책임: 코너 삭제에 맞춰 순회표에서 해당 항목을 제거한다. 없으면 무시(멱등).
func (g *Group) RemoveCornerFromItinerary(cornerID CornerID)
```

- 기존 `MarkVisitStarted`/`MarkVisitCompleted`와 같은 파일, 같은 스타일(에러
  대신 멱등 처리 — 코너 추가/삭제는 방문 불변식과 무관한 구조 변경이므로
  `ErrGroupBusy` 류의 검증 대상이 아님).

### Port (`backend/internal/usecase/port.go`)

```go
type GroupRepository interface {
    Get(ctx context.Context, id domain.GroupID) (*domain.Group, error)
    GetForUpdate(ctx context.Context, id domain.GroupID) (*domain.Group, error)             // 신규
    GetByBadge(ctx context.Context, campID domain.CampID, badgeID domain.BadgeID) (*domain.Group, error)
    ListByCamp(ctx context.Context, campID domain.CampID) ([]*domain.Group, error)
    ListByCampForUpdate(ctx context.Context, campID domain.CampID) ([]*domain.Group, error) // 신규
    Save(ctx context.Context, group *domain.Group) error
    SaveBulk(ctx context.Context, groups []*domain.Group) error                             // 신규
}
```

- `SaveBulk`는 `BadgeRepository.SaveBulk`(`badge_repo.go:100-128`)와 동일
  패턴: 이미 트랜잭션 컨텍스트면 그대로 순차 `Save`, 아니면 새 트랜잭션을
  열어 순차 `Save`. 원소별 upsert라 SQL 자체는 원래 `Save`와 동일하고,
  추가 SELECT 없이 트랜잭션 하나로 묶는 것이 목적.

### Infrastructure — SQL (`db/query.sql`)

```sql
-- name: GetGroupForUpdate :one
SELECT * FROM groups WHERE id = $1 FOR UPDATE;

-- name: ListGroupsByCampForUpdate :many
SELECT * FROM groups WHERE camp_id = $1 FOR UPDATE;
```

- 추가 후 `sqlc generate`로 `internal/infrastructure/postgres/db/query.sql.go`
  재생성 (`backend/docs/DEVELOPER_GUIDE.md`가 명시한 대로 손으로 편집 금지).

### Infrastructure — Repository (`backend/internal/infrastructure/postgres/group_repo.go`)

```go
func (r *pgGroupRepository) GetForUpdate(ctx context.Context, id domain.GroupID) (*domain.Group, error)
func (r *pgGroupRepository) ListByCampForUpdate(ctx context.Context, campID domain.CampID) ([]*domain.Group, error)
func (r *pgGroupRepository) SaveBulk(ctx context.Context, groups []*domain.Group) error
```

- `GetForUpdate`/`ListByCampForUpdate`는 반드시 트랜잭션 컨텍스트
  (`ExtractTx(ctx) != nil`) 안에서만 호출된다는 전제 — usecase 쪽에서
  `tx.RunInTx` 밖에서 호출하면 커넥션 반환 즉시 잠금이 풀리므로 의미가
  없다. 방어적으로 트랜잭션이 없으면 에러를 반환할지, 그냥 `queries(ctx)`가
  풀 커넥션을 쓰게 둘지는 구현 시 기존 `Get`/`ListByCamp` 관례를 따른다
  (이 리포는 트랜잭션 누락을 컴파일 타임에 막지 않으므로, 잘못된 호출부만
  없도록 아래 usecase 변경 범위를 엄격히 지킨다).

### Usecase — CornerService (`backend/internal/usecase/corner.go`)

```go
type CornerService struct {
    camps       CampRepository
    corners     CornerRepository
    tracks      TrackRepository
    groups      GroupRepository // 신규 의존성
    auditLogs   AuditLogRepository
    broadcaster Broadcaster
    tx          TxManager
}

func NewCornerService(camps CampRepository, corners CornerRepository, tracks TrackRepository,
    groups GroupRepository, auditLogs AuditLogRepository, broadcaster Broadcaster, tx TxManager) *CornerService
```

- `AddLearningCorner`: `s.corners.Save` 다음(같은 `RunInTx` 블록 안)에
  `s.groups.ListByCampForUpdate(ctx, campID)` 1회 호출 → 각 Group에
  `AddCornerToItinerary(corner.ID())` → `s.groups.SaveBulk(ctx, groups)`.
- `RemoveCornerFromCamp`: 동일한 흐름으로 `RemoveCornerFromItinerary` 적용.
  `s.corners.Delete`보다 먼저 조회(잠금)해도, 나중에 해도 무방하나 순서를
  "그룹 잠금 → 코너 삭제 → itinerary 반영 → SaveBulk"로 통일해 두 메서드가
  대칭을 이루게 한다.
- 추가 SELECT는 `ListByCampForUpdate` 1회뿐(N+1 방지). `SaveBulk`는 N번의
  UPSERT 라운드트립이 있지만 이는 쓰기이며 캠프당 조 20개 규모에서 무시할
  수준(`docs/domain/domain-model.md:4` 전제).

### Usecase — VisitService (`backend/internal/usecase/visit.go`)

- `StartVisitByQR`(105행), `StartVisitManual`(196행), `CompleteVisit`(296행)의
  `s.groups.Get(ctx, ...)` → `s.groups.GetForUpdate(ctx, ...)`로 교체.
  나머지 로직/에러 처리는 변경 없음.

### Usecase — CampService (`backend/internal/usecase/camp.go`)

- 캠프 종료 일괄완료 루프(196행 부근) `s.groups.Get(ctx, visit.GroupID())` →
  `s.groups.GetForUpdate(ctx, ...)`로 교체.

### 생성자 시그니처 변경 반영 (컴파일 유지용)

- `cmd/server/main.go:155` — `NewCornerService` 호출에 이미 존재하는
  `groupRepo` 변수 전달.
- `internal/usecase/corner_test.go`, `internal/infrastructure/web/corner_handler_test.go`
  — `NewCornerService(...)` 호출부에 `GroupRepository`(테스트는
  `NewMockGroupRepository()`) 인자 추가.
- `internal/usecase/mock_test.go`의 `MockGroupRepository`에 `GetForUpdate`
  (= `Get`과 동일 구현, 메모리 맵이라 잠금 개념 없음),
  `ListByCampForUpdate`(= `ListByCamp`와 동일), `SaveBulk`(= 순차 `Save`)
  추가.

## 범위 제외 (후속 과제로 남김, 사용자 확인 완료)

- `GroupService.RegisterBadge`(`group.go:76-96`)가 배지 등록 시점에
  `corners.ListByCamp`로 코너 목록을 스냅샷하는 부분은 이번 계획 범위 밖.
  조 생성은 INSERT이므로 Group 행 잠금으로는 막을 수 없고, 코너 목록
  자체(또는 Camp 행)에 대한 별도 잠금이 필요하다 — 코너 추가/삭제와 배지
  등록이 동시에 일어나는 경우는 거의 없다고 가정하고 이번 작업 범위에서
  제외하기로 확정.
- 코너 삭제 시 `visits`/`tracks`가 DB `ON DELETE CASCADE`로 통째로
  사라지는 문제: soft delete(`corners.deleted_at` 추가, 목록/조회 쿼리
  필터링)가 맞는 방향으로 확정했으나 이번 계획과 범위가 달라(마이그레이션 +
  조회 경로 전반 수정) 별도 이슈로 분리 등록한다. `ON DELETE CASCADE`를
  단순 제거해 하드블록(`NO ACTION`)으로 바꾸는 대안도 검토했으나, 완료된
  방문이 1건이라도 있으면 해당 코너를 영구히 삭제 못 하게 되는 제약이 커서
  기각.

## 구현 메모

- `fix/exclude-deleted-corners-itinerary` 브랜치(PR #160, 삭제된 코너를 조회
  시점에 필터링하는 `GroupService.withCurrentCorners`) 위에서 이어서 구현했다.
  두 작업은 메커니즘이 다르지만(읽기 시점 필터 vs 쓰기 시점 상태 동기화 +
  잠금) 서로 대체 관계가 아니라는 것을 확인했다: `withCurrentCorners`는
  `ListGroups`/`RetrieveGroupRotationSchedule`/`ListGroupsByTrack` 같은
  조회 경로에서만 적용되고, `VisitService.MarkVisitStarted`가 검사하는
  원본(비필터) itinerary에는 적용되지 않는다. 따라서 코너가 `IN_PROGRESS`
  방문을 가진 채로 삭제되면, 그 유령 `IN_PROGRESS` 항목이 원본 itinerary에
  영구히 남아 해당 조가 이후 어떤 코너에서도 방문을 시작하지 못하는
  (`ErrGroupBusy`) 소프트락 버그가 생길 수 있었다. 이번 계획의
  `RemoveCornerFromItinerary` 쓰기 시점 정리가 이 소프트락을 막는다 —
  단순 UI 중복 표시보다 심각한, 기존 PR #160으로는 해결되지 않는 문제였다.
  회귀 테스트로 `TestRemoveCornerFromCampShouldRemoveCornerFromExistingGroupItineraries`에
  이 시나리오(삭제 전 `IN_PROGRESS`)를 포함시켰다.

## 검증 체크리스트

- [x] 코너 추가 후 기존 조 전원의 itinerary에 `NOT_VISITED` 항목이 추가됨
      (`AddLearningCorner` 유닛 테스트, `MockGroupRepository` 사용)
- [x] 코너 삭제 후 기존 조 전원의 itinerary에서 해당 항목이 제거됨
      (`RemoveCornerFromCamp` 유닛 테스트)
- [x] `AddCornerToItinerary`/`RemoveCornerFromItinerary`가 멱등임을 테스트로
      확인(중복 추가/이미 없는 항목 제거 시 에러 없음, 상태 불변)
- [x] `ListByCampForUpdate` 호출이 정확히 1회인지 Mock 호출 카운트로 검증
      (N+1 회귀 방지)
- [x] `go build ./... && go vet ./... && go test ./...` 통과
- [x] `sqlc generate` 후 `git diff`로 의도한 두 쿼리만 추가됐는지 확인
- [x] 실제 DB(로컬 postgres)에서 `EXPLAIN`으로 두 신규 쿼리가 `LockRows`
      플랜을 타는지 수동 확인 (Mock으로는 `FOR UPDATE` 자체를 검증 못 함)
