package handler

import (
	"net/http"

	"cornermon/backend/internal/interfaces/http/dto"
	"github.com/labstack/echo/v4"
)

type CampHandler struct {
}

func NewCampHandler() *CampHandler {
	return &CampHandler{}
}

// @Summary      캠프 목록 조회
// @Description  전체 캠프 목록을 조회한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Produce      json
// @Success      200 {array} dto.Camp
// @Failure      401 {object} dto.ErrorResponse
// @Router       /camps [get]
func (h *CampHandler) ListCamps(c echo.Context) error {
	return c.JSON(http.StatusOK, []dto.Camp{})
}

type CreateCampRequest struct {
	Name string `json:"name"`
}

// @Summary      새 캠프 생성
// @Description  새로운 코너학습 캠프를 생성한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Accept       json
// @Produce      json
// @Param        request body CreateCampRequest true "캠프 생성 정보"
// @Success      201 {object} dto.Camp
// @Failure      400 {object} dto.ErrorResponse
// @Failure      401 {object} dto.ErrorResponse
// @Router       /camps [post]
func (h *CampHandler) CreateCamp(c echo.Context) error {
	return c.JSON(http.StatusCreated, dto.Camp{})
}

// @Summary      캠프 상세 조회
// @Description  특정 캠프 정보를 조회한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Produce      json
// @Param        id path string true "캠프 ID"
// @Success      200 {object} dto.Camp
// @Failure      404 {object} dto.ErrorResponse
// @Router       /camps/{id} [get]
func (h *CampHandler) GetCamp(c echo.Context) error {
	return c.JSON(http.StatusOK, dto.Camp{})
}

// @Summary      캠프 시작
// @Description  캠프를 ACTIVE 상태로 변경하고 운영을 시작한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Produce      json
// @Param        id path string true "캠프 ID"
// @Success      200 {object} dto.Camp
// @Failure      400 {object} dto.ErrorResponse
// @Failure      409 {object} dto.ErrorResponse "이미 활성화됨 또는 필수 조건 미충족"
// @Router       /camps/{id}/start [post]
func (h *CampHandler) StartCamp(c echo.Context) error {
	return c.JSON(http.StatusOK, dto.Camp{})
}

// @Summary      캠프 종료
// @Description  캠프를 ENDED 상태로 변경한다. 이후 데이터 수정이 불가하다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Produce      json
// @Param        id path string true "캠프 ID"
// @Success      200 {object} dto.Camp
// @Failure      400 {object} dto.ErrorResponse
// @Failure      409 {object} dto.ErrorResponse
// @Router       /camps/{id}/end [post]
func (h *CampHandler) EndCamp(c echo.Context) error {
	return c.JSON(http.StatusOK, dto.Camp{})
}
