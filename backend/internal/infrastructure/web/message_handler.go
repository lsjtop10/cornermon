package web

import (
	"context"
	"errors"
	"net/http"
	"strconv"
	"time"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/usecase"

	"github.com/labstack/echo/v4"
)

type MessageUsecase interface {
	SendDirect(ctx context.Context, trackID domain.TrackID, content string, senderRole domain.SenderRole) (*domain.Message, error)
	ListDirectMessages(ctx context.Context, trackID domain.TrackID, viewerRole domain.SenderRole, after domain.Optional[time.Time], markRead bool) ([]*domain.Message, error)
	GetUnreadCount(ctx context.Context, trackID domain.TrackID, viewerRole domain.SenderRole) (int, error)
}

type AnnouncementUsecase interface {
	SendAnnouncement(ctx context.Context, campID domain.CampID, content string, actorAdminID domain.AdminID) (*domain.Announcement, error)
	ListNoticesByCamp(ctx context.Context, campID domain.CampID) ([]*domain.Announcement, error)
	GetAnnouncementReceipts(ctx context.Context, announcementID domain.AnnouncementID) ([]usecase.BroadcastReceiptDTO, error)
	MarkNoticeRead(ctx context.Context, facilitatorToken string, noticeID domain.AnnouncementID) error
}

type MessageHandler struct {
	message      MessageUsecase
	announcement AnnouncementUsecase
}

type MessageResponse struct {
	ID          string     `json:"id" format:"uuid"`
	ChannelType string     `json:"channelType" enums:"BROADCAST,DIRECT"`
	TrackID     *string    `json:"trackId,omitempty" format:"uuid"`
	SenderRole  string     `json:"senderRole" enums:"ADMIN,TRACK"`
	Content     string     `json:"content"`
	SentAt      time.Time  `json:"sentAt" format:"date-time"`
	IsRead      bool       `json:"isRead"`
	ReadAt      *time.Time `json:"readAt,omitempty" format:"date-time"`
} // @name MessageResponse

type BroadcastReceiptResponse struct {
	TrackID    string     `json:"trackId" format:"uuid"`
	TrackNo    int        `json:"trackNo"`
	CornerName string     `json:"cornerName"`
	IsRead     bool       `json:"isRead"`
	ReadAt     *time.Time `json:"readAt,omitempty" format:"date-time"`
} // @name BroadcastReceiptResponse

func NewMessageHandler(message MessageUsecase, announcement AnnouncementUsecase) *MessageHandler {
	return &MessageHandler{message: message, announcement: announcement}
}

type BroadcastMessageRequest struct {
	Content string `json:"content"`
} // @name BroadcastMessageRequest

// @Summary      전체 공지 발송
// @Description  모든 활성 트랙에 BROADCAST 메시지를 보낸다.
// @Tags         E. Message
// @Security     AdminAuth
// @Accept       json
// @Produce      json
// @Param        campId path string true "캠프 ID"
// @Param        request body BroadcastMessageRequest true "메시지 내용"
// @Success      201 {object} MessageResponse
// @Failure      400 {object} ErrorResponse
// @Router       /camps/{campId}/messages/broadcast [post]
func (h *MessageHandler) SendBroadcast(c echo.Context) error {
	session, ok := c.Get("adminSession").(*domain.AdminSession)
	if !ok {
		return c.JSON(http.StatusUnauthorized, ErrorResponse{Code: "UNAUTHORIZED", Message: "unauthorized"})
	}
	campID := domain.CampID(c.Param("campId"))
	if campID == "" {
		return c.JSON(http.StatusBadRequest, ErrorResponse{Code: "BAD_REQUEST", Message: "campId is required"})
	}

	var req BroadcastMessageRequest
	if err := c.Bind(&req); err != nil {
		return c.JSON(http.StatusBadRequest, ErrorResponse{Code: "BAD_REQUEST", Message: "invalid request"})
	}

	announcement, err := h.announcement.SendAnnouncement(c.Request().Context(), campID, req.Content, session.AdminID())
	if err != nil {
		return c.JSON(http.StatusInternalServerError, ErrorResponse{Code: "INTERNAL_SERVER_ERROR", Message: err.Error()})
	}

	return c.JSON(http.StatusCreated, MessageResponse{
		ID: string(announcement.ID()), ChannelType: string(domain.MessageBroadcast), SenderRole: string(announcement.SenderRole()), Content: announcement.Content(), SentAt: announcement.SentAt(),
	})
}

