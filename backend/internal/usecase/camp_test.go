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

		s := NewCampService(camps, nil, NewMockDeviceRegistrationRepository(), NewMockVisitRepository(), NewMockGroupRepository(), NewMockFacilitatorSessionRepository(), NewMockAdminRepository(), auditLogs, broadcaster, tx)
		s.uuidFn = func() string { return "camp-1" }

		// Act
		camp, err := s.OpenNewCamp(context.Background(), "New Camp", start, end, "admin-1")

		// Assert
		if err != nil {
			t.Fatalf("expected no error, got %v", err)
		}
		saved, _ := camps.Get(context.Background(), "camp-1")
		if saved == nil || saved.Name() != "New Camp" || saved.StartAt() != start || saved.EndAt() != end || saved.Status() != domain.CampPending {
			t.Fatalf("camp not saved as expected: %+v", saved)
		}
		if camp.ID() != "camp-1" {
			t.Fatalf("unexpected returned camp: %+v", camp)
		}
	})

	t.Run("ShoudRecordAdminIDAsActorAndUsernameAsActorNameWhenSucceeded", func(t *testing.T) {
		// Arrange
		start := time.Date(2026, 7, 20, 9, 0, 0, 0, time.UTC)
		end := start.Add(2 * time.Hour)
		camps := NewMockCampRepository()
		auditLogs := &MockAuditLogRepository{}
		broadcaster := &MockBroadcaster{}
		tx := &MockTxManager{}
		admins := NewMockAdminRepository()
		admins.Admins["admin-1"] = domain.NewAdminFromProps(domain.AdminProps{ID: "admin-1", Username: "김관리"})

		s := NewCampService(camps, nil, NewMockDeviceRegistrationRepository(), NewMockVisitRepository(), NewMockGroupRepository(), NewMockFacilitatorSessionRepository(), admins, auditLogs, broadcaster, tx)
		s.uuidFn = func() string { return "camp-1" }

		// Act
		_, err := s.OpenNewCamp(context.Background(), "New Camp", start, end, "admin-1")

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
		if campID, ok := got.CampID().Value(); !ok || campID != "camp-1" {
			t.Errorf("expected CampID Some('camp-1'), got %v (set=%v)", campID, ok)
		}
		if got.TargetName() != "New Camp" {
			t.Errorf("expected TargetName 'New Camp', got %q", got.TargetName())
		}
	})

	t.Run("ShoudReturnInvalidSettingsWithoutSavingWhenPeriodMissing", func(t *testing.T) {
		// Arrange
		camps := NewMockCampRepository()
		s := NewCampService(camps, nil, NewMockDeviceRegistrationRepository(), NewMockVisitRepository(), NewMockGroupRepository(), NewMockFacilitatorSessionRepository(), NewMockAdminRepository(), &MockAuditLogRepository{}, &MockBroadcaster{}, &MockTxManager{})
		s.uuidFn = func() string { return "camp-1" }

		// Act
		camp, err := s.OpenNewCamp(context.Background(), "New Camp", time.Time{}, time.Time{}, "admin-1")

		// Assert
		if !errors.Is(err, domain.ErrCampInvalidSettings) {
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

		s := NewCampService(camps, nil, NewMockDeviceRegistrationRepository(), NewMockVisitRepository(), NewMockGroupRepository(), sessions, NewMockAdminRepository(), auditLogs, broadcaster, tx)
		s.nowFn = func() time.Time { return now }
		s.uuidFn = func() string { return "audit-uuid" }

		// Act
		err := s.ActivateCamp(context.Background(), "camp-1", "admin-1")

		// Assert
		if err != nil {
			t.Fatalf("expected no error, got %v", err)
		}

		updated, _ := camps.Get(context.Background(), "camp-1")
		if updated.Status() != domain.CampActive {
			t.Errorf("expected status 'ACTIVE', got %s", updated.Status())
		}

		if len(broadcaster.Broadcasts) != 1 || broadcaster.Broadcasts[0].Event != EventCampUpdated || broadcaster.Broadcasts[0].Scope != CampScope() {
			t.Errorf("expected EventCampUpdated broadcast with scope 'camp', got %v", broadcaster.Broadcasts)
		}
	})
}

