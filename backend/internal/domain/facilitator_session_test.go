//go:build ignore

package domain_test

import (
	"errors"
	"testing"
	"time"

	"cornermon/backend/internal/domain"
)

func TestFacilitatorSession_Lifecycle(t *testing.T) {
	now := time.Date(2026, 7, 9, 15, 0, 0, 0, time.UTC)

	t.Run("New session is active and can be revoked", func(t *testing.T) {
		session := domain.NewFacilitatorSessionFromProps(domain.FacilitatorSessionProps{ID:        domain.FacilitatorSessionID("session-1"),
			TrackID:   domain.TrackID("track-1"),
			TokenHash: "token-hash",
			CreatedAt: now,
			RevokedAt: domain.None[time.Time](),
		})

		if !session.IsActive() {
			t.Error("expected session to be active")
		}

		// Revoke session
		err := session.Revoke(now)
		if err != nil {
			t.Fatalf("expected no error, got %v", err)
		}

		if session.IsActive() {
			t.Error("expected session to be inactive")
		}

		revokedAt, ok := session.RevokedAt.Value()
		if !ok || !revokedAt.Equal(now) {
			t.Errorf("expected RevokedAt to be %v, got %v", now, revokedAt)
		}

		// Revoke again fails
		err = session.Revoke(now.Add(time.Minute))
		if !errors.Is(err, domain.ErrSessionRevoked) {
			t.Errorf("expected %v, got %v", domain.ErrSessionRevoked, err)
		}
	})
}
