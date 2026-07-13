package usecase

import (
	"context"
	"time"

	"cornermon/backend/internal/domain"

	"github.com/google/uuid"
)

type CornerService struct {
	camps       CampRepository
	corners     CornerRepository
	auditLogs   AuditLogRepository
	broadcaster Broadcaster
	tx          TxManager

	nowFn  func() time.Time
	uuidFn func() string
}

func NewCornerService(
	camps CampRepository,
	corners CornerRepository,
	auditLogs AuditLogRepository,
	broadcaster Broadcaster,
	tx TxManager,
) *CornerService {
	return &CornerService{
		camps:       camps,
		corners:     corners,
		auditLogs:   auditLogs,
		broadcaster: broadcaster,
		tx:          tx,
		nowFn:       func() time.Time { return time.Now().UTC() },
		uuidFn:      uuid.NewString,
	}
}

// AddLearningCorner
func (s *CornerService) AddLearningCorner(ctx context.Context, campID domain.CampID, name string) (*domain.Corner, error) {
	camp, err := s.camps.Get(ctx, campID)
	if err != nil {
		return nil, err
	}
	if camp == nil {
		return nil, domain.ErrCampInvalidTransition
	}

	corner := &domain.Corner{
		ID:     domain.CornerID(s.uuidFn()),
		CampID: campID,
		Name:   name,
	}

	err = s.tx.RunInTx(ctx, func(ctx context.Context) error {
		return s.corners.Save(ctx, corner)
	})

	if err != nil {
		s.recordAuditLog(ctx, "admin", "CORNER_CREATE", "", false, map[string]any{"error": err.Error()})
		return nil, err
	}

	s.recordAuditLog(ctx, "admin", "CORNER_CREATE", string(corner.ID), true, map[string]any{"campID": string(campID), "name": name})
	_ = s.broadcaster.Broadcast(ctx, campID, EventCornersUpdated, "camp")

	return corner, nil
}

// ListCorners
func (s *CornerService) ListCorners(ctx context.Context, campID domain.CampID) ([]*domain.Corner, error) {
	return s.corners.ListByCamp(ctx, campID)
}

// GetCorner
func (s *CornerService) GetCorner(ctx context.Context, id domain.CornerID) (*domain.Corner, error) {
	corner, err := s.corners.Get(ctx, id)
	if err != nil {
		return nil, err
	}
	if corner == nil {
		return nil, domain.ErrCornerNotFound
	}
	return corner, nil
}

// ModifyCornerSpecification
func (s *CornerService) ModifyCornerSpecification(ctx context.Context, id domain.CornerID, name string) (*domain.Corner, error) {
	corner, err := s.corners.Get(ctx, id)
	if err != nil {
		return nil, err
	}
	if corner == nil {
		return nil, domain.ErrCornerNotInItinerary
	}

	corner.Name = name // assuming Name is modifiable

	err = s.tx.RunInTx(ctx, func(ctx context.Context) error {
		return s.corners.Save(ctx, corner)
	})

	if err != nil {
		s.recordAuditLog(ctx, "admin", "CORNER_UPDATE", string(id), false, map[string]any{"error": err.Error()})
		return nil, err
	}

	s.recordAuditLog(ctx, "admin", "CORNER_UPDATE", string(id), true, map[string]any{"name": name})
	_ = s.broadcaster.Broadcast(ctx, corner.CampID, EventCornersUpdated, "camp")

	return corner, nil
}

// RemoveCornerFromCamp
func (s *CornerService) RemoveCornerFromCamp(ctx context.Context, id domain.CornerID) error {
	corner, err := s.corners.Get(ctx, id)
	if err != nil {
		return err
	}
	if corner == nil {
		return nil // already removed
	}

	err = s.tx.RunInTx(ctx, func(ctx context.Context) error {
		return s.corners.Delete(ctx, id)
	})

	if err != nil {
		s.recordAuditLog(ctx, "admin", "CORNER_DELETE", string(id), false, map[string]any{"error": err.Error()})
		return err
	}

	s.recordAuditLog(ctx, "admin", "CORNER_DELETE", string(id), true, nil)
	_ = s.broadcaster.Broadcast(ctx, corner.CampID, EventCornersUpdated, "camp")

	return nil
}

func (s *CornerService) recordAuditLog(ctx context.Context, actor, action, target string, success bool, metadata map[string]any) {
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
