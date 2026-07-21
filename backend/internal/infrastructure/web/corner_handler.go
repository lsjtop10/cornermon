package web

import (
	"errors"
	"net/http"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/usecase"

	"github.com/labstack/echo/v4"
)

type CornerHandler struct {
	svc   *usecase.CornerService
	views usecase.CornerViewQuerier
}

// 추후에 Usecase에 정의된 View로 대체 고려
type CornerMetricResponse struct {
	AvgDurationSeconds int `json:"avgDurationSeconds" example:"640" description:"완료된 방문의 평균 소요 시간(초)"`
	SampleCount        int `json:"sampleCount" example:"15" description:"평균 계산에 사용된 완료 방문 수"`
} // @name CornerMetricResponse

type CornerResponse struct {
	ID            string                 `json:"id" format:"uuid"`
	CampID        string                 `json:"campId" format:"uuid"`
	Name          string                 `json:"name" example:"코너 1"`
	TargetMinutes int                    `json:"targetMinutes" example:"10"`
	Status        string                 `json:"status" enums:"INACTIVE,IDLE,BUSY"`
	IsBottleneck  bool                   `json:"isBottleneck"`
	ActiveTracks  []TrackSummaryResponse `json:"activeTracks"`

	Metric CornerMetricResponse `json:"cornerMetric" description:"조회 전용 코너 지표"`
} // @name CornerResponse

func NewCornerHandler(svc *usecase.CornerService, views usecase.CornerViewQuerier) *CornerHandler {
	return &CornerHandler{svc: svc, views: views}
}

func mapCornerViewToDTO(view usecase.CornerView) CornerResponse {
	activeTracks := make([]TrackSummaryResponse, len(view.ActiveTracks))
	for i, track := range view.ActiveTracks {
		activeTracks[i] = TrackSummaryResponse{
			ID:                string(track.ID),
			CornerID:          string(track.CornerID),
			TrackNo:           track.TrackNo,
			Status:            string(track.Status),
			OperationalStatus: string(track.OperationalStatus),
		}
	}
	return CornerResponse{
		ID: string(view.ID), Name: view.Name, TargetMinutes: view.TargetMinutes,
		ActiveTracks: activeTracks,
		Metric:       CornerMetricResponse{AvgDurationSeconds: view.AvgDurationSeconds, SampleCount: view.SampleCount},
	}
}

func mapDomainCornerToDTO(corner *domain.Corner) CornerResponse {
	if corner == nil {
		return CornerResponse{}
	}
	return CornerResponse{
		ID:            string(corner.ID()),
		CampID:        string(corner.CampID()),
		Name:          corner.Name(),
		TargetMinutes: corner.TargetMinutes(),
		Status:        string(corner.OperationalStatus(nil)),
	}
}

// @Summary      코너 목록 조회
// @Description  특정 캠프의 모든 코너 핵심 정보와 완료 방문 지표를 조회한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Produce      json
// @Param        campId path string true "캠프 ID"
// @Success      200 {array} CornerResponse
// @Failure      400 {object} ErrorResponse
// @Failure      401 {object} ErrorResponse
// @Router       /camps/{campId}/corners [get]
func (h *CornerHandler) ListCorners(c echo.Context) error {
	campID := domain.CampID(c.Param("campId"))
	if campID == "" {
		return echo.NewHTTPError(http.StatusBadRequest, ErrorResponse{Code: CodeBadRequest, Message: "campId is required"})
	}
	views, err := h.views.ListCornerViewsByCamp(c.Request().Context(), campID)
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, ErrorResponse{Code: CodeInternalError, Message: err.Error()}).SetInternal(err)
	}
	res := make([]CornerResponse, len(views))
	for i, view := range views {
		res[i] = mapCornerViewToDTO(view)
	}
	return c.JSON(http.StatusOK, res)
}

type CreateCornerRequest struct {
	CampID        string `json:"campId"`
	Name          string `json:"name"`
	TargetMinutes int    `json:"targetMinutes"`
} // @name CreateCornerRequest

// @Summary      새 코너 추가
// @Description  캠프에 새로운 코너를 생성한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Accept       json
// @Produce      json
// @Param        request body CreateCornerRequest true "코너 생성 정보"
// @Success      201 {object} CornerResponse
// @Failure      400 {object} ErrorResponse
// @Failure      401 {object} ErrorResponse
// @Failure      409 {object} ErrorResponse "CAMP_STATE_CONFLICT: 현재 캠프 상태에서는 코너를 생성할 수 없음"
// @Router       /corners [post]
func (h *CornerHandler) CreateCorner(c echo.Context) error {
	var req CreateCornerRequest
	if err := c.Bind(&req); err != nil {
		return echo.NewHTTPError(http.StatusBadRequest, ErrorResponse{Code: CodeBadRequest, Message: "Invalid request body"}).SetInternal(err)
	}
	corner, err := h.svc.AddLearningCorner(c.Request().Context(), domain.CampID(req.CampID), req.Name)
	if err != nil {
		return cornerHTTPError(err)
	}
	return c.JSON(http.StatusCreated, mapDomainCornerToDTO(corner))
}

// @Summary      코너 상세 조회
// @Description  특정 코너의 핵심 정보와 완료 방문 지표를 조회한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Produce      json
// @Param        id path string true "코너 ID"
// @Success      200 {object} CornerResponse
// @Failure      404 {object} ErrorResponse "CORNER_NOT_FOUND: 대상 코너가 없음"
// @Router       /corners/{id} [get]
func (h *CornerHandler) GetCorner(c echo.Context) error {
	id := domain.CornerID(c.Param("id"))
	view, err := h.views.GetCornerView(c.Request().Context(), id)
	if err != nil {
		return cornerHTTPError(err)
	}
	if view == nil {
		return cornerHTTPError(domain.ErrCornerNotFound)
	}
	return c.JSON(http.StatusOK, mapCornerViewToDTO(*view))
}

