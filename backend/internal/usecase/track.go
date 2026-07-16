package usecase

import (
	"context"
	"fmt"
	"time"

	"cornermon/backend/internal/domain"

	"github.com/google/uuid"
)

type TrackService struct {
	camps        CampRepository
	corners      CornerRepository
	tracks       TrackRepository
	sessions     FacilitatorSessionRepository
	auditLogs    AuditLogRepository
	broadcaster  Broadcaster
	tx           TxManager
	pinProtector TrackPINProtector

	nowFn  func() time.Time
	uuidFn func() string
}

func NewTrackService(
	camps CampRepository,
	corners CornerRepository,
	tracks TrackRepository,
	sessions FacilitatorSessionRepository,
	auditLogs AuditLogRepository,
	broadcaster Broadcaster,
	tx TxManager,
	pinProtectors ...TrackPINProtector,
) *TrackService {
	var pinProtector TrackPINProtector
	if len(pinProtectors) > 0 {
		pinProtector = pinProtectors[0]
	}
	return &TrackService{
		camps:        camps,
		corners:      corners,
		tracks:       tracks,
		sessions:     sessions,
		auditLogs:    auditLogs,
		broadcaster:  broadcaster,
		tx:           tx,
		pinProtector: pinProtector,
		nowFn:        func() time.Time { return time.Now().UTC() },
		uuidFn:       uuid.NewString,
	}
}

// CreateTrack - UC-4
func (s *TrackService) CreateTrack(
	ctx context.Context,
	campID domain.CampID,
	cornerID domain.CornerID,
) (*domain.Track, string, error) {
	camp, err := s.camps.Get(ctx, campID)
	if err != nil {
		return nil, "", err
	}

	if camp == nil {
		return nil, "", domain.ErrCampInvalidTransition
	}

	corner, err := s.corners.Get(ctx, cornerID)
	if err != nil {
		return nil, "", err
	}
	if corner == nil {
		return nil, "", domain.ErrCornerNotInItinerary // Corner not found
	}

	plainPIN, hashPIN, err := generateTrackPIN()
	if err != nil {
		return nil, "", err
	}
	pinCiphertext, err := s.encryptPIN(ctx, plainPIN)
	if err != nil {
		return nil, "", err
	}

	var track *domain.Track
	err = s.tx.RunInTx(ctx, func(ctx context.Context) error {
		existingTracks, err := s.tracks.ListByCorner(ctx, cornerID)
		if err != nil {
			return err
		}

		nextTrackNo := 1
		for _, t := range existingTracks {
			if t.TrackNo >= nextTrackNo {
				nextTrackNo = t.TrackNo + 1
			}
		}

		track = &domain.Track{
			ID:             domain.TrackID(s.uuidFn()),
			CornerID:       cornerID,
			TrackNo:        nextTrackNo,
			Status:         domain.TrackActive,
			PINHash:        hashPIN,
			PINCiphertext:  pinCiphertext,
			CurrentVisitID: domain.None[domain.VisitID](),
		}

		return s.tracks.Save(ctx, track)
	})

	if err != nil {
		s.recordAuditLog(ctx, "admin", "TRACK_CREATE", "", false, map[string]any{"error": err.Error()})
		return nil, "", err
	}

	s.recordAuditLog(ctx, "admin", "TRACK_CREATE", string(track.ID), true, map[string]any{"campID": string(campID), "cornerID": string(cornerID)})
	_ = s.broadcaster.Broadcast(ctx, campID, EventTracksUpdated, CampScope())

	return track, plainPIN, nil
}

