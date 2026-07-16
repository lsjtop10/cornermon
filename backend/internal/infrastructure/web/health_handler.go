package web

import (
	"net/http"

	"github.com/labstack/echo/v4"
)

type HealthHandler struct{}

func NewHealthHandler() *HealthHandler {
	return &HealthHandler{}
}

type HealthResponse struct {
	Status string `json:"status" example:"ok"`
} // @name HealthResponse

// @Summary      헬스체크
// @Description  서버가 정상적으로 응답하는지 확인한다. 인증이 필요하지 않다.
// @Tags         Health
// @Produce      json
// @Success      200 {object} HealthResponse
// @Router       /health [get]
func (h *HealthHandler) Check(c echo.Context) error {
	return c.JSON(http.StatusOK, HealthResponse{Status: "ok"})
}
