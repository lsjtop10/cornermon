package web

import (
	"context"
	"net/http"

	"github.com/labstack/echo/v4"
)

// Pinger checks connectivity to a dependency the server needs to be ready
// (e.g. the database connection pool).
type Pinger interface {
	Ping(ctx context.Context) error
}

type HealthHandler struct {
	db Pinger
}

func NewHealthHandler(db Pinger) *HealthHandler {
	return &HealthHandler{db: db}
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

// @Summary      레디니스 체크
// @Description  서버가 데이터베이스 등 필수 의존성에 연결되어 트래픽을 받을 준비가 되었는지 확인한다. 인증이 필요하지 않다.
// @Tags         Health
// @Produce      json
// @Success      200 {object} HealthResponse
// @Failure      503 {object} HealthResponse
// @Router       /ready [get]
func (h *HealthHandler) Ready(c echo.Context) error {
	if err := h.db.Ping(c.Request().Context()); err != nil {
		return c.JSON(http.StatusServiceUnavailable, HealthResponse{Status: "unavailable"})
	}
	return c.JSON(http.StatusOK, HealthResponse{Status: "ok"})
}
