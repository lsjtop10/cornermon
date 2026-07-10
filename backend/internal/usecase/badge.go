package usecase

import (
	"bytes"
	"context"
	"encoding/csv"
	"time"

	"cornermon/backend/internal/domain"

	"github.com/google/uuid"
)

type BadgeService struct {
	badges    BadgeRepository
	auditLogs AuditLogRepository
	tx        TxManager

	nowFn  func() time.Time
	uuidFn func() string
}

func NewBadgeService(
	badges BadgeRepository,
	auditLogs AuditLogRepository,
	tx TxManager,
) *BadgeService {
	return &BadgeService{
		badges:    badges,
		auditLogs: auditLogs,
		tx:        tx,
		nowFn:     time.Now,
		uuidFn:    uuid.NewString,
	}
}

// IssueInitialBadges
func (s *BadgeService) IssueInitialBadges(ctx context.Context, count int) ([]*domain.Badge, error) {
	var badges []*domain.Badge
	for i := 0; i < count; i++ {
		uid := s.uuidFn()
		badges = append(badges, &domain.Badge{
			ID:              domain.BadgeID(uid),
			ShortID:         uid[:8],
			QRPayload:       "qr-" + uid[:8],
			Status:          domain.BadgeUnassigned,
			AssignedGroupID: domain.None[domain.GroupID](),
		})
	}

	err := s.tx.RunInTx(ctx, func(ctx context.Context) error {
		return s.badges.SaveBulk(ctx, badges)
	})

	if err != nil {
		s.recordAuditLog(ctx, "admin", "BADGE_BULK_GENERATE", "", false, map[string]any{"error": err.Error()})
		return nil, err
	}

	s.recordAuditLog(ctx, "admin", "BADGE_BULK_GENERATE", "", true, map[string]any{"count": count})

	return badges, nil
}

// ListBadges
func (s *BadgeService) ListBadges(ctx context.Context) ([]*domain.Badge, error) {
	return s.badges.ListAll(ctx)
}

// ExportBadges returns CSV content
func (s *BadgeService) ExportBadges(ctx context.Context) ([]byte, error) {
	badges, err := s.badges.ListAll(ctx)
	if err != nil {
		return nil, err
	}

	var buf bytes.Buffer
	writer := csv.NewWriter(&buf)
	
	_ = writer.Write([]string{"BadgeID", "ShortID", "QRPayload", "Status", "AssignedGroupID"})
	for _, b := range badges {
		var groupIDStr string
		if groupID, ok := b.AssignedGroupID.Value(); ok {
			groupIDStr = string(groupID)
		}
		_ = writer.Write([]string{
			string(b.ID),
			b.ShortID,
			b.QRPayload,
			string(b.Status),
			groupIDStr,
		})
	}
	writer.Flush()

	s.recordAuditLog(ctx, "admin", "BADGE_EXPORT", "", true, nil)

	return buf.Bytes(), nil
}

func (s *BadgeService) recordAuditLog(ctx context.Context, actor, action, target string, success bool, metadata map[string]any) {
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
