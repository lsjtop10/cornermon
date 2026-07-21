package web

import (
	"context"
	"errors"
	"net/http"
	"time"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/usecase"

	"github.com/labstack/echo/v4"
)

type AdminAuthUsecase interface {
	Login(ctx context.Context, username, password, deviceInfo string) (string, *domain.AdminSession, error)
	RevokeSession(ctx context.Context, sessionID domain.AdminSessionID, actorAdminID domain.AdminID) error
	ListSessions(ctx context.Context, adminID domain.AdminID) ([]*domain.AdminSession, error)
	ForceTrackLogout(ctx context.Context, trackID domain.TrackID, actorAdminID domain.AdminID) error
}

type FacilitatorAuthUsecase interface {
	Login(ctx context.Context, deviceToken, pin string) (*usecase.TrackLoginResult, error)
	Logout(ctx context.Context, sessionID domain.FacilitatorSessionID) error
	MigrateSession(ctx context.Context, oldSessionToken string) (*usecase.TrackLoginResult, error)
	ListActiveSessions(ctx context.Context, campID domain.CampID) ([]*domain.FacilitatorSession, error)
}

type AuthDeviceTrustUsecase interface {
	ResetPinFailures(ctx context.Context, regID domain.DeviceRegistrationID, actorAdminID domain.AdminID) error
}

type AuthHandler struct {
	adminAuth       AdminAuthUsecase
	facilitatorAuth FacilitatorAuthUsecase
	deviceTrust     AuthDeviceTrustUsecase
}

type AdminSessionResponse struct {
	ID         string    `json:"id" format:"uuid"`
	AdminID    string    `json:"adminId"`
	DeviceInfo *string   `json:"deviceInfo,omitempty"`
	CreatedAt  time.Time `json:"createdAt" format:"date-time"`
	LastUsedAt time.Time `json:"lastUsedAt" format:"date-time"`
} // @name AdminSessionResponse

type AdminLoginRequest struct {
	ID       string `json:"id"`
	Password string `json:"password"`
} // @name AdminLoginRequest

type AdminLoginResponse struct {
	AccessToken      string `json:"accessToken"`
	ExpiresInSeconds int    `json:"expiresInSeconds"`
} // @name AdminLoginResponse

type TrackLoginRequest struct {
	PIN string `json:"pin"`
} // @name TrackLoginRequest

type TrackLoginResponse struct {
	TrackToken string         `json:"trackToken"`
	Track      TrackResponse  `json:"track"`
	Corner     CornerResponse `json:"corner"`
} // @name TrackLoginResponse

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
// @Description  관리자 ID/비밀번호로 로그인하여 액세스 토큰을 발급받는다. 토큰은 슬라이딩 세션으로 활동이 있으면 만료가 연장된다.
// @Tags         A. Auth & Device Trust
// @Accept       json
// @Produce      json
// @Param        request body AdminLoginRequest true "로그인 정보"
// @Success      200 {object} AdminLoginResponse "로그인 성공"
// @Failure      401 {object} ErrorResponse "잘못된 ID 또는 비밀번호"
// @Router       /auth/admin/login [post]
func (h *AuthHandler) AdminLogin(c echo.Context) error {
	var req AdminLoginRequest
	if err := c.Bind(&req); err != nil {
		return echo.NewHTTPError(http.StatusBadRequest, ErrorResponse{Code: CodeBadRequest, Message: "invalid request"}).SetInternal(err)
	}

	deviceInfo := c.Request().UserAgent()
	access, _, err := h.adminAuth.Login(c.Request().Context(), req.ID, req.Password, deviceInfo)
	if err != nil {
		return echo.NewHTTPError(http.StatusUnauthorized, ErrorResponse{Code: CodeUnauthorized, Message: err.Error()}).SetInternal(err)
	}

	return c.JSON(http.StatusOK, AdminLoginResponse{
		AccessToken:      access,
		ExpiresInSeconds: int(usecase.AdminAccessTokenTTL.Seconds()),
	})
}