// @Summary      발송된 공지사항 목록
// @Description  관리자 또는 진행자가 캠프에 발송된 BROADCAST 메시지들의 목록을 조회한다.
// @Tags         E. Message
// @Security     AdminAuth
// @Security     TrackAuth
// @Produce      json
// @Param        campId path string true "캠프 ID"
// @Success      200 {array} MessageResponse
// @Failure      400 {object} ErrorResponse
// @Failure      401 {object} ErrorResponse
// @Router       /camps/{campId}/messages/broadcast [get]
func (h *MessageHandler) ListBroadcasts(c echo.Context) error {
	campID := domain.CampID(c.Param("campId"))
	if campID == "" {
		return c.JSON(http.StatusBadRequest, ErrorResponse{Code: "BAD_REQUEST", Message: "campId is required"})
	}

	announcements, err := h.announcement.ListNoticesByCamp(c.Request().Context(), campID)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, ErrorResponse{Code: "INTERNAL_SERVER_ERROR", Message: err.Error()})
	}

	res := make([]MessageResponse, len(announcements))
	for i, announcement := range announcements {
		res[i] = MessageResponse{
			ID: string(announcement.ID()), ChannelType: string(domain.MessageBroadcast), SenderRole: string(announcement.SenderRole()), Content: announcement.Content(), SentAt: announcement.SentAt(),
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
// @Success      200 {array} BroadcastReceiptResponse
// @Router       /messages/broadcast/{id}/receipts [get]
func (h *MessageHandler) GetBroadcastReceipts(c echo.Context) error {
	announcementID := domain.AnnouncementID(c.Param("id"))

	dtos, err := h.announcement.GetAnnouncementReceipts(c.Request().Context(), announcementID)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, ErrorResponse{Code: "INTERNAL_SERVER_ERROR", Message: err.Error()})
	}

	receipts := make([]BroadcastReceiptResponse, len(dtos))
	for i, dto := range dtos {
		br := BroadcastReceiptResponse{
			TrackID:    string(dto.TrackID),
			TrackNo:    dto.TrackNo,
			CornerName: dto.CornerName,
			IsRead:     dto.IsRead,
		}
		if val, ok := dto.ReadAt.Value(); ok {
			br.ReadAt = &val
		}
		receipts[i] = br
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
	announcementID := domain.AnnouncementID(c.Param("id"))

	token := c.Request().Header.Get("Authorization")
	if token != "" {
		// handle Bearer prefix if present
		if len(token) > 7 && token[:7] == "Bearer " {
			token = token[7:]
		}
	} else {
		token = c.Request().Header.Get("X-Device-Token")
	}

	err := h.announcement.MarkNoticeRead(c.Request().Context(), token, announcementID)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, ErrorResponse{Code: "INTERNAL_SERVER_ERROR", Message: err.Error()})
	}

	return c.NoContent(http.StatusNoContent)
}

type DirectMessageRequest struct {
	Content string `json:"content"`
} // @name DirectMessageRequest

// @Summary      다이렉트 메시지 발송
// @Description  관리자가 특정 트랙에, 또는 특정 트랙이 관리자에게 DIRECT 메시지를 발송한다.
// @Tags         E. Message
// @Security     AdminAuth
// @Accept       json
// @Produce      json
// @Param        trackId path string true "트랙 ID"
// @Param        request body DirectMessageRequest true "메시지 내용"
// @Success      201 {object} MessageResponse
// @Router       /tracks/{trackId}/messages [post]
func (h *MessageHandler) SendDirect(c echo.Context) error {
	trackID := domain.TrackID(c.Param("trackId"))

	var req DirectMessageRequest
	if err := c.Bind(&req); err != nil {
		return c.JSON(http.StatusBadRequest, ErrorResponse{Code: "BAD_REQUEST", Message: "invalid request"})
	}

	var senderRole domain.SenderRole
	if c.Get("adminSession") != nil {
		senderRole = domain.RoleAdmin
	} else if c.Get("facilitatorSession") != nil {
		if err := requireFacilitatorTrackScope(c, trackID); err != nil {
			return err
		}
		senderRole = domain.RoleTrack
	} else {
		return c.JSON(http.StatusUnauthorized, ErrorResponse{Code: "UNAUTHORIZED", Message: "unauthorized"})
	}

	msg, err := h.message.SendDirect(c.Request().Context(), trackID, req.Content, senderRole)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, ErrorResponse{Code: "INTERNAL_SERVER_ERROR", Message: err.Error()})
	}

	var tID *string
	if msg.TrackID() != "" {
		valStr := string(msg.TrackID())
		tID = &valStr
	}

	return c.JSON(http.StatusCreated, MessageResponse{
		ID:          string(msg.ID()),
		ChannelType: string(msg.ChannelType()),
		TrackID:     tID,
		SenderRole:  string(msg.SenderRole()),
		Content:     msg.Content(),
		SentAt:      msg.SentAt(),
	})
}

