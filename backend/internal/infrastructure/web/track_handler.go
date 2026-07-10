package web

import (
	"net/http"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/usecase"

	"github.com/labstack/echo/v4"
)

type TrackHandler struct {
	svc *usecase.TrackService
}

func NewTrackHandler(svc *usecase.TrackService) *TrackHandler {
	return &TrackHandler{svc: svc}
}

func mapDomainTrackToDTO(track *domain.Track) Track {
	if track == nil {
		return Track{}
	}
	return Track{
		TrackSummary: TrackSummary{
			ID:                string(track.ID),
			CornerID:          string(track.CornerID),
			TrackNo:           track.TrackNo,
			Status:            string(track.Status),
			OperationalStatus: string(track.OperationalStatus()),
		},
	}
}

// @Summary      트랙 목록 조회
// @Description  전체 트랙 목록을 조회한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Produce      json
// @Param        campId query string false "캠프 ID 필터"
// @Success      200 {array} Track
// @Router       /tracks [get]
func (h *TrackHandler) ListTracks(c echo.Context) error {
	campID := domain.CampID(c.QueryParam("campId"))
	if campID == "" {
		return c.JSON(http.StatusBadRequest, ErrorResponse{Code: "BAD_REQUEST", Message: "campId is required"})
	}
	tracks, err := h.svc.ListTracksByCamp(c.Request().Context(), campID)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, ErrorResponse{Code: "INTERNAL_ERROR", Message: err.Error()})
	}
	res := make([]Track, len(tracks))
	for i, tr := range tracks {
		res[i] = mapDomainTrackToDTO(tr)
	}
	return c.JSON(http.StatusOK, res)
}

type CreateTracksRequest struct {
	CampID   string `json:"campId"`
	CornerID string `json:"cornerId"`
	Count    int    `json:"count"`
}

// @Summary      트랙 일괄 생성
// @Description  특정 코너에 여러 트랙을 추가 생성한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Accept       json
// @Produce      json
// @Param        request body CreateTracksRequest true "생성 정보"
// @Success      201 {array} Track
// @Router       /tracks [post]
func (h *TrackHandler) CreateTracks(c echo.Context) error {
	var req CreateTracksRequest
	if err := c.Bind(&req); err != nil {
		return c.JSON(http.StatusBadRequest, ErrorResponse{Code: "BAD_REQUEST", Message: "Invalid request body"})
	}
	var res []Track
	for i := 0; i < req.Count; i++ {
		track, pin, err := h.svc.CreateTrack(c.Request().Context(), domain.CampID(req.CampID), domain.CornerID(req.CornerID))
		if err != nil {
			return c.JSON(http.StatusInternalServerError, ErrorResponse{Code: "INTERNAL_ERROR", Message: err.Error()})
		}
		dtoTrack := mapDomainTrackToDTO(track)
		dtoTrack.PIN = pin
		res = append(res, dtoTrack)
	}
	return c.JSON(http.StatusCreated, res)
}

// @Summary      코너별 트랙 목록 조회
// @Description  특정 코너에 속한 트랙 목록을 조회한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Produce      json
// @Param        cornerId path string true "코너 ID"
// @Success      200 {array} Track
// @Router       /corners/{cornerId}/tracks [get]
func (h *TrackHandler) ListTracksByCorner(c echo.Context) error {
	return c.JSON(http.StatusOK, []Track{})
}

// @Summary      트랙 상세 조회
// @Description  트랙 상세 정보(PIN 등)를 조회한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Produce      json
// @Param        id path string true "트랙 ID"
// @Success      200 {object} Track
// @Router       /tracks/{id} [get]
func (h *TrackHandler) GetTrack(c echo.Context) error {
	return c.JSON(http.StatusOK, Track{})
}

type BulkDeleteTracksRequest struct {
	TrackIDs []string `json:"trackIds"`
}

// @Summary      트랙 일괄 삭제
// @Description  선택한 트랙들을 일괄 삭제한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Accept       json
// @Produce      json
// @Param        request body BulkDeleteTracksRequest true "삭제할 트랙 ID 목록"
// @Success      204 "성공적으로 삭제됨"
// @Router       /tracks/bulk-delete [delete]
func (h *TrackHandler) BulkDeleteTracks(c echo.Context) error {
	var req BulkDeleteTracksRequest
	if err := c.Bind(&req); err != nil {
		return c.JSON(http.StatusBadRequest, ErrorResponse{Code: "BAD_REQUEST", Message: "Invalid request body"})
	}
	for _, id := range req.TrackIDs {
		_, err := h.svc.DeleteTrack(c.Request().Context(), domain.TrackID(id))
		if err != nil {
			return c.JSON(http.StatusInternalServerError, ErrorResponse{Code: "INTERNAL_ERROR", Message: err.Error()})
		}
	}
	return c.NoContent(http.StatusNoContent)
}

// @Summary      트랙 교체 (비상용)
// @Description  기기 고장 등으로 트랙 세션을 초기화하거나 새 기기로 교체할 수 있도록 처리한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Produce      json
// @Param        id path string true "트랙 ID"
// @Success      200 {object} Track
// @Router       /tracks/{id}/replace [put]
func (h *TrackHandler) ReplaceTrack(c echo.Context) error {
	return c.JSON(http.StatusOK, Track{})
}

// @Summary      PIN 재발급
// @Description  특정 트랙의 PIN 번호를 새로 생성한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Produce      json
// @Param        id path string true "트랙 ID"
// @Success      200 {object} Track
// @Router       /tracks/{id}/regenerate-pin [post]
func (h *TrackHandler) RegeneratePin(c echo.Context) error {
	id := domain.TrackID(c.Param("id"))
	plainPIN, err := h.svc.RegeneratePIN(c.Request().Context(), id)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, ErrorResponse{Code: "INTERNAL_ERROR", Message: err.Error()})
	}
	return c.JSON(http.StatusOK, map[string]string{"pin": plainPIN})
}

// @Summary      트랙 인증 정보 전체 내보내기
// @Description  인쇄를 위해 전체 트랙의 PIN 번호 등을 CSV로 다운로드한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Produce      text/csv
// @Success      200 "CSV 데이터"
// @Router       /tracks/export [get]
func (h *TrackHandler) ExportTracks(c echo.Context) error {
	return c.String(http.StatusOK, "csv_data")
}

// @Summary      단일 트랙 인증 정보 내보내기
// @Description  특정 트랙의 PIN 번호를 PDF 형태로 다운로드한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Produce      application/pdf
// @Param        id path string true "트랙 ID"
// @Success      200 "PDF 데이터"
// @Router       /tracks/{id}/export [get]
func (h *TrackHandler) ExportTrackSingle(c echo.Context) error {
	return c.String(http.StatusOK, "pdf_data")
}
