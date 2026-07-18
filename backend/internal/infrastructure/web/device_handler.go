package web

import (
	"context"
	"errors"
	"net/http"
	"strings"
	"time"

	"cornermon/backend/internal/domain"

	"github.com/labstack/echo/v4"
)

type DeviceTrustUsecase interface {
	GetMyRegistrationStatus(ctx context.Context, deviceToken string) (*domain.DeviceRegistrationStatus, error)
	RequestRegistration(ctx context.Context, registrationCode string, deviceName, deviceModel, displayName string) (string, *domain.DeviceRegistration, error)
	ApproveDevice(ctx context.Context, regID domain.DeviceRegistrationID, actorAdminID domain.AdminID) error
	RejectDevice(ctx context.Context, regID domain.DeviceRegistrationID, actorAdminID domain.AdminID) error
	RevokeDevice(ctx context.Context, regID domain.DeviceRegistrationID, actorAdminID domain.AdminID) error
	ReviewDeviceTrustRequests(ctx context.Context, campID domain.CampID, status *domain.DeviceRegistrationStatus) ([]*domain.DeviceRegistration, error)
	ListLockedDevices(ctx context.Context, campID domain.CampID) ([]*domain.DeviceRegistration, error)
}

type DeviceHandler struct {
	deviceTrust DeviceTrustUsecase
}

type DeviceStatusResponse struct {
	Status string `json:"status" enums:"PENDING,APPROVED,REJECTED,REVOKED"`
} // @name DeviceStatusResponse

type DeviceRegistrationResponse struct {
	ID                string     `json:"id" format:"uuid"`
	DeviceName        string     `json:"deviceName" example:"iPad Pro #3"`
	DeviceModel       string     `json:"deviceModel" example:"iPad Pro 11 2022"`
	DisplayName       string     `json:"displayName" example:"1번 태블릿"`
	Status            string     `json:"status" enums:"PENDING,APPROVED,REJECTED,REVOKED"`
	CreatedAt         time.Time  `json:"createdAt" format:"date-time"`
	ApprovedAt        *time.Time `json:"approvedAt,omitempty" format:"date-time"`
	FailedPinAttempts int        `json:"failedPinAttempts"`
	LockedUntil       *time.Time `json:"lockedUntil,omitempty" format:"date-time"`
} // @name DeviceRegistrationResponse

type DeviceRegistrationCreatedResponse struct {
	DeviceRegistrationResponse
	DeviceToken string `json:"deviceToken" example:"a1b2c3..."`
} // @name DeviceRegistrationCreatedResponse

func NewDeviceHandler(deviceTrust DeviceTrustUsecase) *DeviceHandler {
	return &DeviceHandler{
		deviceTrust: deviceTrust,
	}
}

type DeviceRegistrationRequest struct {
	// 각 캠프에 유일하게 부여된 등록 코드입니다. 반드시 대문자로 작성합니다.
	RegistrationCode string `json:"registrationCode" example:"7ZQK3M2X"`
	DeviceName       string `json:"deviceName"`
	DeviceModel      string `json:"deviceModel" example:"iPad Pro 11 2022"`
	DisplayName      string `json:"displayName" example:"1번 태블릿"`
	Role             string `json:"role" enums:"ADMIN,FACILITATOR"`
} // @name DeviceRegistrationRequest

// @Summary      내 기기 등록 상태 자체 조회
// @Description  미승인(PENDING) 기기가 자신의 승인 상태를 확인하기 위해 호출한다.
// @Tags         A. Auth & Device Trust
// @Accept       json
// @Produce      json
// @Success      200 {object} DeviceStatusResponse
// @Router       /device-registrations/me [get]
func (h *DeviceHandler) GetMyRegistrationStatus(c echo.Context) error {
	token := extractToken(c.Request().Header.Get("Authorization"))
	if token == "" {
		return echo.NewHTTPError(http.StatusUnauthorized, ErrorResponse{Code: "UNAUTHORIZED", Message: "missing token"})
	}

	status, err := h.deviceTrust.GetMyRegistrationStatus(c.Request().Context(), token)
	if err != nil {
		if err == domain.ErrDeviceNotApproved {
			return echo.NewHTTPError(http.StatusUnauthorized, ErrorResponse{Code: "UNAUTHORIZED", Message: err.Error()}).SetInternal(err)
		}
		return echo.NewHTTPError(http.StatusInternalServerError, ErrorResponse{Code: "INTERNAL_ERROR", Message: err.Error()}).SetInternal(err)
	}

	return c.JSON(http.StatusOK, DeviceStatusResponse{
		Status: string(*status),
	})
}

