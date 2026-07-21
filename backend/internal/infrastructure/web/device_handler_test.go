package web

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"cornermon/backend/internal/domain"

	"github.com/labstack/echo/v4"
)

func TestShouldReturnActualCreatedAtWhenDeviceRegistrationRequested(t *testing.T) {
	// Arrange
	e := echo.New()
	e.HTTPErrorHandler = ErrorHandler()
	createdAt := time.Date(2026, 7, 15, 8, 0, 0, 0, time.UTC)
	stub := &listDeviceTrustStub{requestedReg: domain.NewDeviceRegistrationFromProps(domain.DeviceRegistrationProps{ID: "device-1", CampID: "camp-1", Status: domain.DevicePending, CreatedAt: createdAt})}
	handler := NewDeviceHandler(stub)
	body := bytes.NewBufferString(`{"registrationCode":"7ZQK3M2X","deviceName":"iPad","deviceModel":"iPad Pro 11 2022","displayName":"1번 태블릿"}`)
	req := httptest.NewRequest(http.MethodPost, "/device-registrations", body)
	req.Header.Set(echo.HeaderContentType, echo.MIMEApplicationJSON)
	rec := httptest.NewRecorder()
	c := e.NewContext(req, rec)

	// Act
	err := handler.RequestRegistration(c)
	if err != nil {
		e.HTTPErrorHandler(err, c)
	}

	// Assert
	if rec.Code != http.StatusCreated {
		t.Fatalf("expected 201 response, code=%d err=%v", rec.Code, err)
	}
	var response DeviceRegistrationResponse
	if err := json.Unmarshal(rec.Body.Bytes(), &response); err != nil {
		t.Fatalf("decode response: %v", err)
	}
	if !response.CreatedAt.Equal(createdAt) {
		t.Fatalf("expected CreatedAt %v, got %v", createdAt, response.CreatedAt)
	}
	if response.CampID != "camp-1" {
		t.Fatalf("expected campId camp-1, got %q", response.CampID)
	}
}

func TestDeviceRegistrationMutationShouldMapExpectedDomainErrorsToConflict(t *testing.T) {
	tests := []struct {
		name   string
		handle func(*DeviceHandler, echo.Context) error
		err    error
		code   string
	}{
		{name: "approve invalid transition", handle: (*DeviceHandler).ApproveDevice, err: fmt.Errorf("approve: %w", domain.ErrDeviceInvalidTransition), code: "DEVICE_INVALID_TRANSITION"},
		{name: "reject invalid transition", handle: (*DeviceHandler).RejectDevice, err: domain.ErrDeviceInvalidTransition, code: "DEVICE_INVALID_TRANSITION"},
		{name: "revoke non approved device", handle: (*DeviceHandler).RevokeDevice, err: domain.ErrDeviceNotApproved, code: "DEVICE_NOT_APPROVED"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// arrange
			e := echo.New()
			e.HTTPErrorHandler = ErrorHandler()
			handler := NewDeviceHandler(&listDeviceTrustStub{mutationErr: tt.err})
			req := httptest.NewRequest(http.MethodPost, "/camps/camp-1/device-registrations/device-1", nil)
			rec := httptest.NewRecorder()
			ctx := e.NewContext(req, rec)
			ctx.Set("adminSession", domain.NewAdminSessionFromProps(domain.AdminSessionProps{AdminID: "admin-1"}))
			ctx.SetParamNames("campId", "id")
			ctx.SetParamValues("camp-1", "device-1")

			// act
			if err := tt.handle(handler, ctx); err != nil {
				e.HTTPErrorHandler(err, ctx)
			}

			// assert
			if rec.Code != http.StatusConflict || !bytes.Contains(rec.Body.Bytes(), []byte(tt.code)) {
				t.Fatalf("expected 409 %s, got status=%d body=%s", tt.code, rec.Code, rec.Body.String())
			}
		})
	}
}