// DeleteTrack - UC-5
func (s *TrackService) DeleteTrack(
	ctx context.Context,
	trackID domain.TrackID,
) (bool, error) {
	now := s.nowFn()
	track, err := s.tracks.Get(ctx, trackID)
	if err != nil {
		return false, err
	}
	if track == nil {
		return false, domain.ErrTrackNotActive
	}

	var isLastTrack bool
	var cornerCampID domain.CampID

	err = s.tx.RunInTx(ctx, func(ctx context.Context) error {
		// Event를 트리거하여 상태 변경
		if _, err := track.Delete(now); err != nil {
			return err
		}

		// 마지막 트랙인지 여부 확인
		allTracks, err := s.tracks.ListByCorner(ctx, track.CornerID)
		if err != nil {
			return err
		}

		activeCount := 0
		for _, t := range allTracks {
			if t.ID != trackID && t.Status == domain.TrackActive {
				activeCount++
			}
		}
		isLastTrack = (activeCount == 0)

		// 캠프 ID 확인을 위해 코너 정보 조회
		corner, err := s.corners.Get(ctx, track.CornerID)
		if err != nil {
			return err
		}
		if corner != nil {
			cornerCampID = corner.CampID
		}

		// 세션 일괄 Revoke
		sessions, err := s.sessions.ListActiveByTrack(ctx, trackID)
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

		return s.tracks.Save(ctx, track)
	})

	if err != nil {
		s.recordAuditLog(ctx, "admin", "TRACK_DELETE", string(trackID), false, map[string]any{"error": err.Error()})
		return false, err
	}

	s.recordAuditLog(ctx, "admin", "TRACK_DELETE", string(trackID), true, map[string]any{"isLastTrack": isLastTrack})
	if cornerCampID != "" {
		_ = s.broadcaster.Broadcast(ctx, cornerCampID, EventTracksUpdated, CampScope())
		_ = s.broadcaster.Broadcast(ctx, cornerCampID, EventTrackDeleted, TrackScope(trackID))
	}

	return isLastTrack, nil
}

// ReplaceTrack - UC-6
func (s *TrackService) ReplaceTrack(
	ctx context.Context,
	oldTrackID domain.TrackID,
	newCornerID domain.CornerID,
) (*domain.Track, string, error) {
	now := s.nowFn()
	oldTrack, err := s.tracks.Get(ctx, oldTrackID)
	if err != nil {
		return nil, "", err
	}
	if oldTrack == nil {
		return nil, "", domain.ErrTrackNotActive
	}

	newCorner, err := s.corners.Get(ctx, newCornerID)
	if err != nil {
		return nil, "", err
	}
	if newCorner == nil {
		return nil, "", domain.ErrCornerNotFound
	}
	oldCorner, err := s.corners.Get(ctx, oldTrack.CornerID)
	if err != nil {
		return nil, "", err
	}
	if oldCorner == nil {
		return nil, "", domain.ErrCornerNotFound
	}
	if oldCorner.CampID != newCorner.CampID {
		return nil, "", domain.ErrTrackCampMismatch
	}

	plainPIN, hashPIN, err := generateTrackPIN()
	if err != nil {
		return nil, "", err
	}
	pinCiphertext, err := s.encryptPIN(ctx, plainPIN)
	if err != nil {
		return nil, "", err
	}

	var newTrack *domain.Track

	err = s.tx.RunInTx(ctx, func(ctx context.Context) error {
		// 기존 트랙 삭제
		if _, err := oldTrack.Delete(now); err != nil {
			return err
		}

		if err := s.tracks.Save(ctx, oldTrack); err != nil {
			return err
		}

		// 신규 트랙 생성
		existingTracks, err := s.tracks.ListByCorner(ctx, newCornerID)
		if err != nil {
			return err
		}

		nextTrackNo := 1
		for _, t := range existingTracks {
			if t.TrackNo >= nextTrackNo {
				nextTrackNo = t.TrackNo + 1
			}
		}

		newTrackID := domain.TrackID(s.uuidFn())
		newTrack = &domain.Track{
			ID:             newTrackID,
			CornerID:       newCornerID,
			TrackNo:        nextTrackNo,
			Status:         domain.TrackActive,
			PINHash:        hashPIN,
			PINCiphertext:  pinCiphertext,
			CurrentVisitID: domain.None[domain.VisitID](),
		}

		if err := s.tracks.Save(ctx, newTrack); err != nil {
			return err
		}

		// 기존 트랙 세션에 마이그레이션 타겟 설정 (Revoke 하지 않음)
		sessions, err := s.sessions.ListActiveByTrack(ctx, oldTrackID)
		if err != nil {
			return err
		}
		for _, sess := range sessions {
			sess.SetMigrationTarget(newTrackID)
			if err := s.sessions.Save(ctx, sess); err != nil {
				return err
			}
		}

		return nil
	})

	if err != nil {
		s.recordAuditLog(ctx, "admin", "TRACK_REPLACE", string(oldTrackID), false, map[string]any{"error": err.Error()})
		return nil, "", err
	}

	s.recordAuditLog(ctx, "admin", "TRACK_REPLACE", string(newTrack.ID), true, map[string]any{"oldTrackID": string(oldTrackID)})
	_ = s.broadcaster.Broadcast(ctx, newCorner.CampID, EventTracksUpdated, CampScope())
	_ = s.broadcaster.Broadcast(ctx, newCorner.CampID, EventTrackReplaced, TrackScope(oldTrackID))

	return newTrack, plainPIN, nil
}

