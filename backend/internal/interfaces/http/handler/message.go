package handler

import (
	"net/http"

	"github.com/labstack/echo/v4"
)

type MessageHandler struct {
	// messageUC MessageUsecase
}

func NewMessageHandler() *MessageHandler {
	return &MessageHandler{}
}

// @Summary      공지사항 발송
// @Description  전체 트랙으로 공지사항(BROADCAST) 메시지를 보낸다.
// @Tags         E. Message
// @Security     AdminAuth
// @Accept       json
// @Produce      json
// @Success      201 "발송 성공"
// @Router       /api/v1/messages/broadcast [post]
func (h *MessageHandler) SendBroadcast(c echo.Context) error {
	return c.JSON(http.StatusCreated, map[string]string{"status": "ok"})
}

// @Summary      진행자와 1:1 메시지 전송
// @Description  특정 트랙 진행자에게 다이렉트(DIRECT) 메시지를 보낸다.
// @Tags         E. Message
// @Security     AdminAuth
// @Accept       json
// @Produce      json
// @Param        trackId path string true "트랙 ID"
// @Success      201 "발송 성공"
// @Router       /api/v1/tracks/{trackId}/messages [post]
func (h *MessageHandler) SendDirect(c echo.Context) error {
	return c.JSON(http.StatusCreated, map[string]string{"status": "ok"})
}
