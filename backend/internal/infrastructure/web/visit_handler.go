package web

import (
	"errors"
	"net/http"
	"strings"
	"time"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/usecase"

	"github.com/labstack/echo/v4"
)

type VisitHandler struct {
	visitUC *usecase.VisitService
}

type VisitSummaryResponse struct {
	ID               string     `json:"id" format:"uuid"`
	GroupID          string     `json:"groupId" format:"uuid"`
	CornerID         string     `json:"cornerId" format:"uuid"`
	TrackID          string     `json:"trackId" format:"uuid"`
	Status           string     `json:"status" enums:"IN_PROGRESS,COMPLETED"`
	InputMethod      string     `json:"inputMethod" enums:"QR_SCAN,MANUAL"`
	StartedAt        time.Time  `json:"startedAt" format:"date-time"`
	EndedAt          *time.Time `json:"endedAt,omitempty" format:"date-time"`
	DurationSeconds  *int       `json:"durationSeconds,omitempty"`
	DeviationSeconds *int       `json:"deviationSeconds,omitempty"`
} // @name VisitSummaryResponse

func NewVisitHandler(visitUC *usecase.VisitService) *VisitHandler {
	return &VisitHandler{visitUC: visitUC}
}

type VisitStartRequest struct {
	QRToken string `json:"qrToken"`
	Method  string `json:"method" enums:"MANUAL"`
	GroupID string `json:"groupId"`
} // @name VisitStartRequest

func mapVisitToDTO(v *domain.Visit) VisitSummaryResponse {
	res := VisitSummaryResponse{
		ID:          string(v.ID()),
		GroupID:     string(v.GroupID()),
		CornerID:    string(v.CornerID()),
		TrackID:     string(v.TrackID()),
		Status:      string(v.Status()),
		InputMethod: string(v.InputMethod()),
		StartedAt:   v.StartedAt(),
	}
	if endedAt, ok := v.EndedAt().Value(); ok {
		res.EndedAt = &endedAt
	}
	if dur, ok := v.DurationSeconds().Value(); ok {
		res.DurationSeconds = &dur
	}
	return res
}

// @Summary      방문 시작 (조 입장)
// @Description  진행자가 조의 입장을 처리한다. QR 스캔 또는 수동 처리.
// @Tags         C. Visit (Scan Flow)
// @Security     TrackAuth
// @Accept       json
// @Produce      json
// @Param        trackId path string true "트랙 ID"
// @Param        request body VisitStartRequest true "입장 방식 및 페이로드"
// @Success      201 {object} VisitSummaryResponse
// @Failure      401 {object} ErrorResponse "SESSION_REVOKED: 진행자 세션이 취소됨"
// @Failure      404 {object} ErrorResponse "BADGE_NOT_ASSIGNED: 배지가 존재하지 않거나 조에 배정되지 않음"
// @Failure      409 {object} ErrorResponse "TRACK_BUSY, TRACK_NOT_ACTIVE, ITINERARY_CONFLICT, CAMP_NOT_ACTIVE: 현재 운영 상태에서 방문을 시작할 수 없음"
// @Router       /tracks/{trackId}/visits/start [post]
func (h *VisitHandler) StartVisit(c echo.Context) error {
	authHeader := c.Request().Header.Get("Authorization")
	token := strings.TrimPrefix(authHeader, "Bearer ")

	var req VisitStartRequest
	if err := c.Bind(&req); err != nil {
		return echo.NewHTTPError(http.StatusBadRequest, ErrorResponse{Code: CodeBadRequest, Message: "invalid request"}).SetInternal(err)
	}

	var visit *domain.Visit
	var err error

	if req.Method == "MANUAL" {
		visit, err = h.visitUC.StartVisitManual(c.Request().Context(), token, domain.GroupID(req.GroupID))
	} else {
		visit, err = h.visitUC.StartVisitByQR(c.Request().Context(), token, req.QRToken)
	}

	if err != nil {
		return visitHTTPError(err)
	}

	return c.JSON(http.StatusCreated, mapVisitToDTO(visit))
}

