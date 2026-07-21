package usecase

import (
	"context"
	"time"

	"cornermon/backend/internal/domain"

	"github.com/google/uuid"
)

type VisitService struct {
	camps       CampRepository
	corners     CornerRepository
	tracks      TrackRepository
	visits      VisitRepository
	groups      GroupRepository
	badges      BadgeRepository
	sessions    FacilitatorSessionRepository
	auditLogs   AuditLogRepository
	broadcaster Broadcaster
	tx          TxManager

	// 테스트용 시간 및 UUID 주입
	nowFn  func() time.Time
	uuidFn func() string
}

func NewVisitService(
	camps CampRepository,
	corners CornerRepository,
	tracks TrackRepository,
	visits VisitRepository,
	groups GroupRepository,
	badges BadgeRepository,
	sessions FacilitatorSessionRepository,
	auditLogs AuditLogRepository,
	broadcaster Broadcaster,
	tx TxManager,
) *VisitService {
	return &VisitService{
		camps:       camps,
		corners:     corners,
		tracks:      tracks,
		visits:      visits,
		groups:      groups,
		badges:      badges,
		sessions:    sessions,
		auditLogs:   auditLogs,
		broadcaster: broadcaster,
		tx:          tx,
		nowFn:       func() time.Time { return time.Now().UTC() },
		uuidFn:      uuid.NewString,
	}
}

// StartVisitByQR - UC-1
func (s *VisitService) StartVisitByQR(
	ctx context.Context,
	facilitatorToken string,
	qrPayload string,
) (*domain.Visit, error) {
	now := s.nowFn()
	tokenHash := hashSHA256(facilitatorToken)

	session, err := s.sessions.GetByTokenHash(ctx, tokenHash)
	if err != nil {
		s.recordAuditLog(ctx, "anonymous", ActionVisitStart, "token:"+facilitatorToken, false, map[string]any{"error": err.Error()})
		return nil, err
	}
	if session == nil || !session.IsActive() {
		s.recordAuditLog(ctx, "anonymous", ActionVisitStart, "session:inactive", false, map[string]any{"error": domain.ErrSessionRevoked.Error()})
		return nil, domain.ErrSessionRevoked
	}

	actor := string(session.TrackID())

	var visit *domain.Visit
	var groupCampID domain.CampID

	err = s.tx.RunInTx(ctx, func(ctx context.Context) error {
		track, err := s.tracks.Get(ctx, session.TrackID())
		if err != nil {
			return err
		}
		if track == nil || track.Status() != domain.TrackActive {
			return domain.ErrTrackNotActive
		}
		if track.CurrentVisitID().IsSet() {
			return domain.ErrTrackBusy
		}

		badge, err := s.badges.GetByQRPayload(ctx, qrPayload)
		if err != nil {
			return err
		}
		if badge == nil {
			return domain.ErrBadgeNotAssigned
		}
		assignedGroupID, ok := badge.AssignedGroupID().Value()
		if !ok || badge.Status() != domain.BadgeAssigned {
			return domain.ErrBadgeNotAssigned
		}

		group, err := s.groups.GetForUpdate(ctx, assignedGroupID)
		if err != nil {
			return err
		}
		if group == nil {
			return domain.ErrCornerNotInItinerary
		}
		groupCampID = group.CampID()

		// 캠프가 ACTIVE 상태인지 검사
		camp, err := s.camps.Get(ctx, groupCampID)
		if err != nil {
			return err
		}
		if camp == nil || !camp.IsActive() {
			return domain.ErrCampInvalidTransition // 캠프가 활성화되어 있지 않음
		}

		if err = group.MarkVisitStarted(track.CornerID()); err != nil {
			return err
		}

		visitID := domain.VisitID(s.uuidFn())
		visit = domain.NewVisit(visitID, group.ID(), track.CornerID(), track.ID(), domain.VisitQRScan, now)

		if err := track.StartVisit(visitID); err != nil {
			return err
		}

		if err := s.visits.Save(ctx, visit); err != nil {
			return err
		}
		if err := s.tracks.Save(ctx, track); err != nil {
			return err
		}
		if err := s.groups.Save(ctx, group); err != nil {
			return err
		}

		return nil
	})

	if err != nil {
		s.recordAuditLog(ctx, actor, ActionVisitStart, qrPayload, false, map[string]any{"error": err.Error()})
		return nil, err
	}

	s.recordAuditLog(ctx, actor, ActionVisitStart, string(visit.ID()), true, map[string]any{"method": string(domain.VisitQRScan), "groupID": string(visit.GroupID())})
	_ = s.broadcaster.Broadcast(ctx, groupCampID, EventCornersUpdated, CampScope())
	_ = s.broadcaster.Broadcast(ctx, groupCampID, EventGroupsUpdated, CampScope())
	_ = s.broadcaster.Broadcast(ctx, groupCampID, EventTracksUpdated, CampScope())
	_ = s.broadcaster.Broadcast(ctx, groupCampID, EventTrackUpdated, TrackScope(session.TrackID()))

	return visit, nil
}

