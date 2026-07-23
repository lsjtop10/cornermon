package usecase

import (
	"context"
	"errors"
	"time"

	"cornermon/backend/internal/domain"

	"github.com/google/uuid"
)

const AdminAccessTokenTTL = 12 * time.Hour

type AdminAuthService struct {
	admins              AdminRepository
	sessions            AdminSessionRepository
	facilitatorSessions FacilitatorSessionRepository
	tracks              TrackRepository
	corners             CornerRepository
	broadcaster         Broadcaster
	auditLogs           AuditLogRepository
	tx                  TxManager

	nowFn  func() time.Time
	uuidFn func() string
}

func NewAdminAuthService(
	admins AdminRepository,
	sessions AdminSessionRepository,
	facilitatorSessions FacilitatorSessionRepository,
	tracks TrackRepository,
	corners CornerRepository,
	broadcaster Broadcaster,
	auditLogs AuditLogRepository,
	tx TxManager,
) *AdminAuthService {
	return &AdminAuthService{
		admins:              admins,
		sessions:            sessions,
		facilitatorSessions: facilitatorSessions,
		tracks:              tracks,
		corners:             corners,
		broadcaster:         broadcaster,
		auditLogs:           auditLogs,
		tx:                  tx,
		nowFn:               func() time.Time { return time.Now().UTC() },
		uuidFn:              uuid.NewString,
	}
}

// Login - UC-11
func (s *AdminAuthService) Login(
	ctx context.Context,
	username string,
	password string,
	deviceInfo string,
) (string, *domain.AdminSession, error) {

	now := s.nowFn()

	admin, err := s.admins.GetByUsername(ctx, username)
	if err != nil {
		return "", nil, withErrorContext("auth_admin.login", "repository.get_admin", err, map[string]any{"username": username})
	}
	if admin == nil {
		err = withErrorContext("auth_admin.login", "validate_admin", errors.New("invalid username or password"), map[string]any{"username": username, "admin_found": false})
		s.recordAuditLog(ctx, "anonymous", "anonymous", ActionAdminLogin, username, false, errorAuditMetadata(err, nil))
		return "", nil, err
	}

	if err := verifyPassword(admin.PasswordHash(), password); err != nil {
		err = withErrorContext("auth_admin.login", "validate_password", errors.New("invalid username or password"), map[string]any{"username": username})
		s.recordAuditLog(ctx, "anonymous", "anonymous", ActionAdminLogin, username, false, errorAuditMetadata(err, nil))
		return "", nil, err
	}

	plainAccess, accessHash, err := generateOpaqueToken()
	if err != nil {
		return "", nil, withErrorContext("auth_admin.login", "generate_token", err, nil)
	}

	sessionID := domain.AdminSessionID(s.uuidFn())
	session := domain.NewAdminSessionFromProps(domain.AdminSessionProps{
		ID:              sessionID,
		AdminID:         admin.ID(),
		AccessTokenHash: accessHash,
		DeviceInfo:      deviceInfo,
		CreatedAt:       now,
		LastUsedAt:      now,
		RevokedAt:       domain.None[time.Time](),
	})

	err = s.tx.RunInTx(ctx, func(ctx context.Context) error {
		if err := s.sessions.Save(ctx, session); err != nil {
			return withErrorContext("auth_admin.login", "repository.save_session", err, map[string]any{"session_id": string(sessionID)})
		}
		return nil
	})

	if err != nil {
		s.recordAuditLog(ctx, "anonymous", "anonymous", ActionAdminLogin, username, false, errorAuditMetadata(err, nil))
		return "", nil, err
	}

	s.recordAuditLog(ctx, string(admin.ID()), adminActorLabel(ctx, s.admins, admin.ID(), admin), ActionAdminLogin, string(session.ID()), true, nil)
	return plainAccess, session, nil
}

