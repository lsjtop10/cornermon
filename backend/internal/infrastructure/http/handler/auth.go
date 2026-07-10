package handler

import (
	"context"
	"net/http"
	"strings"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/infrastructure/http/dto"
	"cornermon/backend/internal/usecase"

	"github.com/labstack/echo/v4"
)

type AdminAuthUsecase interface {
	Login(ctx context.Context, username, password, deviceInfo string) (string, string, *domain.AdminSession, error)
	RefreshToken(ctx context.Context, refreshToken string) (string, error)
	RevokeSession(ctx context.Context, sessionID domain.AdminSessionID, actorAdminID domain.AdminID) error
	ListSessions(ctx context.Context, adminID domain.AdminID) ([]*domain.AdminSession, error)
	ForceTrackLogout(ctx context.Context, trackID domain.TrackID, actorAdminID domain.AdminID) error
}

type FacilitatorAuthUsecase interface {
	Login(ctx context.Context, deviceToken, pin string) (*usecase.TrackLoginResult, error)
	Logout(ctx context.Context, sessionID domain.FacilitatorSessionID) error
}

type AuthDeviceTrustUsecase interface {
	ResetPinFailures(ctx context.Context, regID domain.DeviceRegistrationID, actorAdminID domain.AdminID) error
}

type AuthHandler struct {
	adminAuth       AdminAuthUsecase
	facilitatorAuth FacilitatorAuthUsecase
	deviceTrust     AuthDeviceTrustUsecase
}

func NewAuthHandler(
	adminAuth AdminAuthUsecase,
	facilitatorAuth FacilitatorAuthUsecase,
	deviceTrust AuthDeviceTrustUsecase,
) *AuthHandler {
	return &AuthHandler{
		adminAuth:       adminAuth,
		facilitatorAuth: facilitatorAuth,
		deviceTrust:     deviceTrust,
	}
}

// @Summary      관리자 로그인
// @Description  관리자 ID/비밀번호로 로그인하여 액세스 토큰과 리프레시 토큰을 발급받는다.
// @Tags         A. Auth & Device Trust
// @Accept       json
// @Produce      json
// @Param        request body dto.AdminLoginRequest true "로그인 정보"
// @Success      200 {object} dto.AdminLoginResponse "로그인 성공"
// @Failure      401 {object} dto.ErrorResponse "잘못된 ID 또는 비밀번호"
// @Router       /auth/admin/login [post]
func (h *AuthHandler) AdminLogin(c echo.Context) error {
	var req dto.AdminLoginRequest
	if err := c.Bind(&req); err != nil {
		return c.JSON(http.StatusBadRequest, dto.ErrorResponse{Code: "BAD_REQUEST", Message: "invalid request"})
	}

	deviceInfo := c.Request().UserAgent()
	access, refresh, _, err := h.adminAuth.Login(c.Request().Context(), req.ID, req.Password, deviceInfo)
	if err != nil {
		return c.JSON(http.StatusUnauthorized, dto.ErrorResponse{Code: "UNAUTHORIZED", Message: err.Error()})
	}

	return c.JSON(http.StatusOK, dto.AdminLoginResponse{
		AccessToken:      access,
		RefreshToken:     refresh,
		ExpiresInSeconds: 1800,
	})
}

// @Summary      관리자 액세스 토큰 재발급
// @Description  리프레시 토큰으로 새 액세스 토큰을 발급한다.
// @Tags         A. Auth & Device Trust
// @Security     AdminRefreshAuth
// @Produce      json
// @Success      200 {object} dto.AdminRefreshResponse "새 액세스 토큰 발급"
// @Failure      401 {object} dto.ErrorResponse "권한 없음"
// @Router       /auth/admin/refresh [post]
func (h *AuthHandler) AdminRefresh(c echo.Context) error {
	authHeader := c.Request().Header.Get("Authorization")
	refreshToken := strings.TrimPrefix(authHeader, "Bearer ")
	if refreshToken == "" {
		return c.JSON(http.StatusUnauthorized, dto.ErrorResponse{Code: "UNAUTHORIZED", Message: "missing token"})
	}

	access, err := h.adminAuth.RefreshToken(c.Request().Context(), refreshToken)
	if err != nil {
		return c.JSON(http.StatusUnauthorized, dto.ErrorResponse{Code: "UNAUTHORIZED", Message: err.Error()})
	}

	return c.JSON(http.StatusOK, dto.AdminRefreshResponse{
		AccessToken:      access,
		ExpiresInSeconds: 1800,
	})
}

