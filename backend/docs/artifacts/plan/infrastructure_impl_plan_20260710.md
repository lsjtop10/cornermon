# Infrastructure Implementation Plan

## 파일 형식
- 파일명: infrastructure_impl_plan_20260710.md

## 1. 유즈케이스 우선 정의

| 우선순위 | 유즈케이스 | 설명 | 용도 |
| --- | --- | --- | --- |
| P0 | 인프라 구조체 정의 | Postgres Repository 구현 | 프로덕션 핵심 로직 |
| P0 | SSE Broadcaster 구현 | 새로운 SSE 정책에 맞는 Broadcaster 구현 | 프로덕션 핵심 로직 |

## 2. 객체 중심 설계

```go
package postgres

type pgTxManager struct {
    pool *pgxpool.Pool
}

func (t *pgTxManager) RunInTx(ctx context.Context, fn func(ctx context.Context) error) error
```

```go
package postgres

type pgCampRepository struct {
    pool *pgxpool.Pool
}

func (r *pgCampRepository) Get(ctx context.Context, id domain.CampID) (*domain.Camp, error)
func (r *pgCampRepository) Save(ctx context.Context, camp *domain.Camp) error
```

*(다른 Repository들도 동일한 형태로 pool이나 tx를 주입받아 구현)*

```go
package sse

type BroadcasterImpl struct {
	// 필요 시 추가
}

func (b *BroadcasterImpl) Broadcast(ctx context.Context, campID domain.CampID, event usecase.NotificationEvent, scope string) error
```

## 3. 아키텍처 원칙 명시
- domain 패키지에서 infrastructure import 금지
- Service 계층이 구체적 구현체를 모름 (포트에만 의존)
- db layer는 `pgxpool`을 사용

## 4. 구현 단계 (Implementation Phases)

### Phase A: 트랜잭션 매니저 및 기본 Repo 구현
| 순서 | 작업 | 파일 |
| --- | --- | --- |
| A-1 | `TxManager` 구현 | `backend/internal/infrastructure/postgres/tx_manager.go` |
| A-2 | `CampRepository`, `CornerRepository`, `TrackRepository` 구현 | `backend/internal/infrastructure/postgres/camp_repo.go` 등 |

### Phase B: 나머지 Repo 구현
| 순서 | 작업 | 파일 |
| --- | --- | --- |
| B-1 | `VisitRepository`, `GroupRepository`, `BadgeRepository` 등 구현 | `backend/internal/infrastructure/postgres/...` |
| B-2 | 인증, 로깅, 메시지 관련 Repo 구현 | `backend/internal/infrastructure/postgres/...` |

### Phase C: SSE 및 쿼리어 구현
| 순서 | 작업 | 파일 |
| --- | --- | --- |
| C-1 | `Broadcaster` 구현 | `backend/internal/infrastructure/sse/broadcaster.go` |
| C-2 | `ReportQuerier` 구현 | `backend/internal/infrastructure/postgres/report_querier.go` |

## 5. 검증 체크리스트
### 5.1 아키텍처 검증
- [ ] `domain` 패키지에서 `infrastructure` import 없음

### 5.2 유즈케이스 검증
- [ ] DB 통합 테스트 시 트랜잭션이 잘 작동하는지
- [ ] SSE 이벤트가 정상적으로 송출되는지
