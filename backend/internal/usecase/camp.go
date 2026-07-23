package usecase

import (
	"context"
	"time"

	"cornermon/backend/internal/domain"

	"github.com/google/uuid"
)

type CampService struct {
	camps       CampRepository
	tracks      TrackRepository
	devices     DeviceRegistrationRepository
	visits      VisitRepository
	groups      GroupRepository
	sessions    FacilitatorSessionRepository
	admins      AdminRepository
	auditLogs   AuditLogRepository
	broadcaster Broadcaster
	tx          TxManager

	nowFn  func() time.Time
	uuidFn func() string
}

func NewCampService(
	camps CampRepository,
	tracks TrackRepository,
	devices DeviceRegistrationRepository,
	visits VisitRepository,
	groups GroupRepository,
	sessions FacilitatorSessionRepository,
	admins AdminRepository,
	auditLogs AuditLogRepository,
	broadcaster Broadcaster,
	tx TxManager,
) *CampService {
	return &CampService{
		camps:       camps,
		tracks:      tracks,
		devices:     devices,
		visits:      visits,
		groups:      groups,
		sessions:    sessions,
		admins:      admins,
		auditLogs:   auditLogs,
		broadcaster: broadcaster,
		tx:          tx,
		nowFn:       func() time.Time { return time.Now().UTC() },
		uuidFn:      uuid.NewString,
	}
}

// OpenNewCamp
func (s *CampService) OpenNewCamp(ctx context.Context, name string, startAt, endAt time.Time, actorAdminID domain.AdminID) (*domain.Camp, error) {

	camp, err := domain.NewCamp(domain.CampID(s.uuidFn()), name, startAt, endAt)
	if err != nil {
		return nil, withErrorContext("camp.open", "domain.new_camp", err, map[string]any{"name": name})
	}
	err = s.tx.RunInTx(ctx, func(ctx context.Context) error {
		if err := s.camps.Save(ctx, camp); err != nil {
			return withErrorContext("camp.open", "repository.save_camp", err, map[string]any{"camp_id": string(camp.ID())})
		}
		return nil
	})
	if err != nil {
		s.recordAuditLog(ctx, string(actorAdminID), adminActorLabel(ctx, s.admins, actorAdminID, nil), ActionCampCreate, "", false, errorAuditMetadata(err, nil))
		return nil, err
	}
	s.recordAuditLog(ctx, string(actorAdminID), adminActorLabel(ctx, s.admins, actorAdminID, nil), ActionCampCreate, string(camp.ID()), true, map[string]any{"name": name})
	return camp, nil
}

// ListCamps
func (s *CampService) ListCamps(ctx context.Context) ([]*domain.Camp, error) {
	return s.camps.List(ctx)
}

// GetCamp
func (s *CampService) GetCamp(ctx context.Context, id domain.CampID) (*domain.Camp, error) {
	return s.camps.Get(ctx, id)
}

func (s *CampService) UpdateCampSettings(
	ctx context.Context,
	campID domain.CampID,
	actorAdminID domain.AdminID,
	patch domain.CampSettingsPatch,
) (*domain.Camp, error) {

	camp, err := s.camps.Get(ctx, campID)
	if err != nil {
		return nil, withErrorContext("camp.update_settings", "repository.get_camp", err, map[string]any{"camp_id": string(campID)})
	}
	if camp == nil {
		return nil, withErrorContext("camp.update_settings", "validate_camp", domain.ErrCampNotFound, map[string]any{"camp_id": string(campID), "camp_found": false})
	}
	if err := camp.UpdateSettings(patch); err != nil {
		return nil, withErrorContext("camp.update_settings", "domain.update_settings", err, map[string]any{"camp_id": string(campID)})
	}

	err = s.tx.RunInTx(ctx, func(ctx context.Context) error {
		if err := s.camps.Save(ctx, camp); err != nil {
			return withErrorContext("camp.update_settings", "repository.save_camp", err, map[string]any{"camp_id": string(campID)})
		}
		return nil
	})
	if err != nil {
		s.recordAuditLog(ctx, string(actorAdminID), adminActorLabel(ctx, s.admins, actorAdminID, nil), ActionCampSettingsUpdate, string(campID), false, errorAuditMetadata(err, nil))
		return nil, err
	}

	s.recordAuditLog(ctx, string(actorAdminID), adminActorLabel(ctx, s.admins, actorAdminID, nil), ActionCampSettingsUpdate, string(campID), true, nil)
	_ = s.broadcaster.Broadcast(ctx, campID, EventCampUpdated, CampScope())
	return camp, nil
}