// ValidateAccessToken - UC-13 (슬라이딩 세션: 검증 성공 시 활동 시각을 갱신하여 TTL을 연장)
func (s *AdminAuthService) ValidateAccessToken(
	ctx context.Context,
	accessToken string,
) (*domain.AdminSession, error) {

	now := s.nowFn()
	accessHash := hashSHA256(accessToken)

	session, err := s.sessions.GetByAccessTokenHash(ctx, accessHash)
	if err != nil {
		return nil, withErrorContext("auth_admin.validate_token", "repository.get_session", err, nil)
	}
	if session == nil {
		return nil, withErrorContext("auth_admin.validate_token", "validate_session", errors.New("session not found"), map[string]any{"session_found": false})
	}

	if session.IsExpired(now, AdminAccessTokenTTL) {
		if session.RevokedAt().IsSet() {
			return nil, withErrorContext("auth_admin.validate_token", "validate_session_revoked", domain.ErrSessionRevoked, map[string]any{"session_id": string(session.ID())})
		}
		return nil, withErrorContext("auth_admin.validate_token", "validate_session_expired", errors.New("access token expired"), map[string]any{"session_id": string(session.ID())})
	}

	session.TouchActivity(now)
	err = s.tx.RunInTx(ctx, func(ctx context.Context) error {
		if err := s.sessions.Save(ctx, session); err != nil {
			return withErrorContext("auth_admin.validate_token", "repository.save_session", err, map[string]any{"session_id": string(session.ID())})
		}
		return nil
	})
	if err != nil {
		return nil, err
	}

	return session, nil
}

func (s *AdminAuthService) CreateAdmin(
	ctx context.Context,
	actorAdminID domain.AdminID,
	username string,
	password string,
	role domain.AdminRole,
) (*domain.Admin, error) {

	actorAdmin, err := s.authorizeSystemAdmin(ctx, actorAdminID)
	if err != nil {
		return nil, err
	}
	if role != domain.AdminRoleCornerOperator {
		if role == domain.AdminRoleSystemAdmin {
			return nil, withErrorContext("auth_admin.create_admin", "validate_role", domain.ErrAdminForbidden, map[string]any{"role": string(role)})
		}
		return nil, withErrorContext("auth_admin.create_admin", "validate_role", domain.ErrAdminInvalidRole, map[string]any{"role": string(role)})
	}
	existing, err := s.admins.GetByUsername(ctx, username)
	if err != nil {
		return nil, withErrorContext("auth_admin.create_admin", "repository.get_admin", err, map[string]any{"username": username})
	}
	if existing != nil {
		return nil, withErrorContext("auth_admin.create_admin", "validate_admin_exists", domain.ErrAdminUsernameTaken, map[string]any{"username": username})
	}
	passwordHash, err := hashPassword(password)
	if err != nil {
		return nil, withErrorContext("auth_admin.create_admin", "hash_password", err, nil)
	}
	admin := domain.NewAdminFromProps(domain.AdminProps{
		ID:           domain.AdminID(s.uuidFn()),
		Username:     username,
		PasswordHash: passwordHash,
		Role:         role,
	})
	if err := s.tx.RunInTx(ctx, func(ctx context.Context) error {
		if err := s.admins.Save(ctx, admin); err != nil {
			return withErrorContext("auth_admin.create_admin", "repository.save_admin", err, map[string]any{"admin_id": string(admin.ID())})
		}
		return nil
	}); err != nil {
		s.recordAuditLog(ctx, string(actorAdminID), adminActorLabel(ctx, s.admins, actorAdminID, actorAdmin), ActionAdminCreate, username, false, errorAuditMetadata(err, nil))
		return nil, err
	}
	s.recordAuditLog(ctx, string(actorAdminID), adminActorLabel(ctx, s.admins, actorAdminID, actorAdmin), ActionAdminCreate, string(admin.ID()), true, map[string]any{"role": string(role)})
	return admin, nil
}

func (s *AdminAuthService) ChangeAdminPassword(
	ctx context.Context,
	actorAdminID domain.AdminID,
	targetAdminID domain.AdminID,
	newPassword string,
) error {

	if err := s.authorizeSelfOrSystemAdmin(ctx, actorAdminID, targetAdminID); err != nil {
		return err // D-2 allowed: already wrapped or handled
	}
	admin, err := s.admins.Get(ctx, targetAdminID)
	if err != nil {
		return withErrorContext("auth_admin.change_password", "repository.get_admin", err, map[string]any{"target_admin_id": string(targetAdminID)})
	}
	if admin == nil {
		return withErrorContext("auth_admin.change_password", "validate_admin", domain.ErrAdminNotFound, map[string]any{"target_admin_id": string(targetAdminID), "admin_found": false})
	}
	passwordHash, err := hashPassword(newPassword)
	if err != nil {
		return withErrorContext("auth_admin.change_password", "hash_password", err, nil)
	}
	admin.SetPasswordHash(passwordHash)
	var preloadedActor *domain.Admin
	if actorAdminID == targetAdminID {
		preloadedActor = admin
	}
	if err := s.tx.RunInTx(ctx, func(ctx context.Context) error {
		if err := s.admins.Save(ctx, admin); err != nil {
			return withErrorContext("auth_admin.change_password", "repository.save_admin", err, map[string]any{"admin_id": string(admin.ID())})
		}
		return nil
	}); err != nil {
		s.recordAuditLog(ctx, string(actorAdminID), adminActorLabel(ctx, s.admins, actorAdminID, preloadedActor), ActionAdminPasswordChange, string(targetAdminID), false, errorAuditMetadata(err, nil))
		return err // D-2 allowed: already wrapped or handled
	}
	s.recordAuditLog(ctx, string(actorAdminID), adminActorLabel(ctx, s.admins, actorAdminID, preloadedActor), ActionAdminPasswordChange, string(targetAdminID), true, map[string]any{"self": actorAdminID == targetAdminID})
	return nil
}

