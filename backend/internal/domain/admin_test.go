package domain_test

import (
	"errors"
	"testing"
	"time"

	"cornermon/backend/internal/domain"
)

func TestAdminSession_Lifecycle(t *testing.T) {
	now := time.Date(2026, 7, 9, 15, 0, 0, 0, time.UTC)
	idleTTL := 30 * time.Minute

	t.Run("Session touch sliding expiration and expiry verification", func(t *testing.T) {
		session := domain.NewAdminSessionFromProps(domain.AdminSessionProps{ID:              domain.AdminSessionID("session-1"),
			AdminID:         domain.AdminID("admin-1"),
			AccessTokenHash: "access-hash",
			CreatedAt:       now,
			LastUsedAt:      now,
			RevokedAt:       domain.None[time.Time](),
		})

		// 1. Initially not expired
		if session.IsExpired(now.Add(10*time.Minute), idleTTL) {
			t.Error("expected session not to be expired")
		}

		// 2. Expired after idleTTL
		if !session.IsExpired(now.Add(31*time.Minute), idleTTL) {
			t.Error("expected session to be expired after idleTTL")
		}

		// 3. TouchActivity slides expiration
		session.TouchActivity(now.Add(10 * time.Minute))
		if session.IsExpired(now.Add(31*time.Minute), idleTTL) {
			t.Error("expected session not to be expired because lastUsedAt was touched")
		}

		// 4. TouchActivity updates LastUsedAt
		if !session.LastUsedAt().Equal(now.Add(10 * time.Minute)) {
			t.Errorf("expected LastUsedAt to be touched, got %v", session.LastUsedAt)
		}
	})

	t.Run("Revoke and revoked session check", func(t *testing.T) {
		session := domain.NewAdminSessionFromProps(domain.AdminSessionProps{ID:         domain.AdminSessionID("session-2"),
			LastUsedAt: now,
			RevokedAt:  domain.None[time.Time](),
		})

		err := session.Revoke(now)
		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		// Expired because it is revoked
		if !session.IsExpired(now, idleTTL) {
			t.Error("expected session to be expired because it was revoked")
		}

		// Revoking again fails
		err = session.Revoke(now.Add(time.Minute))
		if !errors.Is(err, domain.ErrSessionRevoked) {
			t.Errorf("expected %v, got %v", domain.ErrSessionRevoked, err)
		}
	})
}
