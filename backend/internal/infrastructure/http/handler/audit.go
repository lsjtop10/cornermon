package handler

import (
	"context"
	"net/http"
	"strconv"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/infrastructure/http/dto"
	"github.com/labstack/echo/v4"
)

type AuditLogQuerier interface {
	List(ctx context.Context, limit, offset int) ([]*domain.AuditLog, error)
}

type AuditHandler struct {
	querier AuditLogQuerier
}

func NewAuditHandler(querier AuditLogQuerier) *AuditHandler {
	return &AuditHandler{
		querier: querier,
	}
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
	ctx := c.Request().Context()
	
	limitStr := c.QueryParam("limit")
	limit := 50
	if limitStr != "" {
		if l, err := strconv.Atoi(limitStr); err == nil {
			limit = l
		}
	}

	offsetStr := c.QueryParam("offset")
	offset := 0
	if offsetStr != "" {
		if o, err := strconv.Atoi(offsetStr); err == nil {
			offset = o
		}
	}

	var logs []*domain.AuditLog
	var err error
	if h.querier != nil {
		logs, err = h.querier.List(ctx, limit, offset)
		if err != nil {
			return echo.NewHTTPError(http.StatusInternalServerError, err.Error())
		}
	}

	dtos := make([]dto.AuditLog, len(logs))
	for i, log := range logs {
		dtos[i] = dto.AuditLog{
			ID:         string(log.ID),
			Actor:      log.Actor,
			Action:     log.Action,
			Target:     log.Target,
			Success:    log.Success,
			OccurredAt: log.OccurredAt,
			Metadata:   log.Metadata,
		}
	}

	return c.JSON(http.StatusOK, dtos)
}
