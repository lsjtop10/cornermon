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
		return nil, withErrorContext("message.send_direct", "repository.get_track", err, map[string]any{"track_id": string(trackID)})
	}
	if track == nil || track.Status() != domain.TrackActive {
		var status string
		if track != nil {
			status = string(track.Status())
		}
		return nil, withErrorContext("message.send_direct", "validate_track", domain.ErrTrackNotActive, map[string]any{"track_id": string(trackID), "track_found": track != nil, "track_status": status})
	}
	msg := domain.NewMessageFromProps(domain.MessageProps{ID: domain.MessageID(s.uuidFn()), ChannelType: domain.MessageDirect, TrackID: trackID, SenderRole: senderRole, Content: content, SentAt: s.nowFn()})
	if err := s.tx.RunInTx(ctx, func(ctx context.Context) error {
		if err := s.tracks.IncrementUnreadCount(ctx, trackID, oppositeRole(senderRole)); err != nil {
			return withErrorContext("message.send_direct", "repository.increment_unread", err, map[string]any{"track_id": string(trackID)})
		}
		if err := s.messages.Save(ctx, msg); err != nil {
			return withErrorContext("message.send_direct", "repository.save_message", err, map[string]any{"message_id": string(msg.ID())})
		}
		return nil
	}); err != nil {
		s.recordAuditLog(ctx, string(trackID), trackDisplayLabel(ctx, s.tracks, s.corners, trackID, track), ActionMessageDirect, "", false, errorAuditMetadata(err, nil))
		return nil, err
	}

	corner, err := s.corners.Get(ctx, track.CornerID())
	if err != nil {
		return nil, withErrorContext("message.send_direct", "repository.get_corner", err, map[string]any{"corner_id": string(track.CornerID())})
	}
	if corner == nil {
		return nil, withErrorContext("message.send_direct", "validate_corner", domain.ErrCornerNotInItinerary, map[string]any{"corner_id": string(track.CornerID()), "corner_found": false})
	}

	s.recordAuditLog(ctx, string(trackID), trackDisplayLabel(ctx, s.tracks, s.corners, trackID, track), ActionMessageDirect, string(msg.ID()), true, map[string]any{"trackID": string(trackID)})
	_ = s.broadcaster.Broadcast(ctx, corner.CampID(), EventMessagesChanged, TrackScope(trackID))
	return msg, nil
}

func (s *MessageService) ListDirectMessages(ctx context.Context, trackID domain.TrackID, viewerRole domain.SenderRole, after domain.Optional[time.Time], markRead bool) ([]*domain.Message, error) {

	var messages []*domain.Message
	var readAt time.Time
	err := s.tx.RunInTx(ctx, func(ctx context.Context) error {
		var err error
		messages, err = s.messages.ListMessageByTrackAfter(ctx, trackID, after)
		if err != nil {
			return withErrorContext("message.list_direct", "repository.list_messages", err, map[string]any{"track_id": string(trackID)})
		}
		if !markRead {
			return nil
		}
		if err := s.tracks.ResetUnreadCount(ctx, trackID, viewerRole); err != nil {
			return withErrorContext("message.list_direct", "repository.reset_unread", err, map[string]any{"track_id": string(trackID)})
		}
		readAt = s.nowFn()
		if err := s.messages.MarkAllReadByRecipient(ctx, trackID, viewerRole, readAt); err != nil {
			return withErrorContext("message.list_direct", "repository.mark_read", err, map[string]any{"track_id": string(trackID)})
		}
		return nil
	})
	if err != nil {
		return nil, withErrorContext("message.list_direct", "transaction.run", err, map[string]any{"track_id": string(trackID), "mark_read": markRead})
	}
	if markRead {
		for _, message := range messages {
			if message.SenderRole() == oppositeRole(viewerRole) {
				_ = message.MarkRead(readAt)
			}
		}
	}
	return messages, nil
}

func (s *MessageService) GetUnreadCount(ctx context.Context, trackID domain.TrackID, viewerRole domain.SenderRole) (int, error) {

	track, err := s.tracks.Get(ctx, trackID)
	if err != nil {
		return 0, withErrorContext("message.get_unread", "repository.get_track", err, map[string]any{"track_id": string(trackID)})
	}
	if track == nil {
		return 0, withErrorContext("message.get_unread", "validate_track", domain.ErrTrackNotFound, map[string]any{"track_id": string(trackID), "track_found": false})
	}
	if viewerRole == domain.RoleAdmin {
		return track.UnreadByAdminCount(), nil
	}
	return track.UnreadByTrackCount(), nil
}

func oppositeRole(role domain.SenderRole) domain.SenderRole {
	if role == domain.RoleAdmin {
		return domain.RoleTrack
	}
	return domain.RoleAdmin
}

func (s *MessageService) recordAuditLog(ctx context.Context, actor, actorName string, action AuditAction, target string, success bool, metadata map[string]any) {
	if s.auditLogs != nil {
		_ = s.auditLogs.Save(ctx, domain.NewAuditLogFromProps(domain.AuditLogProps{
			ID:         domain.AuditLogID(s.uuidFn()),
			Actor:      actor,
			ActorName:  actorName,
			Action:     string(action),
			Target:     target,
			Success:    success,
			OccurredAt: s.nowFn(),
			Metadata:   metadata,
		}))
	}
}