func TestCampService_EndCamp(t *testing.T) {
	t.Run("ShoudFinalizeCampResourcesWhenActive", func(t *testing.T) {
		// Arrange
		now := time.Date(2026, 7, 20, 10, 0, 0, 0, time.UTC)
		camps := NewMockCampRepository()
		camp := domain.NewCampFromProps(domain.CampProps{ID: "camp-1", Status: domain.CampActive})
		camps.Save(context.Background(), camp)

		devices := NewMockDeviceRegistrationRepository()
		approvedDevice := domain.NewDeviceRegistrationFromProps(domain.DeviceRegistrationProps{ID: "device-approved", CampID: "camp-1", Status: domain.DeviceApproved})
		pendingDevice := domain.NewDeviceRegistrationFromProps(domain.DeviceRegistrationProps{ID: "device-pending", CampID: "camp-1", Status: domain.DevicePending})
		_ = devices.Save(context.Background(), approvedDevice)
		_ = devices.Save(context.Background(), pendingDevice)

		sessions := NewMockFacilitatorSessionRepository()
		session := domain.NewFacilitatorSessionFromProps(domain.FacilitatorSessionProps{ID: "session-1",
			TrackID:   "track-1",
			TokenHash: "token-hash-1",
			CreatedAt: now,
		})
		sessions.Save(context.Background(), session)
		sessions.TrackCampIDs["track-1"] = "camp-1"

		visits := NewMockVisitRepository()
		inProgressVisit := domain.NewVisit("visit-in-progress", "group-1", "corner-1", "track-1", domain.VisitManual, now.Add(-5*time.Minute))
		completedVisit := domain.NewVisitFromProps(domain.VisitProps{ID: "visit-completed", GroupID: "group-1", CornerID: "corner-2", TrackID: "track-2", Status: domain.VisitStatusCompleted, StartedAt: now.Add(-10 * time.Minute), EndedAt: domain.Some(now.Add(-2 * time.Minute))})
		otherCampVisit := domain.NewVisit("visit-other-camp", "group-2", "corner-4", "track-3", domain.VisitManual, now.Add(-5*time.Minute))
		_ = visits.Save(context.Background(), inProgressVisit)
		_ = visits.Save(context.Background(), completedVisit)
		_ = visits.Save(context.Background(), otherCampVisit)
		visits.GroupCampIDs["group-1"] = "camp-1"
		visits.GroupCampIDs["group-2"] = "camp-2"

		groups := NewMockGroupRepository()
		group := domain.NewGroupFromProps(domain.GroupProps{ID: "group-1", CampID: "camp-1", Itinerary: []domain.CornerProgress{
			domain.NewCornerProgressValFromProps(domain.CornerProgressProps{CornerID: "corner-1", Status: domain.VisitInProgress}),
			domain.NewCornerProgressValFromProps(domain.CornerProgressProps{CornerID: "corner-2", Status: domain.VisitCompleted}),
			domain.NewCornerProgressValFromProps(domain.CornerProgressProps{CornerID: "corner-3", Status: domain.VisitNotVisited}),
		}})
		_ = groups.Save(context.Background(), group)

		tracks := NewMockTrackRepository()
		track := domain.NewTrackFromProps(domain.TrackProps{ID: "track-1", CornerID: "corner-1", Status: domain.TrackActive, CurrentVisitID: domain.Some(domain.VisitID("visit-in-progress"))})
		_ = tracks.Save(context.Background(), track)

		auditLogs := &MockAuditLogRepository{}
		broadcaster := &MockBroadcaster{}
		tx := &MockTxManager{}

		s := NewCampService(camps, tracks, devices, visits, groups, sessions, NewMockAdminRepository(), auditLogs, broadcaster, tx)
		s.nowFn = func() time.Time { return now }
		s.uuidFn = func() string { return "audit-uuid" }

		// Act
		err := s.EndCamp(context.Background(), "camp-1", "admin-1")

		// Assert
		if err != nil {
			t.Fatalf("expected no error, got %v", err)
		}

		updatedCamp, _ := camps.Get(context.Background(), "camp-1")
		if updatedCamp.Status() != domain.CampEnded {
			t.Errorf("expected status 'ENDED', got %s", updatedCamp.Status())
		}

		updatedSession, _ := sessions.GetByTokenHash(context.Background(), "token-hash-1")
		if updatedSession.IsActive() {
			t.Errorf("expected session to be revoked")
		}
		if approvedDevice.Status() != domain.DeviceRevoked {
			t.Errorf("expected approved device to be revoked, got %s", approvedDevice.Status())
		}
		if pendingDevice.Status() != domain.DevicePending {
			t.Errorf("expected pending device to be preserved, got %s", pendingDevice.Status())
		}
		if inProgressVisit.Status() != domain.VisitStatusCompleted {
			t.Errorf("expected in-progress visit to complete, got %s", inProgressVisit.Status())
		}
		if otherCampVisit.Status() != domain.VisitStatusInProgress {
			t.Errorf("expected other camp visit to be preserved, got %s", otherCampVisit.Status())
		}
		if endedAt, ok := inProgressVisit.EndedAt().Value(); !ok || !endedAt.Equal(now) {
			t.Errorf("expected visit completion time %v, got %v", now, inProgressVisit.EndedAt())
		}
		if endedAt, _ := completedVisit.EndedAt().Value(); !endedAt.Equal(now.Add(-2 * time.Minute)) {
			t.Errorf("expected completed visit to be preserved, got %v", completedVisit.EndedAt())
		}
		if track.OperationalStatus() != domain.TrackIdle {
			t.Errorf("expected track to be idle, got %s", track.OperationalStatus())
		}
		itinerary := group.Itinerary()
		if itinerary[0].Status() != domain.VisitCompleted || itinerary[2].Status() != domain.VisitNotVisited {
			t.Errorf("expected completed in-progress corner and preserved not-visited corner, got %+v", itinerary)
		}

		if len(broadcaster.Broadcasts) != 6 ||
			broadcaster.Broadcasts[0].Event != EventCampEnded || broadcaster.Broadcasts[0].Scope != CampScope() ||
			broadcaster.Broadcasts[1].Event != EventCampUpdated ||
			broadcaster.Broadcasts[2].Event != EventDeviceRegistrationUpdated ||
			broadcaster.Broadcasts[3].Event != EventCornersUpdated ||
			broadcaster.Broadcasts[4].Event != EventGroupsUpdated ||
			broadcaster.Broadcasts[5].Event != EventTracksUpdated {
			t.Errorf("expected post-commit camp resource broadcasts and camp_ended, got %v", broadcaster.Broadcasts)
		}
	})

	t.Run("ShoudNotBroadcastWhenEndTransactionFails", func(t *testing.T) {
		// Arrange
		camps := NewMockCampRepository()
		_ = camps.Save(context.Background(), domain.NewCampFromProps(domain.CampProps{ID: "camp-1", Status: domain.CampActive}))
		broadcaster := &MockBroadcaster{}
		txErr := errors.New("transaction failed")
		service := NewCampService(camps, NewMockTrackRepository(), NewMockDeviceRegistrationRepository(), NewMockVisitRepository(), NewMockGroupRepository(), NewMockFacilitatorSessionRepository(), NewMockAdminRepository(), &MockAuditLogRepository{}, broadcaster, failingTxManager{err: txErr})

		// Act
		err := service.EndCamp(context.Background(), "camp-1", "admin-1")

		// Assert
		if !errors.Is(err, txErr) {
			t.Fatalf("expected transaction error, got %v", err)
		}
		if len(broadcaster.Broadcasts) != 0 {
			t.Fatalf("expected no broadcasts before successful commit, got %v", broadcaster.Broadcasts)
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
	service := NewCampService(camps, nil, NewMockDeviceRegistrationRepository(), NewMockVisitRepository(), NewMockGroupRepository(), NewMockFacilitatorSessionRepository(), NewMockAdminRepository(), audits, broadcaster, &MockTxManager{})
	service.uuidFn = func() string { return "audit-1" }

	// Act
	updated, err := service.UpdateCampSettings(context.Background(), "camp-1", "admin-1", domain.NewCampSettingsPatchValFromProps(domain.CampSettingsPatchProps{Name: domain.Some("Updated")}))

	// Assert
	if err != nil || updated.Name() != "Updated" {
		t.Fatalf("unexpected result: camp=%+v err=%v", updated, err)
	}
	if len(audits.Logs) != 1 || !audits.Logs[0].Success() || audits.Logs[0].Actor() != "admin-1" {
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
	service := NewCampService(camps, nil, NewMockDeviceRegistrationRepository(), NewMockVisitRepository(), NewMockGroupRepository(), NewMockFacilitatorSessionRepository(), NewMockAdminRepository(), audits, broadcaster, failingTxManager{err: txErr})
	service.uuidFn = func() string { return "audit-1" }

	// Act
	_, err := service.UpdateCampSettings(context.Background(), "camp-1", "admin-1", domain.NewCampSettingsPatchValFromProps(domain.CampSettingsPatchProps{Name: domain.Some("Updated")}))

	// Assert
	if !errors.Is(err, txErr) {
		t.Fatalf("expected transaction error, got %v", err)
	}
	if len(audits.Logs) != 1 || audits.Logs[0].Success() {
		t.Fatalf("failure audit missing: %+v", audits.Logs)
	}
	if len(broadcaster.Broadcasts) != 0 {
		t.Fatalf("broadcast occurred before successful commit: %+v", broadcaster.Broadcasts)
	}
}

func TestUpdateCampSettingsShoudReturnNotFoundWhenCampMissing(t *testing.T) {
	// Arrange
	service := NewCampService(NewMockCampRepository(), nil, NewMockDeviceRegistrationRepository(), NewMockVisitRepository(), NewMockGroupRepository(), NewMockFacilitatorSessionRepository(), NewMockAdminRepository(), &MockAuditLogRepository{}, &MockBroadcaster{}, &MockTxManager{})

	// Act
	_, err := service.UpdateCampSettings(context.Background(), "missing", "admin-1", domain.CampSettingsPatch{})

	// Assert
	if !errors.Is(err, domain.ErrCampNotFound) {
		t.Fatalf("expected ErrCampNotFound, got %v", err)
	}
}
