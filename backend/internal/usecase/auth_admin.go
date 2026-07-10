package usecase

import (
	"context"
	"errors"
	"time"

	"cornermon/backend/internal/domain"

	"github.com/google/uuid"
)

const AdminAccessTokenTTL = 30 * time.Minute
const AdminRefreshTokenIdleTTL = 12 * time.Hour

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
		nowFn:               time.Now,
		uuidFn:              uuid.NewString,
	}
}

// Login - UC-11
func (s *AdminAuthService) Login(
	ctx context.Context,
	username string,
	password string,
	deviceInfo string,
) (string, string, *domain.AdminSession, error) {
	now := s.nowFn()

	admin, err := s.admins.GetByUsername(ctx, username)
	if err != nil {
		return "", "", nil, err
	}
	if admin == nil {
		s.recordAuditLog(ctx, "anonymous", "ADMIN_LOGIN", username, false, map[string]any{"error": "admin not found"})
		return "", "", nil, errors.New("invalid username or password")
	}

	if err := verifyPassword(admin.PasswordHash, password); err != nil {
		s.recordAuditLog(ctx, "anonymous", "ADMIN_LOGIN", username, false, map[string]any{"error": "invalid password"})
		return "", "", nil, errors.New("invalid username or password")
	}

	plainAccess, accessHash, err := generateOpaqueToken()
	if err != nil {
		return "", "", nil, err
	}

	plainRefresh, refreshHash, err := generateOpaqueToken()
	if err != nil {
		return "", "", nil, err
	}

	sessionID := domain.AdminSessionID(s.uuidFn())
	session := &domain.AdminSession{
		ID:               sessionID,
		AdminID:          admin.ID,
		AccessTokenHash:  accessHash,
		RefreshTokenHash: refreshHash,
		DeviceInfo:       deviceInfo,
		CreatedAt:        now,
		LastUsedAt:       now,
		RevokedAt:        domain.None[time.Time](),
	}

	err = s.tx.RunInTx(ctx, func(ctx context.Context) error {
		return s.sessions.Save(ctx, session)
	})

	if err != nil {
		s.recordAuditLog(ctx, "anonymous", "ADMIN_LOGIN", username, false, map[string]any{"error": err.Error()})
		return "", "", nil, err
	}

	s.recordAuditLog(ctx, string(admin.ID), "ADMIN_LOGIN", string(session.ID), true, nil)
	return plainAccess, plainRefresh, session, nil
}

// RefreshToken - UC-12
func (s *AdminAuthService) RefreshToken(
	ctx context.Context,
	refreshToken string,
) (string, error) {
	now := s.nowFn()
	refreshHash := hashSHA256(refreshToken)

	session, err := s.sessions.GetByRefreshTokenHash(ctx, refreshHash)
	if err != nil {
		return "", err
	}
	if session == nil || session.IsRefreshExpired(now, AdminRefreshTokenIdleTTL) {
		return "", errors.New("refresh token expired or revoked")
	}

	plainAccess, accessHash, err := generateOpaqueToken()
	if err != nil {
		return "", err
	}

	session.AccessTokenHash = accessHash
	session.TouchRefresh(now)

	err = s.tx.RunInTx(ctx, func(ctx context.Context) error {
		return s.sessions.Save(ctx, session)
	})

	if err != nil {
		return "", err
	}

	return plainAccess, nil
}

// ValidateAccessToken - UC-13
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

	if session.RevokedAt.IsSet() {
		return nil, domain.ErrSessionRevoked
	}

	if now.After(session.LastUsedAt.Add(AdminAccessTokenTTL)) {
		return nil, errors.New("access token expired")
	}

	return session, nil
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

	corner, err := s.corners.Get(ctx, track.CornerID)
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
	_ = s.broadcaster.Broadcast(ctx, corner.CampID, EventSessionRevoked, string(trackID))
	return nil
}
