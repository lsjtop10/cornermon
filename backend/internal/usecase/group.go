package usecase

import (
	"context"
	"time"

	"cornermon/backend/internal/domain"

	"github.com/google/uuid"
)

type GroupService struct {
	camps     CampRepository
	corners   CornerRepository
	tracks    TrackRepository
	groups    GroupRepository
	badges    BadgeRepository
	visits    VisitRepository
	auditLogs AuditLogRepository
	tx        TxManager

	nowFn  func() time.Time
	uuidFn func() string
}

func NewGroupService(
	camps CampRepository,
	corners CornerRepository,
	tracks TrackRepository,
	groups GroupRepository,
	badges BadgeRepository,
	visits VisitRepository,
	auditLogs AuditLogRepository,
	tx TxManager,
) *GroupService {
	return &GroupService{
		camps:     camps,
		corners:   corners,
		tracks:    tracks,
		groups:    groups,
		badges:    badges,
		visits:    visits,
		auditLogs: auditLogs,
		tx:        tx,
		nowFn:     func() time.Time { return time.Now().UTC() },
		uuidFn:    uuid.NewString,
	}
}

// AssignBadge creates a group and assigns the badge identified by its ID to it.
// The group belongs to the current registration camp (PENDING or ACTIVE).
func (s *GroupService) AssignBadge(
	ctx context.Context,
	badgeID domain.BadgeID,
	groupName string,
) (*domain.Group, error) {

	badge, err := s.badges.Get(ctx, badgeID)
	if err != nil {
		return nil, withErrorContext("group.assign_badge", "repository.get_badge", err, map[string]any{"badge_id": string(badgeID)})
	}
	if badge == nil {
		return nil, withErrorContext("group.assign_badge", "validate_badge", domain.ErrBadgeNotAssigned, map[string]any{"badge_id": string(badgeID), "badge_found": false})
	}

	return s.registerBadge(ctx, badge, groupName)
}

// ScanAssignBadge creates a group and assigns the badge identified by its QR payload.
// The group belongs to the current registration camp (PENDING or ACTIVE).
func (s *GroupService) ScanAssignBadge(
	ctx context.Context,
	qrPayload string,
	groupName string,
) (*domain.Group, error) {

	badge, err := s.badges.GetByQRPayload(ctx, qrPayload)
	if err != nil {
		return nil, withErrorContext("group.scan_assign_badge", "repository.get_badge", err, nil)
	}
	if badge == nil {
		return nil, withErrorContext("group.scan_assign_badge", "validate_badge", domain.ErrBadgeNotAssigned, map[string]any{"badge_found": false})
	}

	return s.registerBadge(ctx, badge, groupName)
}

func (s *GroupService) registerBadge(ctx context.Context, badge *domain.Badge, groupName string) (*domain.Group, error) {

	camp, err := s.registrationCamp(ctx)
	if err != nil {
		return nil, withErrorContext("group.register_badge", "usecase.registration_camp", err, nil)
	}
	if camp == nil {
		return nil, withErrorContext("group.register_badge", "validate_camp", domain.ErrCampNotFound, map[string]any{"camp_found": false})
	}
	if badge.Status() == domain.BadgeAssigned {
		return nil, withErrorContext("group.register_badge", "validate_badge_status", domain.ErrBadgeAlreadyAssigned, map[string]any{"badge_id": string(badge.ID()), "badge_status": string(badge.Status())})
	}

	campID := camp.ID()
	corners, err := s.corners.ListByCamp(ctx, campID)
	if err != nil {
		return nil, withErrorContext("group.register_badge", "repository.list_corners", err, map[string]any{"camp_id": string(campID)})
	}

	var itinerary []domain.CornerProgress
	for _, c := range corners {
		itinerary = append(itinerary, domain.NewCornerProgressValFromProps(domain.CornerProgressProps{
			CornerID: c.ID(),
			Status:   domain.VisitNotVisited,
		}))
	}

	groupID := domain.GroupID(s.uuidFn())
	group := domain.NewGroupFromProps(domain.GroupProps{
		ID:        groupID,
		CampID:    campID,
		Name:      groupName,
		BadgeID:   badge.ID(),
		Itinerary: itinerary,
	})

	if err := badge.AssignTo(groupID); err != nil {
		return nil, withErrorContext("group.register_badge", "domain.badge_assign", err, map[string]any{"badge_id": string(badge.ID()), "group_id": string(groupID)})
	}

	err = s.tx.RunInTx(ctx, func(ctx context.Context) error {
		if err := s.groups.Save(ctx, group); err != nil {
			return withErrorContext("group.register_badge", "repository.save_group", err, map[string]any{"group_id": string(group.ID())})
		}
		if err := s.badges.Save(ctx, badge); err != nil {
			return withErrorContext("group.register_badge", "repository.save_badge", err, map[string]any{"badge_id": string(badge.ID())})
		}
		return nil
	})

	if err != nil {
		s.recordAuditLog(ctx, "admin", ActionGroupCreate, "", false, errorAuditMetadata(err, nil))
		return nil, err
	}

	s.recordAuditLog(ctx, "admin", ActionGroupCreate, string(groupID), true, map[string]any{"campID": string(campID), "badgeID": string(badge.ID())})
	return group, nil
}

