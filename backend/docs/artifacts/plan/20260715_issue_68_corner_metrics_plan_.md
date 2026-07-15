# GitHub Issue #68 — 코너 상세 정보에 평균 소요시간·샘플 수 추가 구현 계획

> 이슈: https://github.com/lsjtop10/cornermon/issues/68

## 배경 / 문제 정의

프론트엔드가 "평균 10:40 (+2:30)" 같은 카드 문구를 만들려면 코너별 평균 소요시간(`avgDurationSeconds`)과 표본 수(`sampleCount`)가 필요한데, 현재 `CornerResponse`(`GET /camps/{campId}/corners`, `GET /corners/{id}`)에는 이 필드가 없다.

### 코드베이스 조사 결과

- 유사한 집계는 이미 존재한다: `ReportQuerier.QueryCampReport` → `calculateCampReport` (`internal/infrastructure/postgres/report_querier.go:51-190`)가 코너별 `AvgDurationSec`, `CompletedCount`(표본 수) 등을 계산해 `usecase.CornerReport`로 반환한다. 하지만 이 경로는 **캠프의 모든 group/corner/visit을 메모리에 로드한 후 애플리케이션에서 집계**하는 방식이라(`ListGroupsByCamp`, `ListCornersByCamp`, `ListVisitsByCamp` 전체 로딩), 캠프 종료 후 저빈도로 호출되는 리포트 생성에는 맞지만 대시보드에서 반복 폴링되는 `GET /camps/{campId}/corners`에는 부적합하다. 재사용하지 않는다.
- `visits` 스키마: `status`, `started_at`, `ended_at` (`db/schema.sql:76-94`). 완료된 방문은 `status = 'COMPLETED'`이고 `ended_at`이 채워진다(`ReportQuerier`가 이미 이 규약을 사용).
- 조회 응답의 `ActiveTracks`도 코너 카드/상세 뷰의 일부다. `CornerViewQuerier`가 코너 지표와 활성 트랙 요약을 한 SQL에서 함께 반환하며, 핸들러는 그 뷰를 HTTP DTO로 변환만 한다.
- 작업 디렉토리에 이미 `CornerMatricResponse`/`Matric` 필드를 추가한 **미완성 로컬 변경**이 존재한다(`corner_handler.go`, 커밋되지 않음). 필드명은 이슈 원문 스니펫과 동일하게 `CornerMatricResponse`/`json:"cornerMatric"`를 유지한다 — 이미 계약된 필드명을 바꾸면 프론트와 재조율이 필요하므로 API 계약 변경 절차(`workflow/Collaborate.md`) 대상이 된다.

### 설계 방향 (사용자 확정)

최초 초안은 "코너 조회 포트 + 지표 조회 포트를 `CornerService`에서 합성"하는 절충안이었으나, 다음 두 가지 문제로 폐기한다.

1. 코너 목록 조회마다 SQL이 2번(코너 조회 + 지표 집계) 나간다.
2. `map[CornerID]CornerMetrics`를 코너 리스트와 키로 맞춰 합치는 애플리케이션 조합 코드가 필요하다.

대신 **도메인 필드(id, name, targetMinutes), 지표(avgDurationSeconds, sampleCount), 활성 트랙 요약(activeTracks)을 하나의 SQL로 한 번에 반환하는 전용 조회 포트 `CornerViewQuerier`**를 만들고, `GET` 핸들러는 `CornerService`를 거치지 않고 이 포트를 직접 호출한다. `CornerService`/`CornerRepository`는 `Create`/`Update`/`Delete`(Command) 전용으로 남고, 이번 변경으로 건드리지 않는다. 조회 포트가 다시 `TrackRepository`를 호출해 조합하지 않는다.

## 1. 유즈케이스 우선 정의

