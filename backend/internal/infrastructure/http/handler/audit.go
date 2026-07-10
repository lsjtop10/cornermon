package handler

import (
	"net/http"

	"cornermon/backend/internal/infrastructure/http/dto"
	"github.com/labstack/echo/v4"
)

type AuditHandler struct {
}

func NewAuditHandler() *AuditHandler {
	return &AuditHandler{}
}

// @Summary      감사 로그 조회
// @Description  시스템에서 발생한 중요 행위(인증, 방문, 예외 처리 등)의 감사 로그를 조회한다.
// @Tags         G. Audit Logs
// @Security     AdminAuth
// @Produce      json
// @Param        limit query int false "조회 개수" default(50)
// @Param        offset query int false "오프셋" default(0)
// @Success      200 {array} dto.AuditLog
// @Router       /audit-logs [get]
func (h *AuditHandler) ListAuditLogs(c echo.Context) error {
	return c.JSON(http.StatusOK, []dto.AuditLog{})
}
