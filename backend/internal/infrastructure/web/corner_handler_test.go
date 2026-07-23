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

func TestCreateCornerShouldReturnBadRequestWhenTargetMinutesIsNonPositive(t *testing.T) {
	// Arrange
	e := echo.New()
	req := httptest.NewRequest(http.MethodPost, "/corners", strings.NewReader(`{"campId":"camp-1","name":"코너 1","targetMinutes":0}`))
	req.Header.Set(echo.HeaderContentType, echo.MIMEApplicationJSON)
	rec := httptest.NewRecorder()
	c := e.NewContext(req, rec)

	// Act
	err := NewCornerHandler(nil, nil).CreateCorner(c)

	// Assert
	var httpErr *echo.HTTPError
	if !errorsAsHTTPError(err, &httpErr) || httpErr.Code != http.StatusBadRequest {
		t.Fatalf("expected 400 for non-positive targetMinutes, got %v", err)
	}
}

func TestBulkUpdateCornersShouldReturnBadRequestWhenTargetMinutesIsNonPositive(t *testing.T) {
	// Arrange
	e := echo.New()
	req := httptest.NewRequest(http.MethodPut, "/corners/bulk-update", strings.NewReader(`{"corners":[{"id":"corner-1","name":"코너 1","targetMinutes":-1}]}`))
	req.Header.Set(echo.HeaderContentType, echo.MIMEApplicationJSON)
	rec := httptest.NewRecorder()
	c := e.NewContext(req, rec)

	// Act
	err := NewCornerHandler(nil, nil).BulkUpdateCorners(c)

	// Assert
	var httpErr *echo.HTTPError
	if !errorsAsHTTPError(err, &httpErr) || httpErr.Code != http.StatusBadRequest {
		t.Fatalf("expected 400 for non-positive targetMinutes, got %v", err)
	}
}

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

	t.Run("maps missing corner to not found HTTP error", func(t *testing.T) {
		e := echo.New()
		req := httptest.NewRequest(http.MethodGet, "/corners/missing", nil)
		rec := httptest.NewRecorder()
		c := e.NewContext(req, rec)
		c.SetPath("/corners/:id")
		c.SetParamNames("id")
		c.SetParamValues("missing")

		err := NewCornerHandler(nil, fakeCornerViewQuerier{}).GetCorner(c)
		var httpErr *echo.HTTPError
		if !errorsAsHTTPError(err, &httpErr) || httpErr.Code != http.StatusNotFound {
			t.Fatalf("expected 404 HTTP error, got %v", err)
		}
	})
}

func TestGetCornerByTrackShouldReturnCornerWhenSessionTrackMatchesPath(t *testing.T) {
	// Arrange
	corner := domain.NewCornerFromProps(domain.CornerProps{ID: "corner-1", CampID: "camp-1", Name: "코너 1", TargetMinutes: 10})
	track := domain.NewTrackFromProps(domain.TrackProps{ID: "track-1", CornerID: "corner-1"})
	service := usecase.NewCornerService(
		nil,
		cornerRepoForGroupHandler{corner: corner},
		trackRepoForGroupHandler{track: track},
		nil, nil, nil, nil, nil,
	)
	e := echo.New()
	req := httptest.NewRequest(http.MethodGet, "/tracks/track-1/corner", nil)
	rec := httptest.NewRecorder()
	c := e.NewContext(req, rec)
	c.SetPath("/tracks/:trackId/corner")
	c.SetParamNames("trackId")
	c.SetParamValues("track-1")
	c.Set("facilitatorSession", domain.NewFacilitatorSessionFromProps(domain.FacilitatorSessionProps{TrackID: "track-1"}))

	// Act
	err := NewCornerHandler(service, nil).GetCornerByTrack(c)

	// Assert
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	body := rec.Body.String()
	if rec.Code != http.StatusOK || !containsAll(body, `"id":"corner-1"`, `"targetMinutes":10`) || strings.Contains(body, `"activeTracks":[{`) {
		t.Fatalf("expected minimal corner response, status=%d body=%s", rec.Code, body)
	}
}

func TestGetCornerByTrackShouldRejectRequestWhenSessionTrackDiffers(t *testing.T) {
	// Arrange
	e := echo.New()
	req := httptest.NewRequest(http.MethodGet, "/tracks/track-2/corner", nil)
	rec := httptest.NewRecorder()
	c := e.NewContext(req, rec)
	c.SetPath("/tracks/:trackId/corner")
	c.SetParamNames("trackId")
	c.SetParamValues("track-2")
	c.Set("facilitatorSession", domain.NewFacilitatorSessionFromProps(domain.FacilitatorSessionProps{TrackID: "track-1"}))

	// Act
	err := NewCornerHandler(nil, nil).GetCornerByTrack(c)

	// Assert
	var httpErr *echo.HTTPError
	if !errorsAsHTTPError(err, &httpErr) || httpErr.Code != http.StatusForbidden {
		t.Fatalf("expected 403 Forbidden HTTPError, got %v", err)
	}
}

func TestGetCornerByTrackShouldReturnNotFoundWhenTrackMissing(t *testing.T) {
	// Arrange
	service := usecase.NewCornerService(
		nil,
		cornerRepoForGroupHandler{},
		trackRepoForGroupHandler{},
		nil, nil, nil, nil, nil,
	)
	e := echo.New()
	req := httptest.NewRequest(http.MethodGet, "/tracks/track-1/corner", nil)
	rec := httptest.NewRecorder()
	c := e.NewContext(req, rec)
	c.SetPath("/tracks/:trackId/corner")
	c.SetParamNames("trackId")
	c.SetParamValues("track-1")
	c.Set("facilitatorSession", domain.NewFacilitatorSessionFromProps(domain.FacilitatorSessionProps{TrackID: "track-1"}))

	// Act
	err := NewCornerHandler(service, nil).GetCornerByTrack(c)

	// Assert
	var httpErr *echo.HTTPError
	if !errorsAsHTTPError(err, &httpErr) || httpErr.Code != http.StatusNotFound {
		t.Fatalf("expected 404 NotFound HTTPError, got %v", err)
	}
}

func errorsAsHTTPError(err error, target **echo.HTTPError) bool {
	he, ok := err.(*echo.HTTPError)
	if !ok {
		return false
	}
	*target = he
	return true
}

func containsAll(value string, parts ...string) bool {
	for _, part := range parts {
		if !strings.Contains(value, part) {
			return false
		}
	}
	return true
}