// @Summary      관리자 로그아웃
// @Description  현재 활성화된 리프레시 토큰(세션)을 취소(Revoke)한다.
// @Tags         A. Auth & Device Trust
// @Security     AdminAuth
// @Produce      json
// @Success      204 "로그아웃 성공"
// @Failure      401 {object} ErrorResponse "권한 없음"
// @Router       /auth/admin/logout [post]
func (h *AuthHandler) AdminLogout(c echo.Context) error {
	session, ok := c.Get("adminSession").(*domain.AdminSession)
	if !ok {
		return echo.NewHTTPError(http.StatusUnauthorized, ErrorResponse{Code: CodeUnauthorized, Message: "unauthorized"})
	}

	err := h.adminAuth.RevokeSession(c.Request().Context(), session.ID(), session.AdminID())
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, ErrorResponse{Code: CodeInternalServerError, Message: err.Error()}).SetInternal(err)
	}

	return c.NoContent(http.StatusNoContent)
}

// @Summary      관리자 세션 목록 조회
// @Description  현재 로그인된 관리자 세션 목록을 반환한다.
// @Tags         A. Auth & Device Trust
// @Security     AdminAuth
// @Produce      json
// @Success      200 {array} AdminSessionResponse
// @Router       /auth/admin/sessions [get]
func (h *AuthHandler) ListAdminSessions(c echo.Context) error {
	session, ok := c.Get("adminSession").(*domain.AdminSession)
	if !ok {
		return echo.NewHTTPError(http.StatusUnauthorized, ErrorResponse{Code: CodeUnauthorized, Message: "unauthorized"})
	}

	sessions, err := h.adminAuth.ListSessions(c.Request().Context(), session.AdminID())
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, ErrorResponse{Code: CodeInternalServerError, Message: err.Error()}).SetInternal(err)
	}

	var res []AdminSessionResponse
	for _, s := range sessions {
		devInfo := ""
		if s.DeviceInfo() != "" {
			devInfo = s.DeviceInfo()
		}
		res = append(res, AdminSessionResponse{
			ID:         string(s.ID()),
			AdminID:    string(s.AdminID()),
			DeviceInfo: &devInfo,
			CreatedAt:  s.CreatedAt(),
			LastUsedAt: s.LastUsedAt(),
		})
	}

	return c.JSON(http.StatusOK, res)
}

type FacilitatorSessionResponse struct {
	ID        string    `json:"id" format:"uuid"`
	TrackID   string    `json:"trackId" format:"uuid"`
	CreatedAt time.Time `json:"createdAt" format:"date-time"`
} // @name FacilitatorSessionResponse

// @Summary      활성 진행자 세션 목록 조회
// @Description  캠프 내 취소되지 않은(active) 진행자 세션 목록을 조회한다.
// @Tags         A. Auth & Device Trust
// @Security     AdminAuth
// @Produce      json
// @Param        campId query string true "캠프 ID"
// @Success      200 {array} FacilitatorSessionResponse
// @Failure      400 {object} ErrorResponse
// @Router       /auth/track/sessions [get]
func (h *AuthHandler) ListActiveFacilitatorSessions(c echo.Context) error {
	campID := c.QueryParam("campId")
	if campID == "" {
		return echo.NewHTTPError(http.StatusBadRequest, ErrorResponse{Code: CodeBadRequest, Message: "missing campId"})
	}
	sessions, err := h.facilitatorAuth.ListActiveSessions(c.Request().Context(), domain.CampID(campID))
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, ErrorResponse{Code: CodeInternalServerError, Message: err.Error()}).SetInternal(err)
	}
	res := make([]FacilitatorSessionResponse, len(sessions))
	for i, session := range sessions {
		res[i] = FacilitatorSessionResponse{ID: string(session.ID()), TrackID: string(session.TrackID()), CreatedAt: session.CreatedAt()}
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
		return echo.NewHTTPError(http.StatusUnauthorized, ErrorResponse{Code: CodeUnauthorized, Message: "unauthorized"})
	}
	targetID := domain.AdminSessionID(c.Param("id"))

	err := h.adminAuth.RevokeSession(c.Request().Context(), targetID, session.AdminID())
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, ErrorResponse{Code: CodeInternalServerError, Message: err.Error()}).SetInternal(err)
	}

	return c.NoContent(http.StatusNoContent)
}

