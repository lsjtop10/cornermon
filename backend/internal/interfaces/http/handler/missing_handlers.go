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

// Camp
func (h *MissingHandlers) CreateCamp(c echo.Context) error {
	var req struct{ Name string `json:"name"` }
	if err := c.Bind(&req); err != nil { return err }
	camp, err := h.campUC.OpenNewCamp(c.Request().Context(), req.Name)
	if err != nil { return err }
	return c.JSON(http.StatusCreated, camp)
}
func (h *MissingHandlers) ListCamps(c echo.Context) error {
	camps, err := h.campUC.ListCamps(c.Request().Context())
	if err != nil { return err }
	return c.JSON(http.StatusOK, map[string]interface{}{"camps": camps})
}
func (h *MissingHandlers) GetCamp(c echo.Context) error {
	id := c.Param("id")
	camp, err := h.campUC.GetCamp(c.Request().Context(), domain.CampID(id))
	if err != nil { return err }
	if camp == nil { return echo.ErrNotFound }
	return c.JSON(http.StatusOK, camp)
}

// Corner
func (h *MissingHandlers) CreateCorner(c echo.Context) error {
	var req struct{ CampID string `json:"campId"`; Name string `json:"name"` }
	if err := c.Bind(&req); err != nil { return err }
	corner, err := h.cornerUC.AddLearningCorner(c.Request().Context(), domain.CampID(req.CampID), req.Name)
	if err != nil { return err }
	return c.JSON(http.StatusCreated, corner)
}
func (h *MissingHandlers) ListCorners(c echo.Context) error {
	campID := c.QueryParam("campId")
	corners, err := h.cornerUC.ListCorners(c.Request().Context(), domain.CampID(campID))
	if err != nil { return err }
	return c.JSON(http.StatusOK, map[string]interface{}{"corners": corners})
}
func (h *MissingHandlers) UpdateCorner(c echo.Context) error {
	id := c.Param("id")
	var req struct{ Name string `json:"name"` }
	if err := c.Bind(&req); err != nil { return err }
	corner, err := h.cornerUC.ModifyCornerSpecification(c.Request().Context(), domain.CornerID(id), req.Name)
	if err != nil { return err }
	return c.JSON(http.StatusOK, corner)
}
func (h *MissingHandlers) DeleteCorner(c echo.Context) error {
	id := c.Param("id")
	if err := h.cornerUC.RemoveCornerFromCamp(c.Request().Context(), domain.CornerID(id)); err != nil { return err }
	return c.NoContent(http.StatusNoContent)
}

// Track
func (h *MissingHandlers) ListTracks(c echo.Context) error {
	campID := c.Param("id") // /camps/:id/tracks
	tracks, err := h.trackUC.ListTracksByCamp(c.Request().Context(), domain.CampID(campID))
	if err != nil { return err }
	return c.JSON(http.StatusOK, map[string]interface{}{"tracks": tracks})
}

// Badge
func (h *MissingHandlers) BulkGenerateBadges(c echo.Context) error {
	var req struct{ Count int `json:"count"` }
	if err := c.Bind(&req); err != nil { return err }
	badges, err := h.badgeUC.IssueInitialBadges(c.Request().Context(), req.Count)
	if err != nil { return err }
	return c.JSON(http.StatusOK, map[string]interface{}{"badges": badges})
}
func (h *MissingHandlers) ExportBadges(c echo.Context) error {
	data, err := h.badgeUC.ExportBadges(c.Request().Context())
	if err != nil { return err }
	c.Response().Header().Set("Content-Disposition", "attachment; filename=badges.csv")
	return c.Blob(http.StatusOK, "text/csv", data)
}
func (h *MissingHandlers) ListBadges(c echo.Context) error {
	badges, err := h.badgeUC.ListBadges(c.Request().Context())
	if err != nil { return err }
	return c.JSON(http.StatusOK, map[string]interface{}{"badges": badges})
}

// Group
func (h *MissingHandlers) ListGroups(c echo.Context) error {
	campID := c.QueryParam("campId")
	groups, err := h.groupUC.ListGroups(c.Request().Context(), domain.CampID(campID))
	if err != nil { return err }
	return c.JSON(http.StatusOK, map[string]interface{}{"groups": groups})
}
func (h *MissingHandlers) GetGroupSchedule(c echo.Context) error {
	id := c.Param("id")
	group, err := h.groupUC.RetrieveGroupRotationSchedule(c.Request().Context(), domain.GroupID(id))
	if err != nil { return err }
	if group == nil { return echo.ErrNotFound }
	return c.JSON(http.StatusOK, group)
}
