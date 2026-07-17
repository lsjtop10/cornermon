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
		return "", nil, err
	}
	if admin == nil {
		s.recordAuditLog(ctx, "anonymous", "ADMIN_LOGIN", username, false, map[string]any{"error": "admin not found"})
		return "", nil, errors.New("invalid username or password")
	}

	if err := verifyPassword(admin.PasswordHash(), password); err != nil {
		s.recordAuditLog(ctx, "anonymous", "ADMIN_LOGIN", username, false, map[string]any{"error": "invalid password"})
		return "", nil, errors.New("invalid username or password")
	}

	plainAccess, accessHash, err := generateOpaqueToken()
	if err != nil {
		return "", nil, err
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
		return s.sessions.Save(ctx, session)
	})

	if err != nil {
		s.recordAuditLog(ctx, "anonymous", "ADMIN_LOGIN", username, false, map[string]any{"error": err.Error()})
		return "", nil, err
	}

	s.recordAuditLog(ctx, string(admin.ID()), "ADMIN_LOGIN", string(session.ID()), true, nil)
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
		return nil, err
	}
	if session == nil {
		return nil, errors.New("session not found")
	}

	if session.IsExpired(now, AdminAccessTokenTTL) {
		if session.RevokedAt().IsSet() {
			return nil, domain.ErrSessionRevoked
		}
		return nil, errors.New("access token expired")
	}

	session.TouchActivity(now)
	err = s.tx.RunInTx(ctx, func(ctx context.Context) error {
		return s.sessions.Save(ctx, session)
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
	if _, err := s.authorizeSystemAdmin(ctx, actorAdminID); err != nil {
		return nil, err
	}
	if role != domain.AdminRoleCornerOperator {
		if role == domain.AdminRoleSystemAdmin {
			return nil, domain.ErrAdminForbidden
		}
		return nil, domain.ErrAdminInvalidRole
	}
	existing, err := s.admins.GetByUsername(ctx, username)
	if err != nil {
		return nil, err
	}
	if existing != nil {
		return nil, domain.ErrAdminUsernameTaken
	}
	passwordHash, err := hashPassword(password)
	if err != nil {
		return nil, err
	}
	admin := domain.NewAdminFromProps(domain.AdminProps{
		ID:           domain.AdminID(s.uuidFn()),
		Username:     username,
		PasswordHash: passwordHash,
		Role:         role,
	})
	if err := s.tx.RunInTx(ctx, func(ctx context.Context) error {
		return s.admins.Save(ctx, admin)
	}); err != nil {
		s.recordAuditLog(ctx, string(actorAdminID), "ADMIN_CREATE", username, false, map[string]any{"error": err.Error()})
		return nil, err
	}
	s.recordAuditLog(ctx, string(actorAdminID), "ADMIN_CREATE", string(admin.ID()), true, map[string]any{"role": string(role)})
	return admin, nil
}

func (s *AdminAuthService) ChangeAdminPassword(
	ctx context.Context,
	actorAdminID domain.AdminID,
	targetAdminID domain.AdminID,
	newPassword string,
) error {
	if err := s.authorizeSelfOrSystemAdmin(ctx, actorAdminID, targetAdminID); err != nil {
		return err
	}
	admin, err := s.admins.Get(ctx, targetAdminID)
	if err != nil {
		return err
	}
	if admin == nil {
		return domain.ErrAdminNotFound
	}
	passwordHash, err := hashPassword(newPassword)
	if err != nil {
		return err
	}
	admin.SetPasswordHash(passwordHash)
	if err := s.tx.RunInTx(ctx, func(ctx context.Context) error {
		return s.admins.Save(ctx, admin)
	}); err != nil {
		s.recordAuditLog(ctx, string(actorAdminID), "ADMIN_PASSWORD_CHANGE", string(targetAdminID), false, map[string]any{"error": err.Error()})
		return err
	}
	s.recordAuditLog(ctx, string(actorAdminID), "ADMIN_PASSWORD_CHANGE", string(targetAdminID), true, map[string]any{"self": actorAdminID == targetAdminID})
	return nil
}

func (s *AdminAuthService) DeleteAdmin(
	ctx context.Context,
	actorAdminID domain.AdminID,
	targetAdminID domain.AdminID,
) error {
	if _, err := s.authorizeSystemAdmin(ctx, actorAdminID); err != nil {
		return err
	}
	if actorAdminID == targetAdminID {
		return domain.ErrAdminSelfDeleteForbidden
	}
	target, err := s.admins.Get(ctx, targetAdminID)
	if err != nil {
		return err
	}
	if target == nil {
		return domain.ErrAdminNotFound
	}
	if target.IsSystemAdmin() {
		count, err := s.admins.CountByRole(ctx, domain.AdminRoleSystemAdmin)
		if err != nil {
			return err
		}
		if count <= 1 {
			return domain.ErrAdminLastSystemAdmin
		}
	}
	if err := s.tx.RunInTx(ctx, func(ctx context.Context) error {
		return s.admins.Delete(ctx, targetAdminID)
	}); err != nil {
		s.recordAuditLog(ctx, string(actorAdminID), "ADMIN_DELETE", string(targetAdminID), false, map[string]any{"error": err.Error()})
		return err
	}
	s.recordAuditLog(ctx, string(actorAdminID), "ADMIN_DELETE", string(targetAdminID), true, nil)
	return nil
}

func (s *AdminAuthService) authorizeSystemAdmin(ctx context.Context, actorAdminID domain.AdminID) (*domain.Admin, error) {
	admin, err := s.admins.Get(ctx, actorAdminID)
	if err != nil {
		return nil, err
	}
	if admin == nil {
		return nil, domain.ErrAdminNotFound
	}
	if !admin.IsSystemAdmin() {
		return nil, domain.ErrAdminForbidden
	}
	return admin, nil
}

func (s *AdminAuthService) authorizeSelfOrSystemAdmin(ctx context.Context, actorAdminID, targetAdminID domain.AdminID) error {
	if actorAdminID == targetAdminID {
		return nil
	}
	_, err := s.authorizeSystemAdmin(ctx, actorAdminID)
	return err
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
		return err
	}
	if session == nil {
		return errors.New("session not found")
	}

	if err := session.Revoke(now); err != nil {
		return err
	}

	err = s.tx.RunInTx(ctx, func(ctx context.Context) error {
		return s.sessions.Save(ctx, session)
	})

	if err != nil {
		s.recordAuditLog(ctx, string(actorAdminID), "ADMIN_SESSION_REVOKE", string(sessionID), false, map[string]any{"error": err.Error()})
		return err
	}

	s.recordAuditLog(ctx, string(actorAdminID), "ADMIN_SESSION_REVOKE", string(sessionID), true, nil)
	return nil
}

