//go:build ignore

package postgres

import "testing"

func TestMapCornerView(t *testing.T) {
	view, err := mapCornerView(
		"corner-1", "camp-1", "코너 1", 10, 640, 2,
		[]byte(`[{"id":"track-2","cornerId":"corner-1","trackNo":2,"status":"ACTIVE","operationalStatus":"IDLE"},{"id":"track-3","cornerId":"corner-1","trackNo":3,"status":"ACTIVE","operationalStatus":"BUSY"}]`),
	)
	if err != nil {
		t.Fatalf("expected no error, got %v", err)
	}
	if view.AvgDurationSeconds != 640 || view.SampleCount != 2 {
		t.Fatalf("unexpected metrics: %+v", view)
	}
	if len(view.ActiveTracks) != 2 || view.ActiveTracks[0].TrackNo != 2 || view.ActiveTracks[1].OperationalStatus != "BUSY" {
		t.Fatalf("unexpected active tracks: %+v", view.ActiveTracks)
	}
}

func TestMapCornerViewAllowsNoActiveTracks(t *testing.T) {
	view, err := mapCornerView("corner-1", "camp-1", "코너 1", 10, 0, 0, []byte(`[]`))
	if err != nil {
		t.Fatalf("expected no error, got %v", err)
	}
	if view.AvgDurationSeconds != 0 || view.SampleCount != 0 || len(view.ActiveTracks) != 0 {
		t.Fatalf("unexpected empty view: %+v", view)
	}
}
