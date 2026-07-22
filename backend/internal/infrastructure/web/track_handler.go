package web

import (
	"errors"
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

// TrackPINExportResponse contains exactly the printable fields for one track.
// It is intentionally separate from TrackPinResponse so regular track DTOs do
// not become the contract for administrator exports.
type TrackPINExportResponse struct {
	CornerName string `json:"cornerName"`
	TrackNo    int    `json:"trackNo"`
	PIN        string `json:"pin" example:"482910"`
} // @name TrackPINExportResponse

type ExportTracksResponse struct {
	Tracks []TrackPINExportResponse `json:"tracks"`
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
		return echo.NewHTTPError(http.StatusBadRequest, ErrorResponse{Code: CodeBadRequest, Message: "campId is required"})
	}
	tracks, err := h.svc.ListTracksByCamp(c.Request().Context(), campID)
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, ErrorResponse{Code: CodeInternalError, Message: err.Error()}).SetInternal(err)
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
// @Failure      404 {object} ErrorResponse "CORNER_NOT_FOUND: 대상 코너가 없음"
// @Failure      409 {object} ErrorResponse "CAMP_NOT_AVAILABLE: 종료된 캠프에는 트랙을 생성할 수 없음"
// @Router       /tracks [post]
func (h *TrackHandler) CreateTracks(c echo.Context) error {
	var req CreateTracksRequest
	if err := c.Bind(&req); err != nil {
		return echo.NewHTTPError(http.StatusBadRequest, ErrorResponse{Code: CodeBadRequest, Message: "Invalid request body"}).SetInternal(err)
	}
	var res []TrackPinResponse
	for i := 0; i < req.Count; i++ {
		track, pin, err := h.svc.CreateTrack(c.Request().Context(), domain.CampID(req.CampID), domain.CornerID(req.CornerID))
		if err != nil {
			return trackHTTPError(err)
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
// @Failure      404 {object} ErrorResponse "TRACK_NOT_FOUND: 대상 트랙이 없거나 이미 삭제됨"
// @Failure      409 {object} ErrorResponse "TRACK_DELETE_BLOCKED: 진행 중인 방문이 있어 삭제할 수 없음"
// @Router       /tracks/bulk-delete [delete]
func (h *TrackHandler) BulkDeleteTracks(c echo.Context) error {
	var req BulkDeleteTracksRequest
	if err := c.Bind(&req); err != nil {
		return echo.NewHTTPError(http.StatusBadRequest, ErrorResponse{Code: CodeBadRequest, Message: "Invalid request body"}).SetInternal(err)
	}
	for _, id := range req.TrackIDs {
		_, err := h.svc.DeleteTrack(c.Request().Context(), domain.TrackID(id))
		if err != nil {
			return trackHTTPError(err)
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
		return trackHTTPError(err)
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
// @Failure      404 {object} ErrorResponse "TRACK_NOT_FOUND: 대상 트랙이 없거나 활성 상태가 아님"
// @Router       /tracks/{id}/regenerate-pin [post]
func (h *TrackHandler) RegeneratePin(c echo.Context) error {
	id := domain.TrackID(c.Param("id"))
	track, plainPIN, err := h.svc.RegeneratePIN(c.Request().Context(), id)
	if err != nil {
		return trackHTTPError(err)
	}
	return c.JSON(http.StatusOK, TrackPinResponse{Track: mapDomainTrackToDTO(track), PIN: plainPIN})
}

// @Summary      트랙 인증 정보 전체 내보내기
// @Description  인쇄 또는 스프레드시트 내보내기를 위해 지정 캠프 ACTIVE 트랙의 코너 이름, 트랙 번호, PIN을 JSON으로 내려준다.
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
	exports, err := h.svc.ExportTrackPINs(c.Request().Context(), campID)
	if err != nil {
		return trackHTTPError(err)
	}
	res := make([]TrackPINExportResponse, len(exports))
	for i, export := range exports {
		res[i] = TrackPINExportResponse{
			CornerName: export.CornerName,
			TrackNo:    export.TrackNo,
			PIN:        export.PIN,
		}
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
		return trackHTTPError(err)
	}
	c.Response().Header().Set("Cache-Control", "no-store")
	return c.JSON(http.StatusOK, TrackPinResponse{Track: mapDomainTrackToDTO(track), PIN: pin})
}

func trackHTTPError(err error) error {
	switch {
	case errors.Is(err, domain.ErrCornerNotFound), errors.Is(err, domain.ErrCornerNotInItinerary):
		return echo.NewHTTPError(http.StatusNotFound, ErrorResponse{Code: CodeCornerNotFound, Message: "corner not found"}).SetInternal(err)
	case errors.Is(err, domain.ErrTrackNotActive), errors.Is(err, domain.ErrTrackNotFound):
		return echo.NewHTTPError(http.StatusNotFound, ErrorResponse{Code: CodeTrackNotFound, Message: "track not found"}).SetInternal(err)
	case errors.Is(err, domain.ErrTrackDeleteBlocked), errors.Is(err, domain.ErrTrackBusy), errors.Is(err, domain.ErrTrackCampMismatch):
		return echo.NewHTTPError(http.StatusConflict, ErrorResponse{Code: CodeTrackConflict, Message: "track cannot be changed in its current state"}).SetInternal(err)
	case errors.Is(err, domain.ErrCampInvalidTransition):
		return echo.NewHTTPError(http.StatusConflict, ErrorResponse{Code: CodeCampNotAvailable, Message: "camp is not available for track management"}).SetInternal(err)
	default:
		return err
	}
}
