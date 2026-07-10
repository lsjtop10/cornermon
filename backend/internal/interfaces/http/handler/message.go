package handler

import (
	"net/http"

	"cornermon/backend/internal/interfaces/http/dto"
	"github.com/labstack/echo/v4"
)

type MessageHandler struct {
}

func NewMessageHandler() *MessageHandler {
	return &MessageHandler{}
}

type BroadcastMessageRequest struct {
	Content string `json:"content"`
}

// @Summary      전체 공지 발송
// @Description  모든 활성 트랙에 BROADCAST 메시지를 보낸다.
// @Tags         E. Message
// @Security     AdminAuth
// @Accept       json
// @Produce      json
// @Param        request body BroadcastMessageRequest true "메시지 내용"
// @Success      201 {object} dto.Message
// @Router       /messages/broadcast [post]
func (h *MessageHandler) SendBroadcast(c echo.Context) error {
	return c.JSON(http.StatusCreated, dto.Message{})
}

// @Summary      발송된 공지사항 목록
// @Description  관리자가 보낸 BROADCAST 메시지들의 목록을 조회한다.
// @Tags         E. Message
// @Security     AdminAuth
// @Produce      json
// @Success      200 {array} dto.Message
// @Router       /messages/broadcast [get]
func (h *MessageHandler) ListBroadcasts(c echo.Context) error {
	return c.JSON(http.StatusOK, []dto.Message{})
}

// @Summary      공지사항 수신 확인 현황
// @Description  특정 공지사항에 대해 트랙들의 수신/읽음 상태를 확인한다.
// @Tags         E. Message
// @Security     AdminAuth
// @Produce      json
// @Param        id path string true "메시지 ID"
// @Success      200 {array} dto.BroadcastReceipt
// @Router       /messages/broadcast/{id}/receipts [get]
func (h *MessageHandler) GetBroadcastReceipts(c echo.Context) error {
	return c.JSON(http.StatusOK, []dto.BroadcastReceipt{})
}

// @Summary      공지사항 읽음 처리
// @Description  트랙 진행자가 공지사항을 확인(읽음) 처리한다.
// @Tags         E. Message
// @Security     TrackAuth
// @Produce      json
// @Param        id path string true "메시지 ID"
// @Success      204 "성공적으로 읽음 처리됨"
// @Router       /messages/broadcast/{id}/read [post]
func (h *MessageHandler) ReadBroadcast(c echo.Context) error {
	return c.NoContent(http.StatusNoContent)
}

type DirectMessageRequest struct {
	Content string `json:"content"`
}

// @Summary      다이렉트 메시지 발송
// @Description  관리자가 특정 트랙에, 또는 특정 트랙이 관리자에게 DIRECT 메시지를 발송한다.
// @Tags         E. Message
// @Security     AdminAuth
// @Accept       json
// @Produce      json
// @Param        trackId path string true "트랙 ID"
// @Param        request body DirectMessageRequest true "메시지 내용"
// @Success      201 {object} dto.Message
// @Router       /tracks/{trackId}/messages [post]
func (h *MessageHandler) SendDirect(c echo.Context) error {
	return c.JSON(http.StatusCreated, dto.Message{})
}

// @Summary      트랙별 메시지 내역 조회
// @Description  관리자 또는 트랙 진행자가 해당 트랙과 관련된 DIRECT 메시지 내역을 조회한다.
// @Tags         E. Message
// @Security     AdminAuth
// @Produce      json
// @Param        trackId path string true "트랙 ID"
// @Success      200 {array} dto.Message
// @Router       /tracks/{trackId}/messages [get]
func (h *MessageHandler) ListDirectMessages(c echo.Context) error {
	return c.JSON(http.StatusOK, []dto.Message{})
}