// ActivateCamp - UC-18
func (s *CampService) ActivateCamp(
	ctx context.Context,
	campID domain.CampID,
	actorAdminID domain.AdminID,
) error {

	now := s.nowFn()
	camp, err := s.camps.Get(ctx, campID)
	if err != nil {
		return withErrorContext("camp.activate", "repository.get_camp", err, map[string]any{"camp_id": string(campID)})
	}
	if camp == nil {
		return withErrorContext("camp.activate", "validate_camp", domain.ErrCampInvalidTransition, map[string]any{"camp_id": string(campID), "camp_found": false})
	}

	if err := camp.Activate(now); err != nil {
		return withErrorContext("camp.activate", "domain.activate", err, map[string]any{"camp_id": string(campID), "camp_status": string(camp.Status())})
	}

	err = s.tx.RunInTx(ctx, func(ctx context.Context) error {
		if err := s.camps.Save(ctx, camp); err != nil {
			return withErrorContext("camp.activate", "repository.save_camp", err, map[string]any{"camp_id": string(campID)})
		}
		return nil
	})

	if err != nil {
		s.recordAuditLog(ctx, string(actorAdminID), adminActorLabel(ctx, s.admins, actorAdminID, nil), ActionCampActivate, string(campID), false, errorAuditMetadata(err, nil))
		return err // D-2 allowed: already wrapped or handled
	}

	s.recordAuditLog(ctx, string(actorAdminID), adminActorLabel(ctx, s.admins, actorAdminID, nil), ActionCampActivate, string(campID), true, nil)
	_ = s.broadcaster.Broadcast(ctx, campID, EventCampUpdated, CampScope())

	return nil
}

