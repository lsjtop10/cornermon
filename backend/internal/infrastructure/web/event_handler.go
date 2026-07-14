package web

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"time"

	"cornermon/backend/internal/domain"
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
// @Description  관리자용 실시간 이벤트 스트림. 각 event의 data는 SSENotification JSON이며 예시는 {"event":"tracks_updated","scope":{"kind":"camp"}} 입니다.
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
// @Description  트랙 진행자용 실시간 이벤트 스트림. 각 event의 data는 SSENotification JSON이며 예시는 {"event":"track_updated","scope":{"kind":"track","trackId":"track-id"}} 입니다.
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
	corner, err := h.corners.Get(ctx, track.CornerID)
	if err != nil {
		return err
	}
	if corner == nil {
		return echo.NewHTTPError(http.StatusNotFound, "corner not found")
	}

	ch, err := h.subscriber.SubscribeTrack(ctx, corner.CampID, trackID)
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
	if _, err := c.Response().Write([]byte("data: connected\n\n")); err != nil {
		return err
	}
	c.Response().Flush()

	ticker := time.NewTicker(15 * time.Second)
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
				return err
			}
			c.Response().Flush()
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
