package web

import (
	"context"
	"encoding/base64"
	"encoding/json"
	"net/http"
	"strconv"
	"time"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/usecase"

	"github.com/labstack/echo/v4"
)

type AuditLogQuerier interface {
	List(ctx context.Context, query usecase.AuditLogQuery) (*usecase.AuditLogPage, error)
}

type AuditHandler struct {
	querier AuditLogQuerier
}

type AuditLogResponse struct {
	ID         string                 `json:"id" format:"uuid"`
	Actor      string                 `json:"actor"`
	Action     string                 `json:"action"`
	Target     string                 `json:"target"`
	Success    bool                   `json:"success"`
	OccurredAt time.Time              `json:"occurredAt" format:"date-time"`
	Metadata   map[string]interface{} `json:"metadata,omitempty"`
}

// @name AuditLogResponse

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
// @Param        actor query string false "행위자 부분 일치"
// @Param        action query string false "행위 종류 정확히 일치"
// @Param        result query string false "처리 결과" Enums(success,failure)
// @Param        limit query int false "조회 개수" default(50)
// @Param        before query string false "이전 응답의 불투명 nextCursor"
// @Success      200 {object} AuditLogPageResponse
// @Failure      400 {object} ErrorResponse
// @Router       /audit-logs [get]
func (h *AuditHandler) ListAuditLogs(c echo.Context) error {
	ctx := c.Request().Context()
	limit := 50
	if raw := c.QueryParam("limit"); raw != "" {
		parsed, err := strconv.Atoi(raw)
		if err != nil || parsed < 1 || parsed > 200 {
			return echo.NewHTTPError(http.StatusBadRequest, "limit must be between 1 and 200")
		}
		limit = parsed
	}

	query := usecase.AuditLogQuery{Actor: c.QueryParam("actor"), Action: c.QueryParam("action"), Limit: limit}
	if result := c.QueryParam("result"); result != "" {
		switch result {
		case "success":
			value := true
			query.Success = &value
		case "failure":
			value := false
			query.Success = &value
		default:
			return echo.NewHTTPError(http.StatusBadRequest, "result must be success or failure")
		}
	}
	if raw := c.QueryParam("before"); raw != "" {
		cursor, err := decodeAuditLogCursor(raw)
		if err != nil {
			return echo.NewHTTPError(http.StatusBadRequest, "invalid before cursor")
		}
		query.Before = domain.Some(cursor)
	}

	page := &usecase.AuditLogPage{Logs: []*domain.AuditLog{}, NextCursor: domain.None[usecase.AuditLogCursor]()}
	if h.querier != nil {
		var err error
		page, err = h.querier.List(ctx, query)
		if err != nil {
			return err
		}
	}

	dtos := make([]AuditLogResponse, len(page.Logs))
	for i, log := range page.Logs {
		dtos[i] = AuditLogResponse{
			ID:         string(log.ID),
			Actor:      log.Actor,
			Action:     log.Action,
			Target:     log.Target,
			Success:    log.Success,
			OccurredAt: log.OccurredAt,
			Metadata:   log.Metadata,
		}
	}

	response := AuditLogPageResponse{Logs: dtos}
	if cursor, ok := page.NextCursor.Value(); ok {
		response.NextCursor = encodeAuditLogCursor(cursor)
	}
	return c.JSON(http.StatusOK, response)
}

type AuditLogPageResponse struct {
	Logs       []AuditLogResponse `json:"logs"`
	NextCursor string             `json:"nextCursor,omitempty"`
}

// @name AuditLogPageResponse

type auditLogCursorPayload struct {
	OccurredAt time.Time `json:"occurredAt"`
	ID         string    `json:"id"`
}

func encodeAuditLogCursor(cursor usecase.AuditLogCursor) string {
	payload, _ := json.Marshal(auditLogCursorPayload{OccurredAt: cursor.OccurredAt, ID: string(cursor.ID)})
	return base64.RawURLEncoding.EncodeToString(payload)
}

func decodeAuditLogCursor(raw string) (usecase.AuditLogCursor, error) {
	payload, err := base64.RawURLEncoding.DecodeString(raw)
	if err != nil {
		return usecase.AuditLogCursor{}, err
	}
	var value auditLogCursorPayload
	if err := json.Unmarshal(payload, &value); err != nil {
		return usecase.AuditLogCursor{}, err
	}
	if value.OccurredAt.IsZero() || value.ID == "" {
		return usecase.AuditLogCursor{}, echo.NewHTTPError(http.StatusBadRequest, "invalid cursor")
	}
	return usecase.AuditLogCursor{OccurredAt: value.OccurredAt, ID: domain.AuditLogID(value.ID)}, nil
}