func (s *AdminAuthService) DeleteAdmin(
	ctx context.Context,
	actorAdminID domain.AdminID,
	targetAdminID domain.AdminID,
) error {

	if _, err := s.authorizeSystemAdmin(ctx, actorAdminID); err != nil {
		return err // D-2 allowed: already wrapped or handled
	}
	if actorAdminID == targetAdminID {
		return withErrorContext("auth_admin.delete_admin", "validate_self_delete", domain.ErrAdminSelfDeleteForbidden, map[string]any{"admin_id": string(actorAdminID)})
	}
	target, err := s.admins.Get(ctx, targetAdminID)
	if err != nil {
		return withErrorContext("auth_admin.delete_admin", "repository.get_admin", err, map[string]any{"target_admin_id": string(targetAdminID)})
	}
	if target == nil {
		return withErrorContext("auth_admin.delete_admin", "validate_admin", domain.ErrAdminNotFound, map[string]any{"target_admin_id": string(targetAdminID), "admin_found": false})
	}
	if target.IsSystemAdmin() {
		count, err := s.admins.CountByRole(ctx, domain.AdminRoleSystemAdmin)
		if err != nil {
			return withErrorContext("auth_admin.delete_admin", "repository.count_system_admins", err, nil)
		}
		if count <= 1 {
			return withErrorContext("auth_admin.delete_admin", "validate_last_system_admin", domain.ErrAdminLastSystemAdmin, map[string]any{"target_admin_id": string(targetAdminID)})
		}
	}
	if err := s.tx.RunInTx(ctx, func(ctx context.Context) error {
		if err := s.admins.Delete(ctx, targetAdminID); err != nil {
			return withErrorContext("auth_admin.delete_admin", "repository.delete_admin", err, map[string]any{"target_admin_id": string(targetAdminID)})
		}
		return nil
	}); err != nil {
		s.recordAuditLog(ctx, string(actorAdminID), adminActorLabel(ctx, s.admins, actorAdminID, nil), ActionAdminDelete, string(targetAdminID), false, errorAuditMetadata(err, nil))
		return err // D-2 allowed: already wrapped or handled
	}
	s.recordAuditLog(ctx, string(actorAdminID), adminActorLabel(ctx, s.admins, actorAdminID, nil), ActionAdminDelete, string(targetAdminID), true, nil)
	return nil
}

func (s *AdminAuthService) authorizeSystemAdmin(ctx context.Context, actorAdminID domain.AdminID) (*domain.Admin, error) {

	admin, err := s.admins.Get(ctx, actorAdminID)
	if err != nil {
		return nil, withErrorContext("auth_admin.authorize_system_admin", "repository.get_admin", err, map[string]any{"actor_admin_id": string(actorAdminID)})
	}
	if admin == nil {
		return nil, withErrorContext("auth_admin.authorize_system_admin", "validate_admin", domain.ErrAdminNotFound, map[string]any{"actor_admin_id": string(actorAdminID), "admin_found": false})
	}
	if !admin.IsSystemAdmin() {
		return nil, withErrorContext("auth_admin.authorize_system_admin", "validate_system_admin", domain.ErrAdminForbidden, map[string]any{"actor_admin_id": string(actorAdminID), "role": string(admin.Role())})
	}
	return admin, nil
}

func (s *AdminAuthService) authorizeSelfOrSystemAdmin(ctx context.Context, actorAdminID, targetAdminID domain.AdminID) error {
	if actorAdminID == targetAdminID {
		return nil
	}
	_, err := s.authorizeSystemAdmin(ctx, actorAdminID)
	return err // D-2 allowed: already wrapped or handled
}

