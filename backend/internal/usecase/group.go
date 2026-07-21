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
		return nil, err
	}
	if badge == nil {
		return nil, domain.ErrBadgeNotAssigned
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
		return nil, err
	}
	if badge == nil {
		return nil, domain.ErrBadgeNotAssigned
	}

	return s.registerBadge(ctx, badge, groupName)
}

func (s *GroupService) registerBadge(ctx context.Context, badge *domain.Badge, groupName string) (*domain.Group, error) {
	camp, err := s.registrationCamp(ctx)
	if err != nil {
		return nil, err
	}
	if camp == nil {
		return nil, domain.ErrCampNotFound
	}
	if badge.Status() == domain.BadgeAssigned {
		return nil, domain.ErrBadgeAlreadyAssigned
	}

	campID := camp.ID()
	corners, err := s.corners.ListByCamp(ctx, campID)
	if err != nil {
		return nil, err
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
		return nil, err
	}

	err = s.tx.RunInTx(ctx, func(ctx context.Context) error {
		if err := s.groups.Save(ctx, group); err != nil {
			return err
		}
		return s.badges.Save(ctx, badge)
	})

	if err != nil {
		s.recordAuditLog(ctx, "admin", ActionGroupCreate, "", false, map[string]any{"error": err.Error()})
		return nil, err
	}

	s.recordAuditLog(ctx, "admin", ActionGroupCreate, string(groupID), true, map[string]any{"campID": string(campID), "badgeID": string(badge.ID())})
	return group, nil
}

func (s *GroupService) registrationCamp(ctx context.Context) (*domain.Camp, error) {
	camps, err := s.camps.List(ctx)
	if err != nil {
		return nil, err
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
		return nil, err
	}

	return s.withCurrentCorners(ctx, groups)
}

// ListGroupsByTrack derives the camp scope from the track's immutable corner
// assignment and returns only groups belonging to that camp.
func (s *GroupService) ListGroupsByTrack(
	ctx context.Context,
	trackID domain.TrackID,
) ([]*domain.Group, error) {
	track, err := s.tracks.Get(ctx, trackID)
	if err != nil {
		return nil, err
	}
	if track == nil {
		return nil, domain.ErrTrackNotFound
	}

	corner, err := s.corners.Get(ctx, track.CornerID())
	if err != nil {
		return nil, err
	}
	if corner == nil {
		return nil, domain.ErrCornerNotFound
	}

	return s.ListGroups(ctx, corner.CampID())
}

// RetrieveGroupRotationSchedule
func (s *GroupService) RetrieveGroupRotationSchedule(ctx context.Context, groupID domain.GroupID) (*domain.Group, error) {
	group, err := s.groups.Get(ctx, groupID)
	if err != nil || group == nil {
		return group, err
	}

	groups, err := s.withCurrentCorners(ctx, []*domain.Group{group})
	if err != nil {
		return nil, err
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
				return nil, err
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
		return nil, err
	}
	if group == nil {
		return nil, domain.ErrCornerNotInItinerary // map to not found
	}

	visits, err := s.visits.ListByGroup(ctx, groupID)
	if err != nil {
		return nil, err
	}

	corners, err := s.corners.ListByCamp(ctx, group.CampID())
	if err != nil {
		return nil, err
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
