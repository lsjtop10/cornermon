package web

import (
	"context"
	"errors"
	"fmt"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/usecase"

	"github.com/labstack/echo/v4"
)

type adminLoginUsecaseStub struct{ err error }

func (s adminLoginUsecaseStub) Login(context.Context, string, string, string) (string, *domain.AdminSession, error) {
	return "", nil, s.err
}
func (adminLoginUsecaseStub) RevokeSession(context.Context, domain.AdminSessionID, domain.AdminID) error {
	return nil
}
func (adminLoginUsecaseStub) ListSessions(context.Context, domain.AdminID) ([]*domain.AdminSession, error) {
	return nil, nil
}
func (adminLoginUsecaseStub) ForceTrackLogout(context.Context, domain.TrackID, domain.AdminID) error {
	return nil
}

// TestAdminLoginShouldMapExpectedErrorsToHTTPStatus는 로그인 실패 원인에 따라 상태 코드가
// 갈려야 함을 검증한다: 아이디/비밀번호 오류(domain.ErrAdminInvalidCredentials)만 401이고,
// 그 외(DB 커넥션 끊김 등 인프라 실패)는 500으로 떨어져야 한다. 과거에는 원인과 무관하게
// 무조건 401을 반환해 DB 장애가 "로그인 실패"로 오인되는 문제가 있었다.
func TestAdminLoginShouldMapExpectedErrorsToHTTPStatus(t *testing.T) {
	tests := []struct {
		name     string
		err      error
		wantCode int
		wantBody string
	}{
		{name: "invalid credentials", err: domain.ErrAdminInvalidCredentials, wantCode: http.StatusUnauthorized, wantBody: "UNAUTHORIZED"},
		{name: "wrapped invalid credentials", err: fmt.Errorf("login failed: %w", domain.ErrAdminInvalidCredentials), wantCode: http.StatusUnauthorized, wantBody: "UNAUTHORIZED"},
		{name: "infra failure (e.g. db down)", err: errors.New("context canceled"), wantCode: http.StatusInternalServerError, wantBody: "INTERNAL_SERVER_ERROR"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// arrange
			e := echo.New()
			e.HTTPErrorHandler = ErrorHandler()
			e.POST("/api/v1/auth/admin/login", NewAuthHandler(adminLoginUsecaseStub{err: tt.err}, nil, nil).AdminLogin)
			req := httptest.NewRequest(http.MethodPost, "/api/v1/auth/admin/login", strings.NewReader(`{"id":"orca","password":"pw"}`))
			req.Header.Set(echo.HeaderContentType, echo.MIMEApplicationJSON)
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