// StartVisitManual - UC-2
func (s *VisitService) StartVisitManual(
	ctx context.Context,
	facilitatorToken string,
	groupID domain.GroupID,
) (*domain.Visit, error) {
	now := s.nowFn()
	tokenHash := hashSHA256(facilitatorToken)

	session, err := s.sessions.GetByTokenHash(ctx, tokenHash)
	if err != nil {
		s.recordAuditLog(ctx, "anonymous", ActionVisitStart, "token:"+facilitatorToken, false, map[string]any{"error": err.Error()})
		return nil, err
	}
	if session == nil || !session.IsActive() {
		s.recordAuditLog(ctx, "anonymous", ActionVisitStart, "session:inactive", false, map[string]any{"error": domain.ErrSessionRevoked.Error()})
		return nil, domain.ErrSessionRevoked
	}

	actor := string(session.TrackID())
	var visit *domain.Visit
	var groupCampID domain.CampID

	err = s.tx.RunInTx(ctx, func(ctx context.Context) error {
		track, err := s.tracks.Get(ctx, session.TrackID())
		if err != nil {
			return err
		}
		if track == nil || track.Status() != domain.TrackActive {
			return domain.ErrTrackNotActive
		}
		if track.CurrentVisitID().IsSet() {
			return domain.ErrTrackBusy
		}

		group, err := s.groups.GetForUpdate(ctx, groupID)
		if err != nil {
			return err
		}
		if group == nil {
			return domain.ErrCornerNotInItinerary
		}
		groupCampID = group.CampID()

		// 캠프가 ACTIVE 상태인지 검사
		camp, err := s.camps.Get(ctx, groupCampID)
		if err != nil {
			return err
		}
		if camp == nil || !camp.IsActive() {
			return domain.ErrCampInvalidTransition
		}

		if err := group.MarkVisitStarted(track.CornerID()); err != nil {
			return err
		}

		visitID := domain.VisitID(s.uuidFn())
		visit = domain.NewVisit(visitID, group.ID(), track.CornerID(), track.ID(), domain.VisitManual, now)

		if err := track.StartVisit(visitID); err != nil {
			return err
		}

		if err := s.visits.Save(ctx, visit); err != nil {
			return err
		}
		if err := s.tracks.Save(ctx, track); err != nil {
			return err
		}
		if err := s.groups.Save(ctx, group); err != nil {
			return err
		}

		return nil
	})

	if err != nil {
		s.recordAuditLog(ctx, actor, ActionVisitStart, string(groupID), false, map[string]any{"error": err.Error()})
		return nil, err
	}

	s.recordAuditLog(ctx, actor, ActionVisitStart, string(visit.ID()), true, map[string]any{"method": string(domain.VisitManual), "groupID": string(visit.GroupID())})
	_ = s.broadcaster.Broadcast(ctx, groupCampID, EventCornersUpdated, CampScope())
	_ = s.broadcaster.Broadcast(ctx, groupCampID, EventGroupsUpdated, CampScope())
	_ = s.broadcaster.Broadcast(ctx, groupCampID, EventTracksUpdated, CampScope())
	_ = s.broadcaster.Broadcast(ctx, groupCampID, EventTrackUpdated, TrackScope(session.TrackID()))

	return visit, nil
}

