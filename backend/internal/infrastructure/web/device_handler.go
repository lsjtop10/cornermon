package web

import (
	"context"
	"net/http"
	"time"

	"cornermon/backend/internal/domain"

	"github.com/labstack/echo/v4"
)

type DeviceTrustUsecase interface {
	RequestRegistration(ctx context.Context, campID domain.CampID, deviceName string) (string, *domain.DeviceRegistration, error)
	ApproveDevice(ctx context.Context, regID domain.DeviceRegistrationID, actorAdminID domain.AdminID) error
	RejectDevice(ctx context.Context, regID domain.DeviceRegistrationID, actorAdminID domain.AdminID) error
	RevokeDevice(ctx context.Context, regID domain.DeviceRegistrationID, actorAdminID domain.AdminID) error
	ReviewDeviceTrustRequests(ctx context.Context, campID domain.CampID, status *domain.DeviceRegistrationStatus) ([]*domain.DeviceRegistration, error)
}

type DeviceHandler struct {
	deviceTrust DeviceTrustUsecase
}

func NewDeviceHandler(deviceTrust DeviceTrustUsecase) *DeviceHandler {
	return &DeviceHandler{
		deviceTrust: deviceTrust,
	}
}

type DeviceRegistrationRequest struct {
	CampID     string `json:"campId"` // Using campId because RequestRegistration expects a campID
	DeviceName string `json:"deviceName"`
	Role       string `json:"role" enums:"ADMIN,FACILITATOR"`
}

// @Summary      기기 등록 요청 (최초 앱 실행 시)
// @Description  기기가 서버에 등록을 요청한다. 이후 관리자의 승인 대기.
// @Tags         A. Auth & Device Trust
// @Accept       json
// @Produce      json
// @Param        request body DeviceRegistrationRequest true "등록 정보"
// @Success      201 {object} DeviceRegistration
// @Router       /device-registrations [post]
func (h *DeviceHandler) RequestRegistration(c echo.Context) error {
	var req DeviceRegistrationRequest
	if err := c.Bind(&req); err != nil {
		return c.JSON(http.StatusBadRequest, ErrorResponse{Code: "BAD_REQUEST", Message: "invalid request"})
	}

	token, reg, err := h.deviceTrust.RequestRegistration(c.Request().Context(), domain.CampID(req.CampID), req.DeviceName)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, ErrorResponse{Code: "INTERNAL_SERVER_ERROR", Message: err.Error()})
	}

	c.Response().Header().Set("X-Device-Token", token)

	var approvedAt *time.Time
	if reg.ApprovedAt.IsSet() {
		t, _ := reg.ApprovedAt.Value()
		approvedAt = &t
	}

	return c.JSON(http.StatusCreated, DeviceRegistration{
		ID:         string(reg.ID),
		DeviceName: reg.DeviceName,
		Status:     string(reg.Status),
		CreatedAt:  time.Now(),
		ApprovedAt: approvedAt,
	})
}

// @Summary      기기 등록 목록 조회
// @Description  관리자가 등록되었거나 대기 중인 기기 목록을 확인한다.
// @Tags         A. Auth & Device Trust
// @Security     AdminAuth
// @Produce      json
// @Success      200 {array} DeviceRegistration
// @Router       /device-registrations [get]
func (h *DeviceHandler) ListRegistrations(c echo.Context) error {
	campID := c.QueryParam("campId")
	if campID == "" {
		return c.JSON(http.StatusBadRequest, ErrorResponse{Code: "BAD_REQUEST", Message: "missing campId"})
	}

	statusStr := c.QueryParam("status")
	var statusPtr *domain.DeviceRegistrationStatus
	if statusStr != "" {
		st := domain.DeviceRegistrationStatus(statusStr)
		statusPtr = &st
	}

	devices, err := h.deviceTrust.ReviewDeviceTrustRequests(c.Request().Context(), domain.CampID(campID), statusPtr)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, ErrorResponse{Code: "INTERNAL_SERVER_ERROR", Message: err.Error()})
	}

	res := make([]DeviceRegistration, len(devices))
	for i, d := range devices {
		var approvedAt *time.Time
		if d.ApprovedAt.IsSet() {
			t, _ := d.ApprovedAt.Value()
			approvedAt = &t
		}
		res[i] = DeviceRegistration{
			ID:         string(d.ID),
			DeviceName: d.DeviceName,
			Status:     string(d.Status),
			CreatedAt:  time.Now(),
			ApprovedAt: approvedAt,
		}
	}

	return c.JSON(http.StatusOK, res)
}

// @Summary      기기 승인
// @Description  PENDING 상태인 기기를 APPROVED로 승인한다.
// @Tags         A. Auth & Device Trust
// @Security     AdminAuth
// @Produce      json
// @Param        id path string true "기기 등록 ID"
// @Success      200 {object} DeviceRegistration
// @Router       /device-registrations/{id}/approve [post]
func (h *DeviceHandler) ApproveDevice(c echo.Context) error {
	session, ok := c.Get("adminSession").(*domain.AdminSession)
	if !ok {
		return c.JSON(http.StatusUnauthorized, ErrorResponse{Code: "UNAUTHORIZED", Message: "unauthorized"})
	}
	regID := domain.DeviceRegistrationID(c.Param("id"))

	err := h.deviceTrust.ApproveDevice(c.Request().Context(), regID, session.AdminID)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, ErrorResponse{Code: "INTERNAL_SERVER_ERROR", Message: err.Error()})
	}

	return c.NoContent(http.StatusOK)
}

// @Summary      기기 거절
// @Description  PENDING 상태인 기기를 REJECTED로 거절한다.
// @Tags         A. Auth & Device Trust
// @Security     AdminAuth
// @Produce      json
// @Param        id path string true "기기 등록 ID"
// @Success      200 {object} DeviceRegistration
// @Router       /device-registrations/{id}/reject [post]
func (h *DeviceHandler) RejectDevice(c echo.Context) error {
	session, ok := c.Get("adminSession").(*domain.AdminSession)
	if !ok {
		return c.JSON(http.StatusUnauthorized, ErrorResponse{Code: "UNAUTHORIZED", Message: "unauthorized"})
	}
	regID := domain.DeviceRegistrationID(c.Param("id"))

	err := h.deviceTrust.RejectDevice(c.Request().Context(), regID, session.AdminID)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, ErrorResponse{Code: "INTERNAL_SERVER_ERROR", Message: err.Error()})
	}

	return c.NoContent(http.StatusOK)
}

// @Summary      기기 신뢰 취소 (폐기/분실)
// @Description  APPROVED 기기의 권한을 REVOKED로 박탈한다.
// @Tags         A. Auth & Device Trust
// @Security     AdminAuth
// @Produce      json
// @Param        id path string true "기기 등록 ID"
// @Success      200 {object} DeviceRegistration
// @Router       /device-registrations/{id}/revoke [post]
func (h *DeviceHandler) RevokeDevice(c echo.Context) error {
	session, ok := c.Get("adminSession").(*domain.AdminSession)
	if !ok {
		return c.JSON(http.StatusUnauthorized, ErrorResponse{Code: "UNAUTHORIZED", Message: "unauthorized"})
	}
	regID := domain.DeviceRegistrationID(c.Param("id"))

	err := h.deviceTrust.RevokeDevice(c.Request().Context(), regID, session.AdminID)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, ErrorResponse{Code: "INTERNAL_SERVER_ERROR", Message: err.Error()})
	}

	return c.NoContent(http.StatusOK)
}
