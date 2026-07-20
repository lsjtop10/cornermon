package usecase

import (
	"context"
	"cornermon/backend/internal/domain"
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
	s := NewAnnouncementService(repo, receipts, camps, NewMockCornerRepository(), tracks, NewMockFacilitatorSessionRepository(), &MockTxManager{}, &MockAuditLogRepository{}, broadcaster)
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
