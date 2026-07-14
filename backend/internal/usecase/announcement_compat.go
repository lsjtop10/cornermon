package usecase

import (
	"context"
	"cornermon/backend/internal/domain"
)

// Legacy adapters keep the existing HTTP-facing MessageService constructor/API
// stable while making AnnouncementService the owner of announcement behavior.
type legacyAnnouncementRepository struct{ repo MessageRepository }

func (r legacyAnnouncementRepository) Save(ctx context.Context, a *domain.Announcement) error {
	return r.repo.Save(ctx, &domain.Message{ID: domain.MessageID(a.ID), ChannelType: domain.MessageBroadcast, CampID: domain.Some(a.CampID), SenderRole: a.SenderRole, Content: a.Content, SentAt: a.SentAt})
}
func (r legacyAnnouncementRepository) ListNoticeByCamp(ctx context.Context, campID domain.CampID) ([]*domain.Announcement, error) {
	rows, ok := r.repo.(LegacyMessageReader)
	if !ok {
		return nil, nil
	}
	msgs, err := rows.ListBroadcastsByCamp(ctx, campID)
	if err != nil {
		return nil, err
	}
	out := make([]*domain.Announcement, len(msgs))
	for i, m := range msgs {
		out[i] = &domain.Announcement{ID: domain.AnnouncementID(m.ID), CampID: campID, SenderRole: m.SenderRole, Content: m.Content, SentAt: m.SentAt}
	}
	return out, nil
}

type legacyAnnouncementReceiptRepository struct{ repo BroadcastReceiptRepository }

func (r legacyAnnouncementReceiptRepository) Save(ctx context.Context, x *domain.AnnouncementReceipt) error {
	return r.repo.Save(ctx, &domain.BroadcastReceipt{MessageID: domain.MessageID(x.NoticeID), TrackID: x.TrackID, ReadAt: x.ReadAt})
}
func (r legacyAnnouncementReceiptRepository) GetByMessageAndTrack(ctx context.Context, id domain.AnnouncementID, track domain.TrackID) (*domain.AnnouncementReceipt, error) {
	x, err := r.repo.GetByMessageAndTrack(ctx, domain.MessageID(id), track)
	if x == nil || err != nil {
		return nil, err
	}
	return &domain.AnnouncementReceipt{NoticeID: id, TrackID: x.TrackID, ReadAt: x.ReadAt}, nil
}
func (r legacyAnnouncementReceiptRepository) ListByMessage(ctx context.Context, id domain.AnnouncementID) ([]*domain.AnnouncementReceipt, error) {
	xs, err := r.repo.ListByMessage(ctx, domain.MessageID(id))
	if err != nil {
		return nil, err
	}
	out := make([]*domain.AnnouncementReceipt, len(xs))
	for i, x := range xs {
		out[i] = &domain.AnnouncementReceipt{NoticeID: id, TrackID: x.TrackID, ReadAt: x.ReadAt}
	}
	return out, nil
}

func announcementAsMessage(a *domain.Announcement) *domain.Message {
	return &domain.Message{ID: domain.MessageID(a.ID), ChannelType: domain.MessageBroadcast, CampID: domain.Some(a.CampID), SenderRole: a.SenderRole, Content: a.Content, SentAt: a.SentAt}
}
