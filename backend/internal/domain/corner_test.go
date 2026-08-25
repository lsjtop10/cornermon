package domain_test

import (
	"testing"

	"cornermon/backend/internal/domain"
)

func TestCorner_EffectiveTargetMinutes(t *testing.T) {
	corner := domain.NewCornerFromProps(domain.CornerProps{ID: domain.CornerID("corner-1"),
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
