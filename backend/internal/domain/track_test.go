package domain_test

import (
	"errors"
	"testing"
	"time"

	"cornermon/backend/internal/domain"
)

func TestTrack_Delete(t *testing.T) {
	now := time.Date(2026, 7, 9, 15, 30, 0, 0, time.UTC)

	t.Run("Delete on active track succeeds", func(t *testing.T) {
		track := domain.NewTrackFromProps(domain.TrackProps{ID: domain.TrackID("track-1"),
			Status: domain.TrackActive,
		})

		event, err := track.Delete(now)
		if err != nil {
			t.Fatalf("expected no error, got %v", err)
		}

		if track.Status() != domain.TrackDeleted {
			t.Errorf("expected status to be DELETED, got %v", track.Status())
		}

		deletedAt, ok := track.DeletedAt().Value()
		if !ok {
			t.Error("expected DeletedAt to be set")
		}
		if !deletedAt.Equal(now) {
			t.Errorf("expected DeletedAt to be %v, got %v", now, deletedAt)
		}

		if event.TrackID() != track.ID() {
			t.Errorf("expected event TrackID to be %q, got %q", track.ID(), event.TrackID())
		}
		if !event.OccurredAt().Equal(now) {
			t.Errorf("expected event OccurredAt to be %v, got %v", now, event.OccurredAt())
		}
	})

	t.Run("Delete on already DELETED track fails with ErrTrackAlreadyDeleted", func(t *testing.T) {
		track := domain.NewTrackFromProps(domain.TrackProps{ID: domain.TrackID("track-1"),
			Status: domain.TrackDeleted,
		})

		_, err := track.Delete(now)
		if !errors.Is(err, domain.ErrTrackAlreadyDeleted) {
			t.Errorf("expected error %v, got %v", domain.ErrTrackAlreadyDeleted, err)
		}
	})
}

func TestTrack_RegeneratePIN(t *testing.T) {
	now := time.Date(2026, 7, 9, 15, 45, 0, 0, time.UTC)

	t.Run("RegeneratePIN on active track succeeds", func(t *testing.T) {
		track := domain.NewTrackFromProps(domain.TrackProps{ID: domain.TrackID("track-1"),
			Status:  domain.TrackActive,
			PINHash: "old-hash",
		})

		event, err := track.RegeneratePIN("new-hash", now)
		if err != nil {
			t.Fatalf("expected no error, got %v", err)
		}

		if track.PINHash() != "new-hash" {
			t.Errorf("expected PINHash to be 'new-hash', got %q", track.PINHash())
		}

		if event.TrackID() != track.ID() {
			t.Errorf("expected event TrackID to be %q, got %q", track.ID(), event.TrackID())
		}
		if !event.OccurredAt().Equal(now) {
			t.Errorf("expected event OccurredAt to be %v, got %v", now, event.OccurredAt())
		}
	})

	t.Run("RegeneratePIN on DELETED track fails with ErrTrackNotActive", func(t *testing.T) {
		track := domain.NewTrackFromProps(domain.TrackProps{ID: domain.TrackID("track-1"),
			Status: domain.TrackDeleted,
		})

		_, err := track.RegeneratePIN("new-hash", now)
		if !errors.Is(err, domain.ErrTrackNotActive) {
			t.Errorf("expected error %v, got %v", domain.ErrTrackNotActive, err)
		}
	})
}
