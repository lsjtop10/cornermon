package domain_test

import (
	"errors"
	"testing"
	"time"

	"cornermon/backend/internal/domain"
)

func TestTrack_StartVisit(t *testing.T) {
	t.Run("StartVisit on active idle track succeeds", func(t *testing.T) {
		track := domain.NewTrackFromProps(domain.TrackProps{ID: domain.TrackID("track-1"),
			Status:         domain.TrackActive,
			CurrentVisitID: domain.None[domain.VisitID](),
		})

		err := track.StartVisit(domain.VisitID("visit-1"))
		if err != nil {
			t.Fatalf("expected no error, got %v", err)
		}

		visitID, ok := track.CurrentVisitID().Value()
		if !ok {
			t.Error("expected CurrentVisitID to be set")
		}
		if visitID != domain.VisitID("visit-1") {
			t.Errorf("expected visitID to be 'visit-1', got %q", visitID)
		}
	})

	t.Run("StartVisit on DELETED track fails with ErrTrackNotActive", func(t *testing.T) {
		track := domain.NewTrackFromProps(domain.TrackProps{ID: domain.TrackID("track-1"),
			Status:         domain.TrackDeleted,
			CurrentVisitID: domain.None[domain.VisitID](),
		})

		err := track.StartVisit(domain.VisitID("visit-1"))
		if !errors.Is(err, domain.ErrTrackNotActive) {
			t.Errorf("expected error %v, got %v", domain.ErrTrackNotActive, err)
		}
	})

	t.Run("StartVisit on busy track fails with ErrTrackBusy", func(t *testing.T) {
		track := domain.NewTrackFromProps(domain.TrackProps{ID: domain.TrackID("track-1"),
			Status:         domain.TrackActive,
			CurrentVisitID: domain.Some(domain.VisitID("visit-1")),
		})

		err := track.StartVisit(domain.VisitID("visit-2"))
		if !errors.Is(err, domain.ErrTrackBusy) {
			t.Errorf("expected error %v, got %v", domain.ErrTrackBusy, err)
		}
	})
}

func TestTrack_CompleteVisit(t *testing.T) {
	now := time.Date(2026, 7, 9, 15, 0, 0, 0, time.UTC)

	t.Run("CompleteVisit on busy active track succeeds", func(t *testing.T) {
		track := domain.NewTrackFromProps(domain.TrackProps{ID: domain.TrackID("track-1"),
			Status:         domain.TrackActive,
			CurrentVisitID: domain.Some(domain.VisitID("visit-1")),
		})

		event, err := track.CompleteVisit(now)
		if err != nil {
			t.Fatalf("expected no error, got %v", err)
		}

		if track.CurrentVisitID().IsSet() {
			t.Error("expected CurrentVisitID to be cleared")
		}

		if event.TrackID() != track.ID() {
			t.Errorf("expected event TrackID to be %q, got %q", track.ID(), event.TrackID())
		}
		if !event.OccurredAt().Equal(now) {
			t.Errorf("expected event OccurredAt to be %v, got %v", now, event.OccurredAt())
		}
	})

	t.Run("CompleteVisit on DELETED track fails with ErrTrackNotActive", func(t *testing.T) {
		track := domain.NewTrackFromProps(domain.TrackProps{ID: domain.TrackID("track-1"),
			Status:         domain.TrackDeleted,
			CurrentVisitID: domain.Some(domain.VisitID("visit-1")),
		})

		_, err := track.CompleteVisit(now)
		if !errors.Is(err, domain.ErrTrackNotActive) {
			t.Errorf("expected error %v, got %v", domain.ErrTrackNotActive, err)
		}
	})

	t.Run("CompleteVisit on idle track fails with ErrTrackNotBusy", func(t *testing.T) {
		track := domain.NewTrackFromProps(domain.TrackProps{ID: domain.TrackID("track-1"),
			Status:         domain.TrackActive,
			CurrentVisitID: domain.None[domain.VisitID](),
		})

		_, err := track.CompleteVisit(now)
		if !errors.Is(err, domain.ErrTrackNotBusy) {
			t.Errorf("expected error %v, got %v", domain.ErrTrackNotBusy, err)
		}
	})
}

func TestTrack_OperationalStatus(t *testing.T) {
	t.Run("IDLE if no current visit", func(t *testing.T) {
		track := domain.NewTrackFromProps(domain.TrackProps{CurrentVisitID: domain.None[domain.VisitID]()})
		if track.OperationalStatus() != domain.TrackIdle {
			t.Errorf("expected IDLE, got %v", track.OperationalStatus())
		}
	})

	t.Run("BUSY if current visit is set", func(t *testing.T) {
		track := domain.NewTrackFromProps(domain.TrackProps{CurrentVisitID: domain.Some(domain.VisitID("visit-1"))})
		if track.OperationalStatus() != domain.TrackBusy {
			t.Errorf("expected BUSY, got %v", track.OperationalStatus())
		}
	})
}

func TestTrack_Delete(t *testing.T) {
	now := time.Date(2026, 7, 9, 15, 30, 0, 0, time.UTC)

	t.Run("Delete on idle active track succeeds", func(t *testing.T) {
		track := domain.NewTrackFromProps(domain.TrackProps{ID: domain.TrackID("track-1"),
			Status:         domain.TrackActive,
			CurrentVisitID: domain.None[domain.VisitID](),
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

	t.Run("Delete on busy track fails with ErrTrackDeleteBlocked", func(t *testing.T) {
		track := domain.NewTrackFromProps(domain.TrackProps{ID: domain.TrackID("track-1"),
			Status:         domain.TrackActive,
			CurrentVisitID: domain.Some(domain.VisitID("visit-1")),
		})

		_, err := track.Delete(now)
		if !errors.Is(err, domain.ErrTrackDeleteBlocked) {
			t.Errorf("expected error %v, got %v", domain.ErrTrackDeleteBlocked, err)
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
