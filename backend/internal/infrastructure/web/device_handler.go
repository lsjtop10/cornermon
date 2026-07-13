package web

import (
	"context"
	"net/http"
	"time"

	"cornermon/backend/internal/domain"

	"github.com/labstack/echo/v4"
)

type DeviceTrustUsecase interface {
	GetMyRegistrationStatus(ctx context.Context, deviceToken string) (*domain.DeviceRegistrationStatus, error)
	RequestRegistration(ctx context.Context, campID domain.CampID, deviceName string) (string, *domain.DeviceRegistration, error)
	ApproveDevice(ctx context.Context, regID domain.DeviceRegistrationID, actorAdminID domain.AdminID) error
	RejectDevice(ctx context.Context, regID domain.DeviceRegistrationID, actorAdminID domain.AdminID) error
	RevokeDevice(ctx context.Context, regID domain.DeviceRegistrationID, actorAdminID domain.AdminID) error
	ReviewDeviceTrustRequests(ctx context.Context, campID domain.CampID, status *domain.DeviceRegistrationStatus) ([]*domain.DeviceRegistration, error)
}

type DeviceHandler struct {
	deviceTrust DeviceTrustUsecase
}

type DeviceRegistrationResponse struct {
	ID         string     `json:"id" format:"uuid"`
	DeviceName string     `json:"deviceName" example:"iPad Pro #3"`
	Status     string     `json:"status" enums:"PENDING,APPROVED,REJECTED,REVOKED"`
	CreatedAt  time.Time  `json:"createdAt" format:"date-time"`
	ApprovedAt *time.Time `json:"approvedAt,omitempty" format:"date-time"`
} // @name DeviceRegistrationResponse

func NewDeviceHandler(deviceTrust DeviceTrustUsecase) *DeviceHandler {
	return &DeviceHandler{
		deviceTrust: deviceTrust,
	}
}

type DeviceRegistrationRequest struct {
	CampID     string `json:"campId"` // Using campId because RequestRegistration expects a campID
	DeviceName string `json:"deviceName"`
	Role       string `json:"role" enums:"ADMIN,FACILITATOR"`
} // @name DeviceRegistrationRequest

// @Summary      내 기기 등록 상태 자체 조회
// @Description  미승인(PENDING) 기기가 자신의 승인 상태를 확인하기 위해 호출한다.
// @Tags         A. Auth & Device Trust
// @Accept       json
// @Produce      json
// @Success      200 {object} map[string]interface{}
// @Router       /device-registrations/me [get]
func (h *DeviceHandler) GetMyRegistrationStatus(c echo.Context) error {
	token := extractToken(c.Request().Header.Get("Authorization"))
	if token == "" {
		return c.JSON(http.StatusUnauthorized, ErrorResponse{Code: "UNAUTHORIZED", Message: "missing token"})
	}

	status, err := h.deviceTrust.GetMyRegistrationStatus(c.Request().Context(), token)
	if err != nil {
		if err == domain.ErrDeviceNotApproved {
			return c.JSON(http.StatusUnauthorized, ErrorResponse{Code: "UNAUTHORIZED", Message: err.Error()})
		}
		return c.JSON(http.StatusInternalServerError, ErrorResponse{Code: "INTERNAL_ERROR", Message: err.Error()})
	}

	return c.JSON(http.StatusOK, map[string]interface{}{
		"status": status,
	})
}

// @Summary      기기 등록 요청 (최초 앱 실행 시)
// @Description  기기가 서버에 등록을 요청한다. 이후 관리자의 승인 대기.
// @Tags         A. Auth & Device Trust
// @Accept       json
// @Produce      json
// @Param        request body DeviceRegistrationRequest true "등록 정보"
// @Success      201 {object} DeviceRegistrationResponse
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

	return c.JSON(http.StatusCreated, DeviceRegistrationResponse{
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
// @Success      200 {array} DeviceRegistrationResponse
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

	res := make([]DeviceRegistrationResponse, len(devices))
	for i, d := range devices {
		var approvedAt *time.Time
		if d.ApprovedAt.IsSet() {
			t, _ := d.ApprovedAt.Value()
			approvedAt = &t
		}
		res[i] = DeviceRegistrationResponse{
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
// @Success      200 {object} DeviceRegistrationResponse
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
// @Success      200 {object} DeviceRegistrationResponse
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
// @Success      200 {object} DeviceRegistrationResponse
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