// RegeneratePIN - UC-7
func (s *TrackService) RegeneratePIN(
	ctx context.Context,
	trackID domain.TrackID,
) (*domain.Track, string, error) {
	now := s.nowFn()
	track, err := s.tracks.Get(ctx, trackID)
	if err != nil {
		return nil, "", err
	}
	if track == nil || track.Status != domain.TrackActive {
		return nil, "", domain.ErrTrackNotActive
	}

	plainPIN, hashPIN, err := generateTrackPIN()
	if err != nil {
		return nil, "", err
	}
	pinCiphertext, err := s.encryptPIN(ctx, plainPIN)
	if err != nil {
		return nil, "", err
	}

	var cornerCampID domain.CampID

	err = s.tx.RunInTx(ctx, func(ctx context.Context) error {
		if _, err := track.RegeneratePIN(hashPIN, now); err != nil {
			return err
		}
		track.PINCiphertext = pinCiphertext

		// 코너 정보 조회를 통해 캠프 ID 획득
		corner, err := s.corners.Get(ctx, track.CornerID)
		if err != nil {
			return err
		}
		if corner != nil {
			cornerCampID = corner.CampID
		}

		// 세션 일괄 Revoke
		sessions, err := s.sessions.ListActiveByTrack(ctx, trackID)
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

		return s.tracks.Save(ctx, track)
	})

	if err != nil {
		s.recordAuditLog(ctx, "admin", "PIN_REGENERATE", string(trackID), false, map[string]any{"error": err.Error()})
		return nil, "", err
	}

	s.recordAuditLog(ctx, "admin", "PIN_REGENERATE", string(trackID), true, nil)
	if cornerCampID != "" {
		_ = s.broadcaster.Broadcast(ctx, cornerCampID, EventTracksUpdated, CampScope())
		_ = s.broadcaster.Broadcast(ctx, cornerCampID, EventSessionRevoked, TrackScope(trackID))
	}

	return track, plainPIN, nil
}

func (s *TrackService) encryptPIN(ctx context.Context, pin string) (string, error) {
	if s.pinProtector == nil {
		return "", nil
	}
	return s.pinProtector.Encrypt(ctx, pin)
}

// ListTracksByCamp
func (s *TrackService) ListTracksByCamp(ctx context.Context, campID domain.CampID) ([]*domain.Track, error) {
	return s.tracks.ListByCamp(ctx, campID)
}

func (s *TrackService) ExportTrackPIN(ctx context.Context, trackID domain.TrackID) (*domain.Track, string, error) {
	track, err := s.tracks.Get(ctx, trackID)
	if err != nil || track == nil || track.Status != domain.TrackActive {
		return nil, "", err
	}
	if track.PINCiphertext == "" || s.pinProtector == nil {
		return nil, "", fmt.Errorf("track PIN must be regenerated before export")
	}
	pin, err := s.pinProtector.Decrypt(ctx, track.PINCiphertext)
	return track, pin, err
}

func (s *TrackService) ExportTrackPINs(ctx context.Context, campID domain.CampID) ([]*domain.Track, []string, error) {
	tracks, err := s.tracks.ListActiveByCamp(ctx, campID)
	if err != nil || s.pinProtector == nil {
		return nil, nil, fmt.Errorf("track PIN export unavailable: %w", err)
	}
	pins := make([]string, len(tracks))
	for i, track := range tracks {
		if track.PINCiphertext == "" {
			return nil, nil, fmt.Errorf("track PIN must be regenerated before export")
		}
		if pins[i], err = s.pinProtector.Decrypt(ctx, track.PINCiphertext); err != nil {
			return nil, nil, err
		}
	}
	s.recordAuditLog(ctx, "admin", "TRACK_PIN_EXPORT", string(campID), true, map[string]any{"count": len(tracks)})
	return tracks, pins, nil
}

func (s *TrackService) recordAuditLog(ctx context.Context, actor, action, target string, success bool, metadata map[string]any) {
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
