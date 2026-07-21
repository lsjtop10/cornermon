package usecase

import (
	"context"
	"time"

	"cornermon/backend/internal/domain"
	"github.com/google/uuid"
)

// AnnouncementService owns camp-wide notices and their per-track read state.
type AnnouncementService struct {
	announcements AnnouncementRepository
	receipts      AnnouncementReceiptRepository
	camps         CampRepository
	tracks        TrackRepository
	sessions      FacilitatorSessionRepository
	tx            TxManager
	auditLogs     AuditLogRepository
	broadcaster   Broadcaster
	nowFn         func() time.Time
	uuidFn        func() string
}

func NewAnnouncementService(announcements AnnouncementRepository, receipts AnnouncementReceiptRepository, camps CampRepository, tracks TrackRepository, sessions FacilitatorSessionRepository, tx TxManager, auditLogs AuditLogRepository, broadcaster Broadcaster) *AnnouncementService {
	return &AnnouncementService{announcements: announcements, receipts: receipts, camps: camps, tracks: tracks, sessions: sessions, tx: tx, auditLogs: auditLogs, broadcaster: broadcaster, nowFn: func() time.Time { return time.Now().UTC() }, uuidFn: uuid.NewString}
}

func (s *AnnouncementService) SendAnnouncement(ctx context.Context, campID domain.CampID, content string, actorAdminID domain.AdminID) (*domain.Announcement, error) {
	camp, err := s.camps.Get(ctx, campID)
	if err != nil {
		return nil, err
	}
	if camp == nil || !camp.IsActive() {
		return nil, domain.ErrCampInvalidTransition
	}
	a := domain.NewAnnouncementFromProps(domain.AnnouncementProps{ID: domain.AnnouncementID(s.uuidFn()), CampID: campID, SenderRole: domain.RoleAdmin, Content: content, SentAt: s.nowFn()})
	active, err := s.tracks.ListActiveByCamp(ctx, campID)
	if err != nil {
		return nil, err
	}
	err = s.tx.RunInTx(ctx, func(ctx context.Context) error {
		if err := s.announcements.Save(ctx, a); err != nil {
			return err
		}
		for _, t := range active {
			if err := s.receipts.Save(ctx, domain.NewAnnouncementReceiptFromProps(domain.AnnouncementReceiptProps{NoticeID: a.ID(), TrackID: t.ID(), ReadAt: domain.None[time.Time]()})); err != nil {
				return err
			}
		}
		return nil
	})
	if err != nil && s.auditLogs != nil {
		_ = s.auditLogs.Save(ctx, domain.NewAuditLog(domain.AuditLogID(s.uuidFn()), string(actorAdminID), string(ActionMessageBroadcast), "", false, s.nowFn(), map[string]any{"error": err.Error()}))
	}
	if err == nil && s.auditLogs != nil {
		_ = s.auditLogs.Save(ctx, domain.NewAuditLog(domain.AuditLogID(s.uuidFn()), string(actorAdminID), string(ActionMessageBroadcast), string(a.ID()), true, s.nowFn(), map[string]any{"campID": string(campID)}))
	}
	if err == nil && s.broadcaster != nil {
		_ = s.broadcaster.Broadcast(ctx, campID, EventMessagesChanged, CampScope())
	}
	return a, err
}

func (s *AnnouncementService) MarkNoticeRead(ctx context.Context, facilitatorToken string, noticeID domain.AnnouncementID) error {
	session, err := s.sessions.GetByTokenHash(ctx, hashSHA256(facilitatorToken))
	if err != nil {
		return err
	}
	if session == nil || !session.IsActive() {
		return domain.ErrSessionRevoked
	}
	r, err := s.receipts.GetByMessageAndTrack(ctx, noticeID, session.TrackID())
	if err != nil || r == nil {
		return err
	}
	if err := r.MarkRead(s.nowFn()); err != nil {
		return err
	}
	return s.receipts.Save(ctx, r)
}

// BroadcastNoticeView combines a broadcast with the authenticated track's
// receipt state for a read-only response.
type BroadcastNoticeView struct {
	Announcement *domain.Announcement
	ReadAt       domain.Optional[time.Time]
}

// AnnouncementQueryService owns announcement read use cases and never mutates
// announcement or receipt state.
type AnnouncementQueryService struct {
	announcements AnnouncementQuerier
	tracks        TrackRepository
	corners       CornerRepository
}

func NewAnnouncementQueryService(announcements AnnouncementQuerier, tracks TrackRepository, corners CornerRepository) *AnnouncementQueryService {
	return &AnnouncementQueryService{announcements: announcements, tracks: tracks, corners: corners}
}

func (s *AnnouncementQueryService) ListNoticesByCamp(ctx context.Context, campID domain.CampID) ([]*domain.Announcement, error) {
	return s.announcements.ListNoticesByCamp(ctx, campID)
}

func (s *AnnouncementQueryService) ListNoticesForTrack(ctx context.Context, campID domain.CampID, trackID domain.TrackID) ([]BroadcastNoticeView, error) {
	track, err := s.tracks.Get(ctx, trackID)
	if err != nil {
		return nil, err
	}
	if track == nil {
		return nil, domain.ErrTrackScopeForbidden
	}
	corner, err := s.corners.Get(ctx, track.CornerID())
	if err != nil {
		return nil, err
	}
	if corner == nil || corner.CampID() != campID {
		return nil, domain.ErrTrackScopeForbidden
	}
	return s.announcements.ListNoticeViewsByCampAndTrack(ctx, campID, trackID)
}

func (s *AnnouncementQueryService) GetAnnouncementReceipts(ctx context.Context, announcementID domain.AnnouncementID) ([]BroadcastReceiptDTO, error) {
	return s.announcements.ListAnnouncementReceipts(ctx, announcementID)
}
