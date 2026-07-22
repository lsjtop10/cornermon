package usecase

import (
	"context"
	"time"

	"cornermon/backend/internal/domain"
)

// TxManager는 트랜잭션 경계를 정의하기 위한 유스케이스 포트입니다.
type TxManager interface {
	RunInTx(ctx context.Context, fn func(ctx context.Context) error) error
}

// TrackPINProtector seals PINs for the administrator-only reprint flow.
// PIN hashes remain the sole source of truth for facilitator authentication.
type TrackPINProtector interface {
	Encrypt(ctx context.Context, pin string) (string, error)
	Decrypt(ctx context.Context, ciphertext string) (string, error)
}

// CampRepository는 캠프 엔티티의 지속성을 담당하는 포트입니다.
type CampRepository interface {
	Get(ctx context.Context, id domain.CampID) (*domain.Camp, error)
	GetByRegistrationCode(ctx context.Context, code string) (*domain.Camp, error)
	List(ctx context.Context) ([]*domain.Camp, error)
	Save(ctx context.Context, camp *domain.Camp) error
}

// CornerRepository는 코너 엔티티의 지속성을 담당하는 포트입니다.
type CornerRepository interface {
	Get(ctx context.Context, id domain.CornerID) (*domain.Corner, error)
	ListByCamp(ctx context.Context, campID domain.CampID) ([]*domain.Corner, error)
	Save(ctx context.Context, corner *domain.Corner) error
	SoftDelete(ctx context.Context, id domain.CornerID, deletedAt time.Time) error
}

// CornerCleanupRepository physically removes only candidates selected by the
// persistence layer's history-safe cleanup query.
type CornerCleanupRepository interface {
	PurgeDeletedBefore(ctx context.Context, deletedBefore time.Time) (int64, error)
}

// CornerViewQuerier는 코너 핵심 정보, 완료 방문 지표, 활성 트랙을 한 번에 반환하는 읽기 전용 포트입니다.
// 현재 서비스는 단일 테넌트 관리자 모델이므로 campID/cornerID 범위만 검증합니다.
type CornerViewQuerier interface {
	ListCornerViewsByCamp(ctx context.Context, campID domain.CampID) ([]CornerView, error)
	GetCornerView(ctx context.Context, id domain.CornerID) (*CornerView, error)
}

type CornerView struct {
	ID                 domain.CornerID
	CampID             domain.CampID
	Name               string
	TargetMinutes      int
	Status             domain.CornerOperationalStatus
	AvgDurationSeconds int
	SampleCount        int
	ActiveTracks       []TrackView
}

// TrackView는 코너 조회 응답에 포함되는 활성 트랙의 읽기 전용 요약입니다.
type TrackView struct {
	ID                domain.TrackID
	CornerID          domain.CornerID
	TrackNo           int
	Status            domain.TrackStatus
	OperationalStatus domain.TrackOperationalStatus
}

// TrackRepository는 트랙 엔티티의 지속성을 담당하는 포트입니다.
type TrackRepository interface {
	Get(ctx context.Context, id domain.TrackID) (*domain.Track, error)
	ListByCorner(ctx context.Context, cornerID domain.CornerID) ([]*domain.Track, error)
	ListActiveByCamp(ctx context.Context, campID domain.CampID) ([]*domain.Track, error)
	ListByCamp(ctx context.Context, campID domain.CampID) ([]*domain.Track, error)
	Save(ctx context.Context, track *domain.Track) error
	IncrementUnreadCount(ctx context.Context, trackID domain.TrackID, recipient domain.SenderRole) error
	ResetUnreadCount(ctx context.Context, trackID domain.TrackID, reader domain.SenderRole) error
}

// VisitRepository는 방문 엔티티의 지속성을 담당하는 포트입니다.
type VisitRepository interface {
	Get(ctx context.Context, id domain.VisitID) (*domain.Visit, error)
	GetInProgressByTrack(ctx context.Context, trackID domain.TrackID) (*domain.Visit, error)
	GetCompletedByGroupAndCorner(ctx context.Context, groupID domain.GroupID, cornerID domain.CornerID) (*domain.Visit, error)
	ListInProgressByCamp(ctx context.Context, campID domain.CampID) ([]*domain.Visit, error)
	ListByGroup(ctx context.Context, groupID domain.GroupID) ([]*domain.Visit, error)
	Save(ctx context.Context, visit *domain.Visit) error
}

