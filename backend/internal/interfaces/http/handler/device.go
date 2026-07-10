package handler

import (
	"net/http"

	"cornermon/backend/internal/interfaces/http/dto"
	"github.com/labstack/echo/v4"
)

type DeviceHandler struct {
}

func NewDeviceHandler() *DeviceHandler {
	return &DeviceHandler{}
}

type DeviceRegistrationRequest struct {
	DeviceID   string `json:"deviceId"`
	DeviceName string `json:"deviceName"`
	Role       string `json:"role" enums:"ADMIN,FACILITATOR"`
}

// @Summary      기기 등록 요청 (최초 앱 실행 시)
// @Description  기기가 서버에 등록을 요청한다. 이후 관리자의 승인 대기.
// @Tags         A. Auth & Device Trust
// @Accept       json
// @Produce      json
// @Param        request body DeviceRegistrationRequest true "등록 정보"
// @Success      201 {object} dto.DeviceRegistration
// @Router       /device-registrations [post]
func (h *DeviceHandler) RequestRegistration(c echo.Context) error {
	return c.JSON(http.StatusCreated, dto.DeviceRegistration{})
}

// @Summary      기기 등록 목록 조회
// @Description  관리자가 등록되었거나 대기 중인 기기 목록을 확인한다.
// @Tags         A. Auth & Device Trust
// @Security     AdminAuth
// @Produce      json
// @Success      200 {array} dto.DeviceRegistration
// @Router       /device-registrations [get]
func (h *DeviceHandler) ListRegistrations(c echo.Context) error {
	return c.JSON(http.StatusOK, []dto.DeviceRegistration{})
}

// @Summary      기기 승인
// @Description  PENDING 상태인 기기를 APPROVED로 승인한다.
// @Tags         A. Auth & Device Trust
// @Security     AdminAuth
// @Produce      json
// @Param        id path string true "기기 등록 ID"
// @Success      200 {object} dto.DeviceRegistration
// @Router       /device-registrations/{id}/approve [post]
func (h *DeviceHandler) ApproveDevice(c echo.Context) error {
	return c.JSON(http.StatusOK, dto.DeviceRegistration{})
}

// @Summary      기기 거절
// @Description  PENDING 상태인 기기를 REJECTED로 거절한다.
// @Tags         A. Auth & Device Trust
// @Security     AdminAuth
// @Produce      json
// @Param        id path string true "기기 등록 ID"
// @Success      200 {object} dto.DeviceRegistration
// @Router       /device-registrations/{id}/reject [post]
func (h *DeviceHandler) RejectDevice(c echo.Context) error {
	return c.JSON(http.StatusOK, dto.DeviceRegistration{})
}

// @Summary      기기 신뢰 취소 (폐기/분실)
// @Description  APPROVED 기기의 권한을 REVOKED로 박탈한다.
// @Tags         A. Auth & Device Trust
// @Security     AdminAuth
// @Produce      json
// @Param        id path string true "기기 등록 ID"
// @Success      200 {object} dto.DeviceRegistration
// @Router       /device-registrations/{id}/revoke [post]
func (h *DeviceHandler) RevokeDevice(c echo.Context) error {
	return c.JSON(http.StatusOK, dto.DeviceRegistration{})
}
