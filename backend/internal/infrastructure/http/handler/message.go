package handler

import (
	"context"
	"net/http"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/infrastructure/http/dto"

	"github.com/labstack/echo/v4"
)

type MessageUsecase interface {
	SendBroadcast(ctx context.Context, campID domain.CampID, content string, actorAdminID domain.AdminID) (*domain.Message, error)
	ListBroadcastsByCamp(ctx context.Context, campID domain.CampID) ([]*domain.Message, error)
	GetBroadcastReceipts(ctx context.Context, messageID domain.MessageID) ([]dto.BroadcastReceipt, error)
	MarkBroadcastRead(ctx context.Context, facilitatorToken string, messageID domain.MessageID) error
	SendDirect(ctx context.Context, trackID domain.TrackID, content string, senderRole domain.SenderRole) (*domain.Message, error)
	ListDirectMessages(ctx context.Context, trackID domain.TrackID) ([]*domain.Message, error)
}

type MessageHandler struct {
	message MessageUsecase
}

func NewMessageHandler(message MessageUsecase) *MessageHandler {
	return &MessageHandler{
		message: message,
	}
}

type BroadcastMessageRequest struct {
	CampID  string `json:"campId"`
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
	session, ok := c.Get("adminSession").(*domain.AdminSession)
	if !ok {
		return c.JSON(http.StatusUnauthorized, dto.ErrorResponse{Code: "UNAUTHORIZED", Message: "unauthorized"})
	}

	var req BroadcastMessageRequest
	if err := c.Bind(&req); err != nil {
		return c.JSON(http.StatusBadRequest, dto.ErrorResponse{Code: "BAD_REQUEST", Message: "invalid request"})
	}

	msg, err := h.message.SendBroadcast(c.Request().Context(), domain.CampID(req.CampID), req.Content, session.AdminID)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Code: "INTERNAL_SERVER_ERROR", Message: err.Error()})
	}

	return c.JSON(http.StatusCreated, dto.Message{
		ID:          string(msg.ID),
		ChannelType: string(msg.ChannelType),
		SenderRole:  string(msg.SenderRole),
		Content:     msg.Content,
		SentAt:      msg.SentAt,
	})
}

// @Summary      발송된 공지사항 목록
// @Description  관리자가 보낸 BROADCAST 메시지들의 목록을 조회한다.
// @Tags         E. Message
// @Security     AdminAuth
// @Produce      json
// @Success      200 {array} dto.Message
// @Router       /messages/broadcast [get]
func (h *MessageHandler) ListBroadcasts(c echo.Context) error {
	campID := c.QueryParam("campId")
	if campID == "" {
		return c.JSON(http.StatusBadRequest, dto.ErrorResponse{Code: "BAD_REQUEST", Message: "missing campId"})
	}

	msgs, err := h.message.ListBroadcastsByCamp(c.Request().Context(), domain.CampID(campID))
	if err != nil {
		return c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Code: "INTERNAL_SERVER_ERROR", Message: err.Error()})
	}

	res := make([]dto.Message, len(msgs))
	for i, msg := range msgs {
		res[i] = dto.Message{
			ID:          string(msg.ID),
			ChannelType: string(msg.ChannelType),
			SenderRole:  string(msg.SenderRole),
			Content:     msg.Content,
			SentAt:      msg.SentAt,
		}
	}

	return c.JSON(http.StatusOK, res)
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
	msgID := domain.MessageID(c.Param("id"))

	receipts, err := h.message.GetBroadcastReceipts(c.Request().Context(), msgID)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Code: "INTERNAL_SERVER_ERROR", Message: err.Error()})
	}

	return c.JSON(http.StatusOK, receipts)
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
	msgID := domain.MessageID(c.Param("id"))

	token := c.Request().Header.Get("Authorization")
	if token != "" {
		// handle Bearer prefix if present
		if len(token) > 7 && token[:7] == "Bearer " {
			token = token[7:]
		}
	} else {
		token = c.Request().Header.Get("X-Device-Token")
	}

	err := h.message.MarkBroadcastRead(c.Request().Context(), token, msgID)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Code: "INTERNAL_SERVER_ERROR", Message: err.Error()})
	}

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
	trackID := domain.TrackID(c.Param("trackId"))

	var req DirectMessageRequest
	if err := c.Bind(&req); err != nil {
		return c.JSON(http.StatusBadRequest, dto.ErrorResponse{Code: "BAD_REQUEST", Message: "invalid request"})
	}

	var senderRole domain.SenderRole
	if c.Get("adminSession") != nil {
		senderRole = domain.RoleAdmin
	} else if c.Get("facilitatorSession") != nil {
		senderRole = domain.RoleTrack
	} else {
		return c.JSON(http.StatusUnauthorized, dto.ErrorResponse{Code: "UNAUTHORIZED", Message: "unauthorized"})
	}

	msg, err := h.message.SendDirect(c.Request().Context(), trackID, req.Content, senderRole)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Code: "INTERNAL_SERVER_ERROR", Message: err.Error()})
	}

	var tID *string
	if msg.TrackID.IsSet() {
		val, _ := msg.TrackID.Value()
		valStr := string(val)
		tID = &valStr
	}

	return c.JSON(http.StatusCreated, dto.Message{
		ID:          string(msg.ID),
		ChannelType: string(msg.ChannelType),
		TrackID:     tID,
		SenderRole:  string(msg.SenderRole),
		Content:     msg.Content,
		SentAt:      msg.SentAt,
	})
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
	trackID := domain.TrackID(c.Param("trackId"))

	msgs, err := h.message.ListDirectMessages(c.Request().Context(), trackID)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Code: "INTERNAL_SERVER_ERROR", Message: err.Error()})
	}

	res := make([]dto.Message, len(msgs))
	for i, msg := range msgs {
		var tID *string
		if msg.TrackID.IsSet() {
			val, _ := msg.TrackID.Value()
			valStr := string(val)
			tID = &valStr
		}
		res[i] = dto.Message{
			ID:          string(msg.ID),
			ChannelType: string(msg.ChannelType),
			TrackID:     tID,
			SenderRole:  string(msg.SenderRole),
			Content:     msg.Content,
			SentAt:      msg.SentAt,
		}
	}

	return c.JSON(http.StatusOK, res)
}
