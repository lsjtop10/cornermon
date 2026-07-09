# Phase A: 포트(인터페이스) 정의

> usecase 계층이 "필요한 것"을 인터페이스로 선언한다. 구현체는 adapter/postgres, adapter/sse 등이 제공한다.
> 파일: `backend/internal/usecase/port.go` (신규)

---

## A-1. 유틸리티 — 포트 불필요, 직접 호출

아래 유틸리티들은 외부 서비스가 아닌 라이브러리 직접 호출로 처리한다. 의존성 역전 불필요.

| 역할 | 처리 방식 |
|---|---|
| ID 생성 | `uuid.NewString()` 직접 호출 후 domain 타입 캐스팅 |
| 불투명 토큰 발급 | `crypto/rand` 로 32바이트 생성 → hex 인코딩(plain) + SHA-256(hash) |
| 트랙 PIN 발급 | `crypto/rand` 로 6자리 숫자 생성(plain) + bcrypt(hash) |
| 비밀번호 해시/검증 | `bcrypt` 직접 호출 |
| 트랜잭션 경계 | `TxManager` 인터페이스(usecase 선언) → `PgTxManager`(adapter/postgres 구현). ctx에 `pgx.Tx` 주입 → repo가 `ctx.Value(txKey)`로 꺼내 사용 |

```go
// usecase/port.go — 인터페이스 선언
type TxManager interface {
    RunInTx(ctx context.Context, fn func(ctx context.Context) error) error
}

// adapter/postgres/tx.go — 구현체 (usecase는 이 파일을 모름)
type PgTxManager struct{ db *pgxpool.Pool }

func (m *PgTxManager) RunInTx(ctx context.Context, fn func(ctx context.Context) error) error

// repo 내부 패턴
func (r *Repo) getQueries(ctx context.Context) *query.Queries {
    if tx, ok := ctx.Value(txKey).(pgx.Tx); ok {
        return r.queries.WithTx(tx)
    }
    return r.queries
}
```

---

## A-2. 리포지토리 포트

> 각 서비스에 필요한 최소 인터페이스만 정의한다(좁은 인터페이스 원칙, §technical-design.md 1.2).

```go
type CampRepository interface {
    Get(ctx context.Context, id domain.CampID) (*domain.Camp, error)
    Save(ctx context.Context, camp *domain.Camp) error
}

type CornerRepository interface {
    Get(ctx context.Context, id domain.CornerID) (*domain.Corner, error)
    ListByCamp(ctx context.Context, campID domain.CampID) ([]*domain.Corner, error)
    Save(ctx context.Context, corner *domain.Corner) error
}

type TrackRepository interface {
    Get(ctx context.Context, id domain.TrackID) (*domain.Track, error)
    ListByCorner(ctx context.Context, cornerID domain.CornerID) ([]*domain.Track, error)
    ListActiveByCamp(ctx context.Context, campID domain.CampID) ([]*domain.Track, error)
    Save(ctx context.Context, track *domain.Track) error
}

type VisitRepository interface {
    Get(ctx context.Context, id domain.VisitID) (*domain.Visit, error)
    GetInProgressByTrack(ctx context.Context, trackID domain.TrackID) (*domain.Visit, error)
    GetCompletedByGroupAndCorner(ctx context.Context, groupID domain.GroupID, cornerID domain.CornerID) (*domain.Visit, error)
    Save(ctx context.Context, visit *domain.Visit) error
}

type GroupRepository interface {
    Get(ctx context.Context, id domain.GroupID) (*domain.Group, error)
    GetByBadge(ctx context.Context, campID domain.CampID, badgeID domain.BadgeID) (*domain.Group, error)
    ListByCamp(ctx context.Context, campID domain.CampID) ([]*domain.Group, error)
    Save(ctx context.Context, group *domain.Group) error
}

type BadgeRepository interface {
    Get(ctx context.Context, id domain.BadgeID) (*domain.Badge, error)
    GetByQRPayload(ctx context.Context, payload string) (*domain.Badge, error)
    Save(ctx context.Context, badge *domain.Badge) error
}

type DeviceRegistrationRepository interface {
    Get(ctx context.Context, id domain.DeviceRegistrationID) (*domain.DeviceRegistration, error)
    GetByTokenHash(ctx context.Context, hash string) (*domain.DeviceRegistration, error)
    ListPendingByCamp(ctx context.Context, campID domain.CampID) ([]*domain.DeviceRegistration, error)
    Save(ctx context.Context, reg *domain.DeviceRegistration) error
}

type FacilitatorSessionRepository interface {
    GetByTokenHash(ctx context.Context, hash string) (*domain.FacilitatorSession, error)
    ListActiveByTrack(ctx context.Context, trackID domain.TrackID) ([]*domain.FacilitatorSession, error)
    ListActiveByCamp(ctx context.Context, campID domain.CampID) ([]*domain.FacilitatorSession, error)
    Save(ctx context.Context, session *domain.FacilitatorSession) error
}

type AdminRepository interface {
    Get(ctx context.Context, id domain.AdminID) (*domain.Admin, error)
    GetByUsername(ctx context.Context, username string) (*domain.Admin, error)
}

type AdminSessionRepository interface {
    GetByAccessTokenHash(ctx context.Context, hash string) (*domain.AdminSession, error)
    GetByRefreshTokenHash(ctx context.Context, hash string) (*domain.AdminSession, error)
    Save(ctx context.Context, session *domain.AdminSession) error
}

type MessageRepository interface {
    Save(ctx context.Context, msg *domain.Message) error
    ListBroadcastsByCamp(ctx context.Context, campID domain.CampID) ([]*domain.Message, error)
    ListDirectByTrack(ctx context.Context, trackID domain.TrackID) ([]*domain.Message, error)
}

type BroadcastReceiptRepository interface {
    Save(ctx context.Context, receipt *domain.BroadcastReceipt) error
    GetByMessageAndTrack(ctx context.Context, msgID domain.MessageID, trackID domain.TrackID) (*domain.BroadcastReceipt, error)
    ListByMessage(ctx context.Context, msgID domain.MessageID) ([]*domain.BroadcastReceipt, error)
}

type AuditLogRepository interface {
    Save(ctx context.Context, log *domain.AuditLog) error
}
```

