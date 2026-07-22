package usecase

import (
	"context"
	"errors"
	"testing"
	"time"

	"cornermon/backend/internal/domain"
)

type passthroughTrackPINProtector struct{}

func (passthroughTrackPINProtector) Encrypt(_ context.Context, pin string) (string, error) {
	return pin, nil
}

func (passthroughTrackPINProtector) Decrypt(_ context.Context, ciphertext string) (string, error) {
	return ciphertext, nil
}

func TestTrackService_ExportTrackPINs(t *testing.T) {
	// Arrange
	corners := NewMockCornerRepository()
	_ = corners.Save(context.Background(), domain.NewCornerFromProps(domain.CornerProps{
		ID: "corner-1", CampID: "camp-1", Name: "과학 실험실",
	}))
	tracks := NewMockTrackRepository()
	_ = tracks.Save(context.Background(), domain.NewTrackFromProps(domain.TrackProps{
		ID: "track-1", CornerID: "corner-1", TrackNo: 7,
		Status: domain.TrackActive, PINCiphertext: "482910",
	}))
	service := NewTrackService(
		NewMockCampRepository(), corners, tracks, NewMockFacilitatorSessionRepository(),
		&MockAuditLogRepository{}, &MockBroadcaster{}, &MockTxManager{}, passthroughTrackPINProtector{},
	)

	// Act
	exports, err := service.ExportTrackPINs(context.Background(), "camp-1")

	// Assert
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if len(exports) != 1 {
		t.Fatalf("expected one export row, got %d", len(exports))
	}
	if got, want := exports[0], (TrackPINExport{CornerName: "과학 실험실", TrackNo: 7, PIN: "482910"}); got != want {
		t.Fatalf("expected %+v, got %+v", want, got)
	}
}

func TestTrackService_CreateTrack(t *testing.T) {
	t.Run("ShouldCreateTrackWhenCampIsActive", func(t *testing.T) {
		// Arrange
		now := time.Now()
		camps := NewMockCampRepository()
		camp := domain.NewCampFromProps(domain.CampProps{ID: "camp-1", Status: domain.CampActive})
		camps.Save(context.Background(), camp)

		corners := NewMockCornerRepository()
		corner := domain.NewCornerFromProps(domain.CornerProps{ID: "corner-1", CampID: "camp-1"})
		corners.Save(context.Background(), corner)

		tracks := NewMockTrackRepository()
		sessions := NewMockFacilitatorSessionRepository()
		auditLogs := &MockAuditLogRepository{}
		broadcaster := &MockBroadcaster{}
		tx := &MockTxManager{}

		s := NewTrackService(camps, corners, tracks, sessions, auditLogs, broadcaster, tx)
		s.nowFn = func() time.Time { return now }
		s.uuidFn = func() string { return "track-uuid-1" }

		// Act
		track, plainPIN, err := s.CreateTrack(context.Background(), "camp-1", "corner-1")

		// Assert
		if err != nil {
			t.Fatalf("expected no error, got %v", err)
		}
		if track == nil {
			t.Fatal("expected track, got nil")
		}
		if track.ID() != "track-uuid-1" {
			t.Errorf("expected track ID to be 'track-uuid-1', got '%s'", track.ID())
		}
		if track.TrackNo() != 1 {
			t.Errorf("expected track no to be 1, got %d", track.TrackNo())
		}
		if len(plainPIN) != 6 {
			t.Errorf("expected 6-digit plain PIN, got length %d", len(plainPIN))
		}
		if len(broadcaster.Broadcasts) != 1 ||
			broadcaster.Broadcasts[0].CampID != "camp-1" ||
			broadcaster.Broadcasts[0].Event != EventTracksUpdated ||
			broadcaster.Broadcasts[0].Scope != CampScope() {
			t.Errorf("expected EventTracksUpdated broadcast with scope 'camp', got %v", broadcaster.Broadcasts)
		}
	})

	t.Run("ShouldFailCreateTrackWhenCampIsEnded", func(t *testing.T) {
		// Arrange
		camps := NewMockCampRepository()
		camp := domain.NewCampFromProps(domain.CampProps{ID: "camp-1", Status: domain.CampEnded})
		camps.Save(context.Background(), camp)

		corners := NewMockCornerRepository()
		corner := domain.NewCornerFromProps(domain.CornerProps{ID: "corner-1", CampID: "camp-1"})
		corners.Save(context.Background(), corner)

		tracks := NewMockTrackRepository()
		sessions := NewMockFacilitatorSessionRepository()
		auditLogs := &MockAuditLogRepository{}
		broadcaster := &MockBroadcaster{}
		tx := &MockTxManager{}

		s := NewTrackService(camps, corners, tracks, sessions, auditLogs, broadcaster, tx)

		// Act
		_, _, err := s.CreateTrack(context.Background(), "camp-1", "corner-1")

		// Assert
		if !errors.Is(err, domain.ErrCampInvalidTransition) {
			t.Errorf("expected ErrCampInvalidTransition, got %v", err)
		}
	})
}