// @Summary      기기 등록 요청 (최초 앱 실행 시)
// @Description  기기가 서버에 등록을 요청한다. 이후 관리자의 승인 대기.
// @Tags         A. Auth & Device Trust
// @Accept       json
// @Produce      json
// @Param        request body DeviceRegistrationRequest true "등록 정보"
// @Success      201 {object} DeviceRegistrationCreatedResponse
// @Router       /device-registrations [post]
func (h *DeviceHandler) RequestRegistration(c echo.Context) error {
	var req DeviceRegistrationRequest
	if err := c.Bind(&req); err != nil {
		return echo.NewHTTPError(http.StatusBadRequest, ErrorResponse{Code: "BAD_REQUEST", Message: "invalid request"}).SetInternal(err)
	}

	token, reg, err := h.deviceTrust.RequestRegistration(c.Request().Context(), strings.ToUpper(req.RegistrationCode), req.DeviceName, req.DeviceModel, req.DisplayName)
	if err != nil {
		if errors.Is(err, domain.ErrCampNotFound) {
			return echo.NewHTTPError(http.StatusNotFound, ErrorResponse{Code: "CAMP_NOT_FOUND", Message: err.Error()}).SetInternal(err)
		}
		if errors.Is(err, domain.ErrCampInvalidTransition) {
			return echo.NewHTTPError(http.StatusBadRequest, ErrorResponse{Code: "INVALID_TRANSITION", Message: err.Error()}).SetInternal(err)
		}
		return echo.NewHTTPError(http.StatusInternalServerError, ErrorResponse{Code: "INTERNAL_SERVER_ERROR", Message: err.Error()}).SetInternal(err)
	}

	var approvedAt *time.Time
	if reg.ApprovedAt().IsSet() {
		t, _ := reg.ApprovedAt().Value()
		approvedAt = &t
	}

	return c.JSON(http.StatusCreated, DeviceRegistrationCreatedResponse{
		DeviceRegistrationResponse: DeviceRegistrationResponse{
			ID:                string(reg.ID()),
			DeviceName:        reg.DeviceName(),
			DeviceModel:       reg.DeviceModel(),
			DisplayName:       reg.DisplayName(),
			Status:            string(reg.Status()),
			CreatedAt:         reg.CreatedAt(),
			ApprovedAt:        approvedAt,
			FailedPinAttempts: reg.FailedPinAttempts(),
		},
		DeviceToken: token,
	})
}

// @Summary      기기 등록 목록 조회
// @Description  관리자가 등록되었거나 대기 중인 기기 목록을 확인한다.
// @Tags         A. Auth & Device Trust
// @Security     AdminAuth
// @Produce      json
// @Param        campId path string true "캠프 ID"
// @Param        status query string false "기기 등록 상태"
// @Success      200 {array} DeviceRegistrationResponse
// @Failure      400 {object} ErrorResponse
// @Router       /camps/{campId}/device-registrations [get]
func (h *DeviceHandler) ListRegistrations(c echo.Context) error {
	campID := c.Param("campId")
	if campID == "" {
		return echo.NewHTTPError(http.StatusBadRequest, ErrorResponse{Code: "BAD_REQUEST", Message: "missing campId"})
	}

	statusStr := c.QueryParam("status")
	var statusPtr *domain.DeviceRegistrationStatus
	if statusStr != "" {
		st := domain.DeviceRegistrationStatus(statusStr)
		statusPtr = &st
	}

	devices, err := h.deviceTrust.ReviewDeviceTrustRequests(c.Request().Context(), domain.CampID(campID), statusPtr)
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, ErrorResponse{Code: "INTERNAL_SERVER_ERROR", Message: err.Error()}).SetInternal(err)
	}

	res := make([]DeviceRegistrationResponse, len(devices))
	for i, d := range devices {
		var approvedAt *time.Time
		if d.ApprovedAt().IsSet() {
			t, _ := d.ApprovedAt().Value()
			approvedAt = &t
		}
		var lockedUntil *time.Time
		if d.LockedUntil().IsSet() {
			t, _ := d.LockedUntil().Value()
			lockedUntil = &t
		}
		res[i] = DeviceRegistrationResponse{
			ID:                string(d.ID()),
			DeviceName:        d.DeviceName(),
			DeviceModel:       d.DeviceModel(),
			DisplayName:       d.DisplayName(),
			Status:            string(d.Status()),
			CreatedAt:         d.CreatedAt(),
			ApprovedAt:        approvedAt,
			FailedPinAttempts: d.FailedPinAttempts(),
			LockedUntil:       lockedUntil,
		}
	}

	return c.JSON(http.StatusOK, res)
}

