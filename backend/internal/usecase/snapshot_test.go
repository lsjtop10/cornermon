package usecase

import (
	"context"
	"testing"

	"cornermon/backend/internal/domain"
)

func TestSnapshotService_GetSnapshot(t *testing.T) {
	t.Run("ShouldGetSnapshotSuccessfullyAndExcludeDeletedTracks", func(t *testing.T) {
		// Arrange
		camps := NewMockCampRepository()
		camp := &domain.Camp{ID: "camp-1", Status: domain.CampActive}
		camps.Save(context.Background(), camp)

		corners := NewMockCornerRepository()
		corner := &domain.Corner{ID: "corner-1", CampID: "camp-1"}
		corners.Save(context.Background(), corner)

		tracks := NewMockTrackRepository()
		activeTrack := &domain.Track{ID: "track-1", CornerID: "corner-1", Status: domain.TrackActive}
		deletedTrack := &domain.Track{ID: "track-2", CornerID: "corner-1", Status: domain.TrackDeleted}
		tracks.Save(context.Background(), activeTrack)
		tracks.Save(context.Background(), deletedTrack)

		groups := NewMockGroupRepository()
		group := &domain.Group{ID: "group-1", CampID: "camp-1"}
		groups.Save(context.Background(), group)

		s := NewSnapshotService(camps, corners, tracks, groups)

		// Act
		snapshot, err := s.GetSnapshot(context.Background(), "camp-1")

		// Assert
		if err != nil {
			t.Fatalf("expected no error, got %v", err)
		}
		if snapshot == nil {
			t.Fatal("expected snapshot, got nil")
		}
		if len(snapshot.Corners) != 1 {
			t.Errorf("expected 1 corner in snapshot, got %d", len(snapshot.Corners))
		}
		cornerSnap := snapshot.Corners[0]
		if len(cornerSnap.Tracks) != 1 {
			t.Errorf("expected 1 active track, got %d", len(cornerSnap.Tracks))
		}
		if cornerSnap.Tracks[0].ID != "track-1" {
			t.Errorf("expected active track ID to be 'track-1', got '%s'", cornerSnap.Tracks[0].ID)
		}
	})
}
