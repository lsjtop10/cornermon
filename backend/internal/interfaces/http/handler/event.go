package handler

import (
	"github.com/labstack/echo/v4"
)

type EventHandler struct {
	// Not fully implemented yet
}

func NewEventHandler() *EventHandler {
	return &EventHandler{}
}

// @Summary      Admin SSE Stream
// @Description  관리자용 실시간 이벤트 스트림
// @Tags         F. Events (SSE)
// @Security     AdminAuth
// @Produce      text/event-stream
// @Success      200 "SSE Stream"
// @Router       /api/v1/events/admin [get]
func (h *EventHandler) AdminEvents(c echo.Context) error {
	c.Response().Header().Set(echo.HeaderContentType, "text/event-stream")
	c.Response().Header().Set("Cache-Control", "no-cache")
	c.Response().Header().Set("Connection", "keep-alive")

	// Dummy implementation
	if _, err := c.Response().Write([]byte("data: connected\n\n")); err != nil {
		return err
	}
	c.Response().Flush()

	<-c.Request().Context().Done()
	return nil
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
	c.Response().Header().Set(echo.HeaderContentType, "text/event-stream")
	c.Response().Header().Set("Cache-Control", "no-cache")
	c.Response().Header().Set("Connection", "keep-alive")

	// Dummy implementation
	if _, err := c.Response().Write([]byte("data: connected\n\n")); err != nil {
		return err
	}
	c.Response().Flush()

	<-c.Request().Context().Done()
	return nil
}