// @Summary      현재 방문 종료 (조 퇴장)
// @Description  진행 중인 방문을 종료 처리한다. (화면의 종료 확인 2회 탭)
// @Tags         C. Visit (Scan Flow)
// @Security     TrackAuth
// @Produce      json
// @Param        trackId path string true "트랙 ID"
// @Success      200 {object} VisitSummaryResponse
// @Failure      401 {object} ErrorResponse "SESSION_REVOKED: 진행자 세션이 취소됨"
// @Failure      409 {object} ErrorResponse "TRACK_NOT_BUSY, TRACK_NOT_ACTIVE, ITINERARY_CONFLICT: 현재 운영 상태에서 방문을 종료할 수 없음"
// @Router       /tracks/{trackId}/visits/current/end [post]
func (h *VisitHandler) EndCurrentVisit(c echo.Context) error {
	authHeader := c.Request().Header.Get("Authorization")
	token := strings.TrimPrefix(authHeader, "Bearer ")

	visit, err := h.visitUC.CompleteVisit(c.Request().Context(), token)
	if err != nil {
		return visitHTTPError(err)
	}

	return c.JSON(http.StatusOK, mapVisitToDTO(visit))
}

// @Summary      현재 진행 중인 방문 상태 조회
// @Description  스캐너 앱이 크래시되거나 새로고침 되었을 때, 현재 트랙에서 진행 중인 방문이 있는지 확인.
// @Tags         C. Visit (Scan Flow)
// @Security     TrackAuth
// @Produce      json
// @Param        trackId path string true "트랙 ID"
// @Success      200 {object} VisitSummaryResponse
// @Failure      401 {object} ErrorResponse "SESSION_REVOKED: 진행자 세션이 취소됨"
// @Failure      404 {object} ErrorResponse "VISIT_NOT_FOUND: 진행 중인 방문 없음"
// @Router       /tracks/{trackId}/visits/current [get]
func (h *VisitHandler) GetCurrentVisit(c echo.Context) error {
	authHeader := c.Request().Header.Get("Authorization")
	token := strings.TrimPrefix(authHeader, "Bearer ")

	visit, err := h.visitUC.GetCurrentVisit(c.Request().Context(), token)
	if err != nil {
		return visitHTTPError(err)
	}
	if visit == nil {
		return echo.ErrNotFound
	}

	return c.JSON(http.StatusOK, mapVisitToDTO(visit))
}

func visitHTTPError(err error) error {
	switch {
	case errors.Is(err, domain.ErrSessionRevoked):
		return echo.NewHTTPError(http.StatusUnauthorized, ErrorResponse{Code: CodeSessionRevoked, Message: "facilitator session is revoked"}).SetInternal(err)
	case errors.Is(err, domain.ErrBadgeNotAssigned):
		return echo.NewHTTPError(http.StatusNotFound, ErrorResponse{Code: CodeBadgeNotAssigned, Message: "badge is not assigned to a group"}).SetInternal(err)
	case errors.Is(err, domain.ErrTrackBusy):
		return echo.NewHTTPError(http.StatusConflict, ErrorResponse{Code: CodeTrackBusy, Message: "track already has a visit in progress"}).SetInternal(err)
	case errors.Is(err, domain.ErrTrackNotBusy):
		return echo.NewHTTPError(http.StatusConflict, ErrorResponse{Code: CodeTrackNotBusy, Message: "track has no visit in progress"}).SetInternal(err)
	case errors.Is(err, domain.ErrTrackNotActive):
		return echo.NewHTTPError(http.StatusConflict, ErrorResponse{Code: CodeTrackNotActive, Message: "track is not active"}).SetInternal(err)
	case errors.Is(err, domain.ErrCornerNotInItinerary), errors.Is(err, domain.ErrGroupBusy), errors.Is(err, domain.ErrDuplicateVisit), errors.Is(err, domain.ErrVisitAlreadyCompleted):
		return echo.NewHTTPError(http.StatusConflict, ErrorResponse{Code: CodeItineraryConflict, Message: "visit does not satisfy the group itinerary"}).SetInternal(err)
	case errors.Is(err, domain.ErrCampInvalidTransition):
		return echo.NewHTTPError(http.StatusConflict, ErrorResponse{Code: CodeCampNotActive, Message: "camp is not active"}).SetInternal(err)
	default:
		return err
	}
}
