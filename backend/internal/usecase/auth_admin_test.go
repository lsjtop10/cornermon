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
		admin := &domain.Admin{ID: "admin-1", PasswordHash: passwordHash}
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
		access, refresh, session, err := s.Login(context.Background(), "admin-1", "admin-password", "PC")

		// Assert
		if err != nil {
			t.Fatalf("expected no error, got %v", err)
		}
		if access == "" || refresh == "" {
			t.Fatal("expected non-empty tokens")
		}
		if session.ID != "session-uuid" {
			t.Errorf("expected session ID 'session-uuid', got '%s'", session.ID)
		}
	})

	t.Run("ShouldFailLoginAdminWhenPasswordIsIncorrect", func(t *testing.T) {
		// Arrange
		admins := NewMockAdminRepository()
		passwordHash, _ := hashPassword("admin-password")
		admin := &domain.Admin{ID: "admin-1", PasswordHash: passwordHash}
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
		_, _, _, err := s.Login(context.Background(), "admin-1", "wrong-password", "PC")

		// Assert
		if err == nil {
			t.Fatal("expected error, got nil")
		}
	})
}

func TestAdminAuthService_RefreshToken(t *testing.T) {
	t.Run("ShouldRefreshTokenSuccessfullyWhenNotExpired", func(t *testing.T) {
		// Arrange
		now := time.Now()
		sessions := NewMockAdminSessionRepository()
		session := &domain.AdminSession{
			ID:               "session-1",
			AdminID:          "admin-1",
			AccessTokenHash:  "access-hash-1",
			RefreshTokenHash: hashSHA256("refresh-token-1"),
			CreatedAt:        now.Add(-1 * time.Hour),
			LastUsedAt:       now.Add(-10 * time.Minute),
		}
		sessions.Sessions["session-1"] = session

		s := NewAdminAuthService(nil, sessions, nil, nil, nil, nil, nil, &MockTxManager{})

		s.nowFn = func() time.Time { return now }

		// Act
		newAccess, err := s.RefreshToken(context.Background(), "refresh-token-1")

		// Assert
		if err != nil {
			t.Fatalf("expected no error, got %v", err)
		}
		if newAccess == "" {
			t.Fatal("expected non-empty access token")
		}
	})
}
