package postgres

import (
	"testing"

	"cornermon/backend/internal/domain"
)

func TestMapCornerView(t *testing.T) {
	// Act
	view, err := mapCornerView(
		"corner-1", "camp-1", "코너 1", 10, 640, 2,
		[]byte(`[{"id":"track-2","cornerId":"corner-1","trackNo":2,"status":"ACTIVE","operationalStatus":"IDLE"},{"id":"track-3","cornerId":"corner-1","trackNo":3,"status":"ACTIVE","operationalStatus":"BUSY"}]`),
	)

	// Assert
	if err != nil {
		t.Fatalf("expected no error, got %v", err)
	}
	if view.AvgDurationSeconds != 640 || view.SampleCount != 2 {
		t.Fatalf("unexpected metrics: %+v", view)
	}
	if len(view.ActiveTracks) != 2 || view.ActiveTracks[0].TrackNo != 2 || view.ActiveTracks[1].OperationalStatus != "BUSY" {
		t.Fatalf("unexpected active tracks: %+v", view.ActiveTracks)
	}
	if view.Status != domain.CornerBusy {
		t.Fatalf("expected corner status BUSY when any active track is BUSY, got %v", view.Status)
	}
}

func TestMapCornerViewAllowsNoActiveTracks(t *testing.T) {
	// Act
	view, err := mapCornerView("corner-1", "camp-1", "코너 1", 10, 0, 0, []byte(`[]`))

	// Assert
	if err != nil {
		t.Fatalf("expected no error, got %v", err)
	}
	if view.AvgDurationSeconds != 0 || view.SampleCount != 0 || len(view.ActiveTracks) != 0 {
		t.Fatalf("unexpected empty view: %+v", view)
	}
	if view.Status != domain.CornerInactive {
		t.Fatalf("expected corner status INACTIVE when no active tracks, got %v", view.Status)
	}
}

func TestMapCornerViewStatusIsIdleWhenNoTrackIsBusy(t *testing.T) {
	// Arrange / Act
	view, err := mapCornerView(
		"corner-1", "camp-1", "코너 1", 10, 0, 0,
		[]byte(`[{"id":"track-1","cornerId":"corner-1","trackNo":1,"status":"ACTIVE","operationalStatus":"IDLE"}]`),
	)

	// Assert
	if err != nil {
		t.Fatalf("expected no error, got %v", err)
	}
	if view.Status != domain.CornerIdle {
		t.Fatalf("expected corner status IDLE when active tracks exist but none are busy, got %v", view.Status)
	}
}
