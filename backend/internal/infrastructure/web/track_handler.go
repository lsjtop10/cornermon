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

type TrackSummaryResponse struct {
	ID                string `json:"id" format:"uuid"`
	CornerID          string `json:"cornerId" format:"uuid"`
	TrackNo           int    `json:"trackNo"`
	Status            string `json:"status" enums:"ACTIVE,DELETED"`
	OperationalStatus string `json:"operationalStatus" enums:"IDLE,BUSY"`
} // @name TrackSummaryResponse

type TrackResponse struct {
	TrackSummaryResponse
	CurrentVisit *VisitSummaryResponse `json:"currentVisit,omitempty"`
} // @name TrackResponse

// TrackPinResponse is deliberately limited to endpoints that issue or export a
// PIN. Ordinary track reads must never expose a credential.
type TrackPinResponse struct {
	Track TrackResponse `json:"track"`
	PIN   string        `json:"pin" example:"482910"`
} // @name TrackPinResponse
type ExportTracksResponse struct {
	Tracks []TrackPinResponse `json:"tracks"`
} // @name ExportTracksResponse

func NewTrackHandler(svc *usecase.TrackService) *TrackHandler {
	return &TrackHandler{svc: svc}
}

func mapDomainTrackToDTO(track *domain.Track) TrackResponse {
	if track == nil {
		return TrackResponse{}
	}
	return TrackResponse{
		TrackSummaryResponse: TrackSummaryResponse{
			ID:                string(track.ID()),
			CornerID:          string(track.CornerID()),
			TrackNo:           track.TrackNo(),
			Status:            string(track.Status()),
			OperationalStatus: string(track.OperationalStatus()),
		},
	}
}

// @Summary      트랙 목록 조회
// @Description  전체 트랙 목록을 조회한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Produce      json
// @Param        campId path string true "캠프 ID"
// @Success      200 {array} TrackResponse
// @Router       /camps/{campId}/tracks [get]
func (h *TrackHandler) ListTracks(c echo.Context) error {
	campID := domain.CampID(c.Param("campId"))
	if campID == "" {
		return c.JSON(http.StatusBadRequest, ErrorResponse{Code: "BAD_REQUEST", Message: "campId is required"})
	}
	tracks, err := h.svc.ListTracksByCamp(c.Request().Context(), campID)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, ErrorResponse{Code: "INTERNAL_ERROR", Message: err.Error()})
	}
	res := make([]TrackResponse, len(tracks))
	for i, tr := range tracks {
		res[i] = mapDomainTrackToDTO(tr)
	}
	return c.JSON(http.StatusOK, res)
}

type CreateTracksRequest struct {
	CampID   string `json:"campId"`
	CornerID string `json:"cornerId"`
	Count    int    `json:"count"`
} // @name CreateTracksRequest

// @Summary      트랙 일괄 생성
// @Description  특정 코너에 여러 트랙을 추가 생성한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Accept       json
// @Produce      json
// @Param        request body CreateTracksRequest true "생성 정보"
// @Success      201 {array} TrackPinResponse
// @Router       /tracks [post]
func (h *TrackHandler) CreateTracks(c echo.Context) error {
	var req CreateTracksRequest
	if err := c.Bind(&req); err != nil {
		return c.JSON(http.StatusBadRequest, ErrorResponse{Code: "BAD_REQUEST", Message: "Invalid request body"})
	}
	var res []TrackPinResponse
	for i := 0; i < req.Count; i++ {
		track, pin, err := h.svc.CreateTrack(c.Request().Context(), domain.CampID(req.CampID), domain.CornerID(req.CornerID))
		if err != nil {
			return c.JSON(http.StatusInternalServerError, ErrorResponse{Code: "INTERNAL_ERROR", Message: err.Error()})
		}
		res = append(res, TrackPinResponse{Track: mapDomainTrackToDTO(track), PIN: pin})
	}
	return c.JSON(http.StatusCreated, res)
}

// @Summary      코너별 트랙 목록 조회
// @Description  특정 코너에 속한 트랙 목록을 조회한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Produce      json
// @Param        cornerId path string true "코너 ID"
// @Success      200 {array} TrackResponse
// @Router       /corners/{cornerId}/tracks [get]
func (h *TrackHandler) ListTracksByCorner(c echo.Context) error {
	return c.JSON(http.StatusOK, []TrackResponse{})
}