func (s *AdminAuthService) recordAuditLog(ctx context.Context, actor, action, target string, success bool, metadata map[string]any) {
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

func (s *AdminAuthService) ListSessions(ctx context.Context, adminID domain.AdminID) ([]*domain.AdminSession, error) {
	return s.sessions.ListByAdmin(ctx, adminID)
}

func (s *AdminAuthService) ForceTrackLogout(ctx context.Context, trackID domain.TrackID, actorAdminID domain.AdminID) error {
	now := s.nowFn()

	track, err := s.tracks.Get(ctx, trackID)
	if err != nil {
		return err
	}
	if track == nil {
		return errors.New("track not found")
	}

	corner, err := s.corners.Get(ctx, track.CornerID())
	if err != nil {
		return err
	}
	if corner == nil {
		return errors.New("corner not found")
	}

	activeSessions, err := s.facilitatorSessions.ListActiveByTrack(ctx, trackID)
	if err != nil {
		return err
	}

	err = s.tx.RunInTx(ctx, func(ctx context.Context) error {
		for _, sess := range activeSessions {
			if err := sess.Revoke(now); err != nil {
				return err
			}
			if err := s.facilitatorSessions.Save(ctx, sess); err != nil {
				return err
			}
		}
		return nil
	})

	if err != nil {
		s.recordAuditLog(ctx, string(actorAdminID), "TRACK_FORCE_LOGOUT", string(trackID), false, map[string]any{"error": err.Error()})
		return err
	}

	s.recordAuditLog(ctx, string(actorAdminID), "TRACK_FORCE_LOGOUT", string(trackID), true, nil)
	_ = s.broadcaster.Broadcast(ctx, corner.CampID(), EventSessionRevoked, TrackScope(trackID))
	return nil
}