func TestTrackService_DeleteTrack(t *testing.T) {
	t.Run("ShouldDeleteTrackWhenIdle", func(t *testing.T) {
		// Arrange
		now := time.Now()
		camps := NewMockCampRepository()
		corners := NewMockCornerRepository()
		corner := domain.NewCornerFromProps(domain.CornerProps{ID: "corner-1", CampID: "camp-1"})
		corners.Save(context.Background(), corner)

		tracks := NewMockTrackRepository()
		track := domain.NewTrackFromProps(domain.TrackProps{ID: "track-1",
			CornerID:       "corner-1",
			Status:         domain.TrackActive,
			CurrentVisitID: domain.None[domain.VisitID](),
		})
		tracks.Save(context.Background(), track)

		sessions := NewMockFacilitatorSessionRepository()
		session := domain.NewFacilitatorSessionFromProps(domain.FacilitatorSessionProps{ID: "session-1",
			TrackID:   "track-1",
			TokenHash: "hash-1",
			CreatedAt: now,
		})
		sessions.Save(context.Background(), session)

		auditLogs := &MockAuditLogRepository{}
		broadcaster := &MockBroadcaster{}
		tx := &MockTxManager{}

		s := NewTrackService(camps, corners, tracks, sessions, auditLogs, broadcaster, tx)
		s.nowFn = func() time.Time { return now }
		s.uuidFn = func() string { return "audit-uuid" }

		// Act
		isLast, err := s.DeleteTrack(context.Background(), "track-1")

		// Assert
		if err != nil {
			t.Fatalf("expected no error, got %v", err)
		}
		if !isLast {
			t.Errorf("expected isLast to be true since it was the only track")
		}

		updatedTrack, _ := tracks.Get(context.Background(), "track-1")
		if updatedTrack.Status() != domain.TrackDeleted {
			t.Errorf("expected track status to be Deleted, got %s", updatedTrack.Status())
		}

		updatedSession, _ := sessions.GetByTokenHash(context.Background(), "hash-1")
		if updatedSession.IsActive() {
			t.Errorf("expected session to be revoked")
		}

		if len(broadcaster.Broadcasts) != 2 ||
			broadcaster.Broadcasts[0].Event != EventTracksUpdated || broadcaster.Broadcasts[0].Scope != CampScope() ||
			broadcaster.Broadcasts[1].Event != EventTrackDeleted || broadcaster.Broadcasts[1].Scope != TrackScope("track-1") {
			t.Errorf("expected EventTracksUpdated and EventTrackDeleted broadcasts, got %v", broadcaster.Broadcasts)
		}
	})

	t.Run("ShouldFailDeleteTrackWhenBusy", func(t *testing.T) {
		// Arrange
		now := time.Now()
		camps := NewMockCampRepository()
		corners := NewMockCornerRepository()
		tracks := NewMockTrackRepository()
		track := domain.NewTrackFromProps(domain.TrackProps{ID: "track-1",
			CornerID:       "corner-1",
			Status:         domain.TrackActive,
			CurrentVisitID: domain.Some[domain.VisitID]("visit-1"),
		})
		tracks.Save(context.Background(), track)

		sessions := NewMockFacilitatorSessionRepository()
		auditLogs := &MockAuditLogRepository{}
		broadcaster := &MockBroadcaster{}
		tx := &MockTxManager{}

		s := NewTrackService(camps, corners, tracks, sessions, auditLogs, broadcaster, tx)
		s.nowFn = func() time.Time { return now }

		// Act
		_, err := s.DeleteTrack(context.Background(), "track-1")

		// Assert
		if !errors.Is(err, domain.ErrTrackDeleteBlocked) {
			t.Errorf("expected ErrTrackDeleteBlocked, got %v", err)
		}
	})
}

