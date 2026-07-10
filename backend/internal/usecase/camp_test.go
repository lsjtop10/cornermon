package usecase

import (
	"context"
	"testing"
	"time"

	"cornermon/backend/internal/domain"
)

func TestCampService_ActivateCamp(t *testing.T) {
	t.Run("ShouldActivateCampSuccessfullyWhenPending", func(t *testing.T) {
		// Arrange
		now := time.Now()
		camps := NewMockCampRepository()
		camp := &domain.Camp{ID: "camp-1", Status: domain.CampPending}
		camps.Save(context.Background(), camp)

		sessions := NewMockFacilitatorSessionRepository()
		auditLogs := &MockAuditLogRepository{}
		broadcaster := &MockBroadcaster{}
		tx := &MockTxManager{}

		s := NewCampService(camps, nil, sessions, auditLogs, broadcaster, tx)
		s.nowFn = func() time.Time { return now }
		s.uuidFn = func() string { return "audit-uuid" }

		// Act
		err := s.ActivateCamp(context.Background(), "camp-1", "admin-1")

		// Assert
		if err != nil {
			t.Fatalf("expected no error, got %v", err)
		}

		updated, _ := camps.Get(context.Background(), "camp-1")
		if updated.Status != domain.CampActive {
			t.Errorf("expected status 'ACTIVE', got %s", updated.Status)
		}
	})
}

func TestCampService_EndCamp(t *testing.T) {
	t.Run("ShouldEndCampSuccessfullyWhenActiveAndRevokeSessions", func(t *testing.T) {
		// Arrange
		now := time.Now()
		camps := NewMockCampRepository()
		camp := &domain.Camp{ID: "camp-1", Status: domain.CampActive}
		camps.Save(context.Background(), camp)

		sessions := NewMockFacilitatorSessionRepository()
		session := &domain.FacilitatorSession{
			ID:        "session-1",
			TrackID:   "track-1",
			TokenHash: "token-hash-1",
			CreatedAt: now,
		}
		sessions.Save(context.Background(), session)

		auditLogs := &MockAuditLogRepository{}
		broadcaster := &MockBroadcaster{}
		tx := &MockTxManager{}

		s := NewCampService(camps, nil, sessions, auditLogs, broadcaster, tx)
		s.nowFn = func() time.Time { return now }
		s.uuidFn = func() string { return "audit-uuid" }

		// Act
		err := s.EndCamp(context.Background(), "camp-1", "admin-1")

		// Assert
		if err != nil {
			t.Fatalf("expected no error, got %v", err)
		}

		updatedCamp, _ := camps.Get(context.Background(), "camp-1")
		if updatedCamp.Status != domain.CampEnded {
			t.Errorf("expected status 'ENDED', got %s", updatedCamp.Status)
		}

		updatedSession, _ := sessions.GetByTokenHash(context.Background(), "token-hash-1")
		if updatedSession.IsActive() {
			t.Errorf("expected session to be revoked")
		}
	})
}
