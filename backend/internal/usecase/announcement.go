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
	nowFn         func() time.Time
	uuidFn        func() string
}

func NewAnnouncementService(announcements AnnouncementRepository, receipts AnnouncementReceiptRepository, camps CampRepository, tracks TrackRepository, sessions FacilitatorSessionRepository, tx TxManager) *AnnouncementService {
	return &AnnouncementService{announcements: announcements, receipts: receipts, camps: camps, tracks: tracks, sessions: sessions, tx: tx, nowFn: func() time.Time { return time.Now().UTC() }, uuidFn: uuid.NewString}
}

func (s *AnnouncementService) SendAnnouncement(ctx context.Context, campID domain.CampID, content string, actorAdminID domain.AdminID) (*domain.Announcement, error) {
	camp, err := s.camps.Get(ctx, campID)
	if err != nil {
		return nil, err
	}
	if camp == nil || !camp.IsActive() {
		return nil, domain.ErrCampInvalidTransition
	}
	a := &domain.Announcement{ID: domain.AnnouncementID(s.uuidFn()), CampID: campID, SenderRole: domain.RoleAdmin, Content: content, SentAt: s.nowFn()}
	active, err := s.tracks.ListActiveByCamp(ctx, campID)
	if err != nil {
		return nil, err
	}
	err = s.tx.RunInTx(ctx, func(ctx context.Context) error {
		if err := s.announcements.Save(ctx, a); err != nil {
			return err
		}
		for _, t := range active {
			if err := s.receipts.Save(ctx, &domain.AnnouncementReceipt{NoticeID: a.ID, TrackID: t.ID, ReadAt: domain.None[time.Time]()}); err != nil {
				return err
			}
		}
		return nil
	})
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
	r, err := s.receipts.GetByMessageAndTrack(ctx, noticeID, session.TrackID)
	if err != nil || r == nil {
		return err
	}
	if err := r.MarkRead(s.nowFn()); err != nil {
		return err
	}
	return s.receipts.Save(ctx, r)
}
