package web

import (
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
}

// @name VisitSummaryResponse

func NewVisitHandler(visitUC *usecase.VisitService) *VisitHandler {
	return &VisitHandler{visitUC: visitUC}
}

type VisitStartRequest struct {
	QRToken string `json:"qrToken"`
	Method  string `json:"method" enums:"MANUAL"`
	GroupID string `json:"groupId"`
}

// @name VisitStartRequest

func mapVisitToDTO(v *domain.Visit) VisitSummaryResponse {
	res := VisitSummaryResponse{
		ID:          string(v.ID),
		GroupID:     string(v.GroupID),
		CornerID:    string(v.CornerID),
		TrackID:     string(v.TrackID),
		Status:      string(v.Status),
		InputMethod: string(v.InputMethod),
		StartedAt:   v.StartedAt,
	}
	if endedAt, ok := v.EndedAt.Value(); ok {
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
// @Failure      409 {object} ErrorResponse "TRACK_BUSY, DUPLICATE_VISIT 등"
// @Router       /tracks/{trackId}/visits/start [post]
func (h *VisitHandler) StartVisit(c echo.Context) error {
	authHeader := c.Request().Header.Get("Authorization")
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
		return err
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
// @Failure      409 {object} ErrorResponse "TRACK_NOT_BUSY 등"
// @Router       /tracks/{trackId}/visits/current/end [post]
func (h *VisitHandler) EndCurrentVisit(c echo.Context) error {
	authHeader := c.Request().Header.Get("Authorization")
	token := strings.TrimPrefix(authHeader, "Bearer ")

	visit, err := h.visitUC.CompleteVisit(c.Request().Context(), token)
	if err != nil {
		return err
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
// @Failure      404 "진행 중인 방문 없음"
// @Router       /tracks/{trackId}/visits/current [get]
func (h *VisitHandler) GetCurrentVisit(c echo.Context) error {
	authHeader := c.Request().Header.Get("Authorization")
	token := strings.TrimPrefix(authHeader, "Bearer ")

	visit, err := h.visitUC.GetCurrentVisit(c.Request().Context(), token)
	if err != nil {
		return err
	}
	if visit == nil {
		return echo.ErrNotFound
	}

	return c.JSON(http.StatusOK, mapVisitToDTO(visit))
}
