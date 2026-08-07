package sse

import (
	"bytes"
	"context"
	"log/slog"
	"strings"
	"testing"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/errs"
	"cornermon/backend/internal/usecase"
)

// withCapturedLogger는 slog 기본 로거를 버퍼를 향하는 JSON 핸들러(운영 설정과 동일하게
// errs.SlogWrappedHandler로 감쌈)로 교체하고, 테스트 종료 시 원복하는 cleanup 함수를 등록한다.
func withCapturedLogger(t *testing.T) *bytes.Buffer {
	t.Helper()
	buf := &bytes.Buffer{}
	original := slog.Default()
	slog.SetDefault(slog.New(errs.NewSlogWrappedHandler(slog.NewJSONHandler(buf, &slog.HandlerOptions{Level: slog.LevelDebug}))))
	t.Cleanup(func() { slog.SetDefault(original) })
	return buf
}

func TestShouldLogCauseTraceID_WhenBroadcastDispatched(t *testing.T) {
	// Arrange
	buf := withCapturedLogger(t)
	broadcaster := NewBroadcaster()
	ctx := context.WithValue(context.Background(), errs.TraceIDKey, "trace-broadcast")

	// Act
	err := broadcaster.Broadcast(ctx, "camp-a", usecase.EventCampUpdated, usecase.CampScope())

	// Assert
	if err != nil {
		t.Fatalf("Broadcast() error = %v", err)
	}
	logLine := buf.String()
	// trace_id는 SlogWrappedHandler가 ctx로부터 자동 주입한 값(=발행 요청 자신),
	// cause_trace_id는 Broadcast가 message에 실어 SSE 연결까지 전달하는 동일한 값이다.
	if !strings.Contains(logLine, `"trace_id":"trace-broadcast"`) {
		t.Errorf("expected log to contain trace_id, got: %s", logLine)
	}
	if !strings.Contains(logLine, `"cause_trace_id":"trace-broadcast"`) {
		t.Errorf("expected log to contain cause_trace_id, got: %s", logLine)
	}
}

func TestShouldSetCauseTraceIDOnMessage_WhenBroadcastDispatched(t *testing.T) {
	// Arrange
	broadcaster := NewBroadcaster()
	admin, _ := broadcaster.SubscribeAdmin(context.Background(), "camp-a")
	ctx := context.WithValue(context.Background(), errs.TraceIDKey, "trace-message")

	// Act
	_ = broadcaster.Broadcast(ctx, "camp-a", usecase.EventCampUpdated, usecase.CampScope())

	// Assert
	message := <-admin
	if message.CauseTraceID != "trace-message" {
		t.Errorf("expected message.CauseTraceID = %q, got %q", "trace-message", message.CauseTraceID)
	}
}

func TestShouldLogCauseTraceID_WhenSubscriberBufferFull(t *testing.T) {
	// Arrange
	broadcaster := NewBroadcaster()
	admin, _ := broadcaster.SubscribeAdmin(context.Background(), "camp-a")
	for range subscriberBufferSize {
		_ = broadcaster.Broadcast(context.Background(), "camp-a", usecase.EventCampUpdated, usecase.CampScope())
	}
	buf := withCapturedLogger(t)
	ctx := context.WithValue(context.Background(), errs.TraceIDKey, "trace-full")

	// Act
	_ = broadcaster.Broadcast(ctx, "camp-a", usecase.EventCampUpdated, usecase.CampScope())

	// Assert
	for range subscriberBufferSize {
		<-admin
	}
	if !strings.Contains(buf.String(), `"cause_trace_id":"trace-full"`) {
		t.Errorf("expected buffer-full warning log to contain cause_trace_id, got: %s", buf.String())
	}
}

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
