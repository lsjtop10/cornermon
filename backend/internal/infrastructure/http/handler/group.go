package handler

import (
	"net/http"

	"cornermon/backend/internal/infrastructure/http/dto"
	"github.com/labstack/echo/v4"
)

type GroupHandler struct {
}

func NewGroupHandler() *GroupHandler {
	return &GroupHandler{}
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
	return c.JSON(http.StatusOK, []dto.Group{})
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
	return c.JSON(http.StatusOK, dto.Group{})
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
	return c.JSON(http.StatusOK, []dto.VisitSummary{})
}