| 우선순위 | 유즈케이스 | 설명 | 용도 |
| --- | --- | --- | --- |
| **P0** | UC-1: 캠프 코너 뷰 목록 조회 | `GET /camps/{campId}/corners` — 코너 핵심 필드 + `cornerMetric` + `activeTracks`를 단일 쿼리로 조회 | **관리자 대시보드 코너 카드** |
| **P0** | UC-2: 코너 단건 뷰 조회 | `GET /corners/{id}` — 위와 동일한 뷰를 단건으로 조회 | **코너 상세 화면** |
| P1 | UC-3: 코너 생성/수정/삭제 (기존 유지) | `CornerService` 경유, Command 경로는 변경 없음 | **관리자 코너 관리** — 회귀 방지 확인용 |

## 2. 객체 중심 설계

### Domain Layer

변경 없음. `domain.Corner`는 Command(쓰기) 경로 전용으로 유지하고, 조회 응답용 뷰는 도메인 모델에 넣지 않는다(조회 모델과 도메인 모델의 의도적 분리 — plan.md 2절 CQRS 가이드라인).

### Usecase Layer — 전용 조회 포트

```go
// internal/usecase/port.go
// 책임: 캠프/단건 범위로 코너 핵심 필드, 완료 방문 기준 평균 소요시간·표본 수,
// 활성 트랙 요약을 단일 SQL로 함께 조회한다. Command 포트(CornerRepository)와는 완전히 분리된
// 읽기 전용 뷰 모델이며, 어떤 비즈니스 규칙도 개입하지 않는 순수 조회이므로
// CornerService(usecase)를 거치지 않고 handler가 직접 호출한다.
//
// 권한 범위에 대한 의사결정: 이 포트는 campID/cornerID로만 필터링하며 요청 admin이
// 해당 캠프 소속인지는 검증하지 않는다. 현재 도메인 모델(Admin/AdminSession)에는
// "조직(organization)" 개념이 없고 관리자는 전역적으로 모든 캠프에 접근 가능한
// 단일 테넌트 설계다. 캠프별 관리자 권한 분리가 필요해지는 시점은 조직 개념을
// 먼저 도입해야 하는 별도 설계 결정이므로, 그 전까지는 AdminAuthMiddleware의
// "유효한 관리자 세션인지"만으로 충분하다. (2026-07-15, GitHub Issue #68 논의)
type CornerViewQuerier interface {
    ListCornerViewsByCamp(ctx context.Context, campID domain.CampID) ([]CornerView, error)
    GetCornerView(ctx context.Context, id domain.CornerID) (*CornerView, error)
}

// CornerView는 코너 카드/상세 화면 전용 조회 모델입니다. domain.Corner를 대체하지 않습니다.
type CornerView struct {
    ID                  domain.CornerID
    Name                string
    TargetMinutes       int
    AvgDurationSeconds  int
    SampleCount         int
    ActiveTracks        []TrackView
}

type TrackView struct {
    ID                  domain.TrackID
    CornerID            domain.CornerID
    TrackNo             int
    Status              domain.TrackStatus
    OperationalStatus   domain.TrackOperationalStatus
}
```

`CornerService`(`internal/usecase/corner.go`)는 이번 이슈에서 **변경하지 않는다** — `ListCorners`/`GetCorner`(기존 시그니처)는 Command 경로 내부(예: 생성/수정 직후 응답 구성)에서만 쓰이거나, 필요 없다면 그대로 둔다.

### Infrastructure Layer

```go
// internal/infrastructure/postgres/corner_view_querier.go (신규 파일)
type pgCornerViewQuerier struct {
    pool *pgxpool.Pool
}

func NewCornerViewQuerier(pool *pgxpool.Pool) *pgCornerViewQuerier

func (r *pgCornerViewQuerier) ListCornerViewsByCamp(ctx context.Context, campID domain.CampID) ([]usecase.CornerView, error)

// 존재하지 않으면 (nil, nil) 반환 — 기존 repository Get 패턴(device_registration_repo.go 등)과 동일한 관례
func (r *pgCornerViewQuerier) GetCornerView(ctx context.Context, id domain.CornerID) (*usecase.CornerView, error)
```

