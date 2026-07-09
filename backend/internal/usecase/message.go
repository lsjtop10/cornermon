package usecase

import (
	"context"
	"time"

	"cornermon/backend/internal/domain"

	"github.com/google/uuid"
)

type MessageService struct {
	camps       CampRepository
	tracks      TrackRepository
	messages    MessageRepository
	receipts    BroadcastReceiptRepository
	sessions    FacilitatorSessionRepository
	auditLogs   AuditLogRepository
	broadcaster Broadcaster
	tx          TxManager

	nowFn  func() time.Time
	uuidFn func() string
}

func NewMessageService(
	camps CampRepository,
	tracks TrackRepository,
	messages MessageRepository,
	receipts BroadcastReceiptRepository,
	sessions FacilitatorSessionRepository,
	auditLogs AuditLogRepository,
	broadcaster Broadcaster,
	tx TxManager,
) *MessageService {
	return &MessageService{
		camps:       camps,
		tracks:      tracks,
		messages:    messages,
		receipts:    receipts,
		sessions:    sessions,
		auditLogs:   auditLogs,
		broadcaster: broadcaster,
		tx:          tx,
		nowFn:       time.Now,
		uuidFn:      uuid.NewString,
	}
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
		TrackID:     domain.None[domain.TrackID](),
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
	_ = s.broadcaster.BroadcastSnapshot(ctx, campID)

	return msg, nil
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
		TrackID:     domain.Some(trackID),
		SenderRole:  senderRole,
		Content:     content,
		SentAt:      now,
	}

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
	// Mock/기본 구조상 트랙 -> 코너 -> 캠프 정보를 통해 캠프 ID를 획득할 수 있도록 브로드캐스트한다.
	// 이 기능은 테스트 시 캠프 ID 정보가 필요 없으면 단순 로그로 확인한다.
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