// @Summary      관리자 로그아웃
// @Description  현재 활성화된 리프레시 토큰(세션)을 취소(Revoke)한다.
// @Tags         A. Auth & Device Trust
// @Security     AdminAuth
// @Produce      json
// @Success      204 "로그아웃 성공"
// @Failure      401 {object} dto.ErrorResponse "권한 없음"
// @Router       /auth/admin/logout [post]
func (h *AuthHandler) AdminLogout(c echo.Context) error {
	session, ok := c.Get("adminSession").(*domain.AdminSession)
	if !ok {
		return c.JSON(http.StatusUnauthorized, dto.ErrorResponse{Code: "UNAUTHORIZED", Message: "unauthorized"})
	}

	err := h.adminAuth.RevokeSession(c.Request().Context(), session.ID, session.AdminID)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Code: "INTERNAL_SERVER_ERROR", Message: err.Error()})
	}

	return c.NoContent(http.StatusNoContent)
}

// @Summary      관리자 세션 목록 조회
// @Description  현재 로그인된 관리자 세션 목록을 반환한다.
// @Tags         A. Auth & Device Trust
// @Security     AdminAuth
// @Produce      json
// @Success      200 {array} dto.AdminSession
// @Router       /auth/admin/sessions [get]
func (h *AuthHandler) ListAdminSessions(c echo.Context) error {
	session, ok := c.Get("adminSession").(*domain.AdminSession)
	if !ok {
		return c.JSON(http.StatusUnauthorized, dto.ErrorResponse{Code: "UNAUTHORIZED", Message: "unauthorized"})
	}

	sessions, err := h.adminAuth.ListSessions(c.Request().Context(), session.AdminID)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Code: "INTERNAL_SERVER_ERROR", Message: err.Error()})
	}

	var res []dto.AdminSession
	for _, s := range sessions {
		devInfo := ""
		if s.DeviceInfo != "" {
			devInfo = s.DeviceInfo
		}
		res = append(res, dto.AdminSession{
			ID:         string(s.ID),
			AdminID:    string(s.AdminID),
			DeviceInfo: &devInfo,
			CreatedAt:  s.CreatedAt,
			LastUsedAt: s.LastUsedAt,
		})
	}

	return c.JSON(http.StatusOK, res)
}

// @Summary      관리자 세션 강제 종료
// @Description  특정 관리자 세션을 강제 만료 처리한다.
// @Tags         A. Auth & Device Trust
// @Security     AdminAuth
// @Produce      json
// @Param        id path string true "세션 ID"
// @Success      204 "성공적으로 만료 처리됨"
// @Router       /auth/admin/sessions/{id}/revoke [post]
func (h *AuthHandler) RevokeAdminSession(c echo.Context) error {
	session, ok := c.Get("adminSession").(*domain.AdminSession)
	if !ok {
		return c.JSON(http.StatusUnauthorized, dto.ErrorResponse{Code: "UNAUTHORIZED", Message: "unauthorized"})
	}
	targetID := domain.AdminSessionID(c.Param("id"))

	err := h.adminAuth.RevokeSession(c.Request().Context(), targetID, session.AdminID)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Code: "INTERNAL_SERVER_ERROR", Message: err.Error()})
	}

	return c.NoContent(http.StatusNoContent)
}