```sql
-- backend/db/query.sql (신규)
-- name: ListCornerViewsByCamp :many
SELECT
    c.id,
    c.name,
    c.target_minutes,
    metrics.sample_count,
    metrics.avg_duration_seconds,
    active_tracks.active_tracks
FROM corners c
JOIN LATERAL (
    SELECT COUNT(*)::BIGINT AS sample_count,
           COALESCE(AVG(EXTRACT(EPOCH FROM (v.ended_at - v.started_at))), 0)::DOUBLE PRECISION AS avg_duration_seconds
    FROM visits v
    WHERE v.corner_id = c.id AND v.status = 'COMPLETED'
) metrics ON TRUE
JOIN LATERAL (
    SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'id', t.id, 'cornerId', t.corner_id, 'trackNo', t.track_no,
        'status', t.status,
        'operationalStatus', CASE WHEN t.current_visit_id IS NULL THEN 'IDLE' ELSE 'BUSY' END
    ) ORDER BY t.track_no), '[]'::jsonb) AS active_tracks
    FROM tracks t
    WHERE t.corner_id = c.id AND t.status = 'ACTIVE'
) active_tracks ON TRUE
WHERE c.camp_id = $1
ORDER BY c.id;

-- name: GetCornerView :one
SELECT
    c.id,
    c.name,
    c.target_minutes,
    metrics.sample_count,
    metrics.avg_duration_seconds,
    active_tracks.active_tracks
FROM corners c
JOIN LATERAL (
    SELECT COUNT(*)::BIGINT AS sample_count,
           COALESCE(AVG(EXTRACT(EPOCH FROM (v.ended_at - v.started_at))), 0)::DOUBLE PRECISION AS avg_duration_seconds
    FROM visits v
    WHERE v.corner_id = c.id AND v.status = 'COMPLETED'
) metrics ON TRUE
JOIN LATERAL (
    SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'id', t.id, 'cornerId', t.corner_id, 'trackNo', t.track_no,
        'status', t.status,
        'operationalStatus', CASE WHEN t.current_visit_id IS NULL THEN 'IDLE' ELSE 'BUSY' END
    ) ORDER BY t.track_no), '[]'::jsonb) AS active_tracks
    FROM tracks t
    WHERE t.corner_id = c.id AND t.status = 'ACTIVE'
) active_tracks ON TRUE
WHERE c.id = $1
;
```

```go
// internal/infrastructure/web/corner_handler.go
type CornerHandler struct {
    svc   *usecase.CornerService     // Create/Update/Delete 전용 (기존 유지)
    views usecase.CornerViewQuerier  // 신규: GET 전용
}

func NewCornerHandler(svc *usecase.CornerService, views usecase.CornerViewQuerier) *CornerHandler

func mapCornerViewToDTO(view usecase.CornerView) CornerResponse

// GET /camps/{campId}/corners — CornerService를 거치지 않고 views를 직접 호출
func (h *CornerHandler) ListCorners(c echo.Context) error

// GET /corners/{id} — 존재하지 않으면 domain.ErrCornerNotFound를 명시적으로 반환해
// 기존 에러 미들웨어(404 매핑, error_handler_middleware.go)를 그대로 재사용
func (h *CornerHandler) GetCorner(c echo.Context) error
```

`CreateCorner`, `BulkUpdateCorners`, `DeleteCorner`는 `mapDomainCornerToDTO(corner)`(기존 함수, 지표는 항상 0)를 그대로 사용한다 — 생성/수정 직후에는 방문 표본이 없거나 변경되지 않으므로 즉시 지표를 다시 조회할 필요가 없다.

## 3. 아키텍처 원칙 명시

### 3.1 헥사고날 아키텍처 준수
- Domain: 변경 없음.
- Infrastructure: SQL 집계는 postgres 어댑터에 격리.

