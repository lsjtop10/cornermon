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
		return nil, "", withErrorContext("track.create", "repository.get_camp", err, map[string]any{"camp_id": string(campID)})
	}
	if camp == nil || camp.Status() == domain.CampEnded {
		var status string
		if camp != nil {
			status = string(camp.Status())
		}
		return nil, "", withErrorContext("track.create", "validate_camp", domain.ErrCampInvalidTransition, map[string]any{"camp_id": string(campID), "camp_found": camp != nil, "camp_status": status})
	}

	corner, err := s.corners.Get(ctx, cornerID)
	if err != nil {
		return nil, "", withErrorContext("track.create", "repository.get_corner", err, map[string]any{"corner_id": string(cornerID)})
	}
	if corner == nil {
		return nil, "", withErrorContext("track.create", "validate_corner", domain.ErrCornerNotInItinerary, map[string]any{"corner_id": string(cornerID), "corner_found": false})
	}

	plainPIN, hashPIN, err := generateTrackPIN()
	if err != nil {
		return nil, "", withErrorContext("track.create", "domain.generate_pin", err, nil)
	}
	pinCiphertext, err := s.encryptPIN(ctx, plainPIN)
	if err != nil {
		return nil, "", withErrorContext("track.create", "protector.encrypt_pin", err, nil)
	}

	var track *domain.Track
	err = s.tx.RunInTx(ctx, func(ctx context.Context) error {
		existingTracks, err := s.tracks.ListByCorner(ctx, cornerID)
		if err != nil {
			return withErrorContext("track.create", "repository.list_tracks", err, map[string]any{"corner_id": string(cornerID)})
		}

		nextTrackNo := 1
		for _, t := range existingTracks {
			if t.TrackNo() >= nextTrackNo {
				nextTrackNo = t.TrackNo() + 1
			}
		}

		track = domain.NewTrackFromProps(domain.TrackProps{
			ID:             domain.TrackID(s.uuidFn()),
			CornerID:       cornerID,
			TrackNo:        nextTrackNo,
			Status:         domain.TrackActive,
			PINHash:        hashPIN,
			PINCiphertext:  pinCiphertext,
			CurrentVisitID: domain.None[domain.VisitID](),
		})

		if err := s.tracks.Save(ctx, track); err != nil {
			return withErrorContext("track.create", "repository.save_track", err, map[string]any{"track_id": string(track.ID())})
		}
		return nil
	})

	if err != nil {
		s.recordAuditLog(ctx, "admin", ActionTrackCreate, "", false, errorAuditMetadata(err, nil))
		return nil, "", err
	}

	s.recordAuditLog(ctx, "admin", ActionTrackCreate, string(track.ID()), true, map[string]any{"campID": string(campID), "cornerID": string(cornerID)})
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
		return false, withErrorContext("track.delete", "repository.get_track", err, map[string]any{"track_id": string(trackID)})
	}
	if track == nil {
		return false, withErrorContext("track.delete", "validate_track", domain.ErrTrackNotActive, map[string]any{"track_id": string(trackID), "track_found": false})
	}

	var isLastTrack bool
	var cornerCampID domain.CampID

	err = s.tx.RunInTx(ctx, func(ctx context.Context) error {
		if _, err := track.Delete(now); err != nil {
			return withErrorContext("track.delete", "domain.delete", err, map[string]any{"track_id": string(trackID)})
		}

		allTracks, err := s.tracks.ListByCorner(ctx, track.CornerID())
		if err != nil {
			return withErrorContext("track.delete", "repository.list_tracks", err, map[string]any{"corner_id": string(track.CornerID())})
		}

		activeCount := 0
		for _, t := range allTracks {
			if t.ID() != trackID && t.Status() == domain.TrackActive {
				activeCount++
			}
		}
		isLastTrack = (activeCount == 0)

		corner, err := s.corners.Get(ctx, track.CornerID())
		if err != nil {
			return withErrorContext("track.delete", "repository.get_corner", err, map[string]any{"corner_id": string(track.CornerID())})
		}
		if corner != nil {
			cornerCampID = corner.CampID()
		}

		sessions, err := s.sessions.ListActiveByTrack(ctx, trackID)
		if err != nil {
			return withErrorContext("track.delete", "repository.list_sessions", err, map[string]any{"track_id": string(trackID)})
		}
		for _, sess := range sessions {
			if err := sess.Revoke(now); err == nil {
				if err := s.sessions.Save(ctx, sess); err != nil {
					return withErrorContext("track.delete", "repository.save_session", err, map[string]any{"session_id": string(sess.ID())})
				}
			}
		}

		if err := s.tracks.Save(ctx, track); err != nil {
			return withErrorContext("track.delete", "repository.save_track", err, map[string]any{"track_id": string(trackID)})
		}
		return nil
	})

	if err != nil {
		s.recordAuditLog(ctx, "admin", ActionTrackDelete, string(trackID), false, errorAuditMetadata(err, nil))
		return false, err
	}

	s.recordAuditLog(ctx, "admin", ActionTrackDelete, string(trackID), true, map[string]any{"isLastTrack": isLastTrack})
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
		return nil, "", withErrorContext("track.replace", "repository.get_old_track", err, map[string]any{"old_track_id": string(oldTrackID)})
	}
	if oldTrack == nil {
		return nil, "", withErrorContext("track.replace", "validate_old_track", domain.ErrTrackNotActive, map[string]any{"old_track_id": string(oldTrackID), "track_found": false})
	}

	newCorner, err := s.corners.Get(ctx, newCornerID)
	if err != nil {
		return nil, "", withErrorContext("track.replace", "repository.get_new_corner", err, map[string]any{"new_corner_id": string(newCornerID)})
	}
	if newCorner == nil {
		return nil, "", withErrorContext("track.replace", "validate_new_corner", domain.ErrCornerNotFound, map[string]any{"new_corner_id": string(newCornerID), "corner_found": false})
	}
	oldCorner, err := s.corners.Get(ctx, oldTrack.CornerID())
	if err != nil {
		return nil, "", withErrorContext("track.replace", "repository.get_old_corner", err, map[string]any{"old_corner_id": string(oldTrack.CornerID())})
	}
	if oldCorner == nil {
		return nil, "", withErrorContext("track.replace", "validate_old_corner", domain.ErrCornerNotFound, map[string]any{"old_corner_id": string(oldTrack.CornerID()), "corner_found": false})
	}
	if oldCorner.CampID() != newCorner.CampID() {
		return nil, "", withErrorContext("track.replace", "validate_camp_match", domain.ErrTrackCampMismatch, map[string]any{
			"old_camp_id": string(oldCorner.CampID()), "new_camp_id": string(newCorner.CampID()),
		})
	}

	plainPIN, hashPIN, err := generateTrackPIN()
	if err != nil {
		return nil, "", withErrorContext("track.replace", "domain.generate_pin", err, nil)
	}
	pinCiphertext, err := s.encryptPIN(ctx, plainPIN)
	if err != nil {
		return nil, "", withErrorContext("track.replace", "protector.encrypt_pin", err, nil)
	}

	var newTrack *domain.Track

	err = s.tx.RunInTx(ctx, func(ctx context.Context) error {
		if _, err := oldTrack.Delete(now); err != nil {
			return withErrorContext("track.replace", "domain.delete_old", err, map[string]any{"old_track_id": string(oldTrackID)})
		}

		if err := s.tracks.Save(ctx, oldTrack); err != nil {
			return withErrorContext("track.replace", "repository.save_old_track", err, map[string]any{"old_track_id": string(oldTrackID)})
		}

		existingTracks, err := s.tracks.ListByCorner(ctx, newCornerID)
		if err != nil {
			return withErrorContext("track.replace", "repository.list_new_tracks", err, map[string]any{"new_corner_id": string(newCornerID)})
		}

		nextTrackNo := 1
		for _, t := range existingTracks {
			if t.TrackNo() >= nextTrackNo {
				nextTrackNo = t.TrackNo() + 1
			}
		}

		newTrackID := domain.TrackID(s.uuidFn())
		newTrack = domain.NewTrackFromProps(domain.TrackProps{
			ID:             newTrackID,
			CornerID:       newCornerID,
			TrackNo:        nextTrackNo,
			Status:         domain.TrackActive,
			PINHash:        hashPIN,
			PINCiphertext:  pinCiphertext,
			CurrentVisitID: domain.None[domain.VisitID](),
		})

		if err := s.tracks.Save(ctx, newTrack); err != nil {
			return withErrorContext("track.replace", "repository.save_new_track", err, map[string]any{"new_track_id": string(newTrack.ID())})
		}

		sessions, err := s.sessions.ListActiveByTrack(ctx, oldTrackID)
		if err != nil {
			return withErrorContext("track.replace", "repository.list_sessions", err, map[string]any{"old_track_id": string(oldTrackID)})
		}
		for _, sess := range sessions {
			sess.SetMigrationTarget(newTrackID)
			if err := s.sessions.Save(ctx, sess); err != nil {
				return withErrorContext("track.replace", "repository.save_session", err, map[string]any{"session_id": string(sess.ID())})
			}
		}

		return nil
	})

	if err != nil {
		s.recordAuditLog(ctx, "admin", ActionTrackReplace, string(oldTrackID), false, errorAuditMetadata(err, nil))
		return nil, "", err
	}

	s.recordAuditLog(ctx, "admin", ActionTrackReplace, string(newTrack.ID()), true, map[string]any{"oldTrackID": string(oldTrackID)})
	_ = s.broadcaster.Broadcast(ctx, newCorner.CampID(), EventTracksUpdated, CampScope())
	_ = s.broadcaster.Broadcast(ctx, newCorner.CampID(), EventTrackReplaced, TrackScope(oldTrackID))

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
		return nil, "", withErrorContext("track.regenerate_pin", "repository.get_track", err, map[string]any{"track_id": string(trackID)})
	}
	if track == nil || track.Status() != domain.TrackActive {
		var status string
		if track != nil {
			status = string(track.Status())
		}
		return nil, "", withErrorContext("track.regenerate_pin", "validate_track", domain.ErrTrackNotActive, map[string]any{"track_id": string(trackID), "track_found": track != nil, "track_status": status})
	}

	plainPIN, hashPIN, err := generateTrackPIN()
	if err != nil {
		return nil, "", withErrorContext("track.regenerate_pin", "domain.generate_pin", err, nil)
	}
	pinCiphertext, err := s.encryptPIN(ctx, plainPIN)
	if err != nil {
		return nil, "", withErrorContext("track.regenerate_pin", "protector.encrypt_pin", err, nil)
	}

	var cornerCampID domain.CampID

	err = s.tx.RunInTx(ctx, func(ctx context.Context) error {
		if _, err := track.RegeneratePIN(hashPIN, now); err != nil {
			return withErrorContext("track.regenerate_pin", "domain.regenerate_pin", err, map[string]any{"track_id": string(trackID)})
		}
		track.SetPINCiphertext(pinCiphertext)

		corner, err := s.corners.Get(ctx, track.CornerID())
		if err != nil {
			return withErrorContext("track.regenerate_pin", "repository.get_corner", err, map[string]any{"corner_id": string(track.CornerID())})
		}
		if corner != nil {
			cornerCampID = corner.CampID()
		}

		sessions, err := s.sessions.ListActiveByTrack(ctx, trackID)
		if err != nil {
			return withErrorContext("track.regenerate_pin", "repository.list_sessions", err, map[string]any{"track_id": string(trackID)})
		}
		for _, sess := range sessions {
			if err := sess.Revoke(now); err == nil {
				if err := s.sessions.Save(ctx, sess); err != nil {
					return withErrorContext("track.regenerate_pin", "repository.save_session", err, map[string]any{"session_id": string(sess.ID())})
				}
			}
		}

		if err := s.tracks.Save(ctx, track); err != nil {
			return withErrorContext("track.regenerate_pin", "repository.save_track", err, map[string]any{"track_id": string(trackID)})
		}
		return nil
	})

	if err != nil {
		s.recordAuditLog(ctx, "admin", ActionPinRegenerate, string(trackID), false, errorAuditMetadata(err, nil))
		return nil, "", err
	}

	s.recordAuditLog(ctx, "admin", ActionPinRegenerate, string(trackID), true, nil)
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
	if err != nil {
		return nil, "", err
	}
	if track == nil || track.Status() != domain.TrackActive {
		return nil, "", domain.ErrTrackNotActive
	}
	if track.PINCiphertext() == "" || s.pinProtector == nil {
		return nil, "", fmt.Errorf("track PIN must be regenerated before export")
	}
	pin, err := s.pinProtector.Decrypt(ctx, track.PINCiphertext())
	return track, pin, err
}

func (s *TrackService) ExportTrackPINs(ctx context.Context, campID domain.CampID) ([]*domain.Track, []string, error) {
	tracks, err := s.tracks.ListActiveByCamp(ctx, campID)
	if err != nil || s.pinProtector == nil {
		return nil, nil, fmt.Errorf("track PIN export unavailable: %w", err)
	}
	pins := make([]string, len(tracks))
	for i, track := range tracks {
		if track.PINCiphertext() == "" {
			return nil, nil, fmt.Errorf("track PIN must be regenerated before export")
		}
		if pins[i], err = s.pinProtector.Decrypt(ctx, track.PINCiphertext()); err != nil {
			return nil, nil, err
		}
	}
	s.recordAuditLog(ctx, "admin", ActionTrackPinExport, string(campID), true, map[string]any{"count": len(tracks)})
	return tracks, pins, nil
}

func (s *TrackService) recordAuditLog(ctx context.Context, actor string, action AuditAction, target string, success bool, metadata map[string]any) {
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
