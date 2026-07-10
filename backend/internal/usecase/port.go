package usecase

import (
	"context"

	"cornermon/backend/internal/domain"
)

// TxManager는 트랜잭션 경계를 정의하기 위한 유스케이스 포트입니다.
type TxManager interface {
	RunInTx(ctx context.Context, fn func(ctx context.Context) error) error
}

// CampRepository는 캠프 엔티티의 지속성을 담당하는 포트입니다.
type CampRepository interface {
	Get(ctx context.Context, id domain.CampID) (*domain.Camp, error)
	Save(ctx context.Context, camp *domain.Camp) error
}

// CornerRepository는 코너 엔티티의 지속성을 담당하는 포트입니다.
type CornerRepository interface {
	Get(ctx context.Context, id domain.CornerID) (*domain.Corner, error)
	ListByCamp(ctx context.Context, campID domain.CampID) ([]*domain.Corner, error)
	Save(ctx context.Context, corner *domain.Corner) error
}

// TrackRepository는 트랙 엔티티의 지속성을 담당하는 포트입니다.
type TrackRepository interface {
	Get(ctx context.Context, id domain.TrackID) (*domain.Track, error)
	ListByCorner(ctx context.Context, cornerID domain.CornerID) ([]*domain.Track, error)
	ListActiveByCamp(ctx context.Context, campID domain.CampID) ([]*domain.Track, error)
	Save(ctx context.Context, track *domain.Track) error
}

// VisitRepository는 방문 엔티티의 지속성을 담당하는 포트입니다.
type VisitRepository interface {
	Get(ctx context.Context, id domain.VisitID) (*domain.Visit, error)
	GetInProgressByTrack(ctx context.Context, trackID domain.TrackID) (*domain.Visit, error)
	GetCompletedByGroupAndCorner(ctx context.Context, groupID domain.GroupID, cornerID domain.CornerID) (*domain.Visit, error)
	Save(ctx context.Context, visit *domain.Visit) error
}

// GroupRepository는 조 엔티티의 지속성을 담당하는 포트입니다.
type GroupRepository interface {
	Get(ctx context.Context, id domain.GroupID) (*domain.Group, error)
	GetByBadge(ctx context.Context, campID domain.CampID, badgeID domain.BadgeID) (*domain.Group, error)
	ListByCamp(ctx context.Context, campID domain.CampID) ([]*domain.Group, error)
	Save(ctx context.Context, group *domain.Group) error
}

// BadgeRepository는 배지 엔티티의 지속성을 담당하는 포트입니다.
type BadgeRepository interface {
	Get(ctx context.Context, id domain.BadgeID) (*domain.Badge, error)
	GetByQRPayload(ctx context.Context, payload string) (*domain.Badge, error)
	Save(ctx context.Context, badge *domain.Badge) error
}

// DeviceRegistrationRepository는 기기 등록 엔티티의 지속성을 담당하는 포트입니다.
type DeviceRegistrationRepository interface {
	Get(ctx context.Context, id domain.DeviceRegistrationID) (*domain.DeviceRegistration, error)
	GetByTokenHash(ctx context.Context, hash string) (*domain.DeviceRegistration, error)
	ListPendingByCamp(ctx context.Context, campID domain.CampID) ([]*domain.DeviceRegistration, error)
	Save(ctx context.Context, reg *domain.DeviceRegistration) error
}

// FacilitatorSessionRepository는 진행자 세션 엔티티의 지속성을 담당하는 포트입니다.
type FacilitatorSessionRepository interface {
	GetByTokenHash(ctx context.Context, hash string) (*domain.FacilitatorSession, error)
	ListActiveByTrack(ctx context.Context, trackID domain.TrackID) ([]*domain.FacilitatorSession, error)
	ListActiveByCamp(ctx context.Context, campID domain.CampID) ([]*domain.FacilitatorSession, error)
	Save(ctx context.Context, session *domain.FacilitatorSession) error
}

