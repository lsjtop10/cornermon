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
	sessions FacilitatorSessionRepository,
	auditLogs AuditLogRepository,
	broadcaster Broadcaster,
	tx TxManager,
) *CampService {
	return &CampService{
		camps:       camps,
		tracks:      tracks,
		sessions:    sessions,
		auditLogs:   auditLogs,
		broadcaster: broadcaster,
		tx:          tx,
		nowFn:       time.Now,
		uuidFn:      uuid.NewString,
	}
}

// OpenNewCamp
func (s *CampService) OpenNewCamp(ctx context.Context, name string) (*domain.Camp, error) {
	camp := &domain.Camp{
		ID:                   domain.CampID(s.uuidFn()),
		Name:                 name,
		Status:               domain.CampPending,
		BottleneckMinSamples: 3,
		BottleneckRatioPct:   20,
	}
	err := s.tx.RunInTx(ctx, func(ctx context.Context) error {
		return s.camps.Save(ctx, camp)
	})
	if err != nil {
		s.recordAuditLog(ctx, "admin", "CAMP_CREATE", "", false, map[string]any{"error": err.Error()})
		return nil, err
	}
	s.recordAuditLog(ctx, "admin", "CAMP_CREATE", string(camp.ID), true, map[string]any{"name": name})
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
		s.recordAuditLog(ctx, string(actorAdminID), "CAMP_ACTIVATE", string(campID), false, map[string]any{"error": err.Error()})
		return err
	}

	s.recordAuditLog(ctx, string(actorAdminID), "CAMP_ACTIVATE", string(campID), true, nil)
	_ = s.broadcaster.Broadcast(ctx, campID, EventCampUpdated, "camp")

	return nil
}

// EndCamp - UC-20
func (s *CampService) EndCamp(
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

	if _, err := camp.End(now); err != nil {
		return err
	}

	err = s.tx.RunInTx(ctx, func(ctx context.Context) error {
		// 해당 캠프 세션 일괄 무효화
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

		return s.camps.Save(ctx, camp)
	})

	if err != nil {
		s.recordAuditLog(ctx, string(actorAdminID), "CAMP_END", string(campID), false, map[string]any{"error": err.Error()})
		return err
	}

	s.recordAuditLog(ctx, string(actorAdminID), "CAMP_END", string(campID), true, nil)
	_ = s.broadcaster.Broadcast(ctx, campID, EventCampUpdated, "camp")
	_ = s.broadcaster.Broadcast(ctx, campID, EventCampEnded, "camp")

	return nil
}

func (s *CampService) recordAuditLog(ctx context.Context, actor, action, target string, success bool, metadata map[string]any) {
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
