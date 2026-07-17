package web

import (
	"context"
	"errors"
	"net/http"
	"net/http/httptest"
	"testing"

	"cornermon/backend/internal/domain"

	"github.com/labstack/echo/v4"
)

type adminAuthForMessageRoutes struct{}

func (adminAuthForMessageRoutes) ValidateAccessToken(_ context.Context, token string) (*domain.AdminSession, error) {
	if token == "admin-token" {
		return &domain.AdminSession{}, nil
	}
	return nil, errors.New("invalid admin token")
}

type trackAuthForMessageRoutes struct{}

func (trackAuthForMessageRoutes) ValidateSession(_ context.Context, token string) (*domain.FacilitatorSession, error) {
	if token == "track-token" {
		return domain.NewFacilitatorSessionFromProps(domain.FacilitatorSessionProps{TrackID: "track-1"}), nil
	}
	return nil, errors.New("invalid track token")
}

func TestMessageRoutesShoudAuthenticateAdminAndTrackWithoutDuplicateRouteRegistration(t *testing.T) {
	// Arrange
	uc := &messageUsecaseForHandler{}
	e := echo.New()
	RegisterRoutes(e, &Handlers{Auth: &AuthHandler{}, Device: &DeviceHandler{}, Message: NewMessageHandler(uc, nil)}, adminAuthForMessageRoutes{}, trackAuthForMessageRoutes{})

	for _, tc := range []struct {
		name     string
		token    string
		expected domain.SenderRole
	}{
		{name: "admin", token: "admin-token", expected: domain.RoleAdmin},
		{name: "track", token: "track-token", expected: domain.RoleTrack},
	} {
		t.Run(tc.name, func(t *testing.T) {
			// Act
			req := httptest.NewRequest(http.MethodGet, "/api/v1/tracks/track-1/messages", nil)
			req.Header.Set(echo.HeaderAuthorization, "Bearer "+tc.token)
			rec := httptest.NewRecorder()
			e.ServeHTTP(rec, req)

			// Assert
			if rec.Code != http.StatusOK {
				t.Fatalf("expected status 200, got %d: %s", rec.Code, rec.Body.String())
			}
			if uc.viewerRole != tc.expected {
				t.Fatalf("expected viewer role %s, got %s", tc.expected, uc.viewerRole)
			}
		})
	}
}

func TestListBroadcastsRouteShoudAuthenticateBothAdminAndTrackSessions(t *testing.T) {
	// Arrange
	announcementUC := &announcementUsecaseForHandler{notices: []*domain.Announcement{{ID: "notice-1", CampID: "camp-1", Content: "hello"}}}
	e := echo.New()
	RegisterRoutes(e, &Handlers{Auth: &AuthHandler{}, Device: &DeviceHandler{}, Message: NewMessageHandler(&messageUsecaseForHandler{}, announcementUC)}, adminAuthForMessageRoutes{}, trackAuthForMessageRoutes{})

	for _, tc := range []struct {
		name  string
		token string
	}{
		{name: "admin", token: "admin-token"},
		{name: "track", token: "track-token"},
	} {
		t.Run(tc.name, func(t *testing.T) {
			// Act
			req := httptest.NewRequest(http.MethodGet, "/api/v1/camps/camp-1/messages/broadcast", nil)
			req.Header.Set(echo.HeaderAuthorization, "Bearer "+tc.token)
			rec := httptest.NewRecorder()
			e.ServeHTTP(rec, req)

			// Assert
			if rec.Code != http.StatusOK {
				t.Fatalf("expected status 200, got %d: %s", rec.Code, rec.Body.String())
			}
		})
	}
}

func TestListBroadcastsRouteShoudRejectRequestWithoutSession(t *testing.T) {
	// Arrange
	announcementUC := &announcementUsecaseForHandler{}
	e := echo.New()
	RegisterRoutes(e, &Handlers{Auth: &AuthHandler{}, Device: &DeviceHandler{}, Message: NewMessageHandler(&messageUsecaseForHandler{}, announcementUC)}, adminAuthForMessageRoutes{}, trackAuthForMessageRoutes{})

	// Act
	req := httptest.NewRequest(http.MethodGet, "/api/v1/camps/camp-1/messages/broadcast", nil)
	rec := httptest.NewRecorder()
	e.ServeHTTP(rec, req)

	// Assert
	if rec.Code != http.StatusUnauthorized {
		t.Fatalf("expected status 401, got %d: %s", rec.Code, rec.Body.String())
	}
}
