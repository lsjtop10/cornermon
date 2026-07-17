
package web

import (
	"context"
	"encoding/json"
	"errors"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/labstack/echo/v4"
)

type stubPinger struct {
	err error
}

func (s *stubPinger) Ping(ctx context.Context) error {
	return s.err
}

func TestShouldReturnOkStatusWhenHealthChecked(t *testing.T) {
	// Arrange
	e := echo.New()
	handler := NewHealthHandler(&stubPinger{})
	req := httptest.NewRequest(http.MethodGet, "/health", nil)
	rec := httptest.NewRecorder()

	// Act
	err := handler.Check(e.NewContext(req, rec))

	// Assert
	if err != nil || rec.Code != http.StatusOK {
		t.Fatalf("expected 200 response, code=%d err=%v", rec.Code, err)
	}
	var response HealthResponse
	if err := json.Unmarshal(rec.Body.Bytes(), &response); err != nil {
		t.Fatalf("decode response: %v", err)
	}
	if response.Status != "ok" {
		t.Fatalf("expected status ok, got %s", response.Status)
	}
}

func TestShouldReturnOkStatusWhenReadyCheckedAndDbReachable(t *testing.T) {
	// Arrange
	e := echo.New()
	handler := NewHealthHandler(&stubPinger{})
	req := httptest.NewRequest(http.MethodGet, "/ready", nil)
	rec := httptest.NewRecorder()

	// Act
	err := handler.Ready(e.NewContext(req, rec))

	// Assert
	if err != nil || rec.Code != http.StatusOK {
		t.Fatalf("expected 200 response, code=%d err=%v", rec.Code, err)
	}
}

func TestShouldReturnServiceUnavailableWhenReadyCheckedAndDbUnreachable(t *testing.T) {
	// Arrange
	e := echo.New()
	handler := NewHealthHandler(&stubPinger{err: errors.New("connection refused")})
	req := httptest.NewRequest(http.MethodGet, "/ready", nil)
	rec := httptest.NewRecorder()

	// Act
	err := handler.Ready(e.NewContext(req, rec))

	// Assert
	if err != nil || rec.Code != http.StatusServiceUnavailable {
		t.Fatalf("expected 503 response, code=%d err=%v", rec.Code, err)
	}
}