// EndCamp - UC-20
func (s *CampService) EndCamp(
	ctx context.Context,
	campID domain.CampID,
	actorAdminID domain.AdminID,
) error {

	now := s.nowFn()
	err := s.tx.RunInTx(ctx, func(ctx context.Context) error {
		camp, err := s.camps.Get(ctx, campID)
		if err != nil {
			return withErrorContext("camp.end", "repository.get_camp", err, map[string]any{"camp_id": string(campID)})
		}
		if camp == nil {
			return withErrorContext("camp.end", "validate_camp", domain.ErrCampInvalidTransition, map[string]any{"camp_id": string(campID), "camp_found": false})
		}
		if _, err := camp.End(now); err != nil {
			return withErrorContext("camp.end", "domain.end", err, map[string]any{"camp_id": string(campID), "camp_status": string(camp.Status())})
		}

		approvedStatus := domain.DeviceApproved
		devices, err := s.devices.ListByCampAndStatus(ctx, campID, &approvedStatus)
		if err != nil {
			return withErrorContext("camp.end", "repository.list_devices", err, map[string]any{"camp_id": string(campID)})
		}
		for _, device := range devices {
			if err := device.Revoke(); err != nil {
				return withErrorContext("camp.end", "domain.device_revoke", err, map[string]any{"device_id": string(device.ID())})
			}
			if err := s.devices.Save(ctx, device); err != nil {
				return withErrorContext("camp.end", "repository.save_device", err, map[string]any{"device_id": string(device.ID())})
			}
		}

		sessions, err := s.sessions.ListActiveByCamp(ctx, campID)
		if err != nil {
			return withErrorContext("camp.end", "repository.list_sessions", err, map[string]any{"camp_id": string(campID)})
		}
		for _, sess := range sessions {
			if err := sess.Revoke(now); err == nil {
				if err := s.sessions.Save(ctx, sess); err != nil {
					return withErrorContext("camp.end", "repository.save_session", err, map[string]any{"session_id": string(sess.ID())})
				}
			}
		}

		visits, err := s.visits.ListInProgressByCamp(ctx, campID)
		if err != nil {
			return withErrorContext("camp.end", "repository.list_visits", err, map[string]any{"camp_id": string(campID)})
		}
		for _, visit := range visits {
			group, err := s.groups.GetForUpdate(ctx, visit.GroupID())
			if err != nil {
				return withErrorContext("camp.end", "repository.get_group", err, map[string]any{"group_id": string(visit.GroupID()), "visit_id": string(visit.ID())})
			}
			if group == nil {
				return withErrorContext("camp.end", "validate_group", domain.ErrCornerNotInItinerary, map[string]any{"group_id": string(visit.GroupID()), "visit_id": string(visit.ID()), "group_found": false})
			}

			track, err := s.tracks.Get(ctx, visit.TrackID())
			if err != nil {
				return withErrorContext("camp.end", "repository.get_track", err, map[string]any{"track_id": string(visit.TrackID()), "visit_id": string(visit.ID())})
			}
			if track == nil {
				return withErrorContext("camp.end", "validate_track", domain.ErrTrackNotActive, map[string]any{"track_id": string(visit.TrackID()), "visit_id": string(visit.ID()), "track_found": false})
			}

			if err := visit.Complete(now); err != nil {
				return withErrorContext("camp.end", "domain.visit_complete", err, map[string]any{"visit_id": string(visit.ID())})
			}
			if _, err := track.CompleteVisit(now); err != nil {
				return withErrorContext("camp.end", "domain.track_complete_visit", err, map[string]any{"track_id": string(track.ID())})
			}
			if err := group.MarkVisitCompleted(visit.CornerID()); err != nil {
				return withErrorContext("camp.end", "domain.group_mark_completed", err, map[string]any{"group_id": string(group.ID()), "corner_id": string(visit.CornerID())})
			}

			if err := s.visits.Save(ctx, visit); err != nil {
				return withErrorContext("camp.end", "repository.save_visit", err, map[string]any{"visit_id": string(visit.ID())})
			}
			if err := s.tracks.Save(ctx, track); err != nil {
				return withErrorContext("camp.end", "repository.save_track", err, map[string]any{"track_id": string(track.ID())})
			}
			if err := s.groups.Save(ctx, group); err != nil {
				return withErrorContext("camp.end", "repository.save_group", err, map[string]any{"group_id": string(group.ID())})
			}
		}

		if err := s.camps.Save(ctx, camp); err != nil {
			return withErrorContext("camp.end", "repository.save_camp", err, map[string]any{"camp_id": string(campID)})
		}
		return nil
	})

	if err != nil {
		s.recordAuditLog(ctx, string(actorAdminID), adminActorLabel(ctx, s.admins, actorAdminID, nil), ActionCampEnd, string(campID), false, errorAuditMetadata(err, nil))
		return err // D-2 allowed: already wrapped or handled
	}

	s.recordAuditLog(ctx, string(actorAdminID), adminActorLabel(ctx, s.admins, actorAdminID, nil), ActionCampEnd, string(campID), true, nil)
	_ = s.broadcaster.Broadcast(ctx, campID, EventCampEnded, CampScope())
	_ = s.broadcaster.Broadcast(ctx, campID, EventCampUpdated, CampScope())
	_ = s.broadcaster.Broadcast(ctx, campID, EventDeviceRegistrationUpdated, CampScope())
	_ = s.broadcaster.Broadcast(ctx, campID, EventCornersUpdated, CampScope())
	_ = s.broadcaster.Broadcast(ctx, campID, EventGroupsUpdated, CampScope())
	_ = s.broadcaster.Broadcast(ctx, campID, EventTracksUpdated, CampScope())

	return nil
}

func (s *CampService) recordAuditLog(ctx context.Context, actor, actorName string, action AuditAction, target string, success bool, metadata map[string]any) {
	log := domain.NewAuditLogFromProps(domain.AuditLogProps{
		ID:         domain.AuditLogID(s.uuidFn()),
		Actor:      actor,
		ActorName:  actorName,
		Action:     string(action),
		Target:     target,
		Success:    success,
		OccurredAt: s.nowFn(),
		Metadata:   metadata,
	})
	_ = s.auditLogs.Save(ctx, log)
}
