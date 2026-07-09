package domain_test

import (
	"testing"
	"time"

	"cornermon/backend/internal/domain"
)

func TestBroadcastReceipt_MarkRead(t *testing.T) {
	now := time.Date(2026, 7, 9, 15, 0, 0, 0, time.UTC)

	t.Run("MarkRead sets read time on first call and keeps it on subsequent calls", func(t *testing.T) {
		receipt := &domain.BroadcastReceipt{
			MessageID: domain.MessageID("msg-1"),
			TrackID:   domain.TrackID("track-1"),
			ReadAt:    domain.None[time.Time](),
		}

		// First call
		err := receipt.MarkRead(now)
		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		readAt, ok := receipt.ReadAt.Value()
		if !ok || !readAt.Equal(now) {
			t.Errorf("expected ReadAt to be %v, got %v", now, readAt)
		}

		// Second call with different time should keep the first time
		later := now.Add(time.Minute)
		err = receipt.MarkRead(later)
		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		readAt2, ok2 := receipt.ReadAt.Value()
		if !ok2 || !readAt2.Equal(now) {
			t.Errorf("expected ReadAt to remain %v, got %v", now, readAt2)
		}
	})
}
