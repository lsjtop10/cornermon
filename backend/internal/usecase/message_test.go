package usecase

import (
	"context"
	"testing"
	"time"

	"cornermon/backend/internal/domain"
)

func TestMessageService_SendBroadcast(t *testing.T) {
	t.Run("ShouldSendBroadcastSuccessfullyWhenCampIsActive", func(t *testing.T) {
		// Arrange
		now := time.Now()
		camps := NewMockCampRepository()
		camp := &domain.Camp{ID: "camp-1", Status: domain.CampActive}
		camps.Save(context.Background(), camp)

		tracks := NewMockTrackRepository()
		track1 := &domain.Track{ID: "track-1", CornerID: "corner-1", Status: domain.TrackActive}
		track2 := &domain.Track{ID: "track-2", CornerID: "corner-2", Status: domain.TrackActive}
		tracks.Save(context.Background(), track1)
		tracks.Save(context.Background(), track2)

		messages := NewMockMessageRepository()
		receipts := NewMockBroadcastReceiptRepository()
		sessions := NewMockFacilitatorSessionRepository()
		auditLogs := &MockAuditLogRepository{}
		broadcaster := &MockBroadcaster{}
		tx := &MockTxManager{}

		s := NewMessageService(camps, tracks, messages, receipts, sessions, auditLogs, broadcaster, tx)
		s.nowFn = func() time.Time { return now }
		s.uuidFn = func() string { return "msg-uuid" }

		// Act
		msg, err := s.SendBroadcast(context.Background(), "camp-1", "Notice content", "admin-1")

		// Assert
		if err != nil {
			t.Fatalf("expected no error, got %v", err)
		}
		if msg == nil {
			t.Fatal("expected message, got nil")
		}
		if msg.ID != "msg-uuid" {
			t.Errorf("expected message ID 'msg-uuid', got '%s'", msg.ID)
		}

		if len(receipts.Receipts) != 2 {
			t.Errorf("expected 2 receipts to be saved, got %d", len(receipts.Receipts))
		}
	})
}
