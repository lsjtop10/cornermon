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
	ActorName  string                 `json:"actorName,omitempty"`
	Action     string                 `json:"action" enums:"ADMIN_LOGIN,ADMIN_CREATE,ADMIN_PASSWORD_CHANGE,ADMIN_DELETE,ADMIN_SESSION_REVOKE,TRACK_FORCE_LOGOUT,FACILITATOR_LOGIN,SESSION_MIGRATE,FACILITATOR_LOGOUT,BADGE_ASSIGN,BADGE_BULK_GENERATE,BADGE_EXPORT,CAMP_ACTIVATE,CAMP_END,CAMP_CREATE,CAMP_SETTINGS_UPDATE,CORNER_UPDATE,CORNER_DELETE,CORNER_CREATE,DEVICE_APPROVED,DEVICE_REJECTED,DEVICE_REVOKED,PIN_LOCK_RESET,DEVICE_REQUEST,GROUP_CREATE,MESSAGE_DIRECT,MESSAGE_BROADCAST,TRACK_CREATE,TRACK_DELETE,TRACK_REPLACE,PIN_REGENERATE,TRACK_PIN_EXPORT,VISIT_START,VISIT_COMPLETE"`
	Target     string                 `json:"target"`
	TargetName string                 `json:"targetName,omitempty"`
	CampID     *string                `json:"campId,omitempty" format:"uuid"`
	Success    bool                   `json:"success"`
	OccurredAt time.Time              `json:"occurredAt" format:"date-time"`
	Metadata   map[string]interface{} `json:"metadata,omitempty"`
} // @name AuditLogResponse

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
// @Param        action query string false "행위 종류 정확히 일치" Enums(ADMIN_LOGIN,ADMIN_CREATE,ADMIN_PASSWORD_CHANGE,ADMIN_DELETE,ADMIN_SESSION_REVOKE,TRACK_FORCE_LOGOUT,FACILITATOR_LOGIN,SESSION_MIGRATE,FACILITATOR_LOGOUT,BADGE_ASSIGN,BADGE_BULK_GENERATE,BADGE_EXPORT,CAMP_ACTIVATE,CAMP_END,CAMP_CREATE,CAMP_SETTINGS_UPDATE,CORNER_UPDATE,CORNER_DELETE,CORNER_CREATE,DEVICE_APPROVED,DEVICE_REJECTED,DEVICE_REVOKED,PIN_LOCK_RESET,DEVICE_REQUEST,GROUP_CREATE,MESSAGE_DIRECT,MESSAGE_BROADCAST,TRACK_CREATE,TRACK_DELETE,TRACK_REPLACE,PIN_REGENERATE,TRACK_PIN_EXPORT,VISIT_START,VISIT_COMPLETE)
// @Param        result query string false "처리 결과" Enums(success,failure)
// @Param        campId query string false "캠프 ID로 범위 제한"
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

	query := usecase.AuditLogQuery{Actor: c.QueryParam("actor"), Limit: limit}
	if action := c.QueryParam("action"); action != "" {
		if !usecase.IsValidAuditAction(action) {
			return echo.NewHTTPError(http.StatusBadRequest, "action must be one of the known audit actions")
		}
		query.Action = action
	}
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
	if campID := c.QueryParam("campId"); campID != "" {
		query.CampID = domain.Some(domain.CampID(campID))
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
			ID:         string(log.ID()),
			Actor:      log.Actor(),
			ActorName:  log.ActorName(),
			Action:     log.Action(),
			Target:     log.Target(),
			TargetName: log.TargetName(),
			Success:    log.Success(),
			OccurredAt: log.OccurredAt(),
			Metadata:   log.Metadata(),
		}
		if campID, ok := log.CampID().Value(); ok {
			id := string(campID)
			dtos[i].CampID = &id
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
} // @name AuditLogPageResponse

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
