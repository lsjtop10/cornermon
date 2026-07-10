package handler

import (
	"net/http"

	"cornermon/backend/internal/interfaces/http/dto"
	"github.com/labstack/echo/v4"
)

type CornerHandler struct {
}

func NewCornerHandler() *CornerHandler {
	return &CornerHandler{}
}

// @Summary      코너 목록 조회
// @Description  특정 캠프의 모든 코너 목록을 조회한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Produce      json
// @Param        campId query string true "필터링할 캠프 ID"
// @Success      200 {array} dto.Corner
// @Failure      400 {object} dto.ErrorResponse
// @Failure      401 {object} dto.ErrorResponse
// @Router       /corners [get]
func (h *CornerHandler) ListCorners(c echo.Context) error {
	return c.JSON(http.StatusOK, []dto.Corner{})
}

type CreateCornerRequest struct {
	CampID        string `json:"campId"`
	Name          string `json:"name"`
	TargetMinutes int    `json:"targetMinutes"`
}

// @Summary      새 코너 추가
// @Description  캠프에 새로운 코너를 생성한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Accept       json
// @Produce      json
// @Param        request body CreateCornerRequest true "코너 생성 정보"
// @Success      201 {object} dto.Corner
// @Failure      400 {object} dto.ErrorResponse
// @Failure      401 {object} dto.ErrorResponse
// @Router       /corners [post]
func (h *CornerHandler) CreateCorner(c echo.Context) error {
	return c.JSON(http.StatusCreated, dto.Corner{})
}

// @Summary      코너 상세 조회
// @Description  특정 코너 정보를 조회한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Produce      json
// @Param        id path string true "코너 ID"
// @Success      200 {object} dto.Corner
// @Failure      404 {object} dto.ErrorResponse
// @Router       /corners/{id} [get]
func (h *CornerHandler) GetCorner(c echo.Context) error {
	return c.JSON(http.StatusOK, dto.Corner{})
}

// @Summary      코너 삭제
// @Description  코너를 삭제한다. 단, 방문 기록이 있으면 삭제할 수 없다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Produce      json
// @Param        id path string true "코너 ID"
// @Success      204 "성공적으로 삭제됨"
// @Failure      400 {object} dto.ErrorResponse
// @Failure      409 {object} dto.ErrorResponse "활성화된 캠프이거나 종속 데이터가 존재함"
// @Router       /corners/{id} [delete]
func (h *CornerHandler) DeleteCorner(c echo.Context) error {
	return c.NoContent(http.StatusNoContent)
}

type BulkUpdateCornersRequest struct {
	Corners []struct {
		ID            string `json:"id"`
		Name          string `json:"name"`
		TargetMinutes int    `json:"targetMinutes"`
	} `json:"corners"`
}

// @Summary      코너 대량 수정
// @Description  여러 코너의 이름이나 목표 시간을 일괄 수정한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Accept       json
// @Produce      json
// @Param        request body BulkUpdateCornersRequest true "수정할 코너 목록"
// @Success      200 {array} dto.Corner
// @Failure      400 {object} dto.ErrorResponse
// @Failure      409 {object} dto.ErrorResponse
// @Router       /corners/bulk-update [put]
func (h *CornerHandler) BulkUpdateCorners(c echo.Context) error {
	return c.JSON(http.StatusOK, []dto.Corner{})
}