// RevokeSession - UC-17
func (s *AdminAuthService) RevokeSession(
	ctx context.Context,
	sessionID domain.AdminSessionID,
	actorAdminID domain.AdminID,
) error {

	now := s.nowFn()

	session, err := s.sessions.Get(ctx, sessionID)
	if err != nil {
		return withErrorContext("auth_admin.revoke_session", "repository.get_session", err, map[string]any{"session_id": string(sessionID)})
	}
	if session == nil {
		return withErrorContext("auth_admin.revoke_session", "validate_session", errors.New("session not found"), map[string]any{"session_id": string(sessionID), "session_found": false})
	}

	if err := session.Revoke(now); err != nil {
		return withErrorContext("auth_admin.revoke_session", "domain.revoke", err, map[string]any{"session_id": string(sessionID)})
	}

	err = s.tx.RunInTx(ctx, func(ctx context.Context) error {
		if err := s.sessions.Save(ctx, session); err != nil {
			return withErrorContext("auth_admin.revoke_session", "repository.save_session", err, map[string]any{"session_id": string(sessionID)})
		}
		return nil
	})

	if err != nil {
		s.recordAuditLog(ctx, string(actorAdminID), adminActorLabel(ctx, s.admins, actorAdminID, nil), ActionAdminSessionRevoke, string(sessionID), false, errorAuditMetadata(err, nil))
		return err // D-2 allowed: already wrapped or handled
	}

	s.recordAuditLog(ctx, string(actorAdminID), adminActorLabel(ctx, s.admins, actorAdminID, nil), ActionAdminSessionRevoke, string(sessionID), true, nil)
	return nil
}

func (s *AdminAuthService) recordAuditLog(ctx context.Context, actor, actorName string, action AuditAction, target string, success bool, metadata map[string]any) {
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

func (s *AdminAuthService) ListSessions(ctx context.Context, adminID domain.AdminID) ([]*domain.AdminSession, error) {
	return s.sessions.ListByAdmin(ctx, adminID)
}

func (s *AdminAuthService) ForceTrackLogout(ctx context.Context, trackID domain.TrackID, actorAdminID domain.AdminID) error {

	now := s.nowFn()

	track, err := s.tracks.Get(ctx, trackID)
	if err != nil {
		return withErrorContext("auth_admin.force_track_logout", "repository.get_track", err, map[string]any{"track_id": string(trackID)})
	}
	if track == nil {
		return withErrorContext("auth_admin.force_track_logout", "validate_track", errors.New("track not found"), map[string]any{"track_id": string(trackID), "track_found": false})
	}

	corner, err := s.corners.Get(ctx, track.CornerID())
	if err != nil {
		return withErrorContext("auth_admin.force_track_logout", "repository.get_corner", err, map[string]any{"corner_id": string(track.CornerID())})
	}
	if corner == nil {
		return withErrorContext("auth_admin.force_track_logout", "validate_corner", errors.New("corner not found"), map[string]any{"corner_id": string(track.CornerID()), "corner_found": false})
	}

	activeSessions, err := s.facilitatorSessions.ListActiveByTrack(ctx, trackID)
	if err != nil {
		return withErrorContext("auth_admin.force_track_logout", "repository.list_active_sessions", err, map[string]any{"track_id": string(trackID)})
	}

	err = s.tx.RunInTx(ctx, func(ctx context.Context) error {
		for _, sess := range activeSessions {
			if err := sess.Revoke(now); err != nil {
				return withErrorContext("auth_admin.force_track_logout", "domain.revoke", err, map[string]any{"session_id": string(sess.ID())})
			}
			if err := s.facilitatorSessions.Save(ctx, sess); err != nil {
				return withErrorContext("auth_admin.force_track_logout", "repository.save_session", err, map[string]any{"session_id": string(sess.ID())})
			}
		}
		return nil
	})

	if err != nil {
		s.recordAuditLog(ctx, string(actorAdminID), adminActorLabel(ctx, s.admins, actorAdminID, nil), ActionTrackForceLogout, string(trackID), false, errorAuditMetadata(err, nil))
		return err // D-2 allowed: already wrapped or handled
	}

	s.recordAuditLog(ctx, string(actorAdminID), adminActorLabel(ctx, s.admins, actorAdminID, nil), ActionTrackForceLogout, string(trackID), true, nil)
	_ = s.broadcaster.Broadcast(ctx, corner.CampID(), EventSessionRevoked, TrackScope(trackID))
	return nil
}
