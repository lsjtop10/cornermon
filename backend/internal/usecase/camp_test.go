package usecase

import (
	"context"
	"errors"
	"testing"
	"time"

	"cornermon/backend/internal/domain"
)

type failingTxManager struct{ err error }

func (m failingTxManager) RunInTx(context.Context, func(context.Context) error) error { return m.err }

func TestCampService_OpenNewCamp(t *testing.T) {
	t.Run("ShoudCreatePendingCampWhenValid", func(t *testing.T) {
		// Arrange
		start := time.Date(2026, 7, 20, 9, 0, 0, 0, time.UTC)
		end := start.Add(2 * time.Hour)
		camps := NewMockCampRepository()
		auditLogs := &MockAuditLogRepository{}
		broadcaster := &MockBroadcaster{}
		tx := &MockTxManager{}

		s := NewCampService(camps, nil, NewMockFacilitatorSessionRepository(), auditLogs, broadcaster, tx)
		s.uuidFn = func() string { return "camp-1" }

		// Act
		camp, err := s.OpenNewCamp(context.Background(), "New Camp", start, end)

		// Assert
		if err != nil {
			t.Fatalf("expected no error, got %v", err)
		}
		saved, _ := camps.Get(context.Background(), "camp-1")
		if saved == nil || saved.Name != "New Camp" || saved.StartAt != start || saved.EndAt != end || saved.Status != domain.CampPending {
			t.Fatalf("camp not saved as expected: %+v", saved)
		}
		if camp.ID != "camp-1" {
			t.Fatalf("unexpected returned camp: %+v", camp)
		}
	})

	t.Run("ShoudReturnInvalidSettingsWithoutSavingWhenPeriodMissing", func(t *testing.T) {
		// Arrange
		camps := NewMockCampRepository()
		s := NewCampService(camps, nil, NewMockFacilitatorSessionRepository(), &MockAuditLogRepository{}, &MockBroadcaster{}, &MockTxManager{})
		s.uuidFn = func() string { return "camp-1" }

		// Act
		camp, err := s.OpenNewCamp(context.Background(), "New Camp", time.Time{}, time.Time{})

		// Assert
		if err != domain.ErrCampInvalidSettings {
			t.Fatalf("expected ErrCampInvalidSettings, got %v", err)
		}
		if camp != nil {
			t.Fatalf("expected nil camp on error, got %+v", camp)
		}
		if saved, _ := camps.Get(context.Background(), "camp-1"); saved != nil {
			t.Fatalf("camp should not have been saved: %+v", saved)
		}
	})
}

func TestCampService_ActivateCamp(t *testing.T) {
	t.Run("ShouldActivateCampSuccessfullyWhenPending", func(t *testing.T) {
		// Arrange
		now := time.Now()
		camps := NewMockCampRepository()
		camp := domain.NewCampFromProps(domain.CampProps{ID: "camp-1", Status: domain.CampPending})
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

		if len(broadcaster.Broadcasts) != 1 || broadcaster.Broadcasts[0].Event != EventCampUpdated || broadcaster.Broadcasts[0].Scope != CampScope() {
			t.Errorf("expected EventCampUpdated broadcast with scope 'camp', got %v", broadcaster.Broadcasts)
		}
	})
}

func TestCampService_EndCamp(t *testing.T) {
	t.Run("ShouldEndCampSuccessfullyWhenActiveAndRevokeSessions", func(t *testing.T) {
		// Arrange
		now := time.Now()
		camps := NewMockCampRepository()
		camp := domain.NewCampFromProps(domain.CampProps{ID: "camp-1", Status: domain.CampActive})
		camps.Save(context.Background(), camp)

		sessions := NewMockFacilitatorSessionRepository()
		session := domain.NewFacilitatorSessionFromProps(domain.FacilitatorSessionProps{ID:        "session-1",
			TrackID:   "track-1",
			TokenHash: "token-hash-1",
			CreatedAt: now,
		})
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

		if len(broadcaster.Broadcasts) != 2 ||
			broadcaster.Broadcasts[0].Event != EventCampUpdated || broadcaster.Broadcasts[0].Scope != CampScope() ||
			broadcaster.Broadcasts[1].Event != EventCampEnded || broadcaster.Broadcasts[1].Scope != CampScope() {
			t.Errorf("expected EventCampUpdated and EventCampEnded broadcast with scope 'camp', got %v", broadcaster.Broadcasts)
		}
	})
}

