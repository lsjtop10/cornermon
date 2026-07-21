package web

import (
	"context"
	"fmt"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/usecase"

	"github.com/labstack/echo/v4"
)

type trackLoginUsecaseStub struct{ err error }

func (s trackLoginUsecaseStub) Login(context.Context, string, string) (*usecase.TrackLoginResult, error) {
	return nil, s.err
}
func (trackLoginUsecaseStub) Logout(context.Context, domain.FacilitatorSessionID) error { return nil }
func (trackLoginUsecaseStub) MigrateSession(context.Context, string) (*usecase.TrackLoginResult, error) {
	return nil, nil
}
func (trackLoginUsecaseStub) ListActiveSessions(context.Context, domain.CampID) ([]*domain.FacilitatorSession, error) {
	return nil, nil
}

func TestTrackLoginShouldMapExpectedDomainErrorsToHTTPStatus(t *testing.T) {
	tests := []struct {
		name     string
		err      error
		wantCode int
		wantBody string
	}{
		{name: "device not approved", err: domain.ErrDeviceNotApproved, wantCode: http.StatusForbidden, wantBody: "DEVICE_NOT_APPROVED"},
		{name: "device locked", err: domain.NewDeviceLockedErrorFromProps(domain.DeviceLockedErrorProps{}), wantCode: http.StatusTooManyRequests, wantBody: "DEVICE_LOCKED"},
		{name: "invalid pin", err: domain.NewInvalidPinErrorFromProps(domain.InvalidPinErrorProps{}), wantCode: http.StatusBadRequest, wantBody: "INVALID_PIN"},
		{name: "wrapped unavailable camp", err: fmt.Errorf("login failed: %w", domain.ErrCampInvalidTransition), wantCode: http.StatusForbidden, wantBody: "CAMP_NOT_AVAILABLE"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// arrange
			e := echo.New()
			e.HTTPErrorHandler = ErrorHandler()
			e.POST("/api/v1/auth/track/login", NewAuthHandler(nil, trackLoginUsecaseStub{err: tt.err}, nil).TrackLogin)
			req := httptest.NewRequest(http.MethodPost, "/api/v1/auth/track/login", strings.NewReader(`{"pin":"123456"}`))
			req.Header.Set(echo.HeaderContentType, echo.MIMEApplicationJSON)
			req.Header.Set("X-Device-Token", "device-token")
			rec := httptest.NewRecorder()

			// act
			e.ServeHTTP(rec, req)

			// assert
			if rec.Code != tt.wantCode {
				t.Fatalf("expected status %d, got %d: %s", tt.wantCode, rec.Code, rec.Body.String())
			}
			if !strings.Contains(rec.Body.String(), tt.wantBody) {
				t.Fatalf("expected response body to contain %q, got %s", tt.wantBody, rec.Body.String())
			}
		})
	}
}
