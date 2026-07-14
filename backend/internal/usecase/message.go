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

// SendBroadcast - UC-21
func (s *MessageService) SendBroadcast(
	ctx context.Context,
	campID domain.CampID,
	content string,
	actorAdminID domain.AdminID,
) (*domain.Message, error) {
	now := s.nowFn()
	camp, err := s.camps.Get(ctx, campID)
	if err != nil {
		return nil, err
	}
	if camp == nil || !camp.IsActive() {
		return nil, domain.ErrCampInvalidTransition
	}

	msgID := domain.MessageID(s.uuidFn())
	msg := &domain.Message{
		ID:          msgID,
		ChannelType: domain.MessageBroadcast,
		CampID:      domain.Some(campID),
		SenderRole:  domain.RoleAdmin,
		Content:     content,
		SentAt:      now,
	}

	activeTracks, err := s.tracks.ListActiveByCamp(ctx, campID)
	if err != nil {
		return nil, err
	}

	err = s.tx.RunInTx(ctx, func(ctx context.Context) error {
		if err := s.messages.Save(ctx, msg); err != nil {
			return err
		}

		for _, track := range activeTracks {
			receipt := &domain.BroadcastReceipt{
				MessageID: msg.ID,
				TrackID:   track.ID,
				ReadAt:    domain.None[time.Time](),
			}
			if err := s.receipts.Save(ctx, receipt); err != nil {
				return err
			}
		}

		return nil
	})

	if err != nil {
		s.recordAuditLog(ctx, string(actorAdminID), "MESSAGE_BROADCAST", "", false, map[string]any{"error": err.Error()})
		return nil, err
	}

	s.recordAuditLog(ctx, string(actorAdminID), "MESSAGE_BROADCAST", string(msg.ID), true, map[string]any{"campID": string(campID)})
	_ = s.broadcaster.Broadcast(ctx, campID, EventMessagesChanged, CampScope())

	return msg, nil
}

func (s *MessageService) SendDirect(ctx context.Context, trackID domain.TrackID, content string, senderRole domain.SenderRole) (*domain.Message, error) {
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

// MarkBroadcastRead - UC-23
func (s *MessageService) MarkBroadcastRead(
	ctx context.Context,
	facilitatorToken string,
	messageID domain.MessageID,
) error {
	now := s.nowFn()
	tokenHash := hashSHA256(facilitatorToken)

	session, err := s.sessions.GetByTokenHash(ctx, tokenHash)
	if err != nil {
		return err
	}
	if session == nil || !session.IsActive() {
		return domain.ErrSessionRevoked
	}

	receipt, err := s.receipts.GetByMessageAndTrack(ctx, messageID, session.TrackID)
	if err != nil {
		return err
	}
	if receipt == nil {
		return nil // 혹은 에러 반환. 여기서는 그냥 성공 처리
	}

	if err := receipt.MarkRead(now); err != nil {
		return err
	}

	return s.receipts.Save(ctx, receipt)
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
	if r, ok := s.messages.(LegacyMessageReader); ok {
		return r.ListBroadcastsByCamp(ctx, campID)
	}
	return nil, nil
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

func (s *MessageService) recordAuditLog(ctx context.Context, actor, action, target string, success bool, metadata map[string]any) {
	if s.auditLogs != nil {
		_ = s.auditLogs.Save(ctx, domain.NewAuditLog(domain.AuditLogID(s.uuidFn()), actor, action, target, success, s.nowFn(), metadata))
	}
}