func TestUpdateCampSettingsShoudAuditAndBroadcastWhenSaveSucceeds(t *testing.T) {
	// Arrange
	camps := NewMockCampRepository()
	camp := domain.NewCampFromProps(domain.CampProps{ID: "camp-1", Name: "Original", Status: domain.CampActive, BottleneckMinSamples: 3, BottleneckRatioPct: 20})
	_ = camps.Save(context.Background(), camp)
	audits := &MockAuditLogRepository{}
	broadcaster := &MockBroadcaster{}
	service := NewCampService(camps, nil, NewMockFacilitatorSessionRepository(), audits, broadcaster, &MockTxManager{})
	service.uuidFn = func() string { return "audit-1" }

	// Act
	updated, err := service.UpdateCampSettings(context.Background(), "camp-1", "admin-1", domain.NewCampSettingsPatchValFromProps(domain.CampSettingsPatchProps{Name: domain.Some("Updated")}))

	// Assert
	if err != nil || updated.Name != "Updated" {
		t.Fatalf("unexpected result: camp=%+v err=%v", updated, err)
	}
	if len(audits.Logs) != 1 || !audits.Logs[0].Success || audits.Logs[0].Actor != "admin-1" {
		t.Fatalf("success audit missing: %+v", audits.Logs)
	}
	if len(broadcaster.Broadcasts) != 1 || broadcaster.Broadcasts[0].Event != EventCampUpdated {
		t.Fatalf("camp_updated broadcast missing: %+v", broadcaster.Broadcasts)
	}
}

func TestUpdateCampSettingsShoudAuditFailureWithoutBroadcastWhenTransactionFails(t *testing.T) {
	// Arrange
	camps := NewMockCampRepository()
	_ = camps.Save(context.Background(), domain.NewCampFromProps(domain.CampProps{ID: "camp-1", Name: "Original", Status: domain.CampActive, BottleneckMinSamples: 3, BottleneckRatioPct: 20}))
	audits := &MockAuditLogRepository{}
	broadcaster := &MockBroadcaster{}
	txErr := errors.New("save failed")
	service := NewCampService(camps, nil, NewMockFacilitatorSessionRepository(), audits, broadcaster, failingTxManager{err: txErr})
	service.uuidFn = func() string { return "audit-1" }

	// Act
	_, err := service.UpdateCampSettings(context.Background(), "camp-1", "admin-1", domain.NewCampSettingsPatchValFromProps(domain.CampSettingsPatchProps{Name: domain.Some("Updated")}))

	// Assert
	if !errors.Is(err, txErr) {
		t.Fatalf("expected transaction error, got %v", err)
	}
	if len(audits.Logs) != 1 || audits.Logs[0].Success {
		t.Fatalf("failure audit missing: %+v", audits.Logs)
	}
	if len(broadcaster.Broadcasts) != 0 {
		t.Fatalf("broadcast occurred before successful commit: %+v", broadcaster.Broadcasts)
	}
}

func TestUpdateCampSettingsShoudReturnNotFoundWhenCampMissing(t *testing.T) {
	// Arrange
	service := NewCampService(NewMockCampRepository(), nil, NewMockFacilitatorSessionRepository(), &MockAuditLogRepository{}, &MockBroadcaster{}, &MockTxManager{})

	// Act
	_, err := service.UpdateCampSettings(context.Background(), "missing", "admin-1", domain.CampSettingsPatch{})

	// Assert
	if err != domain.ErrCampNotFound {
		t.Fatalf("expected ErrCampNotFound, got %v", err)
	}
}
