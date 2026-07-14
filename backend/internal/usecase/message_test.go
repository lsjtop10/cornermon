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

		corners := NewMockCornerRepository()
		messages := NewMockMessageRepository()
		receipts := NewMockBroadcastReceiptRepository()
		sessions := NewMockFacilitatorSessionRepository()
		auditLogs := &MockAuditLogRepository{}
		broadcaster := &MockBroadcaster{}
		tx := &MockTxManager{}

		s := NewMessageService(camps, corners, tracks, messages, receipts, sessions, auditLogs, broadcaster, tx)
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
		if campID, ok := msg.CampID.Value(); !ok || campID != "camp-1" {
			t.Errorf("expected broadcast CampID 'camp-1', got %q (set=%t)", campID, ok)
		}

		if len(receipts.Receipts) != 2 {
			t.Errorf("expected 2 receipts to be saved, got %d", len(receipts.Receipts))
		}

		if len(broadcaster.Broadcasts) != 1 ||
			broadcaster.Broadcasts[0].CampID != "camp-1" ||
			broadcaster.Broadcasts[0].Event != EventMessagesChanged ||
			broadcaster.Broadcasts[0].Scope != CampScope() {
			t.Errorf("expected EventMessagesChanged broadcast with scope 'broadcast', got %v", broadcaster.Broadcasts)
		}
	})
}

func TestMessageService_ListBroadcastsByCamp(t *testing.T) {
	t.Run("ShouldReturnOnlyMessagesForRequestedCampInSentAtOrder", func(t *testing.T) {
		// Arrange
		messages := NewMockMessageRepository()
		messages.Save(context.Background(), &domain.Message{
			ID:          "message-camp-b",
			ChannelType: domain.MessageBroadcast,
			CampID:      domain.Some(domain.CampID("camp-b")),
			TrackID:     domain.None[domain.TrackID](),
			SentAt:      time.Date(2026, 7, 14, 9, 0, 0, 0, time.UTC),
		})
		messages.Save(context.Background(), &domain.Message{
			ID:          "message-camp-a-later",
			ChannelType: domain.MessageBroadcast,
			CampID:      domain.Some(domain.CampID("camp-a")),
			TrackID:     domain.None[domain.TrackID](),
			SentAt:      time.Date(2026, 7, 14, 11, 0, 0, 0, time.UTC),
		})
		messages.Save(context.Background(), &domain.Message{
			ID:          "message-camp-a-earlier",
			ChannelType: domain.MessageBroadcast,
			CampID:      domain.Some(domain.CampID("camp-a")),
			TrackID:     domain.None[domain.TrackID](),
			SentAt:      time.Date(2026, 7, 14, 10, 0, 0, 0, time.UTC),
		})

		s := &MessageService{messages: messages}

		// Act
		result, err := s.ListBroadcastsByCamp(context.Background(), "camp-a")

		// Assert
		if err != nil {
			t.Fatalf("expected no error, got %v", err)
		}
		if len(result) != 2 {
			t.Fatalf("expected 2 camp-a messages, got %d", len(result))
		}
		if result[0].ID != "message-camp-a-earlier" || result[1].ID != "message-camp-a-later" {
			t.Errorf("expected camp-a messages in sent_at order, got %q then %q", result[0].ID, result[1].ID)
		}
	})
}

func TestMessageService_SendDirect(t *testing.T) {
	t.Run("ShouldSendDirectSuccessfullyAndNotify", func(t *testing.T) {
		// Arrange
		now := time.Now()
		camps := NewMockCampRepository()
		camp := &domain.Camp{ID: "camp-1", Status: domain.CampActive}
		camps.Save(context.Background(), camp)

		corners := NewMockCornerRepository()
		corner := &domain.Corner{ID: "corner-1", CampID: "camp-1"}
		corners.Save(context.Background(), corner)

		tracks := NewMockTrackRepository()
		track := &domain.Track{ID: "track-1", CornerID: "corner-1", Status: domain.TrackActive}
		tracks.Save(context.Background(), track)

		messages := NewMockMessageRepository()
		receipts := NewMockBroadcastReceiptRepository()
		sessions := NewMockFacilitatorSessionRepository()
		auditLogs := &MockAuditLogRepository{}
		broadcaster := &MockBroadcaster{}
		tx := &MockTxManager{}

		s := NewMessageService(camps, corners, tracks, messages, receipts, sessions, auditLogs, broadcaster, tx)
		s.nowFn = func() time.Time { return now }
		s.uuidFn = func() string { return "msg-uuid" }

		// Act
		msg, err := s.SendDirect(context.Background(), "track-1", "Hello Track", domain.RoleAdmin)

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

		if len(broadcaster.Broadcasts) != 1 ||
			broadcaster.Broadcasts[0].CampID != "camp-1" ||
			broadcaster.Broadcasts[0].Event != EventMessagesChanged ||
			broadcaster.Broadcasts[0].Scope != TrackScope("track-1") {
			t.Errorf("expected EventMessagesChanged broadcast with scope 'track:track-1', got %v", broadcaster.Broadcasts)
		}
	})
}