// CompleteVisit - UC-3
func (s *VisitService) CompleteVisit(
	ctx context.Context,
	facilitatorToken string,
) (*domain.Visit, error) {
	now := s.nowFn()
	tokenHash := hashSHA256(facilitatorToken)

	session, err := s.sessions.GetByTokenHash(ctx, tokenHash)
	if err != nil {
		s.recordAuditLog(ctx, "anonymous", ActionVisitComplete, "token:"+facilitatorToken, false, map[string]any{"error": err.Error()})
		return nil, err
	}
	if session == nil || !session.IsActive() {
		s.recordAuditLog(ctx, "anonymous", ActionVisitComplete, "session:inactive", false, map[string]any{"error": domain.ErrSessionRevoked.Error()})
		return nil, domain.ErrSessionRevoked
	}

	actor := string(session.TrackID())
	var visit *domain.Visit
	var groupCampID domain.CampID

	err = s.tx.RunInTx(ctx, func(ctx context.Context) error {
		track, err := s.tracks.Get(ctx, session.TrackID())
		if err != nil {
			return err
		}
		if track == nil || track.Status() != domain.TrackActive {
			return domain.ErrTrackNotActive
		}

		activeVisitID, ok := track.CurrentVisitID().Value()
		if !ok {
			return domain.ErrTrackNotBusy
		}

		visit, err = s.visits.Get(ctx, activeVisitID)
		if err != nil {
			return err
		}
		if visit == nil {
			return domain.ErrTrackNotBusy
		}

		group, err := s.groups.GetForUpdate(ctx, visit.GroupID())
		if err != nil {
			return err
		}
		if group == nil {
			return domain.ErrCornerNotInItinerary
		}
		groupCampID = group.CampID()

		if err := visit.Complete(now); err != nil {
			return err
		}

		if _, err := track.CompleteVisit(now); err != nil {
			return err
		}

		if err := group.MarkVisitCompleted(visit.CornerID()); err != nil {
			return err
		}

		if err := s.visits.Save(ctx, visit); err != nil {
			return err
		}
		if err := s.tracks.Save(ctx, track); err != nil {
			return err
		}
		if err := s.groups.Save(ctx, group); err != nil {
			return err
		}

		return nil
	})

	if err != nil {
		s.recordAuditLog(ctx, actor, ActionVisitComplete, "", false, map[string]any{"error": err.Error()})
		return nil, err
	}

	s.recordAuditLog(ctx, actor, ActionVisitComplete, string(visit.ID()), true, map[string]any{"groupID": string(visit.GroupID())})
	_ = s.broadcaster.Broadcast(ctx, groupCampID, EventCornersUpdated, CampScope())
	_ = s.broadcaster.Broadcast(ctx, groupCampID, EventGroupsUpdated, CampScope())
	_ = s.broadcaster.Broadcast(ctx, groupCampID, EventTracksUpdated, CampScope())
	_ = s.broadcaster.Broadcast(ctx, groupCampID, EventTrackUpdated, TrackScope(session.TrackID()))

	return visit, nil
}

// GetCurrentVisit - UC-4
func (s *VisitService) GetCurrentVisit(
	ctx context.Context,
	facilitatorToken string,
) (*domain.Visit, error) {
	tokenHash := hashSHA256(facilitatorToken)

	session, err := s.sessions.GetByTokenHash(ctx, tokenHash)
	if err != nil {
		return nil, err
	}
	if session == nil || !session.IsActive() {
		return nil, domain.ErrSessionRevoked
	}

	return s.visits.GetInProgressByTrack(ctx, session.TrackID())
}

func (s *VisitService) recordAuditLog(ctx context.Context, actor string, action AuditAction, target string, success bool, metadata map[string]any) {
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
