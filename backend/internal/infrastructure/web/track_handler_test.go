//go:build ignore

package web

import (
	"encoding/json"
	"strings"
	"testing"
)

func TestTrackResponseShoudNotExposePINWhenMarshaled(t *testing.T) {
	// Arrange
	response := TrackResponse{TrackSummaryResponse: TrackSummaryResponse{ID: "track-1"}}

	// Act
	body, err := json.Marshal(response)

	// Assert
	if err != nil {
		t.Fatalf("unexpected marshal error: %v", err)
	}
	if strings.Contains(string(body), "pin") {
		t.Fatalf("ordinary track response exposes PIN: %s", body)
	}
}