func (s *GroupService) registrationCamp(ctx context.Context) (*domain.Camp, error) {

	camps, err := s.camps.List(ctx)
	if err != nil {
		return nil, withErrorContext("group.registration_camp", "repository.list_camps", err, nil)
	}

	var pendingCamp *domain.Camp
	for _, camp := range camps {
		switch camp.Status() {
		case domain.CampActive:
			return camp, nil
		case domain.CampPending:
			pendingCamp = camp
		}
	}
	return pendingCamp, nil
}

// ListGroups
func (s *GroupService) ListGroups(
	ctx context.Context,
	campID domain.CampID,
) ([]*domain.Group, error) {
	groups, err := s.groups.ListByCamp(ctx, campID)
	if err != nil {
		return nil, withErrorContext("group.list", "repository.list_groups", err, map[string]any{"camp_id": string(campID)})
	}

	filtered, err := s.withCurrentCorners(ctx, groups)
	if err != nil {
		return nil, withErrorContext("group.list", "usecase.filter_current_corners", err, map[string]any{"camp_id": string(campID)})
	}
	return filtered, nil
}

// ListGroupsByTrack derives the camp scope from the track's immutable corner
// assignment and returns only groups belonging to that camp.
func (s *GroupService) ListGroupsByTrack(
	ctx context.Context,
	trackID domain.TrackID,
) ([]*domain.Group, error) {

	track, err := s.tracks.Get(ctx, trackID)
	if err != nil {
		return nil, withErrorContext("group.list_groups_by_track", "repository.get_track", err, map[string]any{"track_id": string(trackID)})
	}
	if track == nil {
		return nil, withErrorContext("group.list_groups_by_track", "validate_track", domain.ErrTrackNotFound, map[string]any{"track_id": string(trackID), "track_found": false})
	}

	corner, err := s.corners.Get(ctx, track.CornerID())
	if err != nil {
		return nil, withErrorContext("group.list_groups_by_track", "repository.get_corner", err, map[string]any{"corner_id": string(track.CornerID())})
	}
	if corner == nil {
		return nil, withErrorContext("group.list_groups_by_track", "validate_corner", domain.ErrCornerNotFound, map[string]any{"corner_id": string(track.CornerID()), "corner_found": false})
	}

	return s.ListGroups(ctx, corner.CampID())
}