// GroupRepository는 조 엔티티의 지속성을 담당하는 포트입니다.
type GroupRepository interface {
	Get(ctx context.Context, id domain.GroupID) (*domain.Group, error)
	// GetForUpdate는 Get과 동일하지만 행을 잠급니다(SELECT ... FOR UPDATE). 코너
	// 추가/삭제로 인한 순회표 동기화와 방문 시작/완료가 같은 조 행을 동시에 갱신할 때
	// lost update를 막기 위한 것으로, 반드시 TxManager.RunInTx 안에서만 호출해야 합니다.
	GetForUpdate(ctx context.Context, id domain.GroupID) (*domain.Group, error)
	GetByBadge(ctx context.Context, campID domain.CampID, badgeID domain.BadgeID) (*domain.Group, error)
	ListByCamp(ctx context.Context, campID domain.CampID) ([]*domain.Group, error)
	// ListByCampForUpdate는 ListByCamp와 동일하지만 캠프의 모든 조 행을 잠급니다.
	// 코너 추가/삭제 시 캠프 내 전체 조의 순회표를 갱신하기 전에 사용합니다.
	ListByCampForUpdate(ctx context.Context, campID domain.CampID) ([]*domain.Group, error)
	Save(ctx context.Context, group *domain.Group) error
	SaveBulk(ctx context.Context, groups []*domain.Group) error
}

// BadgeRepository는 배지 엔티티의 지속성을 담당하는 포트입니다.
type BadgeRepository interface {
	Get(ctx context.Context, id domain.BadgeID) (*domain.Badge, error)
	GetByQRPayload(ctx context.Context, payload string) (*domain.Badge, error)
	ListAll(ctx context.Context) ([]*domain.Badge, error)
	Save(ctx context.Context, badge *domain.Badge) error
	SaveBulk(ctx context.Context, badges []*domain.Badge) error
}

// DeviceRegistrationRepository는 기기 등록 엔티티의 지속성을 담당하는 포트입니다.
type DeviceRegistrationRepository interface {
	Get(ctx context.Context, id domain.DeviceRegistrationID) (*domain.DeviceRegistration, error)
	GetByTokenHash(ctx context.Context, hash string) (*domain.DeviceRegistration, error)
	ListPendingByCamp(ctx context.Context, campID domain.CampID) ([]*domain.DeviceRegistration, error)
	ListByCampAndStatus(ctx context.Context, campID domain.CampID, status *domain.DeviceRegistrationStatus) ([]*domain.DeviceRegistration, error)
	Save(ctx context.Context, reg *domain.DeviceRegistration) error
}

// FacilitatorSessionRepository는 진행자 세션 엔티티의 지속성을 담당하는 포트입니다.
type FacilitatorSessionRepository interface {
	Get(ctx context.Context, id domain.FacilitatorSessionID) (*domain.FacilitatorSession, error)
	GetByTokenHash(ctx context.Context, hash string) (*domain.FacilitatorSession, error)
	ListActiveByTrack(ctx context.Context, trackID domain.TrackID) ([]*domain.FacilitatorSession, error)
	ListActiveByCamp(ctx context.Context, campID domain.CampID) ([]*domain.FacilitatorSession, error)
	Save(ctx context.Context, session *domain.FacilitatorSession) error
}

// AdminRepository는 관리자 엔티티의 지속성을 담당하는 포트입니다.
type AdminRepository interface {
	Get(ctx context.Context, id domain.AdminID) (*domain.Admin, error)
	GetByUsername(ctx context.Context, username string) (*domain.Admin, error)
	Save(ctx context.Context, admin *domain.Admin) error
	Delete(ctx context.Context, id domain.AdminID) error
	Count(ctx context.Context) (int, error)
	CountByRole(ctx context.Context, role domain.AdminRole) (int, error)
}

// AdminSessionRepository는 관리자 세션 엔티티의 지속성을 담당하는 포트입니다.
type AdminSessionRepository interface {
	Get(ctx context.Context, id domain.AdminSessionID) (*domain.AdminSession, error)
	GetByAccessTokenHash(ctx context.Context, hash string) (*domain.AdminSession, error)
	Save(ctx context.Context, session *domain.AdminSession) error
	ListByAdmin(ctx context.Context, adminID domain.AdminID) ([]*domain.AdminSession, error)
}

// MessageRepository는 메시지 엔티티의 지속성을 담당하는 포트입니다.
type MessageRepository interface {
	Save(ctx context.Context, msg *domain.Message) error
	ListMessageByTrack(ctx context.Context, trackID domain.TrackID) ([]*domain.Message, error)
	ListMessageByTrackAfter(ctx context.Context, trackID domain.TrackID, after domain.Optional[time.Time]) ([]*domain.Message, error)
	MarkAllReadByRecipient(ctx context.Context, trackID domain.TrackID, recipient domain.SenderRole, readAt time.Time) error
}

// AnnouncementRepository는 공지사항 명령 모델의 지속성을 담당하는 포트입니다.
type AnnouncementRepository interface {
	Save(ctx context.Context, announcement *domain.Announcement) error
}

// AnnouncementQuerier는 공지 화면에 필요한 읽기 전용 스냅샷을 제공하는 포트입니다.
type AnnouncementQuerier interface {
	ListNoticesByCamp(ctx context.Context, campID domain.CampID) ([]*domain.Announcement, error)
	ListNoticeViewsByCampAndTrack(ctx context.Context, campID domain.CampID, trackID domain.TrackID) ([]BroadcastNoticeView, error)
	ListAnnouncementReceipts(ctx context.Context, announcementID domain.AnnouncementID) ([]BroadcastReceiptDTO, error)
}

