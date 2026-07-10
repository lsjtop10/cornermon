package handler

import (
	"context"
	"net/http"

	"cornermon/backend/internal/domain"
	"github.com/labstack/echo/v4"
)

type CampUsecase interface {
	OpenNewCamp(ctx context.Context, name string) (*domain.Camp, error)
	ListCamps(ctx context.Context) ([]*domain.Camp, error)
	GetCamp(ctx context.Context, id domain.CampID) (*domain.Camp, error)
}

type CornerUsecase interface {
	AddLearningCorner(ctx context.Context, campID domain.CampID, name string) (*domain.Corner, error)
	ListCorners(ctx context.Context, campID domain.CampID) ([]*domain.Corner, error)
	ModifyCornerSpecification(ctx context.Context, id domain.CornerID, name string) (*domain.Corner, error)
	RemoveCornerFromCamp(ctx context.Context, id domain.CornerID) error
}

type TrackUsecase interface {
	ListTracksByCamp(ctx context.Context, campID domain.CampID) ([]*domain.Track, error)
}

type BadgeUsecase interface {
	IssueInitialBadges(ctx context.Context, count int) ([]*domain.Badge, error)
	ListBadges(ctx context.Context) ([]*domain.Badge, error)
	ExportBadges(ctx context.Context) ([]byte, error)
}

type GroupUsecase interface {
	ListGroups(ctx context.Context, campID domain.CampID) ([]*domain.Group, error)
	RetrieveGroupRotationSchedule(ctx context.Context, groupID domain.GroupID) (*domain.Group, error)
}

type MissingHandlers struct {
	campUC   CampUsecase
	cornerUC CornerUsecase
	trackUC  TrackUsecase
	badgeUC  BadgeUsecase
	groupUC  GroupUsecase
}

func NewMissingHandlers(campUC CampUsecase, cornerUC CornerUsecase, trackUC TrackUsecase, badgeUC BadgeUsecase, groupUC GroupUsecase) *MissingHandlers {
	return &MissingHandlers{campUC, cornerUC, trackUC, badgeUC, groupUC}
}

// @Summary      캠프 생성
// @Description  새로운 캠프를 생성한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Accept       json
// @Produce      json
// @Success      201 {object} domain.Camp
// @Router       /api/v1/camps [post]
func (h *MissingHandlers) CreateCamp(c echo.Context) error {
	var req struct{ Name string `json:"name"` }
	if err := c.Bind(&req); err != nil { return err }
	camp, err := h.campUC.OpenNewCamp(c.Request().Context(), req.Name)
	if err != nil { return err }
	return c.JSON(http.StatusCreated, camp)
}

// @Summary      캠프 목록 조회
// @Description  전체 캠프 목록을 조회한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Produce      json
// @Success      200 {object} map[string]interface{}
// @Router       /api/v1/camps [get]
func (h *MissingHandlers) ListCamps(c echo.Context) error {
	camps, err := h.campUC.ListCamps(c.Request().Context())
	if err != nil { return err }
	return c.JSON(http.StatusOK, map[string]interface{}{"camps": camps})
}

// @Summary      캠프 단건 조회
// @Description  특정 캠프 정보를 조회한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Produce      json
// @Param        id path string true "캠프 ID"
// @Success      200 {object} domain.Camp
// @Router       /api/v1/camps/{id} [get]
func (h *MissingHandlers) GetCamp(c echo.Context) error {
	id := c.Param("id")
	camp, err := h.campUC.GetCamp(c.Request().Context(), domain.CampID(id))
	if err != nil { return err }
	if camp == nil { return echo.ErrNotFound }
	return c.JSON(http.StatusOK, camp)
}

// @Summary      코너 생성
// @Description  새로운 코너를 생성한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Accept       json
// @Produce      json
// @Success      201 {object} domain.Corner
// @Router       /api/v1/corners [post]
func (h *MissingHandlers) CreateCorner(c echo.Context) error {
	var req struct{ CampID string `json:"campId"`; Name string `json:"name"` }
	if err := c.Bind(&req); err != nil { return err }
	corner, err := h.cornerUC.AddLearningCorner(c.Request().Context(), domain.CampID(req.CampID), req.Name)
	if err != nil { return err }
	return c.JSON(http.StatusCreated, corner)
}

// @Summary      코너 목록 조회
// @Description  특정 캠프의 코너 목록을 조회한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Produce      json
// @Param        campId query string true "캠프 ID"
// @Success      200 {object} map[string]interface{}
// @Router       /api/v1/corners [get]
func (h *MissingHandlers) ListCorners(c echo.Context) error {
	campID := c.QueryParam("campId")
	corners, err := h.cornerUC.ListCorners(c.Request().Context(), domain.CampID(campID))
	if err != nil { return err }
	return c.JSON(http.StatusOK, map[string]interface{}{"corners": corners})
}

