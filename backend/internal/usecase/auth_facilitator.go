package usecase

import (
	"context"
	"errors"
	"fmt"
	"time"

	"cornermon/backend/internal/domain"

	"github.com/google/uuid"
)

type TrackLoginResult struct {
	TrackToken string
	Track      *domain.Track
	Corner     *domain.Corner
}

type FacilitatorAuthService struct {
	camps       CampRepository
	corners     CornerRepository
	tracks      TrackRepository
	devices     DeviceRegistrationRepository
	sessions    FacilitatorSessionRepository
	auditLogs   AuditLogRepository
	broadcaster Broadcaster
	tx          TxManager

	nowFn  func() time.Time
	uuidFn func() string
}

func (s *FacilitatorAuthService) ListActiveSessions(ctx context.Context, campID domain.CampID) ([]*domain.FacilitatorSession, error) {

	sessions, err := s.sessions.ListActiveByCamp(ctx, campID)
	if err != nil {
		return nil, withErrorContext("auth_facil.list_sessions", "repository.list_sessions", err, map[string]any{"camp_id": string(campID)})
	}
	return sessions, nil
}

func NewFacilitatorAuthService(
	camps CampRepository,
	corners CornerRepository,
	tracks TrackRepository,
	devices DeviceRegistrationRepository,
	sessions FacilitatorSessionRepository,
	auditLogs AuditLogRepository,
	broadcaster Broadcaster,
	tx TxManager,
) *FacilitatorAuthService {
	return &FacilitatorAuthService{
		camps:       camps,
		corners:     corners,
		tracks:      tracks,
		devices:     devices,
		sessions:    sessions,
		auditLogs:   auditLogs,
		broadcaster: broadcaster,
		tx:          tx,
		nowFn:       func() time.Time { return time.Now().UTC() },
		uuidFn:      uuid.NewString,
	}
}

