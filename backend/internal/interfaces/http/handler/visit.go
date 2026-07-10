package handler

import (
	"net/http"
	"strings"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/usecase"

	"github.com/labstack/echo/v4"
)

type VisitHandler struct {
	visitUC *usecase.VisitService
}

func NewVisitHandler(visitUC *usecase.VisitService) *VisitHandler {
	return &VisitHandler{visitUC: visitUC}
}

type VisitStartRequest struct {
	QRToken string `json:"qrToken"`
	Method  string `json:"method"`
	GroupID string `json:"groupId"`
}

// @Summary      방문 시작 (조 입장)
// @Description  진행자가 조의 입장을 처리한다.
// @Tags         C. Visit (Scan Flow)
// @Security     TrackAuth
// @Accept       json
// @Produce      json
// @Param        trackId path string true "트랙 ID"
// @Param        request body VisitStartRequest true "입장 방식"
// @Success      201 "방문 시작 성공"
// @Router       /api/v1/tracks/{trackId}/visits/start [post]
func (h *VisitHandler) StartVisit(c echo.Context) error {
	// trackId := c.Param("trackId") // Handled implicitly by session token?
	
	// Get token from auth header
	authHeader := c.Request().Header.Get("Authorization")
	if authHeader == "" {
		return echo.NewHTTPError(http.StatusUnauthorized, "missing authorization header")
	}
	token := strings.TrimPrefix(authHeader, "Bearer ")

	var req VisitStartRequest
	if err := c.Bind(&req); err != nil {
		return err
	}

	var visit *domain.Visit
	var err error

	if req.Method == "MANUAL" {
		visit, err = h.visitUC.StartVisitManual(c.Request().Context(), token, domain.GroupID(req.GroupID))
	} else {
		visit, err = h.visitUC.StartVisitByQR(c.Request().Context(), token, req.QRToken)
	}

	if err != nil {
		return err // In real app, map to specific HTTP status codes
	}

	return c.JSON(http.StatusCreated, visit)
}

// @Summary      현재 방문 종료 (조 퇴장)
// @Description  진행 중인 방문을 종료 처리한다.
// @Tags         C. Visit (Scan Flow)
// @Security     TrackAuth
// @Produce      json
// @Param        trackId path string true "트랙 ID"
// @Success      200 "종료 완료"
// @Router       /api/v1/tracks/{trackId}/visits/current/end [post]
func (h *VisitHandler) EndCurrentVisit(c echo.Context) error {
	authHeader := c.Request().Header.Get("Authorization")
	token := strings.TrimPrefix(authHeader, "Bearer ")

	visit, err := h.visitUC.CompleteVisit(c.Request().Context(), token)
	if err != nil {
		return err
	}

	return c.JSON(http.StatusOK, visit)
}