// AdminRepository는 관리자 엔티티의 지속성을 담당하는 포트입니다.
type AdminRepository interface {
	Get(ctx context.Context, id domain.AdminID) (*domain.Admin, error)
	GetByUsername(ctx context.Context, username string) (*domain.Admin, error)
}

// AdminSessionRepository는 관리자 세션 엔티티의 지속성을 담당하는 포트입니다.
type AdminSessionRepository interface {
	Get(ctx context.Context, id domain.AdminSessionID) (*domain.AdminSession, error)
	GetByAccessTokenHash(ctx context.Context, hash string) (*domain.AdminSession, error)
	GetByRefreshTokenHash(ctx context.Context, hash string) (*domain.AdminSession, error)
	Save(ctx context.Context, session *domain.AdminSession) error
}

// MessageRepository는 메시지 엔티티의 지속성을 담당하는 포트입니다.
type MessageRepository interface {
	Save(ctx context.Context, msg *domain.Message) error
	ListBroadcastsByCamp(ctx context.Context, campID domain.CampID) ([]*domain.Message, error)
	ListDirectByTrack(ctx context.Context, trackID domain.TrackID) ([]*domain.Message, error)
}

// BroadcastReceiptRepository는 공지 수신 확인 엔티티의 지속성을 담당하는 포트입니다.
type BroadcastReceiptRepository interface {
	Save(ctx context.Context, receipt *domain.BroadcastReceipt) error
	GetByMessageAndTrack(ctx context.Context, msgID domain.MessageID, trackID domain.TrackID) (*domain.BroadcastReceipt, error)
	ListByMessage(ctx context.Context, msgID domain.MessageID) ([]*domain.BroadcastReceipt, error)
}

// AuditLogRepository는 감사 로그 엔티티의 지속성을 담당하는 포트입니다.
type AuditLogRepository interface {
	Save(ctx context.Context, log *domain.AuditLog) error
}

type NotificationEvent string

const (
	EventTracksUpdated            NotificationEvent = "tracks_updated"
	EventTrackUpdated             NotificationEvent = "track_updated"
	EventCornersUpdated           NotificationEvent = "corners_updated"
	EventGroupsUpdated            NotificationEvent = "groups_updated"
	EventCampUpdated              NotificationEvent = "camp_updated"
	EventMessagesChanged          NotificationEvent = "messages_changed"
	EventTrackDeleted             NotificationEvent = "track_deleted"
	EventSessionRevoked           NotificationEvent = "session_revoked"
	EventCampEnded                NotificationEvent = "camp_ended"
	EventDeviceRegistrationUpdated NotificationEvent = "device_registration_updated"
	EventLockoutAlert             NotificationEvent = "lockout_alert"
)

// Broadcaster는 트랜잭션 성공 후 SSE 클라이언트에게 실시간 알림을 푸시하는 포트입니다.
type Broadcaster interface {
	Broadcast(ctx context.Context, campID domain.CampID, event NotificationEvent, scope string) error
}

// ReportQuerier는 캠프 종료 시 사후 통계 집계를 담당하는 포트입니다.
type ReportQuerier interface {
	QueryCampReport(ctx context.Context, campID domain.CampID) (*CampReport, error)
}

// CampReport는 캠프 전체 결과 집계 DTO입니다.
type CampReport struct {
	CampID          domain.CampID
	TotalGroups     int
	FinishedGroups  int
	TotalVisits     int
	CompletedVisits int
	ManualVisits    int
	CornerReports   []CornerReport
	GroupReports    []GroupReport
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
	GroupID        domain.GroupID
	GroupName      string
	IsFinished     bool
	CompletedCount int
	VisitDetails   []VisitDetail
}

// VisitDetail은 조의 코너별 방문 상세 정보 DTO입니다.
type VisitDetail struct {
	CornerID     domain.CornerID
	DurationSec  int
	DeviationSec int
}
