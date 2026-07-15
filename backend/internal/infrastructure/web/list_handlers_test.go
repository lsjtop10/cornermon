package web

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/usecase"

	"github.com/labstack/echo/v4"
)

type listDeviceTrustStub struct {
	devices         []*domain.DeviceRegistration
	requestedReg    *domain.DeviceRegistration
	reviewedDevices []*domain.DeviceRegistration
}

func (s *listDeviceTrustStub) GetMyRegistrationStatus(context.Context, string) (*domain.DeviceRegistrationStatus, error) {
	return nil, nil
}
func (s *listDeviceTrustStub) RequestRegistration(context.Context, domain.CampID, string) (string, *domain.DeviceRegistration, error) {
	return "token", s.requestedReg, nil
}
func (s *listDeviceTrustStub) ApproveDevice(context.Context, domain.DeviceRegistrationID, domain.AdminID) error {
	return nil
}
func (s *listDeviceTrustStub) RejectDevice(context.Context, domain.DeviceRegistrationID, domain.AdminID) error {
	return nil
}
func (s *listDeviceTrustStub) RevokeDevice(context.Context, domain.DeviceRegistrationID, domain.AdminID) error {
	return nil
}
func (s *listDeviceTrustStub) ReviewDeviceTrustRequests(context.Context, domain.CampID, *domain.DeviceRegistrationStatus) ([]*domain.DeviceRegistration, error) {
	return s.reviewedDevices, nil
}
func (s *listDeviceTrustStub) ListLockedDevices(context.Context, domain.CampID) ([]*domain.DeviceRegistration, error) {
	return s.devices, nil
}

type listFacilitatorAuthStub struct{ sessions []*domain.FacilitatorSession }

func (s *listFacilitatorAuthStub) Login(context.Context, string, string) (*usecase.TrackLoginResult, error) {
	return nil, nil
}
func (s *listFacilitatorAuthStub) Logout(context.Context, domain.FacilitatorSessionID) error {
	return nil
}
func (s *listFacilitatorAuthStub) MigrateSession(context.Context, string) (*usecase.TrackLoginResult, error) {
	return nil, nil
}
func (s *listFacilitatorAuthStub) ListActiveSessions(context.Context, domain.CampID) ([]*domain.FacilitatorSession, error) {
	return s.sessions, nil
}

type listAdminAuthStub struct{}

func (listAdminAuthStub) ValidateAccessToken(context.Context, string) (*domain.AdminSession, error) {
	return nil, nil
}

func TestShouldReturnLockedDeviceResponseWhenCampIDIsProvided(t *testing.T) {
	// Arrange
	e := echo.New()
	lockedUntil := time.Date(2026, 7, 15, 12, 0, 0, 0, time.UTC)
	handler := NewDeviceHandler(&listDeviceTrustStub{devices: []*domain.DeviceRegistration{{ID: "device-1", DeviceName: "iPad", Status: domain.DeviceApproved, FailedPinAttempts: 5, LockedUntil: domain.Some(lockedUntil)}}})
	req := httptest.NewRequest(http.MethodGet, "/device-registrations/locked?campId=camp-1", nil)
	rec := httptest.NewRecorder()

	// Act
	err := handler.ListLockedDevices(e.NewContext(req, rec))

	// Assert
	if err != nil || rec.Code != http.StatusOK {
		t.Fatalf("expected 200 response, code=%d err=%v", rec.Code, err)
	}
	var response []DeviceRegistrationResponse
	if err := json.Unmarshal(rec.Body.Bytes(), &response); err != nil {
		t.Fatalf("decode response: %v", err)
	}
	if len(response) != 1 || response[0].ID != "device-1" || response[0].LockedUntil == nil || !response[0].LockedUntil.Equal(lockedUntil) {
		t.Fatalf("unexpected response: %+v", response)
	}
}

func TestShouldReturnActiveSessionResponseWhenCampIDIsProvided(t *testing.T) {
	// Arrange
	e := echo.New()
	createdAt := time.Date(2026, 7, 15, 10, 0, 0, 0, time.UTC)
	handler := NewAuthHandler(nil, &listFacilitatorAuthStub{sessions: []*domain.FacilitatorSession{{ID: "session-1", TrackID: "track-1", CreatedAt: createdAt}}}, nil)
	req := httptest.NewRequest(http.MethodGet, "/auth/track/sessions?campId=camp-1", nil)
	rec := httptest.NewRecorder()

	// Act
	err := handler.ListActiveFacilitatorSessions(e.NewContext(req, rec))

	// Assert
	if err != nil || rec.Code != http.StatusOK {
		t.Fatalf("expected 200 response, code=%d err=%v", rec.Code, err)
	}
	var response []FacilitatorSessionResponse
	if err := json.Unmarshal(rec.Body.Bytes(), &response); err != nil {
		t.Fatalf("decode response: %v", err)
	}
	if len(response) != 1 || response[0].ID != "session-1" || !response[0].CreatedAt.Equal(createdAt) {
		t.Fatalf("unexpected response: %+v", response)
	}
}

func TestShouldRejectListRequestsWhenCampIDIsMissing(t *testing.T) {
	for _, test := range []struct {
		name    string
		handler echo.HandlerFunc
		path    string
	}{
		{"locked devices", NewDeviceHandler(&listDeviceTrustStub{}).ListLockedDevices, "/device-registrations/locked"},
		{"active sessions", NewAuthHandler(nil, &listFacilitatorAuthStub{}, nil).ListActiveFacilitatorSessions, "/auth/track/sessions"},
	} {
		t.Run(test.name, func(t *testing.T) {
			// Arrange
			e := echo.New()
			req := httptest.NewRequest(http.MethodGet, test.path, nil)
			rec := httptest.NewRecorder()
			// Act
			err := test.handler(e.NewContext(req, rec))
			// Assert
			if err != nil || rec.Code != http.StatusBadRequest {
				t.Fatalf("expected 400 response, code=%d err=%v", rec.Code, err)
			}
		})
	}
}

func TestShouldRejectListRequestsWhenAdminAuthenticationIsMissing(t *testing.T) {
	// Arrange
	e := echo.New()
	admin := e.Group("")
	admin.Use(AdminAuthMiddleware(listAdminAuthStub{}))
	admin.GET("/auth/track/sessions", NewAuthHandler(nil, &listFacilitatorAuthStub{}, nil).ListActiveFacilitatorSessions)
	admin.GET("/device-registrations/locked", NewDeviceHandler(&listDeviceTrustStub{}).ListLockedDevices)

	for _, path := range []string{"/auth/track/sessions?campId=camp-1", "/device-registrations/locked?campId=camp-1"} {
		t.Run(path, func(t *testing.T) {
			// Act
			rec := httptest.NewRecorder()
			e.ServeHTTP(rec, httptest.NewRequest(http.MethodGet, path, nil))
			// Assert
			if rec.Code != http.StatusUnauthorized {
				t.Fatalf("expected 401 response, got %d", rec.Code)
			}
		})
	}
}
