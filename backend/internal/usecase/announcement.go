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
	corners       CornerRepository
	sessions      FacilitatorSessionRepository
	tx            TxManager
	auditLogs     AuditLogRepository
	broadcaster   Broadcaster
	nowFn         func() time.Time
	uuidFn        func() string
}

func NewAnnouncementService(announcements AnnouncementRepository, receipts AnnouncementReceiptRepository, camps CampRepository, corners CornerRepository, tracks TrackRepository, sessions FacilitatorSessionRepository, tx TxManager, auditLogs AuditLogRepository, broadcaster Broadcaster) *AnnouncementService {
	return &AnnouncementService{announcements: announcements, receipts: receipts, camps: camps, corners: corners, tracks: tracks, sessions: sessions, tx: tx, auditLogs: auditLogs, broadcaster: broadcaster, nowFn: func() time.Time { return time.Now().UTC() }, uuidFn: uuid.NewString}
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
		_ = s.auditLogs.Save(ctx, domain.NewAuditLog(domain.AuditLogID(s.uuidFn()), string(actorAdminID), "MESSAGE_BROADCAST", "", false, s.nowFn(), map[string]any{"error": err.Error()}))
	}
	if err == nil && s.auditLogs != nil {
		_ = s.auditLogs.Save(ctx, domain.NewAuditLog(domain.AuditLogID(s.uuidFn()), string(actorAdminID), "MESSAGE_BROADCAST", string(a.ID()), true, s.nowFn(), map[string]any{"campID": string(campID)}))
	}
	if err == nil && s.broadcaster != nil {
		_ = s.broadcaster.Broadcast(ctx, campID, EventMessagesChanged, CampScope())
	}
	return a, err
}

func (s *AnnouncementService) ListNoticesByCamp(ctx context.Context, campID domain.CampID) ([]*domain.Announcement, error) {
	return s.announcements.ListNoticeByCamp(ctx, campID)
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

func (s *AnnouncementService) GetAnnouncementReceipts(ctx context.Context, announcementID domain.AnnouncementID) ([]BroadcastReceiptDTO, error) {
	receipts, err := s.receipts.ListByMessage(ctx, announcementID)
	if err != nil {
		return nil, err
	}
	result := make([]BroadcastReceiptDTO, len(receipts))
	for i, receipt := range receipts {
		track, err := s.tracks.Get(ctx, receipt.TrackID())
		if err != nil {
			return nil, err
		}
		var trackNo int
		var cornerName string
		if track != nil {
			trackNo = track.TrackNo()
			corner, err := s.corners.Get(ctx, track.CornerID())
			if err != nil {
				return nil, err
			}
			if corner != nil {
				cornerName = corner.Name()
			}
		}
		result[i] = BroadcastReceiptDTO{TrackID: receipt.TrackID(), TrackNo: trackNo, CornerName: cornerName, IsRead: receipt.ReadAt().IsSet(), ReadAt: receipt.ReadAt()}
	}
	return result, nil
}
