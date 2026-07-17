//go:build ignore

package domain_test

import (
	"cornermon/backend/internal/domain"
	"testing"
	"time"
)

func TestMessage_MarkRead(t *testing.T) {
	now := time.Date(2026, 7, 9, 15, 0, 0, 0, time.UTC)

	t.Run("MarkRead sets read time on first call and keeps it on subsequent calls", func(t *testing.T) {
		msg := domain.NewMessageFromProps(domain.MessageProps{ID:         domain.MessageID("msg-1"),
			SenderRole: domain.RoleAdmin,
			Content:    "hello world",
			TrackID:    domain.TrackID("track-1"),
			ReadAt:     domain.None[time.Time](),
		})

		// First call
		err := msg.MarkRead(now)
		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		readAt, ok := msg.ReadAt.Value()
		if !ok || !readAt.Equal(now) {
			t.Errorf("expected ReadAt to be %v, got %v", now, readAt)
		}

		// Second call with different time should keep the first time
		later := now.Add(time.Minute)
		err = msg.MarkRead(later)
		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		readAt2, ok2 := msg.ReadAt.Value()
		if !ok2 || !readAt2.Equal(now) {
			t.Errorf("expected ReadAt to remain %v, got %v", now, readAt2)
		}
	})
}
