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
		return nil, withErrorContext("announcement.send", "repository.get_camp", err, map[string]any{"camp_id": string(campID)})
	}
	if camp == nil || !camp.IsActive() {
		var status string
		if camp != nil {
			status = string(camp.Status())
		}
		return nil, withErrorContext("announcement.send", "validate_camp", domain.ErrCampInvalidTransition, map[string]any{"camp_id": string(campID), "camp_found": camp != nil, "camp_status": status})
	}
	a := domain.NewAnnouncementFromProps(domain.AnnouncementProps{ID: domain.AnnouncementID(s.uuidFn()), CampID: campID, SenderRole: domain.RoleAdmin, Content: content, SentAt: s.nowFn()})
	active, err := s.tracks.ListActiveByCamp(ctx, campID)
	if err != nil {
		return nil, withErrorContext("announcement.send", "repository.list_active_tracks", err, map[string]any{"camp_id": string(campID)})
	}
	err = s.tx.RunInTx(ctx, func(ctx context.Context) error {
		if err := s.announcements.Save(ctx, a); err != nil {
			return withErrorContext("announcement.send", "repository.save_announcement", err, map[string]any{"announcement_id": string(a.ID())})
		}
		for _, t := range active {
			if err := s.receipts.Save(ctx, domain.NewAnnouncementReceiptFromProps(domain.AnnouncementReceiptProps{NoticeID: a.ID(), TrackID: t.ID(), ReadAt: domain.None[time.Time]()})); err != nil {
				return withErrorContext("announcement.send", "repository.save_receipt", err, map[string]any{"announcement_id": string(a.ID()), "track_id": string(t.ID())})
			}
		}
		return nil
	})
	if err != nil && s.auditLogs != nil {
		_ = s.auditLogs.Save(ctx, domain.NewAuditLogFromProps(domain.AuditLogProps{
			ID:         domain.AuditLogID(s.uuidFn()),
			Actor:      string(actorAdminID),
			Action:     string(ActionMessageBroadcast),
			Target:     "",
			Success:    false,
			OccurredAt: s.nowFn(),
			Metadata:   errorAuditMetadata(err, nil),
		}))
	}
	if err == nil && s.auditLogs != nil {
		_ = s.auditLogs.Save(ctx, domain.NewAuditLogFromProps(domain.AuditLogProps{
			ID:         domain.AuditLogID(s.uuidFn()),
			Actor:      string(actorAdminID),
			Action:     string(ActionMessageBroadcast),
			Target:     string(a.ID()),
			Success:    true,
			OccurredAt: s.nowFn(),
			Metadata:   map[string]any{"campID": string(campID)},
		}))
	}
	if err == nil && s.broadcaster != nil {
		_ = s.broadcaster.Broadcast(ctx, campID, EventMessagesChanged, CampScope())
	}
	return a, err
}

func (s *AnnouncementService) MarkNoticeRead(ctx context.Context, facilitatorToken string, noticeID domain.AnnouncementID) error {

	session, err := s.sessions.GetByTokenHash(ctx, hashSHA256(facilitatorToken))
	if err != nil {
		return withErrorContext("announcement.mark_read", "repository.get_session", err, nil)
	}
	if session == nil || !session.IsActive() {
		var active bool
		if session != nil {
			active = session.IsActive()
		}
		return withErrorContext("announcement.mark_read", "validate_session", domain.ErrSessionRevoked, map[string]any{"session_found": session != nil, "session_active": active})
	}
	r, err := s.receipts.GetByMessageAndTrack(ctx, noticeID, session.TrackID())
	if err != nil || r == nil {
		return withErrorContext("announcement.mark_read", "repository.get_receipt", err, map[string]any{"notice_id": string(noticeID), "track_id": string(session.TrackID()), "receipt_found": r != nil})
	}
	if err := r.MarkRead(s.nowFn()); err != nil {
		return withErrorContext("announcement.mark_read", "domain.mark_read", err, map[string]any{"notice_id": string(noticeID), "track_id": string(session.TrackID())})
	}
	if err := s.receipts.Save(ctx, r); err != nil {
		return withErrorContext("announcement.mark_read", "repository.save_receipt", err, map[string]any{"notice_id": string(noticeID), "track_id": string(session.TrackID())})
	}
	return nil
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

	notices, err := s.announcements.ListNoticesByCamp(ctx, campID)
	if err != nil {
		return nil, withErrorContext("announcement.list_by_camp", "repository.list_notices", err, map[string]any{"camp_id": string(campID)})
	}
	return notices, nil
}

func (s *AnnouncementQueryService) ListNoticesForTrack(ctx context.Context, campID domain.CampID, trackID domain.TrackID) ([]BroadcastNoticeView, error) {

	track, err := s.tracks.Get(ctx, trackID)
	if err != nil {
		return nil, withErrorContext("announcement.list_for_track", "repository.get_track", err, map[string]any{"track_id": string(trackID)})
	}
	if track == nil {
		return nil, withErrorContext("announcement.list_for_track", "validate_track", domain.ErrTrackScopeForbidden, map[string]any{"track_id": string(trackID), "track_found": false})
	}
	corner, err := s.corners.Get(ctx, track.CornerID())
	if err != nil {
		return nil, withErrorContext("announcement.list_for_track", "repository.get_corner", err, map[string]any{"corner_id": string(track.CornerID())})
	}
	if corner == nil || corner.CampID() != campID {
		var cCamp string
		if corner != nil {
			cCamp = string(corner.CampID())
		}
		return nil, withErrorContext("announcement.list_for_track", "validate_corner_camp", domain.ErrTrackScopeForbidden, map[string]any{"corner_found": corner != nil, "corner_camp_id": cCamp, "req_camp_id": string(campID)})
	}
	views, err := s.announcements.ListNoticeViewsByCampAndTrack(ctx, campID, trackID)
	if err != nil {
		return nil, withErrorContext("announcement.list_for_track", "repository.list_notice_views", err, map[string]any{"camp_id": string(campID), "track_id": string(trackID)})
	}
	return views, nil
}

func (s *AnnouncementQueryService) GetAnnouncementReceipts(ctx context.Context, announcementID domain.AnnouncementID) ([]BroadcastReceiptDTO, error) {

	receipts, err := s.announcements.ListAnnouncementReceipts(ctx, announcementID)
	if err != nil {
		return nil, withErrorContext("announcement.get_receipts", "repository.list_receipts", err, map[string]any{"announcement_id": string(announcementID)})
	}
	return receipts, nil
}
