//go:build ignore

package usecase

import (
	"context"
	"reflect"
	"testing"
	"time"

	"cornermon/backend/internal/domain"
)

type recordingTrackRepository struct {
	*MockTrackRepository
	operations *[]string
}

func (r *recordingTrackRepository) IncrementUnreadCount(ctx context.Context, trackID domain.TrackID, recipient domain.SenderRole) error {
	*r.operations = append(*r.operations, "increment")
	return r.MockTrackRepository.IncrementUnreadCount(ctx, trackID, recipient)
}

func (r *recordingTrackRepository) ResetUnreadCount(ctx context.Context, trackID domain.TrackID, reader domain.SenderRole) error {
	*r.operations = append(*r.operations, "reset")
	return r.MockTrackRepository.ResetUnreadCount(ctx, trackID, reader)
}

type recordingMessageRepository struct {
	*MockMessageRepository
	operations *[]string
}

func (r *recordingMessageRepository) Save(ctx context.Context, msg *domain.Message) error {
	*r.operations = append(*r.operations, "save")
	return r.MockMessageRepository.Save(ctx, msg)
}

func (r *recordingMessageRepository) MarkAllReadByRecipient(ctx context.Context, trackID domain.TrackID, recipient domain.SenderRole, readAt time.Time) error {
	*r.operations = append(*r.operations, "mark-read")
	return r.MockMessageRepository.MarkAllReadByRecipient(ctx, trackID, recipient, readAt)
}

func TestMessageService_SendDirect(t *testing.T) {
	t.Run("ShouldSendDirectSuccessfullyAndNotify", func(t *testing.T) {
		// Arrange
		now := time.Now()
		corners := NewMockCornerRepository()
		corner := domain.NewCornerFromProps(domain.CornerProps{ID: "corner-1", CampID: "camp-1"})
		corners.Save(context.Background(), corner)

		tracks := NewMockTrackRepository()
		track := domain.NewTrackFromProps(domain.TrackProps{ID: "track-1", CornerID: "corner-1", Status: domain.TrackActive})
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
		if msg.ID() != "msg-uuid" {
			t.Errorf("expected message ID 'msg-uuid', got '%s'", msg.ID)
		}
		if track.UnreadByTrackCount() != 1 {
			t.Fatalf("expected one unread message for track, got %d", track.UnreadByTrackCount)
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
	tracks.Save(context.Background(), domain.NewTrackFromProps(domain.TrackProps{ID: "track-1", Status: domain.TrackActive}))
	messages := NewMockMessageRepository()
	adminMessage := domain.NewMessageFromProps(domain.MessageProps{ID: "admin-1", TrackID: "track-1", ChannelType: domain.MessageDirect, SenderRole: domain.RoleAdmin, SentAt: time.Unix(1, 0)})
	trackMessage := domain.NewMessageFromProps(domain.MessageProps{ID: "track-1", TrackID: "track-1", ChannelType: domain.MessageDirect, SenderRole: domain.RoleTrack, SentAt: time.Unix(2, 0)})
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
	if !adminMessage.ReadAt().IsSet() || trackMessage.ReadAt().IsSet() {
		t.Fatal("expected only the opposite sender message to be marked read")
	}
	if value, _ := adminMessage.ReadAt().Value(); !value.Equal(now) {
		t.Fatalf("expected admin message read at %v, got %v", now, value)
	}
	if track, _ := tracks.Get(context.Background(), "track-1"); track.UnreadByTrackCount() != 0 {
		t.Fatalf("expected unread count to reset after background read, got %d", track.UnreadByTrackCount)
	}
}

func TestListDirectMessagesShoudReturnOnlyMessagesAfterBoundaryWhenAfterIsSet(t *testing.T) {
	// Arrange
	tracks := NewMockTrackRepository()
	tracks.Save(context.Background(), domain.NewTrackFromProps(domain.TrackProps{ID: "track-1", Status: domain.TrackActive}))
	messages := NewMockMessageRepository()
	boundary := time.Unix(10, 0)
	messages.Save(context.Background(), domain.NewMessageFromProps(domain.MessageProps{ID: "at-boundary", TrackID: "track-1", ChannelType: domain.MessageDirect, SenderRole: domain.RoleAdmin, SentAt: boundary}))
	messages.Save(context.Background(), domain.NewMessageFromProps(domain.MessageProps{ID: "after-boundary", TrackID: "track-1", ChannelType: domain.MessageDirect, SenderRole: domain.RoleAdmin, SentAt: boundary.Add(time.Second)}))
	service := NewMessageService(NewMockCornerRepository(), tracks, messages, &MockAuditLogRepository{}, &MockBroadcaster{}, &MockTxManager{})

	// Act
	got, err := service.ListDirectMessages(context.Background(), "track-1", domain.RoleTrack, domain.Some(boundary), false)

	// Assert
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if len(got) != 1 || got[0].ID != "after-boundary" {
		t.Fatalf("expected only message after boundary, got %#v", got)
	}
}

func TestMessageServiceShoudAcquireUnreadCounterLockBeforeMutatingMessages(t *testing.T) {
	// Arrange
	operations := []string{}
	baseTracks := NewMockTrackRepository()
	baseTracks.Save(context.Background(), domain.NewTrackFromProps(domain.TrackProps{ID: "track-1", CornerID: "corner-1", Status: domain.TrackActive}))
	tracks := &recordingTrackRepository{MockTrackRepository: baseTracks, operations: &operations}
	baseMessages := NewMockMessageRepository()
	baseMessages.Save(context.Background(), domain.NewMessageFromProps(domain.MessageProps{ID: "existing", TrackID: "track-1", ChannelType: domain.MessageDirect, SenderRole: domain.RoleAdmin, SentAt: time.Unix(1, 0)}))
	messages := &recordingMessageRepository{MockMessageRepository: baseMessages, operations: &operations}
	corners := NewMockCornerRepository()
	corners.Save(context.Background(), domain.NewCornerFromProps(domain.CornerProps{ID: "corner-1", CampID: "camp-1"}))
	service := NewMessageService(corners, tracks, messages, &MockAuditLogRepository{}, &MockBroadcaster{}, &MockTxManager{})

	// Act
	_, err := service.SendDirect(context.Background(), "track-1", "reply", domain.RoleTrack)
	if err == nil {
		_, err = service.ListDirectMessages(context.Background(), "track-1", domain.RoleTrack, domain.None[time.Time](), true)
	}

	// Assert
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	expected := []string{"increment", "save", "reset", "mark-read"}
	if !reflect.DeepEqual(operations, expected) {
		t.Fatalf("expected lock-first operations %v, got %v", expected, operations)
	}
}

func TestShouldReturnRoleSpecificUnreadCountWhenTrackHasUnreadMessages(t *testing.T) {
	// Arrange
	tracks := NewMockTrackRepository()
	tracks.Save(context.Background(), domain.NewTrackFromProps(domain.TrackProps{ID: "track-1", Status: domain.TrackActive, UnreadByAdminCount: 2, UnreadByTrackCount: 3}))
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