func TestReplaceTrackShoudMigrateSessionAndBroadcastAfterSuccess(t *testing.T) {
	// Arrange
	now := time.Date(2026, 7, 13, 10, 0, 0, 0, time.UTC)
	corners := NewMockCornerRepository()
	_ = corners.Save(context.Background(), domain.NewCornerFromProps(domain.CornerProps{ID: "corner-old", CampID: "camp-1"}))
	_ = corners.Save(context.Background(), domain.NewCornerFromProps(domain.CornerProps{ID: "corner-new", CampID: "camp-1"}))
	tracks := NewMockTrackRepository()
	_ = tracks.Save(context.Background(), domain.NewTrackFromProps(domain.TrackProps{ID: "track-old", CornerID: "corner-old", Status: domain.TrackActive}))
	sessions := NewMockFacilitatorSessionRepository()
	_ = sessions.Save(context.Background(), domain.NewFacilitatorSessionFromProps(domain.FacilitatorSessionProps{ID: "session-1", TrackID: "track-old", CreatedAt: now}))
	broadcaster := &MockBroadcaster{}
	service := NewTrackService(NewMockCampRepository(), corners, tracks, sessions, &MockAuditLogRepository{}, broadcaster, &MockTxManager{})
	service.nowFn = func() time.Time { return now }
	service.uuidFn = func() string { return "track-new" }

	// Act
	track, pin, err := service.ReplaceTrack(context.Background(), "track-old", "corner-new")

	// Assert
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if track.ID() != "track-new" || track.CornerID() != "corner-new" || len(pin) != 6 {
		t.Fatalf("unexpected replacement result: track=%+v pin=%q", track, pin)
	}
	migrated, _ := sessions.Get(context.Background(), "session-1")
	target, ok := migrated.MigrationTargetTrackID().Value()
	if !ok || target != "track-new" || !migrated.IsActive() {
		t.Fatalf("session was not migrated while active: %+v", migrated)
	}
	if len(broadcaster.Broadcasts) != 2 || broadcaster.Broadcasts[1].Event != EventTrackReplaced {
		t.Fatalf("replacement broadcasts missing: %+v", broadcaster.Broadcasts)
	}
}

func TestReplaceTrackShoudRejectDifferentCampBeforeMutation(t *testing.T) {
	// Arrange
	corners := NewMockCornerRepository()
	_ = corners.Save(context.Background(), domain.NewCornerFromProps(domain.CornerProps{ID: "corner-old", CampID: "camp-a"}))
	_ = corners.Save(context.Background(), domain.NewCornerFromProps(domain.CornerProps{ID: "corner-new", CampID: "camp-b"}))
	tracks := NewMockTrackRepository()
	original := domain.NewTrackFromProps(domain.TrackProps{ID: "track-old", CornerID: "corner-old", Status: domain.TrackActive})
	_ = tracks.Save(context.Background(), original)
	broadcaster := &MockBroadcaster{}
	service := NewTrackService(NewMockCampRepository(), corners, tracks, NewMockFacilitatorSessionRepository(), &MockAuditLogRepository{}, broadcaster, &MockTxManager{})

	// Act
	_, _, err := service.ReplaceTrack(context.Background(), "track-old", "corner-new")

	// Assert
	if !errors.Is(err, domain.ErrTrackCampMismatch) {
		t.Fatalf("expected ErrTrackCampMismatch, got %v", err)
	}
	if original.Status() != domain.TrackActive || len(broadcaster.Broadcasts) != 0 {
		t.Fatalf("replacement mutated state before rejecting: track=%+v broadcasts=%+v", original, broadcaster.Broadcasts)
	}
}

func TestReplaceTrackShoudPreserveBusyTrackWhenRejected(t *testing.T) {
	// Arrange
	corners := NewMockCornerRepository()
	_ = corners.Save(context.Background(), domain.NewCornerFromProps(domain.CornerProps{ID: "corner-old", CampID: "camp-1"}))
	_ = corners.Save(context.Background(), domain.NewCornerFromProps(domain.CornerProps{ID: "corner-new", CampID: "camp-1"}))
	tracks := NewMockTrackRepository()
	original := domain.NewTrackFromProps(domain.TrackProps{ID: "track-old", CornerID: "corner-old", Status: domain.TrackActive, CurrentVisitID: domain.Some[domain.VisitID]("visit-1")})
	_ = tracks.Save(context.Background(), original)
	service := NewTrackService(NewMockCampRepository(), corners, tracks, NewMockFacilitatorSessionRepository(), &MockAuditLogRepository{}, &MockBroadcaster{}, &MockTxManager{})

	// Act
	_, _, err := service.ReplaceTrack(context.Background(), "track-old", "corner-new")

	// Assert
	if !errors.Is(err, domain.ErrTrackDeleteBlocked) {
		t.Fatalf("expected ErrTrackDeleteBlocked, got %v", err)
	}
	if original.Status() != domain.TrackActive {
		t.Fatalf("busy track was changed: %+v", original)
	}
}
