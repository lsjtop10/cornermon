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
		auditLogs:   auditLogs,
		broadcaster: broadcaster,
		tx:          tx,
		nowFn:       func() time.Time { return time.Now().UTC() },
		uuidFn:      uuid.NewString,
	}
}

// OpenNewCamp
func (s *CampService) OpenNewCamp(ctx context.Context, name string, startAt, endAt time.Time) (*domain.Camp, error) {
	camp, err := domain.NewCamp(domain.CampID(s.uuidFn()), name, startAt, endAt)
	if err != nil {
		return nil, err
	}
	err = s.tx.RunInTx(ctx, func(ctx context.Context) error {
		return s.camps.Save(ctx, camp)
	})
	if err != nil {
		s.recordAuditLog(ctx, "admin", ActionCampCreate, "", false, map[string]any{"error": err.Error()})
		return nil, err
	}
	s.recordAuditLog(ctx, "admin", ActionCampCreate, string(camp.ID()), true, map[string]any{"name": name})
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
		return nil, err
	}
	if camp == nil {
		return nil, domain.ErrCampNotFound
	}
	if err := camp.UpdateSettings(patch); err != nil {
		return nil, err
	}

	err = s.tx.RunInTx(ctx, func(ctx context.Context) error {
		return s.camps.Save(ctx, camp)
	})
	if err != nil {
		s.recordAuditLog(ctx, string(actorAdminID), ActionCampSettingsUpdate, string(campID), false, map[string]any{"error": err.Error()})
		return nil, err
	}

	s.recordAuditLog(ctx, string(actorAdminID), ActionCampSettingsUpdate, string(campID), true, nil)
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
		return err
	}
	if camp == nil {
		return domain.ErrCampInvalidTransition
	}

	if err := camp.Activate(now); err != nil {
		return err
	}

	err = s.tx.RunInTx(ctx, func(ctx context.Context) error {
		return s.camps.Save(ctx, camp)
	})

	if err != nil {
		s.recordAuditLog(ctx, string(actorAdminID), ActionCampActivate, string(campID), false, map[string]any{"error": err.Error()})
		return err
	}

	s.recordAuditLog(ctx, string(actorAdminID), ActionCampActivate, string(campID), true, nil)
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
			return err
		}
		if camp == nil {
			return domain.ErrCampInvalidTransition
		}
		if _, err := camp.End(now); err != nil {
			return err
		}

		approvedStatus := domain.DeviceApproved
		devices, err := s.devices.ListByCampAndStatus(ctx, campID, &approvedStatus)
		if err != nil {
			return err
		}
		for _, device := range devices {
			if err := device.Revoke(); err != nil {
				return err
			}
			if err := s.devices.Save(ctx, device); err != nil {
				return err
			}
		}

		sessions, err := s.sessions.ListActiveByCamp(ctx, campID)
		if err != nil {
			return err
		}
		for _, sess := range sessions {
			if err := sess.Revoke(now); err == nil {
				if err := s.sessions.Save(ctx, sess); err != nil {
					return err
				}
			}
		}

		visits, err := s.visits.ListInProgressByCamp(ctx, campID)
		if err != nil {
			return err
		}
		for _, visit := range visits {
			group, err := s.groups.Get(ctx, visit.GroupID())
			if err != nil {
				return err
			}
			if group == nil {
				return domain.ErrCornerNotInItinerary
			}

			track, err := s.tracks.Get(ctx, visit.TrackID())
			if err != nil {
				return err
			}
			if track == nil {
				return domain.ErrTrackNotActive
			}

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
		}

		return s.camps.Save(ctx, camp)
	})

	if err != nil {
		s.recordAuditLog(ctx, string(actorAdminID), ActionCampEnd, string(campID), false, map[string]any{"error": err.Error()})
		return err
	}

	s.recordAuditLog(ctx, string(actorAdminID), ActionCampEnd, string(campID), true, nil)
	_ = s.broadcaster.Broadcast(ctx, campID, EventCampUpdated, CampScope())
	_ = s.broadcaster.Broadcast(ctx, campID, EventDeviceRegistrationUpdated, CampScope())
	_ = s.broadcaster.Broadcast(ctx, campID, EventCornersUpdated, CampScope())
	_ = s.broadcaster.Broadcast(ctx, campID, EventGroupsUpdated, CampScope())
	_ = s.broadcaster.Broadcast(ctx, campID, EventTracksUpdated, CampScope())
	_ = s.broadcaster.Broadcast(ctx, campID, EventCampEnded, CampScope())

	return nil
}

func (s *CampService) recordAuditLog(ctx context.Context, actor string, action AuditAction, target string, success bool, metadata map[string]any) {
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
