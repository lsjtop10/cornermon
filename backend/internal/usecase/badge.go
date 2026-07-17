package usecase

import (
	"context"
	"time"

	"cornermon/backend/internal/domain"

	"github.com/google/uuid"
)

type BadgeService struct {
	badges    BadgeRepository
	groups    GroupRepository
	auditLogs AuditLogRepository
	tx        TxManager

	nowFn  func() time.Time
	uuidFn func() string
}

func NewBadgeService(
	badges BadgeRepository,
	groups GroupRepository,
	auditLogs AuditLogRepository,
	tx TxManager,
) *BadgeService {
	return &BadgeService{
		badges:    badges,
		groups:    groups,
		auditLogs: auditLogs,
		tx:        tx,
		nowFn:     func() time.Time { return time.Now().UTC() },
		uuidFn:    uuid.NewString,
	}
}

// IssueInitialBadges
func (s *BadgeService) IssueInitialBadges(ctx context.Context, count int) ([]*domain.Badge, error) {
	var badges []*domain.Badge
	for i := 0; i < count; i++ {
		uid := s.uuidFn()
		badges = append(badges, domain.NewBadgeFromProps(domain.BadgeProps{
			ID:              domain.BadgeID(uid),
			ShortID:         uid[:8],
			QRPayload:       "qr-" + uid[:8],
			Status:          domain.BadgeUnassigned,
			AssignedGroupID: domain.None[domain.GroupID](),
		}))
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

// ExportBadges returns unassigned badges for client printing
func (s *BadgeService) ExportBadges(ctx context.Context) ([]*domain.Badge, error) {
	badges, err := s.badges.ListAll(ctx)
	if err != nil {
		return nil, err
	}

	var unassigned []*domain.Badge
	for _, b := range badges {
		if b.Status() == domain.BadgeUnassigned {
			unassigned = append(unassigned, b)
		}
	}

	s.recordAuditLog(ctx, "admin", "BADGE_EXPORT", "", true, nil)

	return unassigned, nil
}

// AssignBadge
func (s *BadgeService) AssignBadge(ctx context.Context, badgeID domain.BadgeID, groupID domain.GroupID) (*domain.Badge, error) {
	return s.assignBadgeInternal(ctx, groupID, func(ctx context.Context) (*domain.Badge, error) {
		return s.badges.Get(ctx, badgeID)
	})
}

// ScanAssignBadge
func (s *BadgeService) ScanAssignBadge(ctx context.Context, qrPayload string, groupID domain.GroupID) (*domain.Badge, error) {
	return s.assignBadgeInternal(ctx, groupID, func(ctx context.Context) (*domain.Badge, error) {
		return s.badges.GetByQRPayload(ctx, qrPayload)
	})
}

func (s *BadgeService) assignBadgeInternal(
	ctx context.Context,
	groupID domain.GroupID,
	getBadgeFn func(ctx context.Context) (*domain.Badge, error),
) (*domain.Badge, error) {
	var targetBadge *domain.Badge

	err := s.tx.RunInTx(ctx, func(ctx context.Context) error {
		group, err := s.groups.Get(ctx, groupID)
		if err != nil {
			return err
		}
		if group == nil {
			return domain.ErrCornerNotInItinerary // map to not found group
		}

		targetBadge, err = getBadgeFn(ctx)
		if err != nil {
			return err
		}
		if targetBadge == nil {
			return domain.ErrBadgeNotAssigned // map to not found
		}

		if targetBadge.Status() == domain.BadgeAssigned {
			return domain.ErrBadgeAlreadyAssigned
		}

		// Release old badge if group already has one
		if string(group.BadgeID()) != "" && string(group.BadgeID()) != string(targetBadge.ID()) {
			oldBadge, err := s.badges.Get(ctx, group.BadgeID())
			if err != nil {
				return err
			}
			if oldBadge != nil {
				_ = oldBadge.Release()
				if err := s.badges.Save(ctx, oldBadge); err != nil {
					return err
				}
			}
		}

		if err := targetBadge.AssignTo(groupID); err != nil {
			return err
		}
		group.SetBadgeID(targetBadge.ID())

		if err := s.badges.Save(ctx, targetBadge); err != nil {
			return err
		}
		if err := s.groups.Save(ctx, group); err != nil {
			return err
		}

		return nil
	})

	if err != nil {
		s.recordAuditLog(ctx, "admin", "BADGE_ASSIGN", string(groupID), false, map[string]any{"error": err.Error()})
		return nil, err
	}

	s.recordAuditLog(ctx, "admin", "BADGE_ASSIGN", string(targetBadge.ID()), true, map[string]any{"groupID": string(groupID)})

	return targetBadge, nil
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