// @Summary      진행자 코너 조회
// @Description  인증된 진행자(TrackAuth)의 트랙이 속한 코너의 핵심 정보를 조회한다. 세션의 트랙과 path trackId가 일치해야 한다. 다른 트랙의 활성 목록·병목 지표 등 관리자 전용 정보는 포함하지 않는다.
// @Tags         C. Visit (Scan Flow)
// @Security     TrackAuth
// @Produce      json
// @Param        trackId path string true "트랙 ID"
// @Success      200 {object} CornerResponse
// @Failure      401 {object} ErrorResponse
// @Failure      403 {object} ErrorResponse "세션 트랙과 요청 트랙 불일치"
// @Failure      404 {object} ErrorResponse "트랙 또는 코너 없음"
// @Router       /tracks/{trackId}/corner [get]
func (h *CornerHandler) GetCornerByTrack(c echo.Context) error {
	session, ok := c.Get("facilitatorSession").(*domain.FacilitatorSession)
	if !ok {
		return echo.NewHTTPError(http.StatusUnauthorized, ErrorResponse{Code: CodeUnauthorized, Message: "unauthorized"})
	}

	trackID := domain.TrackID(c.Param("trackId"))
	if session.TrackID() != trackID {
		return echo.NewHTTPError(http.StatusForbidden, ErrorResponse{Code: CodeForbidden, Message: domain.ErrTrackScopeForbidden.Error()}).SetInternal(domain.ErrTrackScopeForbidden)
	}

	corner, err := h.svc.GetCornerByTrack(c.Request().Context(), trackID)
	if err != nil {
		if errors.Is(err, domain.ErrTrackNotFound) || errors.Is(err, domain.ErrCornerNotFound) {
			return echo.NewHTTPError(http.StatusNotFound, ErrorResponse{Code: CodeNotFound, Message: err.Error()}).SetInternal(err)
		}
		return echo.NewHTTPError(http.StatusInternalServerError, ErrorResponse{Code: CodeInternalError, Message: err.Error()}).SetInternal(err)
	}
	return c.JSON(http.StatusOK, mapDomainCornerToDTO(corner))
}

// @Summary      코너 삭제
// @Description  코너를 soft-delete한다. 삭제된 코너는 일반 조회에서 제외되며 API 계약은 유지된다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Produce      json
// @Param        id path string true "코너 ID"
// @Success      204 "성공적으로 삭제됨"
// @Failure      400 {object} ErrorResponse
// @Failure      409 {object} ErrorResponse "CAMP_STATE_CONFLICT: 현재 캠프 상태에서는 코너를 삭제할 수 없음"
// @Router       /corners/{id} [delete]
func (h *CornerHandler) DeleteCorner(c echo.Context) error {
	id := domain.CornerID(c.Param("id"))
	err := h.svc.RemoveCornerFromCamp(c.Request().Context(), id)
	if err != nil {
		return cornerHTTPError(err)
	}
	return c.NoContent(http.StatusNoContent)
}

type BulkUpdateCornersRequest struct {
	Corners []struct {
		ID            string `json:"id"`
		Name          string `json:"name"`
		TargetMinutes int    `json:"targetMinutes"`
	} `json:"corners"`
} // @name BulkUpdateCornersRequest

// @Summary      코너 대량 수정
// @Description  여러 코너의 이름이나 목표 시간을 일괄 수정한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Accept       json
// @Produce      json
// @Param        request body BulkUpdateCornersRequest true "수정할 코너 목록"
// @Success      200 {array} CornerResponse
// @Failure      400 {object} ErrorResponse
// @Failure      404 {object} ErrorResponse "CORNER_NOT_FOUND: 수정할 코너가 없음"
// @Failure      409 {object} ErrorResponse "CAMP_STATE_CONFLICT: 현재 캠프 상태에서는 코너를 수정할 수 없음"
// @Router       /corners/bulk-update [put]
func (h *CornerHandler) BulkUpdateCorners(c echo.Context) error {
	var req BulkUpdateCornersRequest
	if err := c.Bind(&req); err != nil {
		return echo.NewHTTPError(http.StatusBadRequest, ErrorResponse{Code: CodeBadRequest, Message: "Invalid request body"}).SetInternal(err)
	}
	res := make([]CornerResponse, len(req.Corners))
	for i, cr := range req.Corners {
		updated, err := h.svc.ModifyCornerSpecification(c.Request().Context(), domain.CornerID(cr.ID), cr.Name)
		if err != nil {
			return cornerHTTPError(err)
		}
		res[i] = mapDomainCornerToDTO(updated)
	}
	return c.JSON(http.StatusOK, res)
}

func cornerHTTPError(err error) error {
	switch {
	case errors.Is(err, domain.ErrCornerNotFound), errors.Is(err, domain.ErrCornerNotInItinerary):
		return echo.NewHTTPError(http.StatusNotFound, ErrorResponse{Code: CodeCornerNotFound, Message: "corner not found"}).SetInternal(err)
	case errors.Is(err, domain.ErrCampInvalidTransition), errors.Is(err, domain.ErrCampSettingsLocked):
		return echo.NewHTTPError(http.StatusConflict, ErrorResponse{Code: CodeCampStateConflict, Message: "camp cannot modify corners in its current state"}).SetInternal(err)
	default:
		return err
	}
}
