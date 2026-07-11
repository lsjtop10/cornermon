# ListGroupVisits 구현 계획

## 1. 유즈케이스 우선 정의

| 우선순위 | 유즈케이스 | 설명 | 용도 |
| -------- | ---------- | ---- | ---- |
| **P0**   | UC-2: 조별 방문 기록 조회 | 특정 조의 전체 방문(Visit) 기록과 각 코너의 소요 시간 등을 조회합니다. | **어드민 패널 조 상세 보기** |

## 2. 객체 중심 설계 (Object-Oriented Design)

### Domain / Port Layer
```go
// internal/usecase/port.go
type VisitRepository interface {
    // ...
    ListByGroup(ctx context.Context, groupID domain.GroupID) ([]*domain.Visit, error)
}
```

### Usecase Layer
```go
// internal/usecase/group.go
type GroupService struct {
    // ...
    visits VisitRepository // 신규 주입
}

type GroupVisitDetail struct {
    Visit  *domain.Visit
    Corner *domain.Corner
}

func (s *GroupService) ListGroupVisitDetails(ctx context.Context, groupID domain.GroupID) ([]GroupVisitDetail, error)
```

### Infrastructure Layer (Web)
```go
// internal/infrastructure/web/group_handler.go
func (h *GroupHandler) ListGroupVisits(c echo.Context) error
// -> 호출된 결과를 api_dtos.go 의 VisitSummary 형식에 맞추어 변환 후 응답
```

## 3. 구현 단계 (Implementation Phases)

### Phase A: 쿼리 및 DB 리포지토리 추가
1. `backend/db/queries/visits.sql` 에 `ListVisitsByGroup` 쿼리 추가.
2. `make sqlc` 또는 `sqlc generate` 실행하여 DB 모델 업데이트.
3. `internal/infrastructure/postgres/visit_repo.go` 에 `ListByGroup` 구현.

### Phase B: Usecase & 포트 갱신
1. `internal/usecase/port.go` 의 `VisitRepository` 인터페이스에 `ListByGroup` 추가.
2. `internal/usecase/group.go` 의 `GroupService` 생성자 서명에 `VisitRepository` 추가.
3. `cmd/server/main.go` 에 `NewGroupService` 호출 시 `visitRepo` 인자 추가 주입.
4. `GroupService.ListGroupVisitDetails` 유즈케이스 구현: 해당 그룹의 방문기록과 소속 캠프의 코너 정보를 묶어서 반환.

### Phase C: Handler 연동
1. `internal/infrastructure/web/group_handler.go` 의 `ListGroupVisits` 핸들러에서 501 반환을 제거하고 유즈케이스 연동.
2. `Visit` 과 `Corner` 를 활용해 `DurationSeconds`, `DeviationSeconds` 계산 로직 수행 후 `VisitSummary` 로 변환.