### 3.2 Query 계층의 통제된 우회 (Open Layering)
- `ListCorners`/`GetCorner`(GET)는 상태 변이나 권한 필터링, 조건부 비즈니스 로직이 없는 단순 조회이므로 `Handler → CornerViewQuerier(Read-Only Port) → Database`로 직행하고 `CornerService`(usecase)를 건너뛴다(plan.md 2절).
- **권한 범위 결정**: 요청 admin이 해당 캠프 소속인지 검증하지 않는다. 현재 `Admin`/`AdminSession`(`internal/domain/admin.go`)에는 "조직(organization)" 개념이 없고, 관리자는 전역적으로 모든 캠프에 접근 가능한 단일 테넌트 설계다(`router.go`의 `AdminAuthMiddleware`는 세션 유효성만 검증). 멀티테넌트/캠프별 권한 분리는 이번 이슈 범위가 아니며, 그러려면 먼저 "조직" 개념 자체를 도입하는 별도 설계 결정이 필요하다 — 이 근거를 `CornerViewQuerier` 인터페이스 주석에 명시한다(2절 코드 스니펫 참고).
- **리팩토링 트리거 감시**: 이후 조직/캠프별 관리자 권한 분리가 도입되는 순간, 조회 포트의 호출 경계에 권한 정책을 추가할지 별도 설계를 결정한다. 이번 범위에서는 별도 조회 서비스를 만들지 않는다.
- 쓰기 경로(`CreateCorner`/`ModifyCornerSpecification`/`RemoveCornerFromCamp`)는 여전히 `CornerService` → `CornerRepository`를 통과하며, 이번 변경으로 전혀 손대지 않는다(Command 수호 원칙).

### 3.3 기존 포트 활용 우선
- `ReportQuerier`를 확장하지 않고 `CornerViewQuerier`를 신규 생성한 이유: `ReportQuerier.QueryCampReport`는 저빈도 "캠프 사후 통계"(표준편차·중앙값 포함, 전체 로딩) 책임이고, 이번 요구는 고빈도 "코너 카드 뷰"(평균·표본 수만, 경량 JOIN) 책임이라 목적이 다르다. 두 책임을 한 포트에 합치면 오히려 포트가 두 호출 패턴을 동시에 지원해야 하는 결합이 생긴다.
- `CornerRepository`(Command 포트)에 조회 메서드를 얹지 않고 `CornerViewQuerier`로 완전히 분리한다 — Command와 Query 포트를 섞지 않는다.

### 검증 항목
- [x] `domain` 패키지에서 `infrastructure` import 없음
- [x] `CornerHandler.ListCorners`/`GetCorner`가 `CornerService`를 호출하지 않고 `CornerViewQuerier`만 호출함
- [x] 코너 핵심 필드 + 지표 + 활성 트랙이 단일 SQL 쿼리(1 round-trip)로 조회됨 — N+1, 애플리케이션 레벨 join 없음
- [x] `CornerService`/`CornerRepository`는 Command 핸들러(Create/Update/Delete)에서만 호출됨

## 4. 계층별 책임 분리

### Infrastructure Layer (Web)
- `CornerHandler`가 GET/Command 두 종류의 의존성(`views`, `svc`)을 명시적으로 분리해서 갖는다 — 각 핸들러 메서드가 어느 쪽을 쓰는지 타입 시그니처만으로 드러난다.

### Infrastructure Layer (Postgres)
- `pgCornerViewQuerier`는 SQL 실행과 row → `CornerView` 매핑만 담당한다. 완료 방문 집계와 활성 트랙 JSON 집계를 LATERAL subquery로 분리해 조인 곱으로 인한 지표 왜곡을 막는다. 코너에 완료 방문이나 활성 트랙이 없으면 각각 `0`, `[]`을 반환한다.

## 5. 구현 단계

