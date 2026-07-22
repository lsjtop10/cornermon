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
	tracks      TrackRepository
	groups      GroupRepository
	auditLogs   AuditLogRepository
	broadcaster Broadcaster
	tx          TxManager

	nowFn  func() time.Time
	uuidFn func() string
}

func NewCornerService(
	camps CampRepository,
	corners CornerRepository,
	tracks TrackRepository,
	groups GroupRepository,
	auditLogs AuditLogRepository,
	broadcaster Broadcaster,
	tx TxManager,
) *CornerService {
	return &CornerService{
		camps:       camps,
		corners:     corners,
		tracks:      tracks,
		groups:      groups,
		auditLogs:   auditLogs,
		broadcaster: broadcaster,
		tx:          tx,
		nowFn:       func() time.Time { return time.Now().UTC() },
		uuidFn:      uuid.NewString,
	}
}

// AddLearningCorner
func (s *CornerService) AddLearningCorner(ctx context.Context, campID domain.CampID, name string, targetMinutes int) (*domain.Corner, error) {

	camp, err := s.camps.Get(ctx, campID)
	if err != nil {
		return nil, withErrorContext("corner.add", "repository.get_camp", err, map[string]any{"camp_id": string(campID)})
	}
	if camp == nil {
		return nil, withErrorContext("corner.add", "validate_camp", domain.ErrCampInvalidTransition, map[string]any{"camp_id": string(campID), "camp_found": false})
	}

	corner := domain.NewCornerFromProps(domain.CornerProps{
		ID:            domain.CornerID(s.uuidFn()),
		CampID:        campID,
		Name:          name,
		TargetMinutes: targetMinutes,
	})

	err = s.tx.RunInTx(ctx, func(ctx context.Context) error {
		if err := s.corners.Save(ctx, corner); err != nil {
			return withErrorContext("corner.add", "repository.save_corner", err, map[string]any{"corner_id": string(corner.ID())})
		}
		if err := s.syncGroupItineraries(ctx, campID, func(g *domain.Group) {
			g.AddCornerToItinerary(corner.ID())
		}); err != nil {
			return withErrorContext("corner.add", "domain.sync_itinerary", err, map[string]any{"corner_id": string(corner.ID())})
		}
		return nil
	})

	if err != nil {
		s.recordAuditLog(ctx, "admin", ActionCornerCreate, "", false, errorAuditMetadata(err, nil))
		return nil, err
	}

	s.recordAuditLog(ctx, "admin", ActionCornerCreate, string(corner.ID()), true, map[string]any{"campID": string(campID), "name": name})
	_ = s.broadcaster.Broadcast(ctx, campID, EventCornersUpdated, CampScope())

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
		return nil, withErrorContext("corner.get", "repository.get_corner", err, map[string]any{"corner_id": string(id)})
	}
	if corner == nil {
		return nil, withErrorContext("corner.get", "validate_corner", domain.ErrCornerNotFound, map[string]any{"corner_id": string(id), "corner_found": false})
	}
	return corner, nil
}

// GetCornerByTrack derives the corner from the track's immutable corner
// assignment — for TrackAuth (진행자) callers, who may only see their own
// track's corner, never another track's admin-facing detail.
func (s *CornerService) GetCornerByTrack(ctx context.Context, trackID domain.TrackID) (*domain.Corner, error) {

	track, err := s.tracks.Get(ctx, trackID)
	if err != nil {
		return nil, withErrorContext("corner.get_by_track", "repository.get_track", err, map[string]any{"track_id": string(trackID)})
	}
	if track == nil {
		return nil, withErrorContext("corner.get_by_track", "validate_track", domain.ErrTrackNotFound, map[string]any{"track_id": string(trackID), "track_found": false})
	}

	corner, err := s.corners.Get(ctx, track.CornerID())
	if err != nil {
		return nil, withErrorContext("corner.get_by_track", "repository.get_corner", err, map[string]any{"corner_id": string(track.CornerID())})
	}
	if corner == nil {
		return nil, withErrorContext("corner.get_by_track", "validate_corner", domain.ErrCornerNotFound, map[string]any{"corner_id": string(track.CornerID()), "corner_found": false})
	}
	return corner, nil
}