---

## A-3. SSE 브로드캐스터 포트

```go
// Broadcaster — 커밋 성공 후 SSE 클라이언트에게 캠프 전체 스냅샷 push
// (§technical-design.md 2.3-b: 브로드캐스트는 커밋 성공 직후에만, 전체 스냅샷 방식)
type Broadcaster interface {
    BroadcastSnapshot(ctx context.Context, campID domain.CampID) error
}
```

---

## A-4. 리포트 전용 쿼리어 포트 (Phase D에서 사용)

> 일반 CRUD Repository와 분리. 무거운 집계 쿼리 전용 (§technical-design.md 1.2).

```go
// ReportQuerier — 캠프 종료 시 사후 통계 집계 전용 (analytics-model.md §1)
// 구현체: adapter/postgres 의 손튜닝된 SQL
type ReportQuerier interface {
    QueryCampReport(ctx context.Context, campID domain.CampID) (*CampReport, error)
}

// CampReport — 리포트 결과 집계 DTO (usecase 계층 내 정의)
type CampReport struct {
    CampID          domain.CampID
    // 캠프 레벨 (analytics-model.md §1.1)
    TotalGroups     int
    FinishedGroups  int
    TotalVisits     int
    CompletedVisits int
    ManualVisits    int
    // 코너/트랙/조 레벨 상세는 중첩 슬라이스로
    CornerReports   []CornerReport
    GroupReports    []GroupReport
}

type CornerReport struct {
    CornerID        domain.CornerID
    CornerName      string
    CompletedCount  int
    AvgDurationSec  float64
    MedianDurationSec float64
    StdDevDurationSec float64
    AvgDeviationSec float64
    PositiveDeviationRatio float64
}

type GroupReport struct {
    GroupID        domain.GroupID
    GroupName      string
    IsFinished     bool
    CompletedCount int
    VisitDetails   []VisitDetail
}

type VisitDetail struct {
    CornerID       domain.CornerID
    DurationSec    int
    DeviationSec   int
}
```

---

## A-5. 검증 체크리스트

- [ ] `port.go`가 `domain` 패키지 외에 다른 infrastructure import 없음
- [ ] 모든 메서드 첫 번째 인자는 `context.Context`
- [ ] 각 포트는 최소 필요 메서드만 포함 (YAGNI)
- [ ] `adapter/postgres.RunInTx` 가 tx 커밋/롤백을 올바르게 처리하는지 확인