// @Summary      진행자 트랙 PIN 로그인
// @Description  신뢰 기기에서 트랙 PIN 으로 로그인하여 트랙 세션 토큰을 발급받는다.
// @Tags         A. Auth & Device Trust
// @Security     TrustedDeviceAuth
// @Accept       json
// @Produce      json
// @Param        request body dto.TrackLoginRequest true "6자리 숫자 트랙 PIN"
// @Success      200 {object} dto.TrackLoginResponse "로그인 성공 — 트랙 세션 토큰 발급"
// @Failure      400 {object} dto.ErrorResponse "잘못된 PIN"
// @Failure      403 {object} dto.ErrorResponse "거부됨"
// @Router       /auth/track/login [post]
func (h *AuthHandler) TrackLogin(c echo.Context) error {
	var req dto.TrackLoginRequest
	if err := c.Bind(&req); err != nil {
		return c.JSON(http.StatusBadRequest, dto.ErrorResponse{Code: "BAD_REQUEST", Message: "invalid request"})
	}

	deviceToken := c.Request().Header.Get("X-Device-Token")
	if deviceToken == "" {
		return c.JSON(http.StatusForbidden, dto.ErrorResponse{Code: "FORBIDDEN", Message: "missing device token"})
	}

	res, err := h.facilitatorAuth.Login(c.Request().Context(), deviceToken, req.PIN)
	if err != nil {
		return c.JSON(http.StatusForbidden, dto.ErrorResponse{Code: "FORBIDDEN", Message: err.Error()})
	}

	return c.JSON(http.StatusOK, dto.TrackLoginResponse{
		TrackToken: res.TrackToken,
		Track: dto.Track{
			TrackSummary: dto.TrackSummary{
				ID:       string(res.Track.ID),
				CornerID: string(res.Track.CornerID),
				TrackNo:  res.Track.TrackNo,
				Status:   string(res.Track.Status),
			},
		},
		Corner: dto.Corner{
			ID:   string(res.Corner.ID),
			Name: res.Corner.Name,
		},
	})
}

// @Summary      진행자 트랙 로그아웃
// @Description  트랙 진행자가 스스로 로그아웃한다.
// @Tags         A. Auth & Device Trust
// @Security     TrackAuth
// @Produce      json
// @Success      204 "성공"
// @Router       /auth/track/logout [post]
func (h *AuthHandler) TrackLogout(c echo.Context) error {
	session, ok := c.Get("facilitatorSession").(*domain.FacilitatorSession)
	if !ok {
		return c.JSON(http.StatusUnauthorized, dto.ErrorResponse{Code: "UNAUTHORIZED", Message: "unauthorized"})
	}

	err := h.facilitatorAuth.Logout(c.Request().Context(), session.ID)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Code: "INTERNAL_SERVER_ERROR", Message: err.Error()})
	}

	return c.NoContent(http.StatusNoContent)
}

// @Summary      트랙 강제 로그아웃
// @Description  관리자가 특정 트랙의 진행자 세션을 강제 종료시킨다.
// @Tags         A. Auth & Device Trust
// @Security     AdminAuth
// @Produce      json
// @Param        trackId path string true "트랙 ID"
// @Success      204 "성공"
// @Router       /auth/track/{trackId}/force-logout [post]
func (h *AuthHandler) ForceTrackLogout(c echo.Context) error {
	session, ok := c.Get("adminSession").(*domain.AdminSession)
	if !ok {
		return c.JSON(http.StatusUnauthorized, dto.ErrorResponse{Code: "UNAUTHORIZED", Message: "unauthorized"})
	}
	trackID := domain.TrackID(c.Param("trackId"))

	err := h.adminAuth.ForceTrackLogout(c.Request().Context(), trackID, session.AdminID)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Code: "INTERNAL_SERVER_ERROR", Message: err.Error()})
	}

	return c.NoContent(http.StatusNoContent)
}

// @Summary      디바이스 락아웃 해제
// @Description  관리자가 PIN 다회 오류로 잠긴 기기를 해제한다.
// @Tags         A. Auth & Device Trust
// @Security     AdminAuth
// @Produce      json
// @Param        deviceId path string true "기기 ID"
// @Success      204 "성공"
// @Router       /auth/track/lockout/{deviceId}/release [post]
func (h *AuthHandler) ReleaseLockout(c echo.Context) error {
	session, ok := c.Get("adminSession").(*domain.AdminSession)
	if !ok {
		return c.JSON(http.StatusUnauthorized, dto.ErrorResponse{Code: "UNAUTHORIZED", Message: "unauthorized"})
	}
	deviceID := domain.DeviceRegistrationID(c.Param("deviceId"))

	err := h.deviceTrust.ResetPinFailures(c.Request().Context(), deviceID, session.AdminID)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Code: "INTERNAL_SERVER_ERROR", Message: err.Error()})
	}

	return c.NoContent(http.StatusNoContent)
}
