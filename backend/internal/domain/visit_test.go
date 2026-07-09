package domain_test

import (
	"errors"
	"testing"
	"time"

	"cornermon/backend/internal/domain"
)

func TestVisit_LifecycleAndCalculations(t *testing.T) {
	startedAt := time.Date(2026, 7, 9, 15, 0, 0, 0, time.UTC)

	t.Run("NewVisit creates progress visit with unset Duration and Deviation", func(t *testing.T) {
		visit := domain.NewVisit(
			domain.VisitID("visit-1"),
			domain.GroupID("group-1"),
			domain.CornerID("corner-1"),
			domain.TrackID("track-1"),
			domain.VisitQRScan,
			startedAt,
		)

		if visit.Status != domain.VisitStatusInProgress {
			t.Errorf("expected VisitStatusInProgress, got %v", visit.Status)
		}
		if visit.EndedAt.IsSet() {
			t.Error("expected EndedAt to be unset")
		}

		if visit.DurationSeconds().IsSet() {
			t.Error("expected DurationSeconds to be unset")
		}
		if visit.DeviationSeconds(10).IsSet() {
			t.Error("expected DeviationSeconds to be unset")
		}
	})

	t.Run("Complete visit calculation flow", func(t *testing.T) {
		visit := domain.NewVisit(
			domain.VisitID("visit-1"),
			domain.GroupID("group-1"),
			domain.CornerID("corner-1"),
			domain.TrackID("track-1"),
			domain.VisitQRScan,
			startedAt,
		)

		// 1. Complete with time before startedAt fails
		invalidEndedAt := startedAt.Add(-1 * time.Minute)
		err := visit.Complete(invalidEndedAt)
		if !errors.Is(err, domain.ErrVisitEndBeforeStart) {
			t.Errorf("expected %v, got %v", domain.ErrVisitEndBeforeStart, err)
		}

		// 2. Complete with 12 minutes (720 seconds) later
		endedAt := startedAt.Add(12 * time.Minute)
		err = visit.Complete(endedAt)
		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		if visit.Status != domain.VisitStatusCompleted {
			t.Errorf("expected status to be VisitStatusCompleted, got %v", visit.Status)
		}

		endedTime, ok := visit.EndedAt.Value()
		if !ok || !endedTime.Equal(endedAt) {
			t.Errorf("expected EndedAt to be %v, got %v", endedAt, endedTime)
		}

		// 3. Complete again fails
		err = visit.Complete(endedAt.Add(time.Minute))
		if !errors.Is(err, domain.ErrVisitAlreadyCompleted) {
			t.Errorf("expected %v, got %v", domain.ErrVisitAlreadyCompleted, err)
		}

		// 4. Check calculations:
		// Duration: 12 minutes = 720 seconds
		duration, ok := visit.DurationSeconds().Value()
		if !ok || duration != 720 {
			t.Errorf("expected duration to be 720, got %d", duration)
		}

		// Deviation (Target = 10 minutes = 600 seconds)
		// Deviation = 720 - 600 = 120 seconds
		deviation, ok := visit.DeviationSeconds(10).Value()
		if !ok || deviation != 120 {
			t.Errorf("expected deviation to be 120, got %d", deviation)
		}

		// Deviation (Target = 15 minutes = 900 seconds)
		// Deviation = 720 - 900 = -180 seconds
		deviationNeg, ok := visit.DeviationSeconds(15).Value()
		if !ok || deviationNeg != -180 {
			t.Errorf("expected deviation to be -180, got %d", deviationNeg)
		}
	})
}
