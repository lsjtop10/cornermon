
package web

import (
	"context"
	"reflect"
	"slices"
	"sort"
	"strings"
	"testing"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/usecase"
)

type mockSubscriber struct {
	adminCh     chan usecase.SSEMessage
	trackCh     chan usecase.SSEMessage
	adminCampID domain.CampID
	trackCampID domain.CampID
	trackID     domain.TrackID
}

func (m *mockSubscriber) SubscribeAdmin(_ context.Context, campID domain.CampID) (<-chan usecase.SSEMessage, error) {
	m.adminCampID = campID
	return m.adminCh, nil
}

func (m *mockSubscriber) SubscribeTrack(_ context.Context, campID domain.CampID, trackID domain.TrackID) (<-chan usecase.SSEMessage, error) {
	m.trackCampID = campID
	m.trackID = trackID
	return m.trackCh, nil
}

func TestShouldFormatStructuredPayloadWhenFormattingSSEMessage(t *testing.T) {
	// Arrange
	message := usecase.SSEMessage{
		Event: usecase.EventTrackUpdated,
		Scope: usecase.TrackScope("track-1"),
	}

	// Act
	got, err := formatSSEMessage(message)

	// Assert
	if err != nil {
		t.Fatalf("formatSSEMessage() error = %v", err)
	}
	want := "event: track_updated\ndata: {\"event\":\"track_updated\",\"scope\":{\"kind\":\"track\",\"trackId\":\"track-1\"}}\n\n"
	if got != want {
		t.Fatalf("formatSSEMessage() = %q, want %q", got, want)
	}
}

func TestShouldOmitTrackIDWhenFormattingCampScope(t *testing.T) {
	// Arrange
	message := usecase.SSEMessage{Event: usecase.EventCampUpdated, Scope: usecase.CampScope()}

	// Act
	got, err := formatSSEMessage(message)

	// Assert
	if err != nil {
		t.Fatalf("formatSSEMessage() error = %v", err)
	}
	if strings.Contains(got, "trackId") {
		t.Fatalf("camp-scoped payload should omit trackId: %s", got)
	}
}

func TestShouldKeepSwaggerEventEnumInSyncWhenNotificationEventsChange(t *testing.T) {
	// Arrange
	field, _ := reflect.TypeOf(SSENotification{}).FieldByName("Event")
	got := strings.Split(field.Tag.Get("enums"), ",")
	want := make([]string, 0, len(usecase.NotificationEvents()))
	for _, event := range usecase.NotificationEvents() {
		want = append(want, string(event))
	}

	// Act
	sort.Strings(got)
	sort.Strings(want)

	// Assert
	if !slices.Equal(got, want) {
		t.Fatalf("SSENotification Event enums = %v, want %v", got, want)
	}
}