// ModifyCornerSpecification
func (s *CornerService) ModifyCornerSpecification(ctx context.Context, id domain.CornerID, name string, targetMinutes int) (*domain.Corner, error) {

	corner, err := s.corners.Get(ctx, id)
	if err != nil {
		return nil, withErrorContext("corner.modify", "repository.get_corner", err, map[string]any{"corner_id": string(id)})
	}
	if corner == nil {
		return nil, withErrorContext("corner.modify", "validate_corner", domain.ErrCornerNotInItinerary, map[string]any{"corner_id": string(id), "corner_found": false})
	}

	corner.SetName(name)
	corner.SetTargetMinutes(targetMinutes)

	err = s.tx.RunInTx(ctx, func(ctx context.Context) error {
		if err := s.corners.Save(ctx, corner); err != nil {
			return withErrorContext("corner.modify", "repository.save_corner", err, map[string]any{"corner_id": string(id)})
		}
		return nil
	})

	if err != nil {
		s.recordAuditLog(ctx, "admin", ActionCornerUpdate, string(id), false, errorAuditMetadata(err, nil))
		return nil, err
	}

	s.recordAuditLog(ctx, "admin", ActionCornerUpdate, string(id), true, map[string]any{"name": name, "targetMinutes": targetMinutes})
	_ = s.broadcaster.Broadcast(ctx, corner.CampID(), EventCornersUpdated, CampScope())

	return corner, nil
}

// RemoveCornerFromCamp
func (s *CornerService) RemoveCornerFromCamp(ctx context.Context, id domain.CornerID) error {

	corner, err := s.corners.Get(ctx, id)
	if err != nil {
		return withErrorContext("corner.remove", "repository.get_corner", err, map[string]any{"corner_id": string(id)})
	}
	if corner == nil {
		return nil // already removed
	}

	err = s.tx.RunInTx(ctx, func(ctx context.Context) error {
		if err := s.corners.SoftDelete(ctx, id, s.nowFn()); err != nil {
			return withErrorContext("corner.remove", "repository.soft_delete", err, map[string]any{"corner_id": string(id)})
		}
		if err := s.syncGroupItineraries(ctx, corner.CampID(), func(g *domain.Group) {
			g.RemoveCornerFromItinerary(id)
		}); err != nil {
			return withErrorContext("corner.remove", "domain.sync_itinerary", err, map[string]any{"corner_id": string(id)})
		}
		return nil
	})

	if err != nil {
		s.recordAuditLog(ctx, "admin", ActionCornerDelete, string(id), false, errorAuditMetadata(err, nil))
		return err // D-2 allowed: already wrapped or handled
	}

	s.recordAuditLog(ctx, "admin", ActionCornerDelete, string(id), true, nil)
	_ = s.broadcaster.Broadcast(ctx, corner.CampID(), EventCornersUpdated, CampScope())

	return nil
}

// syncGroupItineraries는 코너 추가/삭제에 맞춰 캠프 내 모든 조의 순회표를 갱신한다.
// ListByCampForUpdate로 한 번에 잠금+조회(N+1 방지)한 뒤 SaveBulk로 한 트랜잭션에서
// 저장하며, 반드시 호출부의 s.tx.RunInTx 블록 안에서만 호출해야 한다.
func (s *CornerService) syncGroupItineraries(ctx context.Context, campID domain.CampID, mutate func(*domain.Group)) error {
	groups, err := s.groups.ListByCampForUpdate(ctx, campID)
	if err != nil {
		return err // D-2 allowed: already wrapped or handled
	}
	for _, g := range groups {
		mutate(g)
	}
	return s.groups.SaveBulk(ctx, groups)
}

func (s *CornerService) recordAuditLog(ctx context.Context, actor string, action AuditAction, target string, success bool, metadata map[string]any) {
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
