package web

import (
	"context"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/usecase"
	"github.com/labstack/echo/v4"
)

type trackRepoForGroupHandler struct{ track *domain.Track }

func (r trackRepoForGroupHandler) Get(context.Context, domain.TrackID) (*domain.Track, error) {
	return r.track, nil
}
func (trackRepoForGroupHandler) ListByCorner(context.Context, domain.CornerID) ([]*domain.Track, error) {
	return nil, nil
}
func (trackRepoForGroupHandler) ListActiveByCamp(context.Context, domain.CampID) ([]*domain.Track, error) {
	return nil, nil
}
func (trackRepoForGroupHandler) ListByCamp(context.Context, domain.CampID) ([]*domain.Track, error) {
	return nil, nil
}
func (trackRepoForGroupHandler) Save(context.Context, *domain.Track) error { return nil }
func (trackRepoForGroupHandler) IncrementUnreadCount(context.Context, domain.TrackID, domain.SenderRole) error {
	return nil
}
func (trackRepoForGroupHandler) ResetUnreadCount(context.Context, domain.TrackID, domain.SenderRole) error {
	return nil
}

type cornerRepoForGroupHandler struct{ corner *domain.Corner }

func (r cornerRepoForGroupHandler) Get(context.Context, domain.CornerID) (*domain.Corner, error) {
	return r.corner, nil
}
func (cornerRepoForGroupHandler) ListByCamp(context.Context, domain.CampID) ([]*domain.Corner, error) {
	return nil, nil
}
func (cornerRepoForGroupHandler) Save(context.Context, *domain.Corner) error { return nil }
func (cornerRepoForGroupHandler) SoftDelete(context.Context, domain.CornerID, time.Time) error {
	return nil
}

type groupRepoForGroupHandler struct{ groups []*domain.Group }

func (groupRepoForGroupHandler) Get(context.Context, domain.GroupID) (*domain.Group, error) {
	return nil, nil
}
func (groupRepoForGroupHandler) GetForUpdate(context.Context, domain.GroupID) (*domain.Group, error) {
	return nil, nil
}
func (groupRepoForGroupHandler) GetByBadge(context.Context, domain.CampID, domain.BadgeID) (*domain.Group, error) {
	return nil, nil
}
func (r groupRepoForGroupHandler) ListByCamp(context.Context, domain.CampID) ([]*domain.Group, error) {
	return r.groups, nil
}
func (r groupRepoForGroupHandler) ListByCampForUpdate(context.Context, domain.CampID) ([]*domain.Group, error) {
	return r.groups, nil
}
func (groupRepoForGroupHandler) Save(context.Context, *domain.Group) error       { return nil }
func (groupRepoForGroupHandler) SaveBulk(context.Context, []*domain.Group) error { return nil }

func TestListGroupsByTrackShoudReturnGroupsWhenSessionTrackMatchesPath(t *testing.T) {
	// Arrange
	service := usecase.NewGroupService(
		nil,
		cornerRepoForGroupHandler{corner: domain.NewCornerFromProps(domain.CornerProps{ID: "corner-1", CampID: "camp-1"})},
		trackRepoForGroupHandler{track: domain.NewTrackFromProps(domain.TrackProps{ID: "track-1", CornerID: "corner-1"})},
		groupRepoForGroupHandler{groups: []*domain.Group{domain.NewGroupFromProps(domain.GroupProps{ID: "group-1", CampID: "camp-1", Name: "1조"})}},
		nil, nil, nil, nil, nil,
	)
	e := echo.New()
	req := httptest.NewRequest(http.MethodGet, "/tracks/track-1/groups", nil)
	rec := httptest.NewRecorder()
	c := e.NewContext(req, rec)
	c.SetParamNames("trackId")
	c.SetParamValues("track-1")
	c.Set("facilitatorSession", domain.NewFacilitatorSessionFromProps(domain.FacilitatorSessionProps{TrackID: "track-1"}))

	// Act
	err := NewGroupHandler(service).ListGroupsByTrack(c)

	// Assert
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if rec.Code != http.StatusOK || rec.Body.String() == "[]\n" {
		t.Fatalf("unexpected response: status=%d body=%s", rec.Code, rec.Body.String())
	}
}

func TestListGroupsByTrackShoudRejectRequestWhenSessionTrackDiffers(t *testing.T) {
	// Arrange
	e := echo.New()
	req := httptest.NewRequest(http.MethodGet, "/tracks/track-2/groups", nil)
	rec := httptest.NewRecorder()
	c := e.NewContext(req, rec)
	c.SetParamNames("trackId")
	c.SetParamValues("track-2")
	c.Set("facilitatorSession", domain.NewFacilitatorSessionFromProps(domain.FacilitatorSessionProps{TrackID: "track-1"}))

	// Act
	err := NewGroupHandler(nil).ListGroupsByTrack(c)

	// Assert
	var httpErr *echo.HTTPError
	if !errorsAsHTTPError(err, &httpErr) || httpErr.Code != http.StatusForbidden {
		t.Fatalf("expected 403 HTTP error, got %v", err)
	}
}
