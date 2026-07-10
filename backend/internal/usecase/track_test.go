package usecase

import (
	"context"
	"testing"
	"time"

	"cornermon/backend/internal/domain"
)

func TestTrackService_CreateTrack(t *testing.T) {
	t.Run("ShouldCreateTrackWhenCampIsActive", func(t *testing.T) {
		// Arrange
		now := time.Now()
		camps := NewMockCampRepository()
		camp := &domain.Camp{ID: "camp-1", Status: domain.CampActive}
		camps.Save(context.Background(), camp)

		corners := NewMockCornerRepository()
		corner := &domain.Corner{ID: "corner-1", CampID: "camp-1"}
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
		if track.ID != "track-uuid-1" {
			t.Errorf("expected track ID to be 'track-uuid-1', got '%s'", track.ID)
		}
		if track.TrackNo != 1 {
			t.Errorf("expected track no to be 1, got %d", track.TrackNo)
		}
		if len(plainPIN) != 6 {
			t.Errorf("expected 6-digit plain PIN, got length %d", len(plainPIN))
		}
		if len(broadcaster.Broadcasts) != 1 ||
			broadcaster.Broadcasts[0].CampID != "camp-1" ||
			broadcaster.Broadcasts[0].Event != EventTracksUpdated ||
			broadcaster.Broadcasts[0].Scope != "camp" {
			t.Errorf("expected EventTracksUpdated broadcast with scope 'camp', got %v", broadcaster.Broadcasts)
		}
	})

	t.Run("ShouldFailCreateTrackWhenCampIsEnded", func(t *testing.T) {
		// Arrange
		camps := NewMockCampRepository()
		camp := &domain.Camp{ID: "camp-1", Status: domain.CampEnded}
		camps.Save(context.Background(), camp)

		corners := NewMockCornerRepository()
		corner := &domain.Corner{ID: "corner-1", CampID: "camp-1"}
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
		if err != domain.ErrCampInvalidTransition {
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
		corner := &domain.Corner{ID: "corner-1", CampID: "camp-1"}
		corners.Save(context.Background(), corner)

		tracks := NewMockTrackRepository()
		track := &domain.Track{
			ID:             "track-1",
			CornerID:       "corner-1",
			Status:         domain.TrackActive,
			CurrentVisitID: domain.None[domain.VisitID](),
		}
		tracks.Save(context.Background(), track)

		sessions := NewMockFacilitatorSessionRepository()
		session := &domain.FacilitatorSession{
			ID:        "session-1",
			TrackID:   "track-1",
			TokenHash: "hash-1",
			CreatedAt: now,
		}
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
		if updatedTrack.Status != domain.TrackDeleted {
			t.Errorf("expected track status to be Deleted, got %s", updatedTrack.Status)
		}

		updatedSession, _ := sessions.GetByTokenHash(context.Background(), "hash-1")
		if updatedSession.IsActive() {
			t.Errorf("expected session to be revoked")
		}

		if len(broadcaster.Broadcasts) != 2 ||
			broadcaster.Broadcasts[0].Event != EventTracksUpdated || broadcaster.Broadcasts[0].Scope != "camp" ||
			broadcaster.Broadcasts[1].Event != EventTrackDeleted || broadcaster.Broadcasts[1].Scope != "track:track-1" {
			t.Errorf("expected EventTracksUpdated and EventTrackDeleted broadcasts, got %v", broadcaster.Broadcasts)
		}
	})

	t.Run("ShouldFailDeleteTrackWhenBusy", func(t *testing.T) {
		// Arrange
		now := time.Now()
		camps := NewMockCampRepository()
		corners := NewMockCornerRepository()
		tracks := NewMockTrackRepository()
		track := &domain.Track{
			ID:             "track-1",
			CornerID:       "corner-1",
			Status:         domain.TrackActive,
			CurrentVisitID: domain.Some[domain.VisitID]("visit-1"),
		}
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
		if err != domain.ErrTrackDeleteBlocked {
			t.Errorf("expected ErrTrackDeleteBlocked, got %v", err)
		}
	})
}