// @Summary      트랙별 메시지 내역 조회
// @Description  관리자 또는 자신의 트랙 진행자가 DIRECT 메시지 내역을 조회한다.
// @Tags         E. Message
// @Security     AdminAuth
// @Security     TrackAuth
// @Produce      json
// @Param        trackId path string true "트랙 ID"
// @Param        background query bool false "true면 상대측이 보낸 미확인 메시지를 읽음 처리"
// @Param        after query string false "RFC3339 UTC 이후 메시지만 반환"
// @Success      200 {array} MessageResponse
// @Failure      403 {object} ErrorResponse "세션 트랙과 요청 트랙 불일치"
// @Router       /tracks/{trackId}/messages [get]
func (h *MessageHandler) ListDirectMessages(c echo.Context) error {
	trackID := domain.TrackID(c.Param("trackId"))
	viewerRole := domain.RoleAdmin
	if _, ok := c.Get("facilitatorSession").(*domain.FacilitatorSession); ok {
		if err := requireFacilitatorTrackScope(c, trackID); err != nil {
			return err
		}
		viewerRole = domain.RoleTrack
	}
	background, err := parseBackground(c.QueryParam("background"))
	if err != nil {
		return c.JSON(http.StatusBadRequest, ErrorResponse{Code: "BAD_REQUEST", Message: err.Error()})
	}
	after, err := parseAfter(c.QueryParam("after"))
	if err != nil {
		return c.JSON(http.StatusBadRequest, ErrorResponse{Code: "BAD_REQUEST", Message: "after must be RFC3339"})
	}
	msgs, err := h.message.ListDirectMessages(c.Request().Context(), trackID, viewerRole, after, background)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, ErrorResponse{Code: "INTERNAL_SERVER_ERROR", Message: err.Error()})
	}

	return c.JSON(http.StatusOK, mapMessages(msgs))
}

type UnreadCountResponse struct {
	UnreadCount int `json:"unreadCount"`
} // @name UnreadCountResponse

// @Summary      트랙 미확인 다이렉트 메시지 개수 조회
// @Description  호출자(관리자 또는 진행자) 기준으로 상대측이 보낸 미확인 메시지 개수를 반환한다.
// @Tags         E. Message
// @Security     AdminAuth
// @Security     TrackAuth
// @Produce      json
// @Param        trackId path string true "트랙 ID"
// @Success      200 {object} UnreadCountResponse
// @Failure      403 {object} ErrorResponse "세션 트랙과 요청 트랙 불일치"
// @Router       /tracks/{trackId}/messages/unread-count [get]
func (h *MessageHandler) GetUnreadCount(c echo.Context) error {
	trackID := domain.TrackID(c.Param("trackId"))
	role := domain.RoleAdmin
	if _, ok := c.Get("facilitatorSession").(*domain.FacilitatorSession); ok {
		if err := requireFacilitatorTrackScope(c, trackID); err != nil {
			return err
		}
		role = domain.RoleTrack
	}
	count, err := h.message.GetUnreadCount(c.Request().Context(), trackID, role)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, ErrorResponse{Code: "INTERNAL_SERVER_ERROR", Message: err.Error()})
	}
	return c.JSON(http.StatusOK, UnreadCountResponse{UnreadCount: count})
}

func requireFacilitatorTrackScope(c echo.Context, trackID domain.TrackID) error {
	session, ok := c.Get("facilitatorSession").(*domain.FacilitatorSession)
	if !ok {
		return echo.NewHTTPError(http.StatusUnauthorized, "unauthorized")
	}
	if session.TrackID() != trackID {
		return domain.ErrTrackScopeForbidden
	}
	return nil
}

func parseBackground(value string) (bool, error) {
	if value == "" {
		return false, nil
	}
	parsed, err := strconv.ParseBool(value)
	if err != nil {
		return false, errors.New("background must be boolean")
	}
	return parsed, nil
}

func parseAfter(value string) (domain.Optional[time.Time], error) {
	if value == "" {
		return domain.None[time.Time](), nil
	}
	t, err := time.Parse(time.RFC3339, value)
	if err != nil {
		return domain.None[time.Time](), err
	}
	return domain.Some(t.UTC()), nil
}

func mapMessages(msgs []*domain.Message) []MessageResponse {
	res := make([]MessageResponse, len(msgs))
	for i, msg := range msgs {
		var trackID *string
		if msg.TrackID() != "" {
			value := string(msg.TrackID())
			trackID = &value
		}
		res[i] = MessageResponse{ID: string(msg.ID()), ChannelType: string(msg.ChannelType()), TrackID: trackID, SenderRole: string(msg.SenderRole()), Content: msg.Content(), SentAt: msg.SentAt(), IsRead: msg.ReadAt().IsSet()}
		if readAt, ok := msg.ReadAt().Value(); ok {
			res[i].ReadAt = &readAt
		}
	}
	return res
}
