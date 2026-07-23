package usecase

import (
	"context"
	"testing"

	"cornermon/backend/internal/domain"
)

func TestAdminActorLabelShoudReturnUsernameWhenAdminExists(t *testing.T) {
	// arrange
	admins := NewMockAdminRepository()
	admin := domain.NewAdminFromProps(domain.AdminProps{ID: "admin-1", Username: "김관리"})
	admins.Admins[admin.ID()] = admin

	// act
	got := adminActorLabel(context.Background(), admins, admin.ID(), nil)

	// assert
	if got != "김관리" {
		t.Errorf("expected '김관리', got %q", got)
	}
}

func TestAdminActorLabelShoudFallBackToIDWhenAdminNotFound(t *testing.T) {
	// arrange
	admins := NewMockAdminRepository()

	// act
	got := adminActorLabel(context.Background(), admins, domain.AdminID("missing-admin"), nil)

	// assert
	if got != "missing-admin" {
		t.Errorf("expected fallback to raw ID 'missing-admin', got %q", got)
	}
}

type spyAdminRepository struct {
	*MockAdminRepository
	getCalls int
}

func (r *spyAdminRepository) Get(ctx context.Context, id domain.AdminID) (*domain.Admin, error) {
	r.getCalls++
	return r.MockAdminRepository.Get(ctx, id)
}

func TestAdminActorLabelShoudSkipRepositoryWhenPreloadedProvided(t *testing.T) {
	// arrange
	spy := &spyAdminRepository{MockAdminRepository: NewMockAdminRepository()}
	preloaded := domain.NewAdminFromProps(domain.AdminProps{ID: "admin-1", Username: "김관리"})

	// act
	got := adminActorLabel(context.Background(), spy, preloaded.ID(), preloaded)

	// assert
	if got != "김관리" {
		t.Errorf("expected '김관리', got %q", got)
	}
	if spy.getCalls != 0 {
		t.Errorf("expected repository Get to be skipped when preloaded is provided, got %d calls", spy.getCalls)
	}
}

func TestTrackDisplayLabelShoudFormatCornerAndTrackNoWhenTrackExists(t *testing.T) {
	// arrange
	tracks := NewMockTrackRepository()
	corners := NewMockCornerRepository()
	corner := domain.NewCornerFromProps(domain.CornerProps{ID: "corner-1", CampID: "camp-1", Name: "체험 코너"})
	track := domain.NewTrackFromProps(domain.TrackProps{ID: "track-1", CornerID: corner.ID(), TrackNo: 3})
	corners.Corners[corner.ID()] = corner
	tracks.Tracks[track.ID()] = track

	// act
	got := trackDisplayLabel(context.Background(), tracks, corners, track.ID(), nil)

	// assert
	want := "체험 코너 · 3번 트랙"
	if got != want {
		t.Errorf("expected %q, got %q", want, got)
	}
}

func TestTrackDisplayLabelShoudFallBackToTrackIDWhenTrackDeleted(t *testing.T) {
	// arrange
	tracks := NewMockTrackRepository()
	corners := NewMockCornerRepository()

	// act
	got := trackDisplayLabel(context.Background(), tracks, corners, domain.TrackID("missing-track"), nil)

	// assert
	if got != "missing-track" {
		t.Errorf("expected fallback to raw ID 'missing-track', got %q", got)
	}
}

func TestTrackDisplayLabelShoudUsePreloadedTrackWhenProvided(t *testing.T) {
	// arrange
	tracks := NewMockTrackRepository()
	corners := NewMockCornerRepository()
	corner := domain.NewCornerFromProps(domain.CornerProps{ID: "corner-1", CampID: "camp-1", Name: "체험 코너"})
	corners.Corners[corner.ID()] = corner
	preloadedTrack := domain.NewTrackFromProps(domain.TrackProps{ID: "track-1", CornerID: corner.ID(), TrackNo: 5})

	// act
	got := trackDisplayLabel(context.Background(), tracks, corners, preloadedTrack.ID(), preloadedTrack)

	// assert
	want := "체험 코너 · 5번 트랙"
	if got != want {
		t.Errorf("expected %q, got %q", want, got)
	}
}