// @Summary      진행자 트랙 PIN 로그인
// @Description  신뢰 기기에서 트랙 PIN 으로 로그인하여 트랙 세션 토큰을 발급받는다.
// @Tags         A. Auth & Device Trust
// @Security     TrustedDeviceAuth
// @Accept       json
// @Produce      json
// @Param        X-Device-Token header string true "기기 신뢰 토큰 (opaque token, 값을 그대로 전달)"
// @Param        request body TrackLoginRequest true "6자리 숫자 트랙 PIN"
// @Success      200 {object} TrackLoginResponse "로그인 성공 — 트랙 세션 토큰 발급"
// @Failure      400 {object} ErrorResponse "INVALID_PIN: PIN이 올바르지 않음"
// @Failure      403 {object} ErrorResponse "DEVICE_NOT_APPROVED: 기기가 승인되지 않음; CAMP_NOT_AVAILABLE: 캠프가 로그인 가능한 상태가 아님"
// @Failure      429 {object} ErrorResponse "DEVICE_LOCKED: PIN 실패 횟수 초과로 기기가 일시 잠김"
// @Router       /auth/track/login [post]
func (h *AuthHandler) TrackLogin(c echo.Context) error {
	var req TrackLoginRequest
	if err := c.Bind(&req); err != nil {
		return echo.NewHTTPError(http.StatusBadRequest, ErrorResponse{Code: CodeBadRequest, Message: "invalid request"}).SetInternal(err)
	}

	deviceToken := c.Request().Header.Get("X-Device-Token")
	if deviceToken == "" {
		return echo.NewHTTPError(http.StatusForbidden, ErrorResponse{Code: CodeForbidden, Message: "missing device token"})
	}

	res, err := h.facilitatorAuth.Login(c.Request().Context(), deviceToken, req.PIN)
	if err != nil {
		return trackLoginHTTPError(err)
	}

	return c.JSON(http.StatusOK, TrackLoginResponse{
		TrackToken: res.TrackToken,
		Track: TrackResponse{
			TrackSummaryResponse: TrackSummaryResponse{
				ID:       string(res.Track.ID()),
				CornerID: string(res.Track.CornerID()),
				TrackNo:  res.Track.TrackNo(),
				Status:   string(res.Track.Status()),
			},
		},
		Corner: CornerResponse{
			ID:     string(res.Corner.ID()),
			Name:   res.Corner.Name(),
			CampID: string(res.Corner.CampID()),
		},
	})
}

func trackLoginHTTPError(err error) error {
	switch {
	case errors.Is(err, domain.ErrDeviceNotApproved):
		return echo.NewHTTPError(http.StatusForbidden, ErrorResponse{Code: CodeDeviceNotApproved, Message: "device is not approved"}).SetInternal(err)
	case errors.Is(err, domain.ErrDeviceLocked):
		return echo.NewHTTPError(http.StatusTooManyRequests, ErrorResponse{Code: CodeDeviceLocked, Message: "device is temporarily locked"}).SetInternal(err)
	case errors.Is(err, domain.ErrInvalidPin):
		return echo.NewHTTPError(http.StatusBadRequest, ErrorResponse{Code: CodeInvalidPin, Message: "invalid pin"}).SetInternal(err)
	case errors.Is(err, domain.ErrCampInvalidTransition):
		return echo.NewHTTPError(http.StatusForbidden, ErrorResponse{Code: CodeCampNotAvailable, Message: "camp is not available for track login"}).SetInternal(err)
	default:
		return err
	}
}