// @Summary      잠금 기기 목록 조회
// @Description  캠프 내 PIN 연속 실패로 잠금된(APPROVED, LockedUntil이 미래) 기기 목록을 조회한다.
// @Tags         A. Auth & Device Trust
// @Security     AdminAuth
// @Produce      json
// @Param        campId path string true "캠프 ID"
// @Success      200 {array} DeviceRegistrationResponse
// @Failure      400 {object} ErrorResponse
// @Router       /camps/{campId}/device-registrations/locked [get]
func (h *DeviceHandler) ListLockedDevices(c echo.Context) error {
	campID := c.Param("campId")
	if campID == "" {
		return echo.NewHTTPError(http.StatusBadRequest, ErrorResponse{Code: "BAD_REQUEST", Message: "missing campId"})
	}
	devices, err := h.deviceTrust.ListLockedDevices(c.Request().Context(), domain.CampID(campID))
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, ErrorResponse{Code: "INTERNAL_SERVER_ERROR", Message: err.Error()}).SetInternal(err)
	}
	res := make([]DeviceRegistrationResponse, len(devices))
	for i, device := range devices {
		res[i] = mapDeviceRegistration(device)
	}
	return c.JSON(http.StatusOK, res)
}

func mapDeviceRegistration(device *domain.DeviceRegistration) DeviceRegistrationResponse {
	response := DeviceRegistrationResponse{ID: string(device.ID()), DeviceName: device.DeviceName(), DeviceModel: device.DeviceModel(), DisplayName: device.DisplayName(), Status: string(device.Status()), CreatedAt: device.CreatedAt(), FailedPinAttempts: device.FailedPinAttempts()}
	if value, ok := device.ApprovedAt().Value(); ok {
		response.ApprovedAt = &value
	}
	if value, ok := device.LockedUntil().Value(); ok {
		response.LockedUntil = &value
	}
	return response
}

// @Summary      기기 승인
// @Description  PENDING 상태인 기기를 APPROVED로 승인한다.
// @Tags         A. Auth & Device Trust
// @Security     AdminAuth
// @Produce      json
// @Param        campId path string true "캠프 ID"
// @Param        id path string true "기기 등록 ID"
// @Success      200 {object} DeviceRegistrationResponse
// @Router       /camps/{campId}/device-registrations/{id}/approve [post]
func (h *DeviceHandler) ApproveDevice(c echo.Context) error {
	session, ok := c.Get("adminSession").(*domain.AdminSession)
	if !ok {
		return echo.NewHTTPError(http.StatusUnauthorized, ErrorResponse{Code: "UNAUTHORIZED", Message: "unauthorized"})
	}
	regID := domain.DeviceRegistrationID(c.Param("id"))

	err := h.deviceTrust.ApproveDevice(c.Request().Context(), regID, session.AdminID())
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, ErrorResponse{Code: "INTERNAL_SERVER_ERROR", Message: err.Error()}).SetInternal(err)
	}

	return c.NoContent(http.StatusOK)
}

// @Summary      기기 거절
// @Description  PENDING 상태인 기기를 REJECTED로 거절한다.
// @Tags         A. Auth & Device Trust
// @Security     AdminAuth
// @Produce      json
// @Param        campId path string true "캠프 ID"
// @Param        id path string true "기기 등록 ID"
// @Success      200 {object} DeviceRegistrationResponse
// @Router       /camps/{campId}/device-registrations/{id}/reject [post]
func (h *DeviceHandler) RejectDevice(c echo.Context) error {
	session, ok := c.Get("adminSession").(*domain.AdminSession)
	if !ok {
		return echo.NewHTTPError(http.StatusUnauthorized, ErrorResponse{Code: "UNAUTHORIZED", Message: "unauthorized"})
	}
	regID := domain.DeviceRegistrationID(c.Param("id"))

	err := h.deviceTrust.RejectDevice(c.Request().Context(), regID, session.AdminID())
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, ErrorResponse{Code: "INTERNAL_SERVER_ERROR", Message: err.Error()}).SetInternal(err)
	}

	return c.NoContent(http.StatusOK)
}

// @Summary      기기 신뢰 취소 (폐기/분실)
// @Description  APPROVED 기기의 권한을 REVOKED로 박탈한다.
// @Tags         A. Auth & Device Trust
// @Security     AdminAuth
// @Produce      json
// @Param        campId path string true "캠프 ID"
// @Param        id path string true "기기 등록 ID"
// @Success      200 {object} DeviceRegistrationResponse
// @Router       /camps/{campId}/device-registrations/{id}/revoke [post]
func (h *DeviceHandler) RevokeDevice(c echo.Context) error {
	session, ok := c.Get("adminSession").(*domain.AdminSession)
	if !ok {
		return echo.NewHTTPError(http.StatusUnauthorized, ErrorResponse{Code: "UNAUTHORIZED", Message: "unauthorized"})
	}
	regID := domain.DeviceRegistrationID(c.Param("id"))

	err := h.deviceTrust.RevokeDevice(c.Request().Context(), regID, session.AdminID())
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, ErrorResponse{Code: "INTERNAL_SERVER_ERROR", Message: err.Error()}).SetInternal(err)
	}

	return c.NoContent(http.StatusOK)
}
