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
	devices          []*domain.DeviceRegistration
	requestedReg     *domain.DeviceRegistration
	registrationCode string
	requestErr       error
	reviewedDevices  []*domain.DeviceRegistration
	myRegistration   *domain.DeviceRegistration
	campStatus       domain.CampStatus
	statusErr        error
	deviceToken      string
	mutatedDevice    *domain.DeviceRegistration
}

func (s *listDeviceTrustStub) GetMyRegistrationStatus(_ context.Context, deviceToken string) (*usecase.DeviceRegistrationStatusView, error) {
	s.deviceToken = deviceToken
	return &usecase.DeviceRegistrationStatusView{Registration: s.myRegistration, CampStatus: s.campStatus}, s.statusErr
}
func (s *listDeviceTrustStub) RequestRegistration(_ context.Context, registrationCode, _, _, _ string) (string, *domain.DeviceRegistration, error) {
	s.registrationCode = registrationCode
	if s.requestErr != nil {
		return "", nil, s.requestErr
	}
	return "token", s.requestedReg, nil
}
func (s *listDeviceTrustStub) ApproveDevice(context.Context, domain.DeviceRegistrationID, domain.AdminID) (*domain.DeviceRegistration, error) {
	return s.mutatedDevice, nil
}
func (s *listDeviceTrustStub) RejectDevice(context.Context, domain.DeviceRegistrationID, domain.AdminID) (*domain.DeviceRegistration, error) {
	return s.mutatedDevice, nil
}
func (s *listDeviceTrustStub) RevokeDevice(context.Context, domain.DeviceRegistrationID, domain.AdminID) (*domain.DeviceRegistration, error) {
	return s.mutatedDevice, nil
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
	e := echo.New()
	e.HTTPErrorHandler = ErrorHandler()
	lockedUntil := time.Date(2026, 7, 15, 12, 0, 0, 0, time.UTC)
	handler := NewDeviceHandler(&listDeviceTrustStub{devices: []*domain.DeviceRegistration{domain.NewDeviceRegistrationFromProps(domain.DeviceRegistrationProps{ID: "device-1", DeviceName: "iPad", Status: domain.DeviceApproved, FailedPinAttempts: 5, LockedUntil: domain.Some(lockedUntil)})}})
	req := httptest.NewRequest(http.MethodGet, "/camps/camp-1/device-registrations/locked", nil)
	rec := httptest.NewRecorder()
	ctx := e.NewContext(req, rec)
	ctx.SetPath("/camps/:campId/device-registrations/locked")
	ctx.SetParamNames("campId")
	ctx.SetParamValues("camp-1")

	// Act
	err := handler.ListLockedDevices(ctx)
	if err != nil {
		e.HTTPErrorHandler(err, ctx)
	}

	// Assert
	if rec.Code != http.StatusOK {
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
	e := echo.New()
	e.HTTPErrorHandler = ErrorHandler()
	createdAt := time.Date(2026, 7, 15, 10, 0, 0, 0, time.UTC)
	handler := NewAuthHandler(nil, &listFacilitatorAuthStub{sessions: []*domain.FacilitatorSession{domain.NewFacilitatorSessionFromProps(domain.FacilitatorSessionProps{ID: "session-1", TrackID: "track-1", CreatedAt: createdAt})}}, nil)
	req := httptest.NewRequest(http.MethodGet, "/auth/track/sessions?campId=camp-1", nil)
	rec := httptest.NewRecorder()
	c := e.NewContext(req, rec)

	// Act
	err := handler.ListActiveFacilitatorSessions(c)
	if err != nil {
		e.HTTPErrorHandler(err, c)
	}

	// Assert
	if rec.Code != http.StatusOK {
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
			e := echo.New()
			e.HTTPErrorHandler = ErrorHandler()
			req := httptest.NewRequest(http.MethodGet, test.path, nil)
			rec := httptest.NewRecorder()
			c := e.NewContext(req, rec)
			// Act
			err := test.handler(c)
			if err != nil {
				e.HTTPErrorHandler(err, c)
			}
			// Assert
			if rec.Code != http.StatusBadRequest {
				t.Fatalf("expected 400 response, code=%d err=%v", rec.Code, err)
			}
		})
	}
}

func TestShouldRejectListRequestsWhenAdminAuthenticationIsMissing(t *testing.T) {
	e := echo.New()
	e.HTTPErrorHandler = ErrorHandler()
	admin := e.Group("")
	admin.Use(AdminAuthMiddleware(listAdminAuthStub{}))
	admin.GET("/auth/track/sessions", NewAuthHandler(nil, &listFacilitatorAuthStub{}, nil).ListActiveFacilitatorSessions)
	admin.GET("/camps/:campId/device-registrations/locked", NewDeviceHandler(&listDeviceTrustStub{}).ListLockedDevices)

	for _, path := range []string{"/auth/track/sessions?campId=camp-1", "/camps/camp-1/device-registrations/locked"} {
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
