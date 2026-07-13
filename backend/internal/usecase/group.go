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

// RegisterBadge - UC-19
func (s *GroupService) RegisterBadge(
	ctx context.Context,
	campID domain.CampID,
	qrPayload string,
	groupName string,
) (*domain.Group, error) {
	camp, err := s.camps.Get(ctx, campID)
	if err != nil {
		return nil, err
	}
	if camp == nil || camp.Status == domain.CampEnded {
		return nil, domain.ErrCampInvalidTransition
	}

	badge, err := s.badges.GetByQRPayload(ctx, qrPayload)
	if err != nil {
		return nil, err
	}
	if badge == nil {
		return nil, domain.ErrBadgeNotAssigned
	}
	if badge.Status == domain.BadgeAssigned {
		return nil, domain.ErrBadgeAlreadyAssigned
	}

	corners, err := s.corners.ListByCamp(ctx, campID)
	if err != nil {
		return nil, err
	}

	var itinerary []domain.CornerProgress
	for _, c := range corners {
		itinerary = append(itinerary, domain.CornerProgress{
			CornerID: c.ID,
			Status:   domain.VisitNotVisited,
		})
	}

	groupID := domain.GroupID(s.uuidFn())
	group := &domain.Group{
		ID:        groupID,
		CampID:    campID,
		Name:      groupName,
		BadgeID:   badge.ID,
		Itinerary: itinerary,
	}

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
		s.recordAuditLog(ctx, "admin", "GROUP_CREATE", "", false, map[string]any{"error": err.Error()})
		return nil, err
	}

	s.recordAuditLog(ctx, "admin", "GROUP_CREATE", string(groupID), true, map[string]any{"campID": string(campID), "badgeID": string(badge.ID)})
	return group, nil
}

// ListGroups
func (s *GroupService) ListGroups(
	ctx context.Context,
	campID domain.CampID,
) ([]*domain.Group, error) {
	return s.groups.ListByCamp(ctx, campID)
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

	corner, err := s.corners.Get(ctx, track.CornerID)
	if err != nil {
		return nil, err
	}
	if corner == nil {
		return nil, domain.ErrCornerNotFound
	}

	return s.groups.ListByCamp(ctx, corner.CampID)
}

// RetrieveGroupRotationSchedule
func (s *GroupService) RetrieveGroupRotationSchedule(ctx context.Context, groupID domain.GroupID) (*domain.Group, error) {
	return s.groups.Get(ctx, groupID)
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

	corners, err := s.corners.ListByCamp(ctx, group.CampID)
	if err != nil {
		return nil, err
	}

	cornerMap := make(map[domain.CornerID]*domain.Corner)
	for _, c := range corners {
		cornerMap[c.ID] = c
	}

	var details []GroupVisitDetail
	for _, v := range visits {
		c, ok := cornerMap[v.CornerID]
		if ok {
			details = append(details, GroupVisitDetail{
				Visit:  v,
				Corner: c,
			})
		}
	}

	return details, nil
}

func (s *GroupService) recordAuditLog(ctx context.Context, actor, action, target string, success bool, metadata map[string]any) {
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
