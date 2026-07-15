package usecase

import (
	"context"
	"time"

	"cornermon/backend/internal/domain"
	"github.com/google/uuid"
)

// MessageService owns only the administrator/facilitator thread for one track.
type MessageService struct {
	corners     CornerRepository
	tracks      TrackRepository
	messages    MessageRepository
	auditLogs   AuditLogRepository
	broadcaster Broadcaster
	tx          TxManager
	nowFn       func() time.Time
	uuidFn      func() string
}

func NewMessageService(corners CornerRepository, tracks TrackRepository, messages MessageRepository, auditLogs AuditLogRepository, broadcaster Broadcaster, tx TxManager) *MessageService {
	return &MessageService{corners: corners, tracks: tracks, messages: messages, auditLogs: auditLogs, broadcaster: broadcaster, tx: tx, nowFn: func() time.Time { return time.Now().UTC() }, uuidFn: uuid.NewString}
}

func (s *MessageService) SendDirect(ctx context.Context, trackID domain.TrackID, content string, senderRole domain.SenderRole) (*domain.Message, error) {
	track, err := s.tracks.Get(ctx, trackID)
	if err != nil {
		return nil, err
	}
	if track == nil || track.Status != domain.TrackActive {
		return nil, domain.ErrTrackNotActive
	}
	msg := &domain.Message{ID: domain.MessageID(s.uuidFn()), ChannelType: domain.MessageDirect, TrackID: trackID, SenderRole: senderRole, Content: content, SentAt: s.nowFn()}
	if err := s.tx.RunInTx(ctx, func(ctx context.Context) error { return s.messages.Save(ctx, msg) }); err != nil {
		s.recordAuditLog(ctx, string(trackID), "MESSAGE_DIRECT", "", false, map[string]any{"error": err.Error()})
		return nil, err
	}

	corner, err := s.corners.Get(ctx, track.CornerID)
	if err != nil {
		return nil, err
	}
	if corner == nil {
		return nil, domain.ErrCornerNotInItinerary
	}

	s.recordAuditLog(ctx, string(trackID), "MESSAGE_DIRECT", string(msg.ID), true, map[string]any{"trackID": string(trackID)})
	_ = s.broadcaster.Broadcast(ctx, corner.CampID, EventMessagesChanged, TrackScope(trackID))
	return msg, nil
}

func (s *MessageService) ListDirectMessages(ctx context.Context, trackID domain.TrackID) ([]*domain.Message, error) {
	return s.messages.ListMessageByTrack(ctx, trackID)
}

func (s *MessageService) recordAuditLog(ctx context.Context, actor, action, target string, success bool, metadata map[string]any) {
	if s.auditLogs != nil {
		_ = s.auditLogs.Save(ctx, domain.NewAuditLog(domain.AuditLogID(s.uuidFn()), actor, action, target, success, s.nowFn(), metadata))
	}
}
