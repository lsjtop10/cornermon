package usecase

import (
	"context"
	"testing"
	"time"

	"cornermon/backend/internal/domain"
)

func TestMessageService_SendDirect(t *testing.T) {
	t.Run("ShouldSendDirectSuccessfullyAndNotify", func(t *testing.T) {
		// Arrange
		now := time.Now()
		corners := NewMockCornerRepository()
		corner := &domain.Corner{ID: "corner-1", CampID: "camp-1"}
		corners.Save(context.Background(), corner)

		tracks := NewMockTrackRepository()
		track := &domain.Track{ID: "track-1", CornerID: "corner-1", Status: domain.TrackActive}
		tracks.Save(context.Background(), track)

		messages := NewMockMessageRepository()
		auditLogs := &MockAuditLogRepository{}
		broadcaster := &MockBroadcaster{}
		tx := &MockTxManager{}

		s := NewMessageService(corners, tracks, messages, auditLogs, broadcaster, tx)
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

func TestShouldMarkOnlyOppositeMessagesWhenBackgroundIsTrue(t *testing.T) {
	// Arrange
	tracks := NewMockTrackRepository()
	tracks.Save(context.Background(), &domain.Track{ID: "track-1", Status: domain.TrackActive})
	messages := NewMockMessageRepository()
	adminMessage := &domain.Message{ID: "admin-1", TrackID: "track-1", ChannelType: domain.MessageDirect, SenderRole: domain.RoleAdmin, SentAt: time.Unix(1, 0)}
	trackMessage := &domain.Message{ID: "track-1", TrackID: "track-1", ChannelType: domain.MessageDirect, SenderRole: domain.RoleTrack, SentAt: time.Unix(2, 0)}
	messages.Save(context.Background(), adminMessage)
	messages.Save(context.Background(), trackMessage)
	s := NewMessageService(NewMockCornerRepository(), tracks, messages, &MockAuditLogRepository{}, &MockBroadcaster{}, &MockTxManager{})
	now := time.Unix(10, 0)
	s.nowFn = func() time.Time { return now }

	// Act
	got, err := s.ListDirectMessages(context.Background(), "track-1", domain.RoleTrack, domain.None[time.Time](), true)

	// Assert
	if err != nil {
		t.Fatalf("expected no error, got %v", err)
	}
	if len(got) != 2 {
		t.Fatalf("expected 2 messages, got %d", len(got))
	}
	if !adminMessage.ReadAt.IsSet() || trackMessage.ReadAt.IsSet() {
		t.Fatal("expected only the opposite sender message to be marked read")
	}
	if value, _ := adminMessage.ReadAt.Value(); !value.Equal(now) {
		t.Fatalf("expected admin message read at %v, got %v", now, value)
	}
}

func TestShouldReturnRoleSpecificUnreadCountWhenTrackHasUnreadMessages(t *testing.T) {
	// Arrange
	tracks := NewMockTrackRepository()
	tracks.Save(context.Background(), &domain.Track{ID: "track-1", Status: domain.TrackActive, UnreadByAdminCount: 2, UnreadByTrackCount: 3})
	s := NewMessageService(NewMockCornerRepository(), tracks, NewMockMessageRepository(), &MockAuditLogRepository{}, &MockBroadcaster{}, &MockTxManager{})

	// Act
	adminCount, adminErr := s.GetUnreadCount(context.Background(), "track-1", domain.RoleAdmin)
	trackCount, trackErr := s.GetUnreadCount(context.Background(), "track-1", domain.RoleTrack)

	// Assert
	if adminErr != nil || trackErr != nil {
		t.Fatalf("expected no errors, got %v and %v", adminErr, trackErr)
	}
	if adminCount != 2 || trackCount != 3 {
		t.Fatalf("expected role-specific counts 2 and 3, got %d and %d", adminCount, trackCount)
	}
}
