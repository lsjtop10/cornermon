package web

import (
	"context"
	"fmt"
	"net/http"
	"time"

	"github.com/labstack/echo/v4"
)

type EventSubscriber interface {
	SubscribeAdmin(ctx context.Context) (<-chan string, error)
	SubscribeTrack(ctx context.Context, trackID string) (<-chan string, error)
}

type EventHandler struct {
	subscriber EventSubscriber
}

func NewEventHandler(subscriber EventSubscriber) *EventHandler {
	return &EventHandler{
		subscriber: subscriber,
	}
}

// @Summary      Admin SSE Stream
// @Description  관리자용 실시간 이벤트 스트림
// @Tags         F. Events (SSE)
// @Security     AdminAuth
// @Produce      text/event-stream
// @Success      200 "SSE Stream"
// @Router       /api/v1/events/admin [get]
func (h *EventHandler) AdminEvents(c echo.Context) error {
	ctx := c.Request().Context()
	c.Response().Header().Set(echo.HeaderContentType, "text/event-stream")
	c.Response().Header().Set("Cache-Control", "no-cache")
	c.Response().Header().Set("Connection", "keep-alive")
	c.Response().Header().Set("X-Accel-Buffering", "no")

	var ch <-chan string
	if h.subscriber != nil {
		var err error
		ch, err = h.subscriber.SubscribeAdmin(ctx)
		if err != nil {
			return echo.NewHTTPError(http.StatusInternalServerError, err.Error())
		}
	}

	if _, err := c.Response().Write([]byte("data: connected\n\n")); err != nil {
		return err
	}
	c.Response().Flush()

	ticker := time.NewTicker(15 * time.Second)
	defer ticker.Stop()

	if ch != nil {
		for {
			select {
			case <-ctx.Done():
				return nil
			case msg, ok := <-ch:
				if !ok {
					return nil
				}
				if _, err := c.Response().Write([]byte(fmt.Sprintf("data: %s\n\n", msg))); err != nil {
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
	} else {
		for {
			select {
			case <-ctx.Done():
				return nil
			case <-ticker.C:
				if _, err := c.Response().Write([]byte(":heartbeat\n\n")); err != nil {
					return err
				}
				c.Response().Flush()
			}
		}
	}
}

// @Summary      Track SSE Stream
// @Description  트랙 진행자용 실시간 이벤트 스트림
// @Tags         F. Events (SSE)
// @Security     TrackAuth
// @Produce      text/event-stream
// @Param        trackId path string true "트랙 ID"
// @Success      200 "SSE Stream"
// @Router       /api/v1/events/track/{trackId} [get]
func (h *EventHandler) TrackEvents(c echo.Context) error {
	ctx := c.Request().Context()
	trackID := c.Param("trackId")

	c.Response().Header().Set(echo.HeaderContentType, "text/event-stream")
	c.Response().Header().Set("Cache-Control", "no-cache")
	c.Response().Header().Set("Connection", "keep-alive")
	c.Response().Header().Set("X-Accel-Buffering", "no")

	var ch <-chan string
	if h.subscriber != nil {
		var err error
		ch, err = h.subscriber.SubscribeTrack(ctx, trackID)
		if err != nil {
			return echo.NewHTTPError(http.StatusInternalServerError, err.Error())
		}
	}

	if _, err := c.Response().Write([]byte("data: connected\n\n")); err != nil {
		return err
	}
	c.Response().Flush()

	ticker := time.NewTicker(15 * time.Second)
	defer ticker.Stop()

	if ch != nil {
		for {
			select {
			case <-ctx.Done():
				return nil
			case msg, ok := <-ch:
				if !ok {
					return nil
				}
				if _, err := c.Response().Write([]byte(fmt.Sprintf("data: %s\n\n", msg))); err != nil {
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
	} else {
		for {
			select {
			case <-ctx.Done():
				return nil
			case <-ticker.C:
				if _, err := c.Response().Write([]byte(":heartbeat\n\n")); err != nil {
					return err
				}
				c.Response().Flush()
			}
		}
	}
}
