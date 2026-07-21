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
		err = withErrorContext("visit.start_qr", "repository.get_session", err, nil)
		s.recordAuditLog(ctx, "anonymous", ActionVisitStart, "token:provided", false, errorAuditMetadata(err, nil))
		return nil, err
	}
	if session == nil || !session.IsActive() {
		err = withErrorContext("visit.start_qr", "validate_session", domain.ErrSessionRevoked, map[string]any{"session_found": session != nil})
		s.recordAuditLog(ctx, "anonymous", ActionVisitStart, "session:inactive", false, errorAuditMetadata(err, nil))
		return nil, err
	}

	actor := string(session.TrackID())

	var visit *domain.Visit
	var groupCampID domain.CampID

	err = s.tx.RunInTx(ctx, func(ctx context.Context) error {
		track, err := s.tracks.Get(ctx, session.TrackID())
		if err != nil {
			return withErrorContext("visit.start_qr", "repository.get_track", err, map[string]any{"track_id": string(session.TrackID())})
		}
		if track == nil || track.Status() != domain.TrackActive {
			var status string
			if track != nil {
				status = string(track.Status())
			}
			return withErrorContext("visit.start_qr", "validate_track_active", domain.ErrTrackNotActive, map[string]any{
				"track_id": string(session.TrackID()), "track_found": track != nil, "track_status": status,
			})
		}
		if track.CurrentVisitID().IsSet() {
			return withErrorContext("visit.start_qr", "validate_track_busy", domain.ErrTrackBusy, map[string]any{
				"track_id": string(session.TrackID()), "current_visit_id": "",
			})
		}

		badge, err := s.badges.GetByQRPayload(ctx, qrPayload)
		if err != nil {
			return withErrorContext("visit.start_qr", "repository.get_badge", err, nil)
		}
		if badge == nil {
			return withErrorContext("visit.start_qr", "validate_badge", domain.ErrBadgeNotAssigned, map[string]any{"badge_found": false})
		}
		assignedGroupID, ok := badge.AssignedGroupID().Value()
		if !ok || badge.Status() != domain.BadgeAssigned {
			return withErrorContext("visit.start_qr", "validate_badge_assigned", domain.ErrBadgeNotAssigned, map[string]any{
				"badge_id": string(badge.ID()), "badge_status": string(badge.Status()),
			})
		}

		group, err := s.groups.GetForUpdate(ctx, assignedGroupID)
		if err != nil {
			return withErrorContext("visit.start_qr", "repository.get_group", err, map[string]any{"group_id": string(assignedGroupID)})
		}
		if group == nil {
			return withErrorContext("visit.start_qr", "validate_group", domain.ErrCornerNotInItinerary, map[string]any{
				"group_id": string(assignedGroupID), "group_found": false,
			})
		}
		groupCampID = group.CampID()

		camp, err := s.camps.Get(ctx, groupCampID)
		if err != nil {
			return withErrorContext("visit.start_qr", "repository.get_camp", err, map[string]any{"camp_id": string(groupCampID)})
		}
		if camp == nil || !camp.IsActive() {
			var status string
			if camp != nil {
				status = string(camp.Status())
			}
			return withErrorContext("visit.start_qr", "validate_camp_active", domain.ErrCampInvalidTransition, map[string]any{
				"camp_id": string(groupCampID), "camp_found": camp != nil, "camp_status": status,
			})
		}

		if err = group.MarkVisitStarted(track.CornerID()); err != nil {
			return withErrorContext("visit.start_qr", "domain.group_mark_started", err, map[string]any{
				"group_id": string(group.ID()), "corner_id": string(track.CornerID()),
			})
		}

		visitID := domain.VisitID(s.uuidFn())
		visit = domain.NewVisit(visitID, group.ID(), track.CornerID(), track.ID(), domain.VisitQRScan, now)

		if err := track.StartVisit(visitID); err != nil {
			return withErrorContext("visit.start_qr", "domain.track_start_visit", err, map[string]any{
				"track_id": string(track.ID()), "visit_id": string(visitID),
			})
		}

		if err := s.visits.Save(ctx, visit); err != nil {
			return withErrorContext("visit.start_qr", "repository.save_visit", err, map[string]any{"visit_id": string(visit.ID())})
		}
		if err := s.tracks.Save(ctx, track); err != nil {
			return withErrorContext("visit.start_qr", "repository.save_track", err, map[string]any{"track_id": string(track.ID())})
		}
		if err := s.groups.Save(ctx, group); err != nil {
			return withErrorContext("visit.start_qr", "repository.save_group", err, map[string]any{"group_id": string(group.ID())})
		}

		return nil
	})

	if err != nil {
		s.recordAuditLog(ctx, actor, ActionVisitStart, "badge:qr_scanned", false, errorAuditMetadata(err, nil))
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
		err = withErrorContext("visit.start_manual", "repository.get_session", err, nil)
		s.recordAuditLog(ctx, "anonymous", ActionVisitStart, "token:provided", false, errorAuditMetadata(err, nil))
		return nil, err
	}
	if session == nil || !session.IsActive() {
		err = withErrorContext("visit.start_manual", "validate_session", domain.ErrSessionRevoked, map[string]any{"session_found": session != nil})
		s.recordAuditLog(ctx, "anonymous", ActionVisitStart, "session:inactive", false, errorAuditMetadata(err, nil))
		return nil, err
	}

	actor := string(session.TrackID())
	var visit *domain.Visit
	var groupCampID domain.CampID

	err = s.tx.RunInTx(ctx, func(ctx context.Context) error {
		track, err := s.tracks.Get(ctx, session.TrackID())
		if err != nil {
			return withErrorContext("visit.start_manual", "repository.get_track", err, map[string]any{"track_id": string(session.TrackID())})
		}
		if track == nil || track.Status() != domain.TrackActive {
			var status string
			if track != nil {
				status = string(track.Status())
			}
			return withErrorContext("visit.start_manual", "validate_track_active", domain.ErrTrackNotActive, map[string]any{
				"track_id": string(session.TrackID()), "track_found": track != nil, "track_status": status,
			})
		}
		if track.CurrentVisitID().IsSet() {
			return withErrorContext("visit.start_manual", "validate_track_busy", domain.ErrTrackBusy, map[string]any{
				"track_id": string(session.TrackID()), "current_visit_id": "",
			})
		}

		group, err := s.groups.GetForUpdate(ctx, groupID)
		if err != nil {
			return withErrorContext("visit.start_manual", "repository.get_group", err, map[string]any{"group_id": string(groupID)})
		}
		if group == nil {
			return withErrorContext("visit.start_manual", "validate_group", domain.ErrCornerNotInItinerary, map[string]any{
				"group_id": string(groupID), "group_found": false,
			})
		}
		groupCampID = group.CampID()

		camp, err := s.camps.Get(ctx, groupCampID)
		if err != nil {
			return withErrorContext("visit.start_manual", "repository.get_camp", err, map[string]any{"camp_id": string(groupCampID)})
		}
		if camp == nil || !camp.IsActive() {
			var status string
			if camp != nil {
				status = string(camp.Status())
			}
			return withErrorContext("visit.start_manual", "validate_camp_active", domain.ErrCampInvalidTransition, map[string]any{
				"camp_id": string(groupCampID), "camp_found": camp != nil, "camp_status": status,
			})
		}

		if err := group.MarkVisitStarted(track.CornerID()); err != nil {
			return withErrorContext("visit.start_manual", "domain.group_mark_started", err, map[string]any{
				"group_id": string(group.ID()), "corner_id": string(track.CornerID()),
			})
		}

		visitID := domain.VisitID(s.uuidFn())
		visit = domain.NewVisit(visitID, group.ID(), track.CornerID(), track.ID(), domain.VisitManual, now)

		if err := track.StartVisit(visitID); err != nil {
			return withErrorContext("visit.start_manual", "domain.track_start_visit", err, map[string]any{
				"track_id": string(track.ID()), "visit_id": string(visitID),
			})
		}

		if err := s.visits.Save(ctx, visit); err != nil {
			return withErrorContext("visit.start_manual", "repository.save_visit", err, map[string]any{"visit_id": string(visit.ID())})
		}
		if err := s.tracks.Save(ctx, track); err != nil {
			return withErrorContext("visit.start_manual", "repository.save_track", err, map[string]any{"track_id": string(track.ID())})
		}
		if err := s.groups.Save(ctx, group); err != nil {
			return withErrorContext("visit.start_manual", "repository.save_group", err, map[string]any{"group_id": string(group.ID())})
		}

		return nil
	})

	if err != nil {
		s.recordAuditLog(ctx, actor, ActionVisitStart, string(groupID), false, errorAuditMetadata(err, nil))
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
		err = withErrorContext("visit.complete", "repository.get_session", err, nil)
		s.recordAuditLog(ctx, "anonymous", ActionVisitComplete, "token:provided", false, errorAuditMetadata(err, nil))
		return nil, err
	}
	if session == nil || !session.IsActive() {
		err = withErrorContext("visit.complete", "validate_session", domain.ErrSessionRevoked, map[string]any{"session_found": session != nil})
		s.recordAuditLog(ctx, "anonymous", ActionVisitComplete, "session:inactive", false, errorAuditMetadata(err, nil))
		return nil, err
	}

	actor := string(session.TrackID())
	var visit *domain.Visit
	var groupCampID domain.CampID

	err = s.tx.RunInTx(ctx, func(ctx context.Context) error {
		track, err := s.tracks.Get(ctx, session.TrackID())
		if err != nil {
			return withErrorContext("visit.complete", "repository.get_track", err, map[string]any{"track_id": string(session.TrackID())})
		}
		if track == nil || track.Status() != domain.TrackActive {
			var status string
			if track != nil {
				status = string(track.Status())
			}
			return withErrorContext("visit.complete", "validate_track_active", domain.ErrTrackNotActive, map[string]any{
				"track_id": string(session.TrackID()), "track_found": track != nil, "track_status": status,
			})
		}

		activeVisitID, ok := track.CurrentVisitID().Value()
		if !ok {
			return withErrorContext("visit.complete", "validate_track_busy", domain.ErrTrackNotBusy, map[string]any{
				"track_id": string(session.TrackID()),
			})
		}

		visit, err = s.visits.Get(ctx, activeVisitID)
		if err != nil {
			return withErrorContext("visit.complete", "repository.get_visit", err, map[string]any{"visit_id": string(activeVisitID)})
		}
		if visit == nil {
			return withErrorContext("visit.complete", "validate_visit", domain.ErrTrackNotBusy, map[string]any{"visit_id": string(activeVisitID), "visit_found": false})
		}

		group, err := s.groups.GetForUpdate(ctx, visit.GroupID())
		if err != nil {
			return withErrorContext("visit.complete", "repository.get_group", err, map[string]any{"group_id": string(visit.GroupID())})
		}
		if group == nil {
			return withErrorContext("visit.complete", "validate_group", domain.ErrCornerNotInItinerary, map[string]any{
				"group_id": string(visit.GroupID()), "group_found": false,
			})
		}
		groupCampID = group.CampID()

		if err := visit.Complete(now); err != nil {
			return withErrorContext("visit.complete", "domain.visit_complete", err, map[string]any{"visit_id": string(visit.ID())})
		}

		if _, err := track.CompleteVisit(now); err != nil {
			return withErrorContext("visit.complete", "domain.track_complete_visit", err, map[string]any{"track_id": string(track.ID())})
		}

		if err := group.MarkVisitCompleted(visit.CornerID()); err != nil {
			return withErrorContext("visit.complete", "domain.group_mark_completed", err, map[string]any{
				"group_id": string(group.ID()), "corner_id": string(visit.CornerID()),
			})
		}

		if err := s.visits.Save(ctx, visit); err != nil {
			return withErrorContext("visit.complete", "repository.save_visit", err, map[string]any{"visit_id": string(visit.ID())})
		}
		if err := s.tracks.Save(ctx, track); err != nil {
			return withErrorContext("visit.complete", "repository.save_track", err, map[string]any{"track_id": string(track.ID())})
		}
		if err := s.groups.Save(ctx, group); err != nil {
			return withErrorContext("visit.complete", "repository.save_group", err, map[string]any{"group_id": string(group.ID())})
		}

		return nil
	})

	if err != nil {
		s.recordAuditLog(ctx, actor, ActionVisitComplete, "", false, errorAuditMetadata(err, nil))
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
		// get current visit doesn't generate audit log typically on error based on previous code, wait previous didn't.
		// We will just wrap it.
		return nil, withErrorContext("visit.get_current", "repository.get_session", err, nil)
	}
	if session == nil || !session.IsActive() {
		return nil, withErrorContext("visit.get_current", "validate_session", domain.ErrSessionRevoked, nil)
	}

	visit, err := s.visits.GetInProgressByTrack(ctx, session.TrackID())
	if err != nil {
		return nil, withErrorContext("visit.get_current", "repository.get_visit", err, map[string]any{"track_id": string(session.TrackID())})
	}
	return visit, nil
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