// Login - UC-9
func (s *FacilitatorAuthService) Login(
	ctx context.Context,
	deviceToken string,
	pin string,
) (*TrackLoginResult, error) {

	now := s.nowFn()
	deviceTokenHash := hashSHA256(deviceToken)

	device, err := s.devices.GetByTokenHash(ctx, deviceTokenHash)
	if err != nil {
		return nil, withErrorContext("auth_facil.login", "repository.get_device", err, nil)
	}
	if device == nil || device.Status() != domain.DeviceApproved {
		var status string
		if device != nil {
			status = string(device.Status())
		}
		err = withErrorContext("auth_facil.login", "validate_device", domain.ErrDeviceNotApproved, map[string]any{"device_found": device != nil, "device_status": status})
		s.recordAuditLog(ctx, "anonymous", ActionFacilitatorLogin, "", false, errorAuditMetadata(err, nil))
		return nil, err
	}

	if device.IsLocked(now) {
		lockedUntil, _ := device.LockedUntil().Value()
		errLocked := domain.NewDeviceLockedErrorFromProps(domain.DeviceLockedErrorProps{LockedUntil: lockedUntil})
		err = withErrorContext("auth_facil.login", "validate_device_locked", errLocked, map[string]any{"locked_until": lockedUntil})
		s.recordAuditLog(ctx, "anonymous", ActionFacilitatorLogin, "", false, errorAuditMetadata(err, nil))
		return nil, err
	}

	campID := device.CampID()

	camp, err := s.camps.Get(ctx, campID)
	if err != nil {
		return nil, withErrorContext("auth_facil.login", "repository.get_camp", err, map[string]any{"camp_id": string(campID)})
	}
	if camp == nil {
		return nil, withErrorContext("auth_facil.login", "validate_camp", fmt.Errorf("camp: camp %s is not exist", campID), map[string]any{"camp_id": string(campID), "camp_found": false})
	}

	if camp.Status() == domain.CampEnded {
		err = withErrorContext("auth_facil.login", "validate_camp_status", domain.ErrCampInvalidTransition, map[string]any{"camp_id": string(campID), "camp_status": string(camp.Status())})
		s.recordAuditLog(ctx, "anonymous", ActionFacilitatorLogin, "", false, errorAuditMetadata(err, nil))
		return nil, err
	}

	activeTracks, err := s.tracks.ListActiveByCamp(ctx, campID)
	if err != nil {
		return nil, withErrorContext("auth_facil.login", "repository.list_tracks", err, map[string]any{"camp_id": string(campID)})
	}

	var track *domain.Track
	for _, t := range activeTracks {
		if err := verifyPassword(t.PINHash(), pin); err == nil {
			track = t
			break
		}
	}

	if track == nil {
		delay, needsAdminAlert := device.RecordPinFailure(now)
		_ = s.devices.Save(ctx, device)

		if needsAdminAlert {
			_ = s.broadcaster.Broadcast(ctx, device.CampID(), EventLockoutAlert, CampScope())
		}

		var optLocked domain.Optional[time.Time]
		if delay > 0 {
			lockedUntil, _ := device.LockedUntil().Value()
			optLocked = domain.Some(lockedUntil)
		} else {
			optLocked = domain.None[time.Time]()
		}
		errInvalid := domain.NewInvalidPinErrorFromProps(domain.InvalidPinErrorProps{LockedUntil: optLocked})
		err = withErrorContext("auth_facil.login", "validate_pin", errInvalid, map[string]any{"device_id": string(device.ID()), "failures": device.FailedPinAttempts()})
		s.recordAuditLog(ctx, "anonymous", ActionFacilitatorLogin, "", false, errorAuditMetadata(err, map[string]any{"device_failures": device.FailedPinAttempts()}))
		return nil, err
	}

	trackID := track.ID()

	corner, err := s.corners.Get(ctx, track.CornerID())
	if err != nil {
		return nil, withErrorContext("auth_facil.login", "repository.get_corner", err, map[string]any{"corner_id": string(track.CornerID())})
	}
	if corner == nil {
		return nil, withErrorContext("auth_facil.login", "validate_corner", domain.ErrCornerNotInItinerary, map[string]any{"corner_id": string(track.CornerID()), "corner_found": false})
	}

	device.ResetPinFailures()

	plainToken, sessionTokenHash, err := generateOpaqueToken()
	if err != nil {
		return nil, withErrorContext("auth_facil.login", "generate_token", err, nil)
	}

	sessionID := domain.FacilitatorSessionID(s.uuidFn())
	session := domain.NewFacilitatorSessionFromProps(domain.FacilitatorSessionProps{
		ID:        sessionID,
		TrackID:   trackID,
		TokenHash: sessionTokenHash,
		CreatedAt: now,
		RevokedAt: domain.None[time.Time](),
	})

	err = s.tx.RunInTx(ctx, func(ctx context.Context) error {
		if err := s.devices.Save(ctx, device); err != nil {
			return withErrorContext("auth_facil.login", "repository.save_device", err, map[string]any{"device_id": string(device.ID())})
		}
		if err := s.sessions.Save(ctx, session); err != nil {
			return withErrorContext("auth_facil.login", "repository.save_session", err, map[string]any{"session_id": string(session.ID())})
		}
		return nil
	})

	if err != nil {
		s.recordAuditLog(ctx, "anonymous", ActionFacilitatorLogin, string(trackID), false, errorAuditMetadata(err, nil))
		return nil, err
	}

	s.recordAuditLog(ctx, string(trackID), ActionFacilitatorLogin, string(session.ID()), true, nil)
	return &TrackLoginResult{
		TrackToken: plainToken,
		Track:      track,
		Corner:     corner,
	}, nil
}