func TestShouldNormalizeRegistrationCodeWhenDeviceRegistrationRequestedWithLowercaseCode(t *testing.T) {
	// Arrange
	e := echo.New()
	stub := &listDeviceTrustStub{requestedReg: domain.NewDeviceRegistrationFromProps(domain.DeviceRegistrationProps{ID: "device-1", Status: domain.DevicePending})}
	handler := NewDeviceHandler(stub)
	body := bytes.NewBufferString(`{"registrationCode":"7Zqk3m2x","deviceName":"iPad","deviceModel":"iPad Pro 11 2022","displayName":"1번 태블릿"}`)
	req := httptest.NewRequest(http.MethodPost, "/device-registrations", body)
	req.Header.Set(echo.HeaderContentType, echo.MIMEApplicationJSON)
	rec := httptest.NewRecorder()

	// Act
	err := handler.RequestRegistration(e.NewContext(req, rec))

	// Assert
	if err != nil || rec.Code != http.StatusCreated {
		t.Fatalf("expected 201 response, code=%d err=%v", rec.Code, err)
	}
	if stub.registrationCode != "7ZQK3M2X" {
		t.Fatalf("expected uppercased registration code, got %q", stub.registrationCode)
	}
}

func TestShouldReturnRegistrationAndCampIdentityWhenGettingMyRegistrationStatus(t *testing.T) {
	// Arrange
	e := echo.New()
	registration := domain.NewDeviceRegistrationFromProps(domain.DeviceRegistrationProps{
		ID:     "device-1",
		CampID: "camp-1",
		Status: domain.DevicePending,
	})
	stub := &listDeviceTrustStub{myRegistration: registration, campStatus: domain.CampActive}
	handler := NewDeviceHandler(stub)
	req := httptest.NewRequest(http.MethodGet, "/device-registrations/me", nil)
	req.Header.Set("X-Device-Token", "device-token")
	rec := httptest.NewRecorder()

	// Act
	err := handler.GetMyRegistrationStatus(e.NewContext(req, rec))

	// Assert
	if err != nil || rec.Code != http.StatusOK {
		t.Fatalf("expected 200 response, code=%d err=%v", rec.Code, err)
	}
	var response DeviceStatusResponse
	if err := json.Unmarshal(rec.Body.Bytes(), &response); err != nil {
		t.Fatalf("decode response: %v", err)
	}
	if response.ID != "device-1" || response.CampID != "camp-1" || response.Status != string(domain.DevicePending) || response.CampStatus != string(domain.CampActive) {
		t.Fatalf("expected device and camp identity, got %+v", response)
	}
	if stub.deviceToken != "device-token" {
		t.Fatalf("expected X-Device-Token to identify requester")
	}
}

func TestShouldReturnUnauthorizedWhenDeviceTokenHeaderIsMissingForMyRegistrationStatus(t *testing.T) {
	// Arrange
	e := echo.New()
	e.HTTPErrorHandler = ErrorHandler()
	handler := NewDeviceHandler(&listDeviceTrustStub{})
	req := httptest.NewRequest(http.MethodGet, "/device-registrations/me", nil)
	rec := httptest.NewRecorder()
	ctx := e.NewContext(req, rec)

	// Act
	err := handler.GetMyRegistrationStatus(ctx)
	if err != nil {
		e.HTTPErrorHandler(err, ctx)
	}

	// Assert
	if rec.Code != http.StatusUnauthorized {
		t.Fatalf("expected 401 response, code=%d err=%v", rec.Code, err)
	}
}

func TestShouldReturnNotFoundWhenRegistrationCodeDoesNotMatchAnyCamp(t *testing.T) {
	// Arrange
	e := echo.New()
	e.HTTPErrorHandler = ErrorHandler()
	stub := &listDeviceTrustStub{requestErr: domain.ErrCampNotFound}
	handler := NewDeviceHandler(stub)
	body := bytes.NewBufferString(`{"registrationCode":"UNKNOWN1","deviceName":"iPad"}`)
	req := httptest.NewRequest(http.MethodPost, "/device-registrations", body)
	req.Header.Set(echo.HeaderContentType, echo.MIMEApplicationJSON)
	rec := httptest.NewRecorder()
	c := e.NewContext(req, rec)

	// Act
	err := handler.RequestRegistration(c)
	if err != nil {
		e.HTTPErrorHandler(err, c)
	}

	// Assert
	if rec.Code != http.StatusNotFound {
		t.Fatalf("expected 404 response, code=%d err=%v", rec.Code, err)
	}
}

