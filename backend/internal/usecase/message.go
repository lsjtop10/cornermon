package usecase

import (
	"context"
	"time"

	"cornermon/backend/internal/domain"

	"github.com/google/uuid"
)

type MessageService struct {
	announcements *AnnouncementService
	camps         CampRepository
	corners       CornerRepository
	tracks        TrackRepository
	messages      MessageRepository
	receipts      BroadcastReceiptRepository
	sessions      FacilitatorSessionRepository
	auditLogs     AuditLogRepository
	broadcaster   Broadcaster
	tx            TxManager

	nowFn  func() time.Time
	uuidFn func() string
}

func NewMessageService(
	camps CampRepository,
	corners CornerRepository,
	tracks TrackRepository,
	messages MessageRepository,
	receipts BroadcastReceiptRepository,
	sessions FacilitatorSessionRepository,
	auditLogs AuditLogRepository,
	broadcaster Broadcaster,
	tx TxManager,
) *MessageService {
	s := &MessageService{
		camps:       camps,
		corners:     corners,
		tracks:      tracks,
		messages:    messages,
		receipts:    receipts,
		sessions:    sessions,
		auditLogs:   auditLogs,
		broadcaster: broadcaster,
		tx:          tx,
		nowFn:       func() time.Time { return time.Now().UTC() },
		uuidFn:      uuid.NewString,
	}
	s.announcements = NewAnnouncementService(legacyAnnouncementRepository{repo: messages}, legacyAnnouncementReceiptRepository{repo: receipts}, camps, tracks, sessions, tx, auditLogs, broadcaster)
	return s
}

// SendBroadcast - UC-21
func (s *MessageService) SendBroadcast(
	ctx context.Context,
	campID domain.CampID,
	content string,
	actorAdminID domain.AdminID,
) (*domain.Message, error) {
	if s.announcements == nil {
		s.announcements = NewAnnouncementService(legacyAnnouncementRepository{repo: s.messages}, legacyAnnouncementReceiptRepository{repo: s.receipts}, s.camps, s.tracks, s.sessions, s.tx, s.auditLogs, s.broadcaster)
	}
	s.announcements.uuidFn = s.uuidFn
	a, err := s.announcements.SendAnnouncement(ctx, campID, content, actorAdminID)
	if err != nil {
		return nil, err
	}
	return announcementAsMessage(a), nil
}

// SendDirect - UC-22
func (s *MessageService) SendDirect(
	ctx context.Context,
	trackID domain.TrackID,
	content string,
	senderRole domain.SenderRole,
) (*domain.Message, error) {
	now := s.nowFn()
	track, err := s.tracks.Get(ctx, trackID)
	if err != nil {
		return nil, err
	}
	if track == nil || track.Status != domain.TrackActive {
		return nil, domain.ErrTrackNotActive
	}

	msgID := domain.MessageID(s.uuidFn())
	msg := &domain.Message{
		ID:          msgID,
		ChannelType: domain.MessageDirect,
		CampID:      domain.None[domain.CampID](),
		SenderRole:  senderRole,
		Content:     content,
		SentAt:      now,
	}
	msg.TrackID = trackID

	err = s.tx.RunInTx(ctx, func(ctx context.Context) error {
		return s.messages.Save(ctx, msg)
	})

	actor := "system"
	if senderRole == domain.RoleTrack {
		actor = string(trackID)
	}

	if err != nil {
		s.recordAuditLog(ctx, actor, "MESSAGE_DIRECT", "", false, map[string]any{"error": err.Error()})
		return nil, err
	}

	s.recordAuditLog(ctx, actor, "MESSAGE_DIRECT", string(msg.ID), true, map[string]any{"trackID": string(trackID)})

	// SSE 푸시를 위해 해당 트랙 소속 코너/캠프 조회
	corner, err := s.corners.Get(ctx, track.CornerID)
	if err != nil {
		return nil, err
	}
	if corner == nil {
		return nil, domain.ErrCornerNotInItinerary
	}

	_ = s.broadcaster.Broadcast(ctx, corner.CampID, EventMessagesChanged, TrackScope(trackID))

	return msg, nil
}

// MarkBroadcastRead - UC-23
func (s *MessageService) MarkBroadcastRead(
	ctx context.Context,
	facilitatorToken string,
	messageID domain.MessageID,
) error {
	if s.announcements == nil {
		s.announcements = NewAnnouncementService(legacyAnnouncementRepository{repo: s.messages}, legacyAnnouncementReceiptRepository{repo: s.receipts}, s.camps, s.tracks, s.sessions, s.tx, s.auditLogs, s.broadcaster)
	}
	return s.announcements.MarkNoticeRead(ctx, facilitatorToken, domain.AnnouncementID(messageID))
}

func (s *MessageService) recordAuditLog(ctx context.Context, actor, action, target string, success bool, metadata map[string]any) {
	log := domain.NewAuditLog(
		domain.AuditLogID(s.uuidFn()),
		actor,
		action,
		target,
		success,
		s.nowFn(),
		metadata,
	)
	_ = s.auditLogs.Save(ctx, log)
}

func (s *MessageService) ListBroadcastsByCamp(ctx context.Context, campID domain.CampID) ([]*domain.Message, error) {
	if s.announcements == nil {
		if r, ok := s.messages.(LegacyMessageReader); ok {
			return r.ListBroadcastsByCamp(ctx, campID)
		}
		return nil, nil
	}
	rows, err := s.announcements.ListNoticesByCamp(ctx, campID)
	if err != nil {
		return nil, err
	}
	out := make([]*domain.Message, len(rows))
	for i, a := range rows {
		out[i] = announcementAsMessage(a)
	}
	return out, nil
}

func (s *MessageService) ListDirectMessages(ctx context.Context, trackID domain.TrackID) ([]*domain.Message, error) {
	if r, ok := s.messages.(LegacyMessageReader); ok {
		return r.ListDirectByTrack(ctx, trackID)
	}
	if r, ok := s.messages.(MessageReader); ok {
		return r.ListMessageByTrack(ctx, trackID)
	}
	return nil, nil
}

func (s *MessageService) GetBroadcastReceipts(ctx context.Context, messageID domain.MessageID) ([]BroadcastReceiptDTO, error) {
	receipts, err := s.receipts.ListByMessage(ctx, messageID)
	if err != nil {
		return nil, err
	}

	dtos := make([]BroadcastReceiptDTO, len(receipts))
	for i, r := range receipts {
		track, err := s.tracks.Get(ctx, r.TrackID)
		if err != nil {
			return nil, err
		}

		var trackNo int
		var cornerName string
		if track != nil {
			trackNo = track.TrackNo

			corner, err := s.corners.Get(ctx, track.CornerID)
			if err != nil {
				return nil, err
			}
			if corner != nil {
				cornerName = corner.Name
			}
		}

		dtos[i] = BroadcastReceiptDTO{
			TrackID:    r.TrackID,
			TrackNo:    trackNo,
			CornerName: cornerName,
			IsRead:     r.ReadAt.IsSet(),
			ReadAt:     r.ReadAt,
		}
	}

	return dtos, nil
}