// @Summary      코너 수정
// @Description  코너 정보를 수정한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Accept       json
// @Produce      json
// @Param        id path string true "코너 ID"
// @Success      200 {object} domain.Corner
// @Router       /api/v1/corners/{id} [put]
func (h *MissingHandlers) UpdateCorner(c echo.Context) error {
	id := c.Param("id")
	var req struct{ Name string `json:"name"` }
	if err := c.Bind(&req); err != nil { return err }
	corner, err := h.cornerUC.ModifyCornerSpecification(c.Request().Context(), domain.CornerID(id), req.Name)
	if err != nil { return err }
	return c.JSON(http.StatusOK, corner)
}

// @Summary      코너 삭제
// @Description  코너를 삭제한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Produce      json
// @Param        id path string true "코너 ID"
// @Success      204 "삭제 성공"
// @Router       /api/v1/corners/{id} [delete]
func (h *MissingHandlers) DeleteCorner(c echo.Context) error {
	id := c.Param("id")
	if err := h.cornerUC.RemoveCornerFromCamp(c.Request().Context(), domain.CornerID(id)); err != nil { return err }
	return c.NoContent(http.StatusNoContent)
}

// @Summary      트랙 목록 조회
// @Description  특정 캠프의 트랙 목록을 조회한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Produce      json
// @Param        id path string true "캠프 ID"
// @Success      200 {object} map[string]interface{}
// @Router       /api/v1/camps/{id}/tracks [get]
func (h *MissingHandlers) ListTracks(c echo.Context) error {
	campID := c.Param("id") // /camps/:id/tracks
	tracks, err := h.trackUC.ListTracksByCamp(c.Request().Context(), domain.CampID(campID))
	if err != nil { return err }
	return c.JSON(http.StatusOK, map[string]interface{}{"tracks": tracks})
}

// @Summary      배지 대량 생성
// @Description  초기 배지를 대량으로 발급한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Accept       json
// @Produce      json
// @Success      200 {object} map[string]interface{}
// @Router       /api/v1/badges/bulk-generate [post]
func (h *MissingHandlers) BulkGenerateBadges(c echo.Context) error {
	var req struct{ Count int `json:"count"` }
	if err := c.Bind(&req); err != nil { return err }
	badges, err := h.badgeUC.IssueInitialBadges(c.Request().Context(), req.Count)
	if err != nil { return err }
	return c.JSON(http.StatusOK, map[string]interface{}{"badges": badges})
}

// @Summary      배지 CSV 내보내기
// @Description  생성된 배지 목록을 CSV로 다운로드한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Produce      text/csv
// @Success      200 "CSV 데이터"
// @Router       /api/v1/badges/export [get]
func (h *MissingHandlers) ExportBadges(c echo.Context) error {
	data, err := h.badgeUC.ExportBadges(c.Request().Context())
	if err != nil { return err }
	c.Response().Header().Set("Content-Disposition", "attachment; filename=badges.csv")
	return c.Blob(http.StatusOK, "text/csv", data)
}

// @Summary      배지 목록 조회
// @Description  전체 배지 목록을 조회한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Produce      json
// @Success      200 {object} map[string]interface{}
// @Router       /api/v1/badges [get]
func (h *MissingHandlers) ListBadges(c echo.Context) error {
	badges, err := h.badgeUC.ListBadges(c.Request().Context())
	if err != nil { return err }
	return c.JSON(http.StatusOK, map[string]interface{}{"badges": badges})
}

// @Summary      조 목록 조회
// @Description  특정 캠프의 조 목록을 조회한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Produce      json
// @Param        campId query string true "캠프 ID"
// @Success      200 {object} map[string]interface{}
// @Router       /api/v1/groups [get]
func (h *MissingHandlers) ListGroups(c echo.Context) error {
	campID := c.QueryParam("campId")
	groups, err := h.groupUC.ListGroups(c.Request().Context(), domain.CampID(campID))
	if err != nil { return err }
	return c.JSON(http.StatusOK, map[string]interface{}{"groups": groups})
}

// @Summary      조 순회 일정 조회
// @Description  특정 조의 코너 순회 일정을 조회한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Produce      json
// @Param        id path string true "조 ID"
// @Success      200 {object} domain.Group
// @Router       /api/v1/groups/{id}/schedule [get]
func (h *MissingHandlers) GetGroupSchedule(c echo.Context) error {
	id := c.Param("id")
	group, err := h.groupUC.RetrieveGroupRotationSchedule(c.Request().Context(), domain.GroupID(id))
	if err != nil { return err }
	if group == nil { return echo.ErrNotFound }
	return c.JSON(http.StatusOK, group)
}
