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
		ID: "corner-1", Name: "코너 1", TargetMinutes: 10, AvgDurationSeconds: 640, SampleCount: 15,
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

func containsAll(value string, parts ...string) bool {
	for _, part := range parts {
		if !strings.Contains(value, part) {
			return false
		}
	}
	return true
}
