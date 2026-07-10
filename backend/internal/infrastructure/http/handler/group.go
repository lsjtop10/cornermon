package handler

import (
	"net/http"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/infrastructure/http/dto"
	"cornermon/backend/internal/usecase"
	"github.com/labstack/echo/v4"
)

type GroupHandler struct {
	groupUC *usecase.GroupService
}

func NewGroupHandler(groupUC *usecase.GroupService) *GroupHandler {
	return &GroupHandler{groupUC: groupUC}
}

func mapGroupToDTO(g *domain.Group) dto.Group {
	res := dto.Group{
		ID:         string(g.ID),
		Name:       g.Name,
		BadgeID:    string(g.BadgeID),
		Status:     string(g.Status()),
		IsFinished: g.IsFinished(),
		Itinerary:  make([]dto.CornerProgress, 0, len(g.Itinerary)),
	}
	for _, c := range g.Itinerary {
		res.Itinerary = append(res.Itinerary, dto.CornerProgress{
			CornerID: string(c.CornerID),
			Status:   string(c.Status),
		})
	}
	return res
}

// @Summary      전체 조 목록 조회
// @Description  특정 캠프에 속한 모든 조의 목록과 상태를 조회한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Produce      json
// @Param        campId query string false "캠프 ID 필터"
// @Success      200 {array} dto.Group
// @Router       /groups [get]
func (h *GroupHandler) ListGroups(c echo.Context) error {
	campID := c.QueryParam("campId")
	groups, err := h.groupUC.ListGroups(c.Request().Context(), domain.CampID(campID))
	if err != nil {
		return err
	}
	res := make([]dto.Group, len(groups))
	for i, g := range groups {
		res[i] = mapGroupToDTO(g)
	}
	return c.JSON(http.StatusOK, res)
}

// @Summary      특정 조 상세 조회
// @Description  특정 조의 현재 위치 및 순회표(Itinerary) 진행 상태를 조회한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Produce      json
// @Param        id path string true "조 ID"
// @Success      200 {object} dto.Group
// @Router       /groups/{id} [get]
func (h *GroupHandler) GetGroup(c echo.Context) error {
	id := c.Param("id")
	g, err := h.groupUC.RetrieveGroupRotationSchedule(c.Request().Context(), domain.GroupID(id))
	if err != nil {
		return err
	}
	if g == nil {
		return echo.ErrNotFound
	}
	return c.JSON(http.StatusOK, mapGroupToDTO(g))
}

// @Summary      조별 방문 기록 조회
// @Description  특정 조의 전체 방문(Visit) 기록과 각 코너의 소요 시간 등을 조회한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Produce      json
// @Param        id path string true "조 ID"
// @Success      200 {array} dto.VisitSummary
// @Router       /groups/{id}/visits [get]
func (h *GroupHandler) ListGroupVisits(c echo.Context) error {
	return echo.NewHTTPError(http.StatusNotImplemented, "Not implemented yet")
}
