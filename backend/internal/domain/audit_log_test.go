
package domain_test

import (
	"testing"
	"time"

	"cornermon/backend/internal/domain"
)

func TestAuditLog_Creation(t *testing.T) {
	now := time.Date(2026, 7, 9, 15, 0, 0, 0, time.UTC)
	metadata := map[string]any{"ip": "127.0.0.1"}

	t.Run("NewAuditLog initializes all fields correctly", func(t *testing.T) {
		log := domain.NewAuditLog(
			domain.AuditLogID("log-1"),
			"admin-1",
			"CAMP_ACTIVATE",
			"camp-1",
			true,
			now,
			metadata,
		)

		if log.ID() != domain.AuditLogID("log-1") {
			t.Errorf("expected ID 'log-1', got %q", log.ID())
		}
		if log.Actor() != "admin-1" {
			t.Errorf("expected Actor 'admin-1', got %q", log.Actor())
		}
		if log.Action() != "CAMP_ACTIVATE" {
			t.Errorf("expected Action 'CAMP_ACTIVATE', got %q", log.Action())
		}
		if log.Target() != "camp-1" {
			t.Errorf("expected Target 'camp-1', got %q", log.Target())
		}
		if !log.Success() {
			t.Error("expected Success to be true")
		}
		if !log.OccurredAt().Equal(now) {
			t.Errorf("expected OccurredAt %v, got %v", now, log.OccurredAt())
		}
		if log.Metadata()["ip"] != "127.0.0.1" {
			t.Errorf("expected metadata ip to be '127.0.0.1', got %v", log.Metadata()["ip"])
		}
	})
}
