package web

import (
	"context"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/labstack/echo/v4"
)

type mockSubscriber struct {
	adminCh chan string
	trackCh chan string
}

func (m *mockSubscriber) SubscribeAdmin(ctx context.Context) (<-chan string, error) {
	return m.adminCh, nil
}

func (m *mockSubscriber) SubscribeTrack(ctx context.Context, trackID string) (<-chan string, error) {
	return m.trackCh, nil
}

func TestEventHandler_Headers(t *testing.T) {
	// Arrange
	e := echo.New()
	req := httptest.NewRequest(http.MethodGet, "/api/v1/events/admin", nil)
	rec := httptest.NewRecorder()
	c := e.NewContext(req, rec)

	sub := &mockSubscriber{
		adminCh: make(chan string),
	}
	h := NewEventHandler(sub)

	ctx, cancel := context.WithCancel(context.Background())
	req = req.WithContext(ctx)
	c.SetRequest(req)

	// Act - Cancel immediately to stop the handler from waiting 15 seconds
	go func() {
		time.Sleep(100 * time.Millisecond)
		cancel()
	}()

	err := h.AdminEvents(c)

	// Assert
	if err != nil {
		t.Fatalf("expected no error, got %v", err)
	}

	headers := rec.Header()
	if headers.Get("Content-Type") != "text/event-stream" {
		t.Errorf("expected Content-Type text/event-stream, got %s", headers.Get("Content-Type"))
	}
	if headers.Get("X-Accel-Buffering") != "no" {
		t.Errorf("expected X-Accel-Buffering no, got %s", headers.Get("X-Accel-Buffering"))
	}
}
