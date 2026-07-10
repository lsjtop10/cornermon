package handler

import (
	"context"
	"net/http"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/interfaces/http/dto"

	"github.com/labstack/echo/v4"
)

type DeviceTrustUsecase interface {
	RequestRegistration(ctx context.Context, campID domain.CampID, deviceName string) (string, *domain.DeviceRegistration, error)
	ApproveDevice(ctx context.Context, registrationID domain.DeviceRegistrationID) error
	RejectDevice(ctx context.Context, registrationID domain.DeviceRegistrationID) error
	RevokeDevice(ctx context.Context, registrationID domain.DeviceRegistrationID) error
	ListPending(ctx context.Context, campID domain.CampID) ([]*domain.DeviceRegistration, error)
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

// @Summary      기기 등록 요청
// @Description  진행자 기기가 등록 코드와 함께 신뢰 기기 등록을 요청한다.
// @Tags         A. Auth & Device Trust
// @Accept       json
// @Produce      json
// @Param        request body dto.DeviceRegistrationRequest true "기기 등록 정보"
// @Success      201 {object} dto.DeviceRegistrationResponse "등록 요청 성공"
// @Failure      400 {object} dto.ErrorResponse "잘못된 등록 코드"
// @Router       /api/v1/auth/device [post]
func (h *DeviceHandler) RequestRegistration(c echo.Context) error {
	var req dto.DeviceRegistrationRequest
	if err := c.Bind(&req); err != nil {
		return err
	}

	// Assuming RegistrationCode acts as CampID
	deviceToken, reg, err := h.deviceTrust.RequestRegistration(
		c.Request().Context(),
		domain.CampID(req.RegistrationCode),
		req.DeviceName,
	)
	if err != nil {
		return err
	}

	return c.JSON(http.StatusCreated, dto.DeviceRegistrationResponse{
		DeviceRegistration: dto.ToDeviceRegistrationDTO(reg),
		DeviceToken:        deviceToken,
	})
}

// @Summary      기기 등록 요청 목록 조회 (대기 목록)
// @Description  관리자가 승인 대기 중인 기기 등록 요청 목록을 조회한다.
// @Tags         A. Auth & Device Trust
// @Security     AdminAuth
// @Produce      json
// @Success      200 {object} dto.DeviceRegistrationsResponse "기기 등록 목록"
// @Failure      401 {object} dto.ErrorResponse "권한 없음"
// @Failure      403 {object} dto.ErrorResponse "접근 금지"
// @Router       /api/v1/device-registrations [get]
func (h *DeviceHandler) ListRegistrations(c echo.Context) error {
	sessionData := c.Get("adminSession")
	if sessionData == nil {
		return echo.NewHTTPError(http.StatusUnauthorized, "missing session")
	}

	campIDStr := c.QueryParam("campId")
	if campIDStr == "" {
		return echo.NewHTTPError(http.StatusBadRequest, "campId is required")
	}

	statusStr := c.QueryParam("status")
	var status *domain.DeviceRegistrationStatus
	if statusStr != "" {
		s := domain.DeviceRegistrationStatus(statusStr)
		status = &s
	}

	regs, err := h.deviceTrust.ReviewDeviceTrustRequests(c.Request().Context(), domain.CampID(campIDStr), status)
	if err != nil {
		return err
	}

	dtos := make([]dto.DeviceRegistrationDTO, len(regs))
	for i, reg := range regs {
		dtos[i] = dto.ToDeviceRegistrationDTO(reg)
	}

	return c.JSON(http.StatusOK, dto.DeviceRegistrationsResponse{
		DeviceRegistrations: dtos,
	})
}

// @Summary      기기 승인
// @Description  관리자가 대기 중인 기기 등록을 승인한다.
// @Tags         A. Auth & Device Trust
// @Security     AdminAuth
// @Produce      json
// @Param        id path string true "기기 등록 ID"
// @Success      204 "승인 완료"
// @Failure      404 {object} dto.ErrorResponse "기기 등록 정보 없음"
// @Router       /api/v1/device-registrations/{id}/approve [post]
func (h *DeviceHandler) ApproveDevice(c echo.Context) error {
	id := c.Param("id")
	if id == "" {
		return echo.NewHTTPError(http.StatusBadRequest, "id is required")
	}

	if err := h.deviceTrust.ApproveDevice(c.Request().Context(), domain.DeviceRegistrationID(id)); err != nil {
		return err
	}

	return c.NoContent(http.StatusNoContent)
}

// @Summary      기기 거절
// @Description  관리자가 대기 중인 기기 등록을 거절한다.
// @Tags         A. Auth & Device Trust
// @Security     AdminAuth
// @Produce      json
// @Param        id path string true "기기 등록 ID"
// @Success      204 "거절 완료"
// @Failure      404 {object} dto.ErrorResponse "기기 등록 정보 없음"
// @Router       /api/v1/device-registrations/{id}/reject [post]
func (h *DeviceHandler) RejectDevice(c echo.Context) error {
	id := c.Param("id")
	if id == "" {
		return echo.NewHTTPError(http.StatusBadRequest, "id is required")
	}

	if err := h.deviceTrust.RejectDevice(c.Request().Context(), domain.DeviceRegistrationID(id)); err != nil {
		return err
	}

	return c.NoContent(http.StatusNoContent)
}

// @Summary      기기 신뢰 회수
// @Description  관리자가 기존에 승인된 기기의 신뢰 상태를 회수(취소)한다.
// @Tags         A. Auth & Device Trust
// @Security     AdminAuth
// @Produce      json
// @Param        id path string true "기기 등록 ID"
// @Success      204 "회수 완료"
// @Failure      404 {object} dto.ErrorResponse "기기 등록 정보 없음"
// @Router       /api/v1/device-registrations/{id}/revoke [post]
func (h *DeviceHandler) RevokeDevice(c echo.Context) error {
	id := c.Param("id")
	if id == "" {
		return echo.NewHTTPError(http.StatusBadRequest, "id is required")
	}

	if err := h.deviceTrust.RevokeDevice(c.Request().Context(), domain.DeviceRegistrationID(id)); err != nil {
		return err
	}

	return c.NoContent(http.StatusNoContent)
}
