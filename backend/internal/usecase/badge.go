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
	admins    AdminRepository
	auditLogs AuditLogRepository
	tx        TxManager

	nowFn  func() time.Time
	uuidFn func() string
}

func NewBadgeService(
	badges BadgeRepository,
	groups GroupRepository,
	admins AdminRepository,
	auditLogs AuditLogRepository,
	tx TxManager,
) *BadgeService {
	return &BadgeService{
		badges:    badges,
		groups:    groups,
		admins:    admins,
		auditLogs: auditLogs,
		tx:        tx,
		nowFn:     func() time.Time { return time.Now().UTC() },
		uuidFn:    uuid.NewString,
	}
}

// IssueInitialBadges
func (s *BadgeService) IssueInitialBadges(ctx context.Context, count int, actorAdminID domain.AdminID) ([]*domain.Badge, error) {

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
		if err := s.badges.SaveBulk(ctx, badges); err != nil {
			return withErrorContext("badge.issue_initial", "repository.save_bulk", err, map[string]any{"count": count})
		}
		return nil
	})

	if err != nil {
		s.recordAuditLog(ctx, domain.None[domain.CampID](), string(actorAdminID), adminActorLabel(ctx, s.admins, actorAdminID, nil), ActionBadgeBulkGenerate, "", "", false, errorAuditMetadata(err, nil))
		return nil, err
	}

	s.recordAuditLog(ctx, domain.None[domain.CampID](), string(actorAdminID), adminActorLabel(ctx, s.admins, actorAdminID, nil), ActionBadgeBulkGenerate, "", "", true, map[string]any{"count": count})

	return badges, nil
}

// ListBadges
func (s *BadgeService) ListBadges(ctx context.Context) ([]*domain.Badge, error) {
	return s.badges.ListAll(ctx)
}

// ExportBadges returns unassigned badges for client printing
func (s *BadgeService) ExportBadges(ctx context.Context, actorAdminID domain.AdminID) ([]*domain.Badge, error) {

	badges, err := s.badges.ListAll(ctx)
	if err != nil {
		return nil, withErrorContext("badge.export", "repository.list_badges", err, nil)
	}

	var unassigned []*domain.Badge
	for _, b := range badges {
		if b.Status() == domain.BadgeUnassigned {
			unassigned = append(unassigned, b)
		}
	}

	s.recordAuditLog(ctx, domain.None[domain.CampID](), string(actorAdminID), adminActorLabel(ctx, s.admins, actorAdminID, nil), ActionBadgeExport, "", "", true, nil)

	return unassigned, nil
}

// AssignBadge
func (s *BadgeService) AssignBadge(ctx context.Context, badgeID domain.BadgeID, groupID domain.GroupID, actorAdminID domain.AdminID) (*domain.Badge, error) {
	return s.assignBadgeInternal(ctx, groupID, actorAdminID, func(ctx context.Context) (*domain.Badge, error) {
		return s.badges.Get(ctx, badgeID)
	})
}

// ScanAssignBadge
func (s *BadgeService) ScanAssignBadge(ctx context.Context, qrPayload string, groupID domain.GroupID, actorAdminID domain.AdminID) (*domain.Badge, error) {
	return s.assignBadgeInternal(ctx, groupID, actorAdminID, func(ctx context.Context) (*domain.Badge, error) {
		return s.badges.GetByQRPayload(ctx, qrPayload)
	})
}

func (s *BadgeService) assignBadgeInternal(
	ctx context.Context,
	groupID domain.GroupID,
	actorAdminID domain.AdminID,
	getBadgeFn func(ctx context.Context) (*domain.Badge, error),
) (*domain.Badge, error) {
	var targetBadge *domain.Badge
	groupCampID := domain.None[domain.CampID]()
	var groupName string

	err := s.tx.RunInTx(ctx, func(ctx context.Context) error {
		group, err := s.groups.Get(ctx, groupID)
		if err != nil {
			return withErrorContext("badge.assign", "repository.get_group", err, map[string]any{"group_id": string(groupID)})
		}
		if group == nil {
			return withErrorContext("badge.assign", "validate_group", domain.ErrCornerNotInItinerary, map[string]any{"group_id": string(groupID), "group_found": false})
		}
		groupCampID = domain.Some(group.CampID())
		groupName = group.Name()

		targetBadge, err = getBadgeFn(ctx)
		if err != nil {
			return withErrorContext("badge.assign", "repository.get_badge", err, map[string]any{"group_id": string(groupID)})
		}
		if targetBadge == nil {
			return withErrorContext("badge.assign", "validate_badge", domain.ErrBadgeNotAssigned, map[string]any{"group_id": string(groupID), "badge_found": false})
		}

		if targetBadge.Status() == domain.BadgeAssigned {
			return withErrorContext("badge.assign", "validate_badge_status", domain.ErrBadgeAlreadyAssigned, map[string]any{"badge_id": string(targetBadge.ID()), "badge_status": string(targetBadge.Status())})
		}

		// Release old badge if group already has one
		if string(group.BadgeID()) != "" && string(group.BadgeID()) != string(targetBadge.ID()) {
			oldBadge, err := s.badges.Get(ctx, group.BadgeID())
			if err != nil {
				return withErrorContext("badge.assign", "repository.get_old_badge", err, map[string]any{"badge_id": string(group.BadgeID())})
			}
			if oldBadge != nil {
				_ = oldBadge.Release()
				if err := s.badges.Save(ctx, oldBadge); err != nil {
					return withErrorContext("badge.assign", "repository.save_old_badge", err, map[string]any{"badge_id": string(oldBadge.ID())})
				}
			}
		}

		if err := targetBadge.AssignTo(groupID); err != nil {
			return withErrorContext("badge.assign", "domain.assign_badge", err, map[string]any{"badge_id": string(targetBadge.ID()), "group_id": string(groupID)})
		}
		group.SetBadgeID(targetBadge.ID())

		if err := s.badges.Save(ctx, targetBadge); err != nil {
			return withErrorContext("badge.assign", "repository.save_badge", err, map[string]any{"badge_id": string(targetBadge.ID())})
		}
		if err := s.groups.Save(ctx, group); err != nil {
			return withErrorContext("badge.assign", "repository.save_group", err, map[string]any{"group_id": string(group.ID())})
		}

		return nil
	})

	if err != nil {
		s.recordAuditLog(ctx, groupCampID, string(actorAdminID), adminActorLabel(ctx, s.admins, actorAdminID, nil), ActionBadgeAssign, string(groupID), groupName, false, errorAuditMetadata(err, nil))
		return nil, err
	}

	s.recordAuditLog(ctx, groupCampID, string(actorAdminID), adminActorLabel(ctx, s.admins, actorAdminID, nil), ActionBadgeAssign, string(targetBadge.ID()), targetBadge.ShortID(), true, map[string]any{"groupID": string(groupID)})

	return targetBadge, nil
}

func (s *BadgeService) recordAuditLog(ctx context.Context, campID domain.Optional[domain.CampID], actor, actorName string, action AuditAction, target, targetName string, success bool, metadata map[string]any) {
	log := domain.NewAuditLogFromProps(domain.AuditLogProps{
		ID:         domain.AuditLogID(s.uuidFn()),
		CampID:     campID,
		Actor:      actor,
		ActorName:  actorName,
		Action:     string(action),
		Target:     target,
		TargetName: targetName,
		Success:    success,
		OccurredAt: s.nowFn(),
		Metadata:   filterErrorAttributes(metadata),
	})
	_ = s.auditLogs.Save(ctx, log)
}
