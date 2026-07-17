package web

import (
	"bytes"
	"encoding/json"
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
	createdAt := time.Date(2026, 7, 15, 8, 0, 0, 0, time.UTC)
	stub := &listDeviceTrustStub{requestedReg: domain.NewDeviceRegistrationFromProps(domain.DeviceRegistrationProps{ID: "device-1", Status: domain.DevicePending, CreatedAt: createdAt})}
	handler := NewDeviceHandler(stub)
	body := bytes.NewBufferString(`{"registrationCode":"7ZQK3M2X","deviceName":"iPad","deviceModel":"iPad Pro 11 2022","displayName":"1번 태블릿"}`)
	req := httptest.NewRequest(http.MethodPost, "/device-registrations", body)
	req.Header.Set(echo.HeaderContentType, echo.MIMEApplicationJSON)
	rec := httptest.NewRecorder()

	// Act
	err := handler.RequestRegistration(e.NewContext(req, rec))

	// Assert
	if err != nil || rec.Code != http.StatusCreated {
		t.Fatalf("expected 201 response, code=%d err=%v", rec.Code, err)
	}
	var response DeviceRegistrationResponse
	if err := json.Unmarshal(rec.Body.Bytes(), &response); err != nil {
		t.Fatalf("decode response: %v", err)
	}
	if !response.CreatedAt.Equal(createdAt) {
		t.Fatalf("expected CreatedAt %v, got %v", createdAt, response.CreatedAt)
	}
}

func TestShouldReturnNotFoundWhenRegistrationCodeDoesNotMatchAnyCamp(t *testing.T) {
	// Arrange
	e := echo.New()
	stub := &listDeviceTrustStub{requestErr: domain.ErrCampNotFound}
	handler := NewDeviceHandler(stub)
	body := bytes.NewBufferString(`{"registrationCode":"UNKNOWN1","deviceName":"iPad"}`)
	req := httptest.NewRequest(http.MethodPost, "/device-registrations", body)
	req.Header.Set(echo.HeaderContentType, echo.MIMEApplicationJSON)
	rec := httptest.NewRecorder()

	// Act
	err := handler.RequestRegistration(e.NewContext(req, rec))

	// Assert
	if err != nil || rec.Code != http.StatusNotFound {
		t.Fatalf("expected 404 response, code=%d err=%v", rec.Code, err)
	}
}

func TestShouldReturnBadRequestWhenCampIsNotActiveForRegistration(t *testing.T) {
	// Arrange
	e := echo.New()
	stub := &listDeviceTrustStub{requestErr: domain.ErrCampInvalidTransition}
	handler := NewDeviceHandler(stub)
	body := bytes.NewBufferString(`{"registrationCode":"7ZQK3M2X","deviceName":"iPad"}`)
	req := httptest.NewRequest(http.MethodPost, "/device-registrations", body)
	req.Header.Set(echo.HeaderContentType, echo.MIMEApplicationJSON)
	rec := httptest.NewRecorder()

	// Act
	err := handler.RequestRegistration(e.NewContext(req, rec))

	// Assert
	if err != nil || rec.Code != http.StatusBadRequest {
		t.Fatalf("expected 400 response, code=%d err=%v", rec.Code, err)
	}
}

func TestShouldReturnActualCreatedAtWhenListingRegistrations(t *testing.T) {
	// Arrange
	e := echo.New()
	createdAt := time.Date(2026, 7, 14, 9, 0, 0, 0, time.UTC)
	stub := &listDeviceTrustStub{reviewedDevices: []*domain.DeviceRegistration{{ID: "device-1", Status: domain.DevicePending, CreatedAt: createdAt}}}
	handler := NewDeviceHandler(stub)
	req := httptest.NewRequest(http.MethodGet, "/device-registrations?campId=camp-1", nil)
	rec := httptest.NewRecorder()

	// Act
	err := handler.ListRegistrations(e.NewContext(req, rec))

	// Assert
	if err != nil || rec.Code != http.StatusOK {
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