// MigrateSession - UC-2 (이슈 #30)
func (s *FacilitatorAuthService) MigrateSession(
	ctx context.Context,
	oldSessionToken string,
) (*TrackLoginResult, error) {

	now := s.nowFn()
	oldSessionTokenHash := hashSHA256(oldSessionToken)

	oldSession, err := s.sessions.GetByTokenHash(ctx, oldSessionTokenHash)
	if err != nil {
		return nil, withErrorContext("auth_facil.migrate_session", "repository.get_old_session", err, nil)
	}
	if oldSession == nil || !oldSession.IsActive() {
		var active bool
		if oldSession != nil {
			active = oldSession.IsActive()
		}
		return nil, withErrorContext("auth_facil.migrate_session", "validate_old_session", domain.ErrSessionRevoked, map[string]any{"session_found": oldSession != nil, "session_active": active})
	}

	if !oldSession.MigrationTargetTrackID().IsSet() {
		return nil, withErrorContext("auth_facil.migrate_session", "validate_migration_target", errors.New("no migration target for this session"), map[string]any{"session_id": string(oldSession.ID())})
	}
	newTrackID, _ := oldSession.MigrationTargetTrackID().Value()

	newTrack, err := s.tracks.Get(ctx, newTrackID)
	if err != nil {
		return nil, withErrorContext("auth_facil.migrate_session", "repository.get_new_track", err, map[string]any{"new_track_id": string(newTrackID)})
	}
	if newTrack == nil {
		return nil, withErrorContext("auth_facil.migrate_session", "validate_new_track", errors.New("migration target track not found"), map[string]any{"new_track_id": string(newTrackID), "track_found": false})
	}

	corner, err := s.corners.Get(ctx, newTrack.CornerID())
	if err != nil {
		return nil, withErrorContext("auth_facil.migrate_session", "repository.get_corner", err, map[string]any{"corner_id": string(newTrack.CornerID())})
	}
	if corner == nil {
		return nil, withErrorContext("auth_facil.migrate_session", "validate_corner", domain.ErrCornerNotInItinerary, map[string]any{"corner_id": string(newTrack.CornerID()), "corner_found": false})
	}

	plainToken, sessionTokenHash, err := generateOpaqueToken()
	if err != nil {
		return nil, withErrorContext("auth_facil.migrate_session", "generate_token", err, nil)
	}

	sessionID := domain.FacilitatorSessionID(s.uuidFn())
	newSession := domain.NewFacilitatorSessionFromProps(domain.FacilitatorSessionProps{
		ID:                     sessionID,
		TrackID:                newTrackID,
		TokenHash:              sessionTokenHash,
		CreatedAt:              now,
		RevokedAt:              domain.None[time.Time](),
		MigrationTargetTrackID: domain.None[domain.TrackID](),
	})

	err = s.tx.RunInTx(ctx, func(ctx context.Context) error {
		_ = oldSession.Revoke(now)
		if err := s.sessions.Save(ctx, oldSession); err != nil {
			return withErrorContext("auth_facil.migrate_session", "repository.save_old_session", err, map[string]any{"old_session_id": string(oldSession.ID())})
		}
		if err := s.sessions.Save(ctx, newSession); err != nil {
			return withErrorContext("auth_facil.migrate_session", "repository.save_new_session", err, map[string]any{"new_session_id": string(newSession.ID())})
		}
		return nil
	})

	if err != nil {
		s.recordAuditLog(ctx, string(oldSession.TrackID()), ActionSessionMigrate, string(newTrackID), false, errorAuditMetadata(err, nil))
		return nil, err
	}

	s.recordAuditLog(ctx, string(oldSession.TrackID()), ActionSessionMigrate, string(newSession.ID()), true, nil)
	return &TrackLoginResult{
		TrackToken: plainToken,
		Track:      newTrack,
		Corner:     corner,
	}, nil
}

// ValidateSession - UC-10
func (s *FacilitatorAuthService) ValidateSession(
	ctx context.Context,
	plainToken string,
) (*domain.FacilitatorSession, error) {

	tokenHash := hashSHA256(plainToken)

	session, err := s.sessions.GetByTokenHash(ctx, tokenHash)
	if err != nil {
		return nil, withErrorContext("auth_facil.validate_session", "repository.get_session", err, nil)
	}
	if session == nil || !session.IsActive() {
		var active bool
		if session != nil {
			active = session.IsActive()
		}
		return nil, withErrorContext("auth_facil.validate_session", "validate_session", domain.ErrSessionRevoked, map[string]any{"session_found": session != nil, "session_active": active})
	}

	return session, nil
}

func (s *FacilitatorAuthService) Logout(
	ctx context.Context,
	sessionID domain.FacilitatorSessionID,
) error {

	now := s.nowFn()

	session, err := s.sessions.Get(ctx, sessionID)
	if err != nil {
		return withErrorContext("auth_facil.logout", "repository.get_session", err, map[string]any{"session_id": string(sessionID)})
	}
	if session == nil {
		return withErrorContext("auth_facil.logout", "validate_session", errors.New("session not found"), map[string]any{"session_id": string(sessionID), "session_found": false})
	}

	if err := session.Revoke(now); err != nil {
		return withErrorContext("auth_facil.logout", "domain.revoke", err, map[string]any{"session_id": string(sessionID)})
	}

	err = s.tx.RunInTx(ctx, func(ctx context.Context) error {
		if err := s.sessions.Save(ctx, session); err != nil {
			return withErrorContext("auth_facil.logout", "repository.save_session", err, map[string]any{"session_id": string(sessionID)})
		}
		return nil
	})

	if err != nil {
		s.recordAuditLog(ctx, string(session.TrackID()), ActionFacilitatorLogout, string(sessionID), false, errorAuditMetadata(err, nil))
		return err // D-2 allowed: already wrapped or handled
	}

	s.recordAuditLog(ctx, string(session.TrackID()), ActionFacilitatorLogout, string(sessionID), true, nil)
	return nil
}

func (s *FacilitatorAuthService) recordAuditLog(ctx context.Context, actor string, action AuditAction, target string, success bool, metadata map[string]any) {

	log := domain.NewAuditLogFromProps(domain.AuditLogProps{
		ID:         domain.AuditLogID(s.uuidFn()),
		Actor:      actor,
		Action:     string(action),
		Target:     target,
		Success:    success,
		OccurredAt: s.nowFn(),
		Metadata:   metadata,
	})
	_ = s.auditLogs.Save(ctx, log)
}
