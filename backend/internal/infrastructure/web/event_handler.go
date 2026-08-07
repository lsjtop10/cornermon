package web

import (
	"context"
	"encoding/json"
	"fmt"
	"log/slog"
	"net/http"
	"os"
	"time"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/errs"
	"cornermon/backend/internal/usecase"

	"github.com/labstack/echo/v4"
)

type EventSubscriber interface {
	SubscribeAdmin(ctx context.Context, campID domain.CampID) (<-chan usecase.SSEMessage, error)
	SubscribeTrack(ctx context.Context, campID domain.CampID, trackID domain.TrackID) (<-chan usecase.SSEMessage, error)
}

type EventTrackRepository interface {
	Get(ctx context.Context, id domain.TrackID) (*domain.Track, error)
}

type EventCornerRepository interface {
	Get(ctx context.Context, id domain.CornerID) (*domain.Corner, error)
}

type SSENotification struct {
	Event string   `json:"event" enums:"tracks_updated,track_updated,corners_updated,groups_updated,camp_updated,messages_changed,track_deleted,track_replaced,session_revoked,camp_ended,device_registration_updated,lockout_alert" example:"tracks_updated"`
	Scope SSEScope `json:"scope"`
} // @name SSENotification

type SSEScope struct {
	Kind    string `json:"kind" enums:"camp,track" example:"camp"`
	TrackID string `json:"trackId,omitempty" format:"uuid"`
} // @name SSEScope

type EventHandler struct {
	subscriber EventSubscriber
	tracks     EventTrackRepository
	corners    EventCornerRepository
}

func NewEventHandler(subscriber EventSubscriber, tracks EventTrackRepository, corners EventCornerRepository) *EventHandler {
	return &EventHandler{subscriber: subscriber, tracks: tracks, corners: corners}
}

// @Summary      Admin SSE Stream
// @Description  관리자용 best-effort 변경 알림 스트림입니다. 각 event의 data는 SSENotification JSON이며 예시는 {"event":"tracks_updated","scope":{"kind":"camp"}} 입니다. 이벤트에는 상태 스냅샷이 없으므로 수신한 관리자는 해당 REST API로 최신 상태를 조회합니다. `camp_ended`도 관리자는 REST 재조회할 수 있습니다. 서버는 유실된 메시지를 저장·재전송하지 않으며, 버퍼가 찬 연결은 종료됩니다. 재연결 후 REST API로 최신 상태를 다시 조회해야 합니다.
// @Tags         F. Events (SSE)
// @Security     AdminAuth
// @Produce      text/event-stream
// @Param        campId path string true "캠프 ID"
// @Success      200 {object} SSENotification "SSE Stream data payload"
// @Router       /api/v1/camps/{campId}/events/admin [get]
func (h *EventHandler) AdminEvents(c echo.Context) error {
	ctx := c.Request().Context()
	setSSEHeaders(c)

	if h.subscriber == nil {
		return h.streamEvents(c, nil)
	}
	ch, err := h.subscriber.SubscribeAdmin(ctx, domain.CampID(c.Param("campId")))
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, err.Error())
	}
	if ch == nil {
		return nil
	}
	return h.streamEvents(c, ch)
}

// @Summary      Track SSE Stream
// @Description  트랙 진행자용 best-effort 변경 알림 스트림입니다. 각 event의 data는 SSENotification JSON이며 예시는 {"event":"track_updated","scope":{"kind":"track","trackId":"track-id"}} 입니다. 일반 이벤트에는 상태 스냅샷이 없으므로 REST API로 최신 상태를 조회합니다. 단, `camp_ended`는 terminal event이므로 REST 재조회 없이 로컬 진행자 세션·기기 등록을 삭제하고 등록 화면으로 이동합니다. 이벤트 도착·순서는 판정 근거가 아니며, 일반 재조회가 SESSION_REVOKED/401로 실패하거나 SSE를 놓치면 GET /device-registrations/me의 status와 campStatus로 최종 복구합니다: APPROVED/ACTIVE는 PIN 세션만 종료, REVOKED/ENDED는 캠프 종료, REVOKED/그 외는 기기 신뢰 회수입니다. 서버는 유실된 메시지를 저장·재전송하지 않습니다.
// @Tags         F. Events (SSE)
// @Security     TrackAuth
// @Produce      text/event-stream
// @Param        trackId path string true "트랙 ID"
// @Success      200 {object} SSENotification "SSE Stream data payload"
// @Router       /api/v1/events/track/{trackId} [get]
func (h *EventHandler) TrackEvents(c echo.Context) error {
	ctx := c.Request().Context()
	trackID := domain.TrackID(c.Param("trackId"))
	setSSEHeaders(c)

	if h.subscriber == nil {
		return h.streamEvents(c, nil)
	}
	track, err := h.tracks.Get(ctx, trackID)
	if err != nil {
		return err
	}
	if track == nil {
		return echo.NewHTTPError(http.StatusNotFound, "track not found")
	}
	corner, err := h.corners.Get(ctx, track.CornerID())
	if err != nil {
		return err
	}
	if corner == nil {
		return echo.NewHTTPError(http.StatusNotFound, "corner not found")
	}

	ch, err := h.subscriber.SubscribeTrack(ctx, corner.CampID(), trackID)
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, err.Error())
	}
	if ch == nil {
		return nil
	}
	return h.streamEvents(c, ch)
}

