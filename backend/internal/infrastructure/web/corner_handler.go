package web

import (
	"net/http"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/usecase"

	"github.com/labstack/echo/v4"
)

type CornerHandler struct {
	svc   *usecase.CornerService
	views usecase.CornerViewQuerier
}

type CornerMetricResponse struct {
	AvgDurationSeconds int `json:"avgDurationSeconds" example:"640" description:"완료된 방문의 평균 소요 시간(초)"`
	SampleCount        int `json:"sampleCount" example:"15" description:"평균 계산에 사용된 완료 방문 수"`
} // @name CornerMetricResponse

type CornerResponse struct {
	ID            string                 `json:"id" format:"uuid"`
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
		ID:            string(corner.ID),
		Name:          corner.Name,
		TargetMinutes: corner.TargetMinutes,
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
		return c.JSON(http.StatusBadRequest, ErrorResponse{Code: "BAD_REQUEST", Message: "campId is required"})
	}
	views, err := h.views.ListCornerViewsByCamp(c.Request().Context(), campID)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, ErrorResponse{Code: "INTERNAL_ERROR", Message: err.Error()})
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
// @Router       /corners [post]
func (h *CornerHandler) CreateCorner(c echo.Context) error {
	var req CreateCornerRequest
	if err := c.Bind(&req); err != nil {
		return c.JSON(http.StatusBadRequest, ErrorResponse{Code: "BAD_REQUEST", Message: "Invalid request body"})
	}
	corner, err := h.svc.AddLearningCorner(c.Request().Context(), domain.CampID(req.CampID), req.Name)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, ErrorResponse{Code: "INTERNAL_ERROR", Message: err.Error()})
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
// @Failure      404 {object} ErrorResponse
// @Router       /corners/{id} [get]
func (h *CornerHandler) GetCorner(c echo.Context) error {
	id := domain.CornerID(c.Param("id"))
	view, err := h.views.GetCornerView(c.Request().Context(), id)
	if err != nil {
		return err
	}
	if view == nil {
		return domain.ErrCornerNotFound
	}
	return c.JSON(http.StatusOK, mapCornerViewToDTO(*view))
}

// @Summary      코너 삭제
// @Description  코너를 삭제한다. 단, 방문 기록이 있으면 삭제할 수 없다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Produce      json
// @Param        id path string true "코너 ID"
// @Success      204 "성공적으로 삭제됨"
// @Failure      400 {object} ErrorResponse
// @Failure      409 {object} ErrorResponse "활성화된 캠프이거나 종속 데이터가 존재함"
// @Router       /corners/{id} [delete]
func (h *CornerHandler) DeleteCorner(c echo.Context) error {
	id := domain.CornerID(c.Param("id"))
	err := h.svc.RemoveCornerFromCamp(c.Request().Context(), id)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, ErrorResponse{Code: "INTERNAL_ERROR", Message: err.Error()})
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
// @Failure      409 {object} ErrorResponse
// @Router       /corners/bulk-update [put]
func (h *CornerHandler) BulkUpdateCorners(c echo.Context) error {
	var req BulkUpdateCornersRequest
	if err := c.Bind(&req); err != nil {
		return c.JSON(http.StatusBadRequest, ErrorResponse{Code: "BAD_REQUEST", Message: "Invalid request body"})
	}
	res := make([]CornerResponse, len(req.Corners))
	for i, cr := range req.Corners {
		updated, err := h.svc.ModifyCornerSpecification(c.Request().Context(), domain.CornerID(cr.ID), cr.Name)
		if err != nil {
			return c.JSON(http.StatusInternalServerError, ErrorResponse{Code: "INTERNAL_ERROR", Message: err.Error()})
		}
		res[i] = mapDomainCornerToDTO(updated)
	}
	return c.JSON(http.StatusOK, res)
}
