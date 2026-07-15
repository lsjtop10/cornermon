package usecase

import (
	"context"
	"testing"
	"time"

	"cornermon/backend/internal/domain"
)

func TestShouldListOnlyCurrentlyLockedApprovedDevicesWhenCampIsRequested(t *testing.T) {
	// Arrange
	now := time.Unix(100, 0)
	devices := NewMockDeviceRegistrationRepository()
	devices.Devices["locked"] = &domain.DeviceRegistration{ID: "locked", CampID: "camp-1", Status: domain.DeviceApproved, LockedUntil: domain.Some(now.Add(time.Minute))}
	devices.Devices["expired"] = &domain.DeviceRegistration{ID: "expired", CampID: "camp-1", Status: domain.DeviceApproved, LockedUntil: domain.Some(now.Add(-time.Minute))}
	devices.Devices["pending"] = &domain.DeviceRegistration{ID: "pending", CampID: "camp-1", Status: domain.DevicePending, LockedUntil: domain.Some(now.Add(time.Minute))}
	service := NewDeviceTrustService(NewMockCampRepository(), devices, &MockAuditLogRepository{}, &MockBroadcaster{}, &MockTxManager{})
	service.nowFn = func() time.Time { return now }

	// Act
	got, err := service.ListLockedDevices(context.Background(), "camp-1")

	// Assert
	if err != nil {
		t.Fatalf("expected no error, got %v", err)
	}
	if len(got) != 1 || got[0].ID != "locked" {
		t.Fatalf("expected only locked device, got %#v", got)
	}
}

func TestShouldListOnlyActiveFacilitatorSessionsWhenCampIsRequested(t *testing.T) {
	// Arrange
	sessions := NewMockFacilitatorSessionRepository()
	sessions.Sessions["active"] = &domain.FacilitatorSession{ID: "active", TrackID: "track-1", CreatedAt: time.Unix(1, 0), RevokedAt: domain.None[time.Time]()}
	sessions.Sessions["revoked"] = &domain.FacilitatorSession{ID: "revoked", TrackID: "track-1", RevokedAt: domain.Some(time.Unix(2, 0))}
	service := NewFacilitatorAuthService(NewMockCampRepository(), NewMockCornerRepository(), NewMockTrackRepository(), NewMockDeviceRegistrationRepository(), sessions, &MockAuditLogRepository{}, &MockBroadcaster{}, &MockTxManager{})

	// Act
	got, err := service.ListActiveSessions(context.Background(), "camp-1")

	// Assert
	if err != nil {
		t.Fatalf("expected no error, got %v", err)
	}
	if len(got) != 1 || got[0].ID != "active" {
		t.Fatalf("expected only active session, got %#v", got)
	}
}