// RetrieveGroupRotationSchedule
func (s *GroupService) RetrieveGroupRotationSchedule(ctx context.Context, groupID domain.GroupID) (*domain.Group, error) {
	group, err := s.groups.Get(ctx, groupID)
	if err != nil {
		return nil, withErrorContext("group.get_rotation_schedule", "repository.get_group", err, map[string]any{"group_id": string(groupID)})
	}
	if group == nil {
		return nil, withErrorContext("group.get_rotation_schedule", "validate_group", domain.ErrCornerNotInItinerary, map[string]any{"group_id": string(groupID), "group_found": false})
	}

	groups, err := s.withCurrentCorners(ctx, []*domain.Group{group})
	if err != nil {
		return nil, withErrorContext("group.get_rotation_schedule", "usecase.filter_current_corners", err, map[string]any{"group_id": string(groupID)})
	}
	return groups[0], nil
}

// withCurrentCorners returns read snapshots whose itineraries contain only
// corners that still belong to the group camp. Corner deletion cascades to
// visits but not to the itinerary JSON stored on groups.
func (s *GroupService) withCurrentCorners(ctx context.Context, groups []*domain.Group) ([]*domain.Group, error) {
	cornersByCamp := make(map[domain.CampID]map[domain.CornerID]struct{})
	filtered := make([]*domain.Group, len(groups))

	for i, group := range groups {
		cornerIDs, ok := cornersByCamp[group.CampID()]
		if !ok {
			corners, err := s.corners.ListByCamp(ctx, group.CampID())
			if err != nil {
				return nil, withErrorContext("group.filter_current_corners", "repository.list_corners", err, map[string]any{"camp_id": string(group.CampID())})
			}
			cornerIDs = make(map[domain.CornerID]struct{}, len(corners))
			for _, corner := range corners {
				cornerIDs[corner.ID()] = struct{}{}
			}
			cornersByCamp[group.CampID()] = cornerIDs
		}

		itinerary := make([]domain.CornerProgress, 0, len(group.Itinerary()))
		for _, progress := range group.Itinerary() {
			if _, exists := cornerIDs[progress.CornerID()]; exists {
				itinerary = append(itinerary, progress)
			}
		}
		filtered[i] = domain.NewGroupFromProps(domain.GroupProps{
			ID:        group.ID(),
			CampID:    group.CampID(),
			Name:      group.Name(),
			BadgeID:   group.BadgeID(),
			Itinerary: itinerary,
		})
	}

	return filtered, nil
}

type GroupVisitDetail struct {
	Visit  *domain.Visit
	Corner *domain.Corner
}

// ListGroupVisitDetails
func (s *GroupService) ListGroupVisitDetails(ctx context.Context, groupID domain.GroupID) ([]GroupVisitDetail, error) {

	group, err := s.groups.Get(ctx, groupID)
	if err != nil {
		return nil, withErrorContext("group.list_visit_details", "repository.get_group", err, map[string]any{"group_id": string(groupID)})
	}
	if group == nil {
		return nil, withErrorContext("group.list_visit_details", "validate_group", domain.ErrCornerNotInItinerary, map[string]any{"group_id": string(groupID), "group_found": false})
	}

	visits, err := s.visits.ListByGroup(ctx, groupID)
	if err != nil {
		return nil, withErrorContext("group.list_visit_details", "repository.list_visits", err, map[string]any{"group_id": string(groupID)})
	}

	corners, err := s.corners.ListByCamp(ctx, group.CampID())
	if err != nil {
		return nil, withErrorContext("group.list_visit_details", "repository.list_corners", err, map[string]any{"camp_id": string(group.CampID())})
	}

	cornerMap := make(map[domain.CornerID]*domain.Corner)
	for _, c := range corners {
		cornerMap[c.ID()] = c
	}

	var details []GroupVisitDetail
	for _, v := range visits {
		c, ok := cornerMap[v.CornerID()]
		if ok {
			details = append(details, GroupVisitDetail{
				Visit:  v,
				Corner: c,
			})
		}
	}

	return details, nil
}

func (s *GroupService) recordAuditLog(ctx context.Context, actor string, action AuditAction, target string, success bool, metadata map[string]any) {
	log := domain.NewAuditLog(
		domain.AuditLogID(s.uuidFn()),
		actor,
		string(action),
		target,
		success,
		s.nowFn(),
		metadata,
	)
	_ = s.auditLogs.Save(ctx, log)
}
