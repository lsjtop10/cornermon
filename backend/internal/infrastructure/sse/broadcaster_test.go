
package sse

import (
	"context"
	"testing"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/usecase"
)

func TestShouldIsolateSubscribersWhenBroadcastingAcrossCamps(t *testing.T) {
	// Arrange
	broadcaster := NewBroadcaster()
	campAAdmin, _ := broadcaster.SubscribeAdmin(context.Background(), "camp-a")
	campBAdmin, _ := broadcaster.SubscribeAdmin(context.Background(), "camp-b")
	campATrack, _ := broadcaster.SubscribeTrack(context.Background(), "camp-a", "track-a")
	campBTrack, _ := broadcaster.SubscribeTrack(context.Background(), "camp-b", "track-b")

	// Act
	err := broadcaster.Broadcast(context.Background(), "camp-a", usecase.EventCampUpdated, usecase.CampScope())

	// Assert
	if err != nil {
		t.Fatalf("Broadcast() error = %v", err)
	}
	assertMessageReceived(t, campAAdmin, usecase.EventCampUpdated)
	assertMessageReceived(t, campATrack, usecase.EventCampUpdated)
	assertNoMessage(t, campBAdmin)
	assertNoMessage(t, campBTrack)
}

func TestShouldSendOnlyTargetTrackWhenBroadcastingTrackScope(t *testing.T) {
	// Arrange
	broadcaster := NewBroadcaster()
	target, _ := broadcaster.SubscribeTrack(context.Background(), "camp-a", "track-a")
	other, _ := broadcaster.SubscribeTrack(context.Background(), "camp-a", "track-b")

	// Act
	_ = broadcaster.Broadcast(context.Background(), "camp-a", usecase.EventTrackUpdated, usecase.TrackScope("track-a"))

	// Assert
	assertMessageReceived(t, target, usecase.EventTrackUpdated)
	assertNoMessage(t, other)
}

func TestShouldCloseSubscriberWhenBufferIsFull(t *testing.T) {
	// Arrange
	broadcaster := NewBroadcaster()
	admin, _ := broadcaster.SubscribeAdmin(context.Background(), "camp-a")
	for range subscriberBufferSize {
		_ = broadcaster.Broadcast(context.Background(), "camp-a", usecase.EventCampUpdated, usecase.CampScope())
	}

	// Act
	_ = broadcaster.Broadcast(context.Background(), "camp-a", usecase.EventCampUpdated, usecase.CampScope())

	// Assert
	for range subscriberBufferSize {
		<-admin
	}
	if _, ok := <-admin; ok {
		t.Fatal("full subscriber channel should be closed")
	}
	if _, ok := broadcaster.adminSubs[domain.CampID("camp-a")]; ok {
		t.Fatal("full subscriber should be removed from registry")
	}
}

func TestShouldCloseTrackSubscriberWhenBufferIsFull(t *testing.T) {
	// Arrange
	broadcaster := NewBroadcaster()
	track, _ := broadcaster.SubscribeTrack(context.Background(), "camp-a", "track-a")
	for range subscriberBufferSize {
		_ = broadcaster.Broadcast(context.Background(), "camp-a", usecase.EventTrackUpdated, usecase.TrackScope("track-a"))
	}

	// Act
	_ = broadcaster.Broadcast(context.Background(), "camp-a", usecase.EventTrackUpdated, usecase.TrackScope("track-a"))

	// Assert
	for range subscriberBufferSize {
		<-track
	}
	if _, ok := <-track; ok {
		t.Fatal("full track subscriber channel should be closed")
	}
	if _, ok := broadcaster.trackSubs[domain.TrackID("track-a")]; ok {
		t.Fatal("full track subscriber should be removed from registry")
	}
}

func assertMessageReceived(t *testing.T, ch <-chan usecase.SSEMessage, event usecase.NotificationEvent) {
	t.Helper()
	select {
	case message := <-ch:
		if message.Event != event {
			t.Fatalf("message event = %q, want %q", message.Event, event)
		}
	default:
		t.Fatal("expected message, got none")
	}
}

func assertNoMessage(t *testing.T, ch <-chan usecase.SSEMessage) {
	t.Helper()
	select {
	case message := <-ch:
		t.Fatalf("unexpected message: %+v", message)
	default:
	}
}