func (h *EventHandler) streamEvents(c echo.Context, ch <-chan usecase.SSEMessage) error {
	ctx := c.Request().Context()
	// connectionID는 이 SSE 연결이 열릴 때(구독 요청) 발급된 trace_id로, 연결이 유지되는
	// 동안 고정된다. 이 연결로 전달되는 각 메시지의 causation_id(발행을 유발한 요청의
	// CausationID)와는 별개의 수명을 가지므로 로그에서 두 값을 구분해 남긴다 — DEVELOPER_GUIDE.md
	// §4.3.1 참고.
	connectionID := errs.TraceIDFromContext(ctx)
	if _, err := c.Response().Write([]byte("data: connected\n\n")); err != nil {
		return err
	}
	c.Response().Flush()

	heartbeatDuration := 15 * time.Second
	if envInterval := os.Getenv("SSE_HEARTBEAT_INTERVAL"); envInterval != "" {
		if d, err := time.ParseDuration(envInterval); err == nil && d > 0 {
			heartbeatDuration = d
		}
	}
	ticker := time.NewTicker(heartbeatDuration)
	defer ticker.Stop()
	for {
		select {
		case <-ctx.Done():
			return nil
		case msg, ok := <-ch:
			if !ok && ch != nil {
				return nil
			}
			if ch == nil {
				continue
			}
			formatted, err := formatSSEMessage(msg)
			if err != nil {
				return err
			}
			if _, err := c.Response().Write([]byte(formatted)); err != nil {
				// SSE 스트리밍 도중 발생하는 write 실패는 ErrorHandler 미들웨어를 거치지 않고
				// 여기서 바로 반환되므로, 이 지점에서 직접 로그한다.
				slog.WarnContext(ctx, "SSE event write failed",
					"event", msg.Event,
					"scope_kind", msg.Scope.Kind,
					"scope_track_id", msg.Scope.TrackID,
					"connection_id", connectionID,
					"causation_id", msg.CausationID,
					"error", err,
				)
				return err
			}
			c.Response().Flush()
			// broadcaster의 "SSE broadcast dispatched" 로그와 causation_id로 조인하면
			// "어떤 요청이 발행한 알림을 어떤 연결이 언제 받았는지" 추적할 수 있다.
			slog.DebugContext(ctx, "SSE event delivered",
				"event", msg.Event,
				"scope_kind", msg.Scope.Kind,
				"scope_track_id", msg.Scope.TrackID,
				"connection_id", connectionID,
				"causation_id", msg.CausationID,
			)
		case <-ticker.C:
			if _, err := c.Response().Write([]byte(":heartbeat\n\n")); err != nil {
				return err
			}
			c.Response().Flush()
		}
	}
}

func formatSSEMessage(message usecase.SSEMessage) (string, error) {
	notification := SSENotification{
		Event: string(message.Event),
		Scope: SSEScope{Kind: string(message.Scope.Kind), TrackID: string(message.Scope.TrackID)},
	}
	payload, err := json.Marshal(notification)
	if err != nil {
		return "", err
	}
	return fmt.Sprintf("event: %s\ndata: %s\n\n", message.Event, payload), nil
}

func setSSEHeaders(c echo.Context) {
	c.Response().Header().Set(echo.HeaderContentType, "text/event-stream")
	c.Response().Header().Set("Cache-Control", "no-cache")
	c.Response().Header().Set("Connection", "keep-alive")
	c.Response().Header().Set("X-Accel-Buffering", "no")
}
