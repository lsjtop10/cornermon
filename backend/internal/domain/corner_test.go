//go:build ignore

package domain_test

import (
	"testing"

	"cornermon/backend/internal/domain"
)

func TestCorner_OperationalStatus(t *testing.T) {
	corner := domain.NewCornerFromProps(domain.CornerProps{ID:            domain.CornerID("corner-1"),
		TargetMinutes: 10,
	})

	t.Run("INACTIVE status if no tracks provided", func(t *testing.T) {
		status := corner.OperationalStatus([]*domain.Track{})
		if status != domain.CornerInactive {
			t.Errorf("expected status %v, got %v", domain.CornerInactive, status)
		}
	})

	t.Run("INACTIVE status if only DELETED tracks exist", func(t *testing.T) {
		tracks := []*domain.Track{
			{
				ID:       domain.TrackID("track-1"),
				CornerID: corner.ID,
				Status:   domain.TrackDeleted,
			},
		}
		status := corner.OperationalStatus(tracks)
		if status != domain.CornerInactive {
			t.Errorf("expected status %v, got %v", domain.CornerInactive, status)
		}
	})

	t.Run("IDLE status if active tracks exist but none is busy", func(t *testing.T) {
		tracks := []*domain.Track{
			{
				ID:             domain.TrackID("track-1"),
				CornerID:       corner.ID,
				Status:         domain.TrackActive,
				CurrentVisitID: domain.None[domain.VisitID](),
			},
		}
		status := corner.OperationalStatus(tracks)
		if status != domain.CornerIdle {
			t.Errorf("expected status %v, got %v", domain.CornerIdle, status)
		}
	})

	t.Run("BUSY status if at least one active track is busy", func(t *testing.T) {
		tracks := []*domain.Track{
			{
				ID:             domain.TrackID("track-1"),
				CornerID:       corner.ID,
				Status:         domain.TrackActive,
				CurrentVisitID: domain.None[domain.VisitID](),
			},
			{
				ID:             domain.TrackID("track-2"),
				CornerID:       corner.ID,
				Status:         domain.TrackActive,
				CurrentVisitID: domain.Some(domain.VisitID("visit-1")),
			},
		}
		status := corner.OperationalStatus(tracks)
		if status != domain.CornerBusy {
			t.Errorf("expected status %v, got %v", domain.CornerBusy, status)
		}
	})

	t.Run("Ignore tracks belonging to other corners", func(t *testing.T) {
		tracks := []*domain.Track{
			{
				ID:             domain.TrackID("track-other"),
				CornerID:       domain.CornerID("corner-other"),
				Status:         domain.TrackActive,
				CurrentVisitID: domain.Some(domain.VisitID("visit-1")),
			},
		}
		status := corner.OperationalStatus(tracks)
		if status != domain.CornerInactive {
			t.Errorf("expected status %v, got %v", domain.CornerInactive, status)
		}
	})
}

func TestCorner_EffectiveTargetMinutes(t *testing.T) {
	corner := domain.NewCornerFromProps(domain.CornerProps{ID:            domain.CornerID("corner-1"),
		TargetMinutes: 12,
	})

	t.Run("Returns TargetMinutes regardless of track input", func(t *testing.T) {
		track := domain.NewTrackFromProps(domain.TrackProps{ID: domain.TrackID("track-1")})
		minutes := corner.EffectiveTargetMinutes(track)
		if minutes != 12 {
			t.Errorf("expected minutes to be 12, got %d", minutes)
		}

		minutesNil := corner.EffectiveTargetMinutes(nil)
		if minutesNil != 12 {
			t.Errorf("expected minutes to be 12, got %d", minutesNil)
		}
	})
}
