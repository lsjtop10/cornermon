package handler

import (
	"context"
	"net/http"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/interfaces/http/dto"
	"cornermon/backend/internal/usecase"

	"github.com/labstack/echo/v4"
)

type AdminAuthUsecase interface {
	Login(ctx context.Context, username, password, deviceInfo string) (string, string, *domain.AdminSession, error)
	RefreshToken(ctx context.Context, refreshToken string) (string, error)
	RevokeSession(ctx context.Context, sessionID domain.AdminSessionID, actorAdminID domain.AdminID) error
}

type FacilitatorAuthUsecase interface {
	Login(ctx context.Context, deviceToken, pin string) (*usecase.TrackLoginResult, error)
}

type DeviceTrustUsecase interface {
	RequestRegistration(ctx context.Context, campID domain.CampID, deviceName string) (string, *domain.DeviceRegistration, error)
}

type AuthHandler struct {
	adminAuth       AdminAuthUsecase
	facilitatorAuth FacilitatorAuthUsecase
	deviceTrust     DeviceTrustUsecase
}

func NewAuthHandler(
	adminAuth AdminAuthUsecase,
	facilitatorAuth FacilitatorAuthUsecase,
	deviceTrust DeviceTrustUsecase,
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
// @Router       /api/v1/auth/admin/login [post]
func (h *AuthHandler) AdminLogin(c echo.Context) error {
	var req dto.AdminLoginRequest
	if err := c.Bind(&req); err != nil {
		return err
	}

	deviceInfo := c.Request().UserAgent()
	if deviceInfo == "" {
		deviceInfo = "Unknown Device"
	}

	access, refresh, session, err := h.adminAuth.Login(c.Request().Context(), req.ID, req.Password, deviceInfo)
	if err != nil {
		return err
	}

	// AdminAccessTokenTTL = 30 * time.Minute in usecase
	// Hardcoding for response, or extract from usecase
	return c.JSON(http.StatusOK, dto.AdminLoginResponse{
		AccessToken:      access,
		RefreshToken:     refresh,
		ExpiresInSeconds: int(session.LastUsedAt.Add(1800).Unix() - session.LastUsedAt.Unix()), // approximately 1800
	})
}

// @Summary      관리자 액세스 토큰 재발급 (Silent Refresh)
// @Description  리프레시 토큰으로 새 액세스 토큰을 발급한다.
// @Tags         A. Auth & Device Trust
// @Security     AdminRefreshAuth
// @Produce      json
// @Success      200 {object} dto.AdminRefreshResponse "새 액세스 토큰 발급"
// @Failure      401 {object} dto.ErrorResponse "권한 없음"
// @Router       /api/v1/auth/admin/refresh [post]
func (h *AuthHandler) AdminRefresh(c echo.Context) error {
	sessionData := c.Get("adminSession")
	if sessionData == nil {
		return echo.NewHTTPError(http.StatusUnauthorized, "missing session")
	}

	// In refresh, the client might send the refresh token in Authorization header.
	// We need to pass the plain refresh token to the usecase.
	// But AdminAuthMiddleware parses the access token. 
	// Wait! The refresh endpoint needs the refresh token, not the access token.
	// I should extract the refresh token from the request.
	token := c.Request().Header.Get("Authorization")
	if len(token) > 7 && token[:7] == "Bearer " {
		token = token[7:]
	}

	newAccess, err := h.adminAuth.RefreshToken(c.Request().Context(), token)
	if err != nil {
		return err
	}

	return c.JSON(http.StatusOK, dto.AdminRefreshResponse{
		AccessToken:      newAccess,
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
// @Router       /api/v1/auth/admin/logout [post]
func (h *AuthHandler) AdminLogout(c echo.Context) error {
	sessionData := c.Get("adminSession")
	if sessionData == nil {
		return echo.NewHTTPError(http.StatusUnauthorized, "missing session")
	}
	session := sessionData.(*domain.AdminSession)

	err := h.adminAuth.RevokeSession(c.Request().Context(), session.ID, session.AdminID)
	if err != nil {
		return err
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
// @Router       /api/v1/auth/track/login [post]
func (h *AuthHandler) TrackLogin(c echo.Context) error {
	var req dto.TrackLoginRequest
	if err := c.Bind(&req); err != nil {
		return err
	}

	deviceToken := c.Request().Header.Get("Authorization")
	if len(deviceToken) > 7 && deviceToken[:7] == "Bearer " {
		deviceToken = deviceToken[7:]
	}

	res, err := h.facilitatorAuth.Login(c.Request().Context(), deviceToken, req.PIN)
	if err != nil {
		return err
	}

	return c.JSON(http.StatusOK, dto.TrackLoginResponse{
		TrackToken: res.TrackToken,
		Track:      dto.ToTrackDTO(res.Track),
		Corner:     dto.ToCornerDTO(res.Corner),
	})
}