func TestShouldReturnBadRequestWhenCampIsNotActiveForRegistration(t *testing.T) {
	// Arrange
	e := echo.New()
	e.HTTPErrorHandler = ErrorHandler()
	stub := &listDeviceTrustStub{requestErr: domain.ErrCampInvalidTransition}
	handler := NewDeviceHandler(stub)
	body := bytes.NewBufferString(`{"registrationCode":"7ZQK3M2X","deviceName":"iPad"}`)
	req := httptest.NewRequest(http.MethodPost, "/device-registrations", body)
	req.Header.Set(echo.HeaderContentType, echo.MIMEApplicationJSON)
	rec := httptest.NewRecorder()
	c := e.NewContext(req, rec)

	// Act
	err := handler.RequestRegistration(c)
	if err != nil {
		e.HTTPErrorHandler(err, c)
	}

	// Assert
	if rec.Code != http.StatusBadRequest {
		t.Fatalf("expected 400 response, code=%d err=%v", rec.Code, err)
	}
}

func TestShouldReturnUpdatedRegistrationWhenDeviceStatusChanges(t *testing.T) {
	tests := []struct {
		name   string
		path   string
		status domain.DeviceRegistrationStatus
		handle func(*DeviceHandler, echo.Context) error
	}{
		{name: "approved", path: "/camps/camp-1/device-registrations/device-1/approve", status: domain.DeviceApproved, handle: (*DeviceHandler).ApproveDevice},
		{name: "rejected", path: "/camps/camp-1/device-registrations/device-1/reject", status: domain.DeviceRejected, handle: (*DeviceHandler).RejectDevice},
		{name: "revoked", path: "/camps/camp-1/device-registrations/device-1/revoke", status: domain.DeviceRevoked, handle: (*DeviceHandler).RevokeDevice},
	}

	for _, tt := range tests {
		t.Run("ShouldReturnRegistrationWhenDeviceIs"+tt.name, func(t *testing.T) {
			// Arrange
			e := echo.New()
			device := domain.NewDeviceRegistrationFromProps(domain.DeviceRegistrationProps{ID: "device-1", CampID: "camp-1", Status: tt.status})
			handler := NewDeviceHandler(&listDeviceTrustStub{mutatedDevice: device})
			req := httptest.NewRequest(http.MethodPost, tt.path, nil)
			rec := httptest.NewRecorder()
			ctx := e.NewContext(req, rec)
			ctx.Set("adminSession", domain.NewAdminSessionFromProps(domain.AdminSessionProps{AdminID: "admin-1"}))
			ctx.SetPath("/camps/:campId/device-registrations/:id/" + tt.name)
			ctx.SetParamNames("campId", "id")
			ctx.SetParamValues("camp-1", "device-1")

			// Act
			err := tt.handle(handler, ctx)

			// Assert
			if err != nil || rec.Code != http.StatusOK {
				t.Fatalf("expected 200 JSON response, code=%d err=%v", rec.Code, err)
			}
			var response DeviceRegistrationResponse
			if err := json.Unmarshal(rec.Body.Bytes(), &response); err != nil {
				t.Fatalf("decode response: %v", err)
			}
			if response.ID != "device-1" || response.CampID != "camp-1" || response.Status != string(tt.status) {
				t.Fatalf("unexpected updated registration response: %+v", response)
			}
		})
	}
}

func TestShouldReturnActualCreatedAtWhenListingRegistrations(t *testing.T) {
	// Arrange
	e := echo.New()
	e.HTTPErrorHandler = ErrorHandler()
	createdAt := time.Date(2026, 7, 14, 9, 0, 0, 0, time.UTC)
	stub := &listDeviceTrustStub{reviewedDevices: []*domain.DeviceRegistration{domain.NewDeviceRegistrationFromProps(domain.DeviceRegistrationProps{ID: "device-1", Status: domain.DevicePending, CreatedAt: createdAt})}}
	handler := NewDeviceHandler(stub)
	req := httptest.NewRequest(http.MethodGet, "/camps/camp-1/device-registrations", nil)
	rec := httptest.NewRecorder()
	ctx := e.NewContext(req, rec)
	ctx.SetPath("/camps/:campId/device-registrations")
	ctx.SetParamNames("campId")
	ctx.SetParamValues("camp-1")

	// Act
	err := handler.ListRegistrations(ctx)
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
	if len(response) != 1 || !response[0].CreatedAt.Equal(createdAt) {
		t.Fatalf("unexpected response: %+v", response)
	}
}