### Phase A: SQL / 영속성 계층 (예상 소요: 30분)
| 순서 | 작업 | 파일 |
| --- | --- | --- |
| A-1 | `ListCornerViewsByCamp`, `GetCornerView` 쿼리 작성 | `backend/db/query.sql` |
| A-2 | `sqlc generate` 실행 | (생성물) |
| A-3 | `pgCornerViewQuerier` 구현 (`GetCornerView`는 `pgx.ErrNoRows` 시 `nil, nil`) | `internal/infrastructure/postgres/corner_view_querier.go` |

### Phase B: Usecase 계층 (예상 소요: 15분)
| 순서 | 작업 | 파일 |
| --- | --- | --- |
| B-1 | `CornerViewQuerier` 포트, `CornerView` DTO 정의 (권한 범위 의사결정 주석 포함, 2절 참고) | `internal/usecase/port.go` |
| B-2 | `NewCornerViewQuerier` DI 조립 지점(예: `cmd/server/main.go`)에 등록 | `cmd/server/main.go` |

### Phase C: 인프라/핸들러 계층 (예상 소요: 30분)
| 순서 | 작업 | 파일 |
| --- | --- | --- |
| C-1 | `CornerHandler`에 `views` 필드 추가, `NewCornerHandler` 시그니처 확장 | `internal/infrastructure/web/corner_handler.go` |
| C-2 | `mapCornerViewToDTO` 작성, `ListCorners`/`GetCorner`를 `views` 직접 호출로 교체(`svc` 미사용으로 전환) | `internal/infrastructure/web/corner_handler.go` |
| C-3 | `GetCorner`에서 `nil` 응답 시 `domain.ErrCornerNotFound` 반환 확인 (기존 404 매핑 유지) | `internal/infrastructure/web/corner_handler.go` |
| C-4 | `NewCornerHandler` 호출부 수정 | `cmd/server/main.go` |
| C-5 | swaggo 주석에 `cornerMatric` 필드 반영 확인 후 `swag init` 재생성 | `api/*` |

## 6. 검증 체크리스트

### 6.1 아키텍처 검증
- [x] `domain` 패키지에 `infrastructure` import 없음
- [x] `CornerHandler.ListCorners`/`GetCorner` 내부에 `h.svc` 참조가 없음(전량 `h.views` 사용)
- [x] `avgDurationSeconds`/`sampleCount`와 `activeTracks`가 단일 SQL에서 수행됨(N+1 없음)
- [x] `CreateCorner`/`BulkUpdateCorners`/`DeleteCorner`는 기존과 동일하게 `h.svc`만 사용(회귀 없음)

### 6.2 유즈케이스 검증
- [ ] UC-1/2: 완료된 visit이 없는 코너는 `avgDurationSeconds=0, sampleCount=0` 반환(에러 아님)
- [ ] UC-1: 다른 캠프의 visit이 지표에 섞이지 않음
- [ ] UC-1/2: `IN_PROGRESS` 상태 visit은 표본에서 제외
- [ ] UC-1/2: `activeTracks`는 ACTIVE 트랙만 포함하고 트랙 번호 순으로 반환
- [ ] UC-2: 존재하지 않는 코너 ID 요청 시 404(`ErrCornerNotFound`)
- [ ] UC-2: 단건 조회 응답과 목록 조회 응답의 동일 코너 지표 값이 일치
- [ ] UC-3: 코너 생성/수정/삭제 API가 기존과 동일하게 동작(회귀 테스트)

### 6.3 자동화 테스트
- [ ] `pgCornerViewQuerier` 통합 테스트: 완료 0건/1건/N건, 진행중 혼합, 존재하지 않는 ID 케이스
- [ ] handler 레벨 테스트: `ListCorners`/`GetCorner`가 `CornerViewQuerier`의 fake만으로 테스트 가능한지 확인(= `CornerService` 의존성 없이 격리됨을 증명)
- [x] handler 레벨 테스트: 응답 JSON에 `cornerMetric.avgDurationSeconds`, `cornerMetric.sampleCount`, `activeTracks` 존재 확인