// BroadcastReceiptRepository는 공지 수신 확인 엔티티의 지속성을 담당하는 포트입니다.
type AnnouncementReceiptRepository interface {
	Save(ctx context.Context, receipt *domain.AnnouncementReceipt) error
	GetByMessageAndTrack(ctx context.Context, msgID domain.AnnouncementID, trackID domain.TrackID) (*domain.AnnouncementReceipt, error)
}

// AuditLogRepository는 감사 로그 엔티티의 지속성을 담당하는 포트입니다.
type AuditLogRepository interface {
	Save(ctx context.Context, log *domain.AuditLog) error
}

type AuditLogQuerier interface {
	List(ctx context.Context, query AuditLogQuery) (*AuditLogPage, error)
}

type AuditLogCursor struct {
	OccurredAt time.Time
	ID         domain.AuditLogID
}

type AuditLogQuery struct {
	Actor   string
	Action  string
	Success *bool
	Before  domain.Optional[AuditLogCursor]
	Limit   int
}

type AuditLogPage struct {
	Logs       []*domain.AuditLog
	NextCursor domain.Optional[AuditLogCursor]
}

type NotificationEvent string

const (
	EventTracksUpdated             NotificationEvent = "tracks_updated"
	EventTrackUpdated              NotificationEvent = "track_updated"
	EventCornersUpdated            NotificationEvent = "corners_updated"
	EventGroupsUpdated             NotificationEvent = "groups_updated"
	EventCampUpdated               NotificationEvent = "camp_updated"
	EventMessagesChanged           NotificationEvent = "messages_changed"
	EventTrackDeleted              NotificationEvent = "track_deleted"
	EventTrackReplaced             NotificationEvent = "track_replaced"
	EventSessionRevoked            NotificationEvent = "session_revoked"
	EventCampEnded                 NotificationEvent = "camp_ended"
	EventDeviceRegistrationUpdated NotificationEvent = "device_registration_updated"
	EventLockoutAlert              NotificationEvent = "lockout_alert"
)

func NotificationEvents() []NotificationEvent {
	return []NotificationEvent{
		EventTracksUpdated,
		EventTrackUpdated,
		EventCornersUpdated,
		EventGroupsUpdated,
		EventCampUpdated,
		EventMessagesChanged,
		EventTrackDeleted,
		EventTrackReplaced,
		EventSessionRevoked,
		EventCampEnded,
		EventDeviceRegistrationUpdated,
		EventLockoutAlert,
	}
}

type ScopeKind string

const (
	ScopeCamp  ScopeKind = "camp"
	ScopeTrack ScopeKind = "track"
)

type Scope struct {
	Kind    ScopeKind
	TrackID domain.TrackID
}

func CampScope() Scope {
	return Scope{Kind: ScopeCamp}
}

func TrackScope(trackID domain.TrackID) Scope {
	return Scope{Kind: ScopeTrack, TrackID: trackID}
}

type SSEMessage struct {
	Event NotificationEvent
	Scope Scope
}

// Broadcaster는 트랜잭션 성공 후 SSE 클라이언트에게 실시간 알림을 푸시하는 포트입니다.
type Broadcaster interface {
	Broadcast(ctx context.Context, campID domain.CampID, event NotificationEvent, scope Scope) error
}

// ReportQuerier는 캠프 종료 시 사후 통계 집계를 담당하는 포트입니다.
type ReportQuerier interface {
	QueryCampReport(ctx context.Context, campID domain.CampID) (*CampReport, error)
}

// CampReport는 캠프 전체 결과 집계 DTO입니다.
type CampReport struct {
	CampID             domain.CampID
	TotalGroups        int
	FinishedGroups     int
	TotalVisits        int
	CompletedVisits    int
	ManualVisits       int
	ProgramDurationSec int     // 첫 방문 started_at ~ 캠프 종료 선언 시각(진행 중이면 현재 시각)
	AvgDeviationSec    float64 // 모든 COMPLETED 방문의 (실제 소요시간 - 목표시간) 평균
	CornerReports      []CornerReport
	GroupReports       []GroupReport
}

// CornerReport는 코너별 분석 집계 DTO입니다.
type CornerReport struct {
	CornerID               domain.CornerID
	CornerName             string
	CompletedCount         int
	AvgDurationSec         float64
	MedianDurationSec      float64
	StdDevDurationSec      float64
	AvgDeviationSec        float64
	PositiveDeviationRatio float64
}

// GroupReport는 조별 분석 집계 DTO입니다.
type GroupReport struct {
	GroupID          domain.GroupID
	GroupName        string
	IsFinished       bool
	CompletedCount   int
	TotalDurationSec int // 완료한 모든 방문의 소요시간 합
	VisitDetails     []VisitDetail
}

// VisitDetail은 조의 코너별 방문 상세 정보 DTO입니다.
type VisitDetail struct {
	CornerID     domain.CornerID
	DurationSec  int
	DeviationSec int
}

type BroadcastReceiptDTO struct {
	TrackID    domain.TrackID
	TrackNo    int
	CornerName string
	IsRead     bool
	ReadAt     domain.Optional[time.Time]
}
