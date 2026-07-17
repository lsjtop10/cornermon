//go:build ignore

package web

import (
	"context"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/usecase"

	"github.com/labstack/echo/v4"
)

type fakeCornerViewQuerier struct {
	views []usecase.CornerView
}

func (f fakeCornerViewQuerier) ListCornerViewsByCamp(context.Context, domain.CampID) ([]usecase.CornerView, error) {
	return f.views, nil
}

func (f fakeCornerViewQuerier) GetCornerView(context.Context, domain.CornerID) (*usecase.CornerView, error) {
	if len(f.views) == 0 {
		return nil, nil
	}
	return &f.views[0], nil
}

func TestShouldReturnCornerMetricsWhenListingCornerViews(t *testing.T) {
	// Arrange
	e := echo.New()
	req := httptest.NewRequest(http.MethodGet, "/camps/camp-1/corners", nil)
	rec := httptest.NewRecorder()
	c := e.NewContext(req, rec)
	c.SetPath("/camps/:campId/corners")
	c.SetParamNames("campId")
	c.SetParamValues("camp-1")
	h := NewCornerHandler(nil, fakeCornerViewQuerier{views: []usecase.CornerView{{
		ID: "corner-1", CampID: "camp-1", Name: "코너 1", TargetMinutes: 10, AvgDurationSeconds: 640, SampleCount: 15,
		ActiveTracks: []usecase.TrackView{{ID: "track-1", CornerID: "corner-1", TrackNo: 1, Status: domain.TrackActive, OperationalStatus: domain.TrackBusy}},
	}}})

	// Act
	err := h.ListCorners(c)

	// Assert
	if err != nil {
		t.Fatalf("expected no error, got %v", err)
	}
	body := rec.Body.String()
	if rec.Code != http.StatusOK || !containsAll(body, `"cornerMetric"`, `"avgDurationSeconds":640`, `"sampleCount":15`, `"activeTracks"`, `"id":"track-1"`, `"operationalStatus":"BUSY"`) {
		t.Fatalf("expected documented metric response, status=%d body=%s", rec.Code, body)
	}
}

func TestGetCornerShouldReturnViewAndNotFound(t *testing.T) {
	t.Run("returns the complete view", func(t *testing.T) {
		e := echo.New()
		req := httptest.NewRequest(http.MethodGet, "/corners/corner-1", nil)
		rec := httptest.NewRecorder()
		c := e.NewContext(req, rec)
		c.SetPath("/corners/:id")
		c.SetParamNames("id")
		c.SetParamValues("corner-1")
		h := NewCornerHandler(nil, fakeCornerViewQuerier{views: []usecase.CornerView{{
			ID: "corner-1", CampID: "camp-1", Name: "코너 1", TargetMinutes: 10, AvgDurationSeconds: 600, SampleCount: 2,
			ActiveTracks: []usecase.TrackView{{ID: "track-2", CornerID: "corner-1", TrackNo: 2, Status: domain.TrackActive, OperationalStatus: domain.TrackIdle}},
		}}})

		if err := h.GetCorner(c); err != nil {
			t.Fatalf("expected no error, got %v", err)
		}
		if rec.Code != http.StatusOK || !containsAll(rec.Body.String(), `"sampleCount":2`, `"id":"track-2"`, `"operationalStatus":"IDLE"`) {
			t.Fatalf("expected complete corner view, status=%d body=%s", rec.Code, rec.Body.String())
		}
	})

	t.Run("returns the domain not-found error", func(t *testing.T) {
		e := echo.New()
		req := httptest.NewRequest(http.MethodGet, "/corners/missing", nil)
		rec := httptest.NewRecorder()
		c := e.NewContext(req, rec)
		c.SetPath("/corners/:id")
		c.SetParamNames("id")
		c.SetParamValues("missing")

		err := NewCornerHandler(nil, fakeCornerViewQuerier{}).GetCorner(c)
		if err != domain.ErrCornerNotFound {
			t.Fatalf("expected ErrCornerNotFound, got %v", err)
		}
	})
}

func containsAll(value string, parts ...string) bool {
	for _, part := range parts {
		if !strings.Contains(value, part) {
			return false
		}
	}
	return true
}