// @Summary      트랙 상세 조회
// @Description  트랙 상세 정보(PIN 등)를 조회한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Produce      json
// @Param        id path string true "트랙 ID"
// @Success      200 {object} TrackResponse
// @Router       /tracks/{id} [get]
func (h *TrackHandler) GetTrack(c echo.Context) error {
	return c.JSON(http.StatusOK, TrackResponse{})
}

type BulkDeleteTracksRequest struct {
	TrackIDs []string `json:"trackIds"`
} // @name BulkDeleteTracksRequest

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

type ReplaceTrackRequest struct {
	NewCornerID string `json:"newCornerId"`
} // @name ReplaceTrackRequest

// @Summary      트랙 교체 (비상용)
// @Description  기존 트랙을 삭제하고 지정한 대상 코너에 새 트랙을 생성하며 기존 진행자 세션의 마이그레이션 대상을 설정한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Accept       json
// @Produce      json
// @Param        id path string true "트랙 ID"
// @Param        request body ReplaceTrackRequest true "대상 코너"
// @Success      200 {object} TrackPinResponse
// @Failure      400 {object} ErrorResponse
// @Failure      404 {object} ErrorResponse
// @Failure      409 {object} ErrorResponse
// @Router       /tracks/{id}/replace [put]
func (h *TrackHandler) ReplaceTrack(c echo.Context) error {
	var req ReplaceTrackRequest
	if err := c.Bind(&req); err != nil || req.NewCornerID == "" {
		return echo.NewHTTPError(http.StatusBadRequest, "newCornerId is required")
	}

	track, pin, err := h.svc.ReplaceTrack(
		c.Request().Context(),
		domain.TrackID(c.Param("id")),
		domain.CornerID(req.NewCornerID),
	)
	if err != nil {
		return err
	}
	return c.JSON(http.StatusOK, TrackPinResponse{Track: mapDomainTrackToDTO(track), PIN: pin})
}

// @Summary      PIN 재발급
// @Description  특정 트랙의 PIN 번호를 새로 생성한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Produce      json
// @Param        id path string true "트랙 ID"
// @Success      200 {object} TrackPinResponse
// @Router       /tracks/{id}/regenerate-pin [post]
func (h *TrackHandler) RegeneratePin(c echo.Context) error {
	id := domain.TrackID(c.Param("id"))
	track, plainPIN, err := h.svc.RegeneratePIN(c.Request().Context(), id)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, ErrorResponse{Code: "INTERNAL_ERROR", Message: err.Error()})
	}
	return c.JSON(http.StatusOK, TrackPinResponse{Track: mapDomainTrackToDTO(track), PIN: plainPIN})
}

// @Summary      트랙 인증 정보 전체 내보내기
// @Description  인쇄를 위해 지정 캠프의 ACTIVE 트랙 PIN을 JSON으로 내려준다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Produce      json
// @Param        campId query string true "캠프 ID"
// @Success      200 {object} ExportTracksResponse
// @Router       /tracks/export [get]
func (h *TrackHandler) ExportTracks(c echo.Context) error {
	campID := domain.CampID(c.QueryParam("campId"))
	if campID == "" {
		return echo.NewHTTPError(http.StatusBadRequest, "campId is required")
	}
	tracks, pins, err := h.svc.ExportTrackPINs(c.Request().Context(), campID)
	if err != nil {
		return err
	}
	res := make([]TrackPinResponse, len(tracks))
	for i, track := range tracks {
		res[i] = TrackPinResponse{Track: mapDomainTrackToDTO(track), PIN: pins[i]}
	}
	c.Response().Header().Set("Cache-Control", "no-store")
	return c.JSON(http.StatusOK, ExportTracksResponse{Tracks: res})
}

// @Summary      단일 트랙 인증 정보 내보내기
// @Description  특정 트랙의 PIN을 JSON으로 내려준다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Produce      json
// @Param        id path string true "트랙 ID"
// @Success      200 {object} TrackPinResponse
// @Router       /tracks/{id}/export [get]
func (h *TrackHandler) ExportTrackSingle(c echo.Context) error {
	track, pin, err := h.svc.ExportTrackPIN(c.Request().Context(), domain.TrackID(c.Param("id")))
	if err != nil {
		return err
	}
	c.Response().Header().Set("Cache-Control", "no-store")
	return c.JSON(http.StatusOK, TrackPinResponse{Track: mapDomainTrackToDTO(track), PIN: pin})
}