// @Summary      진행자 트랙 로그아웃
// @Description  트랙 진행자가 스스로 로그아웃한다.
// @Tags         A. Auth & Device Trust
// @Security     TrackAuth
// @Produce      json
// @Success      204 "성공"
// @Failure      401 {object} ErrorResponse "SESSION_REVOKED: 세션이 이미 취소됨"
// @Router       /auth/track/logout [post]
func (h *AuthHandler) TrackLogout(c echo.Context) error {
	session, ok := c.Get("facilitatorSession").(*domain.FacilitatorSession)
	if !ok {
		return echo.NewHTTPError(http.StatusUnauthorized, ErrorResponse{Code: CodeUnauthorized, Message: "unauthorized"})
	}

	err := h.facilitatorAuth.Logout(c.Request().Context(), session.ID())
	if err != nil {
		if errors.Is(err, domain.ErrSessionRevoked) {
			return echo.NewHTTPError(http.StatusUnauthorized, ErrorResponse{Code: CodeSessionRevoked, Message: "session is revoked"}).SetInternal(err)
		}
		return echo.NewHTTPError(http.StatusInternalServerError, ErrorResponse{Code: CodeInternalServerError, Message: err.Error()}).SetInternal(err)
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
		return echo.NewHTTPError(http.StatusUnauthorized, ErrorResponse{Code: CodeUnauthorized, Message: "unauthorized"})
	}
	trackID := domain.TrackID(c.Param("trackId"))

	err := h.adminAuth.ForceTrackLogout(c.Request().Context(), trackID, session.AdminID())
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, ErrorResponse{Code: CodeInternalServerError, Message: err.Error()}).SetInternal(err)
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
// @Failure      409 {object} ErrorResponse "DEVICE_INVALID_TRANSITION: 존재하지 않거나 잠금 해제할 수 없는 기기"
// @Router       /auth/track/lockout/{deviceId}/release [post]
func (h *AuthHandler) ReleaseLockout(c echo.Context) error {
	session, ok := c.Get("adminSession").(*domain.AdminSession)
	if !ok {
		return echo.NewHTTPError(http.StatusUnauthorized, ErrorResponse{Code: CodeUnauthorized, Message: "unauthorized"})
	}
	deviceID := domain.DeviceRegistrationID(c.Param("deviceId"))

	err := h.deviceTrust.ResetPinFailures(c.Request().Context(), deviceID, session.AdminID())
	if err != nil {
		if errors.Is(err, domain.ErrDeviceInvalidTransition) {
			return echo.NewHTTPError(http.StatusConflict, ErrorResponse{Code: CodeDeviceInvalidTransition, Message: "device registration cannot reset pin failures"}).SetInternal(err)
		}
		return echo.NewHTTPError(http.StatusInternalServerError, ErrorResponse{Code: CodeInternalServerError, Message: err.Error()}).SetInternal(err)
	}

	return c.NoContent(http.StatusNoContent)
}

// @Summary      교체된 트랙의 세션 마이그레이션
// @Description  트랙이 교체되어 `track_replaced` 알림을 받은 기기가 호출한다. 기존 세션 토큰을 Authorization 헤더에 담아 새 세션을 발급받는다.
// @Tags         B. Camp / Corner / Track
// @Security     TrackAuth
// @Produce      json
// @Param        id path string true "기존 트랙 ID"
// @Success      200 {object} TrackLoginResponse
// @Failure      401 {object} ErrorResponse "권한 없음 또는 세션 만료"
// @Router       /tracks/{id}/migrate-session [post]
func (h *AuthHandler) MigrateSession(c echo.Context) error {
	sessionToken := extractToken(c.Request().Header.Get("Authorization"))
	if sessionToken == "" {
		return echo.NewHTTPError(http.StatusUnauthorized, ErrorResponse{Code: CodeUnauthorized, Message: "missing token"})
	}

	res, err := h.facilitatorAuth.MigrateSession(c.Request().Context(), sessionToken)
	if err != nil {
		if errors.Is(err, domain.ErrSessionRevoked) {
			return echo.NewHTTPError(http.StatusUnauthorized, ErrorResponse{Code: CodeSessionRevoked, Message: "session is revoked"}).SetInternal(err)
		}
		return echo.NewHTTPError(http.StatusInternalServerError, ErrorResponse{Code: CodeInternalServerError, Message: err.Error()}).SetInternal(err)
	}

	return c.JSON(http.StatusOK, TrackLoginResponse{
		TrackToken: res.TrackToken,
		Track: TrackResponse{
			TrackSummaryResponse: TrackSummaryResponse{
				ID:       string(res.Track.ID()),
				CornerID: string(res.Track.CornerID()),
				TrackNo:  res.Track.TrackNo(),
				Status:   string(res.Track.Status()),
			},
		},
		Corner: CornerResponse{
			ID:   string(res.Corner.ID()),
			Name: res.Corner.Name(),
		},
	})
}
