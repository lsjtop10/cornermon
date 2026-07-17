//go:build ignore

package web

import (
	"encoding/json"
	"testing"
)

func TestUpdateCampRequestShoudDistinguishOmittedFieldsFromZeroValues(t *testing.T) {
	// Arrange
	var request UpdateCampRequest

	// Act
	err := json.Unmarshal([]byte(`{"name":"","bottleneckMinSamples":0,"bottleneckRatioPct":0}`), &request)

	// Assert
	if err != nil {
		t.Fatalf("unexpected decode error: %v", err)
	}
	if request.Name == nil || *request.Name != "" {
		t.Fatalf("explicit empty name was treated as omitted: %+v", request.Name)
	}
	if request.BottleneckMinSamples == nil || *request.BottleneckMinSamples != 0 {
		t.Fatalf("explicit zero samples was treated as omitted: %+v", request.BottleneckMinSamples)
	}
	if request.BottleneckRatioPct == nil || *request.BottleneckRatioPct != 0 {
		t.Fatalf("explicit zero ratio was treated as omitted: %+v", request.BottleneckRatioPct)
	}
	if request.StartAt != nil || request.EndAt != nil {
		t.Fatalf("omitted dates were unexpectedly set: start=%v end=%v", request.StartAt, request.EndAt)
	}
}
