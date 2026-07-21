package usecase

import (
	"context"
	"cornermon/backend/internal/domain"
	"errors"
	"testing"
	"time"
)

func TestAnnouncementService_SendAnnouncement(t *testing.T) {
	// Arrange
	camps := NewMockCampRepository()
	_ = camps.Save(context.Background(), domain.NewCampFromProps(domain.CampProps{ID: "camp-1", Status: domain.CampActive}))
	tracks := NewMockTrackRepository()
	_ = tracks.Save(context.Background(), domain.NewTrackFromProps(domain.TrackProps{ID: "track-1", Status: domain.TrackActive}))
	repo := NewMockAnnouncementRepository()
	receipts := NewMockAnnouncementReceiptRepository()
	broadcaster := &MockBroadcaster{}
	s := NewAnnouncementService(repo, receipts, camps, tracks, NewMockFacilitatorSessionRepository(), &MockTxManager{}, &MockAuditLogRepository{}, broadcaster)
	s.uuidFn = func() string { return "announcement-1" }
	s.nowFn = func() time.Time { return time.Date(2026, 7, 14, 0, 0, 0, 0, time.UTC) }

	// Act
	a, err := s.SendAnnouncement(context.Background(), "camp-1", "notice", "admin-1")

	// Assert
	if err != nil || a.ID() != "announcement-1" {
		t.Fatalf("SendAnnouncement() = %v, %v", a, err)
	}
	if len(receipts.Receipts) != 1 {
		t.Fatalf("receipts = %d, want 1", len(receipts.Receipts))
	}
	if len(broadcaster.Broadcasts) != 1 || broadcaster.Broadcasts[0].Scope != CampScope() {
		t.Fatalf("broadcasts = %#v", broadcaster.Broadcasts)
	}
}

func TestAnnouncementQueryService_ShouldReturnTrackReceiptStateWhenTrackBelongsToCamp(t *testing.T) {
	// Arrange
	tracks := NewMockTrackRepository()
	corners := NewMockCornerRepository()
	_ = tracks.Save(context.Background(), domain.NewTrackFromProps(domain.TrackProps{ID: "track-1", CornerID: "corner-1", Status: domain.TrackActive}))
	_ = corners.Save(context.Background(), domain.NewCornerFromProps(domain.CornerProps{ID: "corner-1", CampID: "camp-1", Name: "corner"}))
	readAt := time.Date(2026, 7, 20, 1, 2, 3, 0, time.UTC)
	querier := &MockAnnouncementQuerier{Views: []BroadcastNoticeView{
		{Announcement: domain.NewAnnouncementFromProps(domain.AnnouncementProps{ID: "unread", CampID: "camp-1"}), ReadAt: domain.None[time.Time]()},
		{Announcement: domain.NewAnnouncementFromProps(domain.AnnouncementProps{ID: "read", CampID: "camp-1"}), ReadAt: domain.Some(readAt)},
	}}
	service := NewAnnouncementQueryService(querier, tracks, corners)

	// Act
	views, err := service.ListNoticesForTrack(context.Background(), "camp-1", "track-1")

	// Assert
	if err != nil || len(views) != 2 {
		t.Fatalf("ListNoticesForTrack() = %#v, %v", views, err)
	}
	if views[0].ReadAt.IsSet() || !views[1].ReadAt.IsSet() || querier.ListViewsCallCnt != 1 {
		t.Fatalf("views = %#v, calls = %d", views, querier.ListViewsCallCnt)
	}
}

func TestAnnouncementQueryService_ShouldRejectBroadcastQueryWhenTrackIsOutsideCamp(t *testing.T) {
	// Arrange
	tracks := NewMockTrackRepository()
	corners := NewMockCornerRepository()
	_ = tracks.Save(context.Background(), domain.NewTrackFromProps(domain.TrackProps{ID: "track-1", CornerID: "corner-1", Status: domain.TrackActive}))
	_ = corners.Save(context.Background(), domain.NewCornerFromProps(domain.CornerProps{ID: "corner-1", CampID: "camp-2", Name: "corner"}))
	querier := &MockAnnouncementQuerier{}
	service := NewAnnouncementQueryService(querier, tracks, corners)

	// Act
	_, err := service.ListNoticesForTrack(context.Background(), "camp-1", "track-1")

	// Assert
	if !errors.Is(err, domain.ErrTrackScopeForbidden) {
		t.Fatalf("ListNoticesForTrack() error = %v, want %v", err, domain.ErrTrackScopeForbidden)
	}
	if querier.ListViewsCallCnt != 0 {
		t.Fatalf("query calls = %d, want 0", querier.ListViewsCallCnt)
	}
}

func TestAnnouncementService_ShouldPreserveFirstReadAtWhenNoticeIsMarkedReadTwice(t *testing.T) {
	// Arrange
	receipts := NewMockAnnouncementReceiptRepository()
	receipt := domain.NewAnnouncementReceiptFromProps(domain.AnnouncementReceiptProps{NoticeID: "notice-1", TrackID: "track-1", ReadAt: domain.None[time.Time]()})
	_ = receipts.Save(context.Background(), receipt)
	sessions := NewMockFacilitatorSessionRepository()
	const token = "facilitator-token"
	_ = sessions.Save(context.Background(), domain.NewFacilitatorSessionFromProps(domain.FacilitatorSessionProps{ID: "session-1", TrackID: "track-1", TokenHash: hashSHA256(token)}))
	service := NewAnnouncementService(NewMockAnnouncementRepository(), receipts, NewMockCampRepository(), NewMockTrackRepository(), sessions, &MockTxManager{}, nil, nil)
	firstReadAt := time.Date(2026, 7, 20, 1, 2, 3, 0, time.UTC)
	service.nowFn = func() time.Time { return firstReadAt }

	// Act
	if err := service.MarkNoticeRead(context.Background(), token, "notice-1"); err != nil {
		t.Fatalf("first MarkNoticeRead() error = %v", err)
	}
	service.nowFn = func() time.Time { return firstReadAt.Add(time.Hour) }
	if err := service.MarkNoticeRead(context.Background(), token, "notice-1"); err != nil {
		t.Fatalf("second MarkNoticeRead() error = %v", err)
	}

	// Assert
	readAt, ok := receipt.ReadAt().Value()
	if !ok || !readAt.Equal(firstReadAt) {
		t.Fatalf("receipt.ReadAt() = %v, %v; want %v", readAt, ok, firstReadAt)
	}
}
