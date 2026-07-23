package usecase

import (
	"context"
	"testing"
	"time"

	"cornermon/backend/internal/domain"
)

func TestAdminAuthService_Login(t *testing.T) {
	t.Run("ShouldLoginAdminSuccessfullyWhenCredentialsAreValid", func(t *testing.T) {
		// Arrange
		now := time.Now()
		admins := NewMockAdminRepository()
		passwordHash, _ := hashPassword("admin-password")
		admin := domain.NewAdminFromProps(domain.AdminProps{ID: "admin-1", PasswordHash: passwordHash})
		admins.Admins["admin-1"] = admin

		sessions := NewMockAdminSessionRepository()
		auditLogs := &MockAuditLogRepository{}
		tx := &MockTxManager{}
		facSessions := NewMockFacilitatorSessionRepository()
		tracks := NewMockTrackRepository()
		corners := NewMockCornerRepository()
		broadcaster := &MockBroadcaster{}

		s := NewAdminAuthService(admins, sessions, facSessions, tracks, corners, broadcaster, auditLogs, tx)

		s.nowFn = func() time.Time { return now }
		s.uuidFn = func() string { return "session-uuid" }

		// Act
		access, session, err := s.Login(context.Background(), "admin-1", "admin-password", "PC")

		// Assert
		if err != nil {
			t.Fatalf("expected no error, got %v", err)
		}
		if access == "" {
			t.Fatal("expected non-empty token")
		}
		if session.ID() != "session-uuid" {
			t.Errorf("expected session ID 'session-uuid', got '%s'", session.ID())
		}
	})

	t.Run("ShouldRecordAdminIDAsActorAndUsernameAsActorNameWhenSucceeded", func(t *testing.T) {
		// Arrange
		now := time.Now()
		admins := NewMockAdminRepository()
		passwordHash, _ := hashPassword("admin-password")
		admin := domain.NewAdminFromProps(domain.AdminProps{ID: "admin-1", Username: "김관리", PasswordHash: passwordHash})
		admins.Admins["admin-1"] = admin

		sessions := NewMockAdminSessionRepository()
		auditLogs := &MockAuditLogRepository{}
		tx := &MockTxManager{}
		facSessions := NewMockFacilitatorSessionRepository()
		tracks := NewMockTrackRepository()
		corners := NewMockCornerRepository()
		broadcaster := &MockBroadcaster{}

		s := NewAdminAuthService(admins, sessions, facSessions, tracks, corners, broadcaster, auditLogs, tx)
		s.nowFn = func() time.Time { return now }
		s.uuidFn = func() string { return "session-uuid" }

		// Act
		_, _, err := s.Login(context.Background(), "admin-1", "admin-password", "PC")

		// Assert
		if err != nil {
			t.Fatalf("expected no error, got %v", err)
		}
		if len(auditLogs.Logs) != 1 {
			t.Fatalf("expected 1 audit log, got %d", len(auditLogs.Logs))
		}
		got := auditLogs.Logs[0]
		if got.Actor() != "admin-1" {
			t.Errorf("expected Actor to remain raw admin ID 'admin-1', got %q", got.Actor())
		}
		if got.ActorName() != "김관리" {
			t.Errorf("expected ActorName '김관리', got %q", got.ActorName())
		}
		if _, ok := got.CampID().Value(); ok {
			t.Errorf("expected CampID None for account-level ADMIN_LOGIN, got %v", got.CampID())
		}
		if got.TargetName() != "admin-1" {
			t.Errorf("expected TargetName 'admin-1', got %q", got.TargetName())
		}
	})

	t.Run("ShouldFailLoginAdminWhenPasswordIsIncorrect", func(t *testing.T) {
		// Arrange
		admins := NewMockAdminRepository()
		passwordHash, _ := hashPassword("admin-password")
		admin := domain.NewAdminFromProps(domain.AdminProps{ID: "admin-1", PasswordHash: passwordHash})
		admins.Admins["admin-1"] = admin

		sessions := NewMockAdminSessionRepository()
		auditLogs := &MockAuditLogRepository{}
		tx := &MockTxManager{}
		facSessions := NewMockFacilitatorSessionRepository()
		tracks := NewMockTrackRepository()
		corners := NewMockCornerRepository()
		broadcaster := &MockBroadcaster{}

		s := NewAdminAuthService(admins, sessions, facSessions, tracks, corners, broadcaster, auditLogs, tx)

		// Act
		_, _, err := s.Login(context.Background(), "admin-1", "wrong-password", "PC")

		// Assert
		if err == nil {
			t.Fatal("expected error, got nil")
		}
	})
}

func TestAdminAuthService_ValidateAccessToken(t *testing.T) {
	t.Run("ShouldSlideExpirationWhenAccessTokenIsValid", func(t *testing.T) {
		// Arrange
		now := time.Now()
		sessions := NewMockAdminSessionRepository()
		session := domain.NewAdminSessionFromProps(domain.AdminSessionProps{ID: "session-1",
			AdminID:         "admin-1",
			AccessTokenHash: hashSHA256("access-token-1"),
			CreatedAt:       now.Add(-1 * time.Hour),
			LastUsedAt:      now.Add(-10 * time.Minute),
		})
		sessions.Sessions["session-1"] = session

		s := NewAdminAuthService(nil, sessions, nil, nil, nil, nil, nil, &MockTxManager{})
		s.nowFn = func() time.Time { return now }

		// Act
		got, err := s.ValidateAccessToken(context.Background(), "access-token-1")

		// Assert
		if err != nil {
			t.Fatalf("expected no error, got %v", err)
		}
		if !got.LastUsedAt().Equal(now) {
			t.Errorf("expected LastUsedAt to slide to %v, got %v", now, got.LastUsedAt())
		}
	})

	t.Run("ShouldFailWhenAccessTokenIdleExpired", func(t *testing.T) {
		// Arrange
		now := time.Now()
		sessions := NewMockAdminSessionRepository()
		session := domain.NewAdminSessionFromProps(domain.AdminSessionProps{ID: "session-1",
			AdminID:         "admin-1",
			AccessTokenHash: hashSHA256("access-token-1"),
			CreatedAt:       now.Add(-13 * time.Hour),
			LastUsedAt:      now.Add(-13 * time.Hour),
		})
		sessions.Sessions["session-1"] = session

		s := NewAdminAuthService(nil, sessions, nil, nil, nil, nil, nil, &MockTxManager{})
		s.nowFn = func() time.Time { return now }

		// Act
		_, err := s.ValidateAccessToken(context.Background(), "access-token-1")

		// Assert
		if err == nil {
			t.Fatal("expected error, got nil")
		}
	})
}
