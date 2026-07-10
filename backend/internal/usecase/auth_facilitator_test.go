package usecase

import (
	"context"
	"testing"
	"time"

	"cornermon/backend/internal/domain"
)

func TestFacilitatorAuthService_Login(t *testing.T) {
	t.Run("ShouldLoginSuccessfullyWhenCredentialsAreValid", func(t *testing.T) {
		// Arrange
		now := time.Now()
		camps := NewMockCampRepository()
		camp := &domain.Camp{ID: "camp-1", Status: domain.CampActive}
		camps.Save(context.Background(), camp)

		tracks := NewMockTrackRepository()
		pinHash, _ := hashPassword("123456")
		track := &domain.Track{
			ID:       "track-1",
			CornerID: "corner-1",
			Status:   domain.TrackActive,
			PINHash:  pinHash,
		}
		tracks.Save(context.Background(), track)

		devices := NewMockDeviceRegistrationRepository()
		deviceToken := "device-token-1"
		deviceTokenHash := hashSHA256(deviceToken)
		device := &domain.DeviceRegistration{
			ID:        "device-1",
			CampID:    "camp-1",
			Status:    domain.DeviceApproved,
			TokenHash: deviceTokenHash,
		}
		devices.Save(context.Background(), device)

		sessions := NewMockFacilitatorSessionRepository()
		auditLogs := &MockAuditLogRepository{}
		broadcaster := &MockBroadcaster{}
		tx := &MockTxManager{}

		s := NewFacilitatorAuthService(camps, tracks, devices, sessions, auditLogs, broadcaster, tx)
		s.nowFn = func() time.Time { return now }
		s.uuidFn = func() string { return "session-uuid" }

		// Act
		plainToken, session, err := s.Login(context.Background(), deviceToken, "123456")

		// Assert
		if err != nil {
			t.Fatalf("expected no error, got %v", err)
		}
		if plainToken == "" {
			t.Fatal("expected plainToken, got empty")
		}
		if session == nil {
			t.Fatal("expected session, got nil")
		}
		if session.ID != "session-uuid" {
			t.Errorf("expected session ID to be 'session-uuid', got '%s'", session.ID)
		}
		if session.TrackID != "track-1" {
			t.Errorf("expected track ID to be 'track-1', got '%s'", session.TrackID)
		}
	})

	t.Run("ShouldFailLoginWhenDeviceIsNotApproved", func(t *testing.T) {
		// Arrange
		now := time.Now()
		camps := NewMockCampRepository()
		camp := &domain.Camp{ID: "camp-1", Status: domain.CampActive}
		camps.Save(context.Background(), camp)

		tracks := NewMockTrackRepository()
		pinHash, _ := hashPassword("123456")
		track := &domain.Track{
			ID:       "track-1",
			CornerID: "corner-1",
			Status:   domain.TrackActive,
			PINHash:  pinHash,
		}
		tracks.Save(context.Background(), track)

		devices := NewMockDeviceRegistrationRepository()
		deviceToken := "device-token-1"
		deviceTokenHash := hashSHA256(deviceToken)
		device := &domain.DeviceRegistration{
			ID:        "device-1",
			CampID:    "camp-1",
			Status:    domain.DevicePending,
			TokenHash: deviceTokenHash,
		}
		devices.Save(context.Background(), device)

		sessions := NewMockFacilitatorSessionRepository()
		auditLogs := &MockAuditLogRepository{}
		broadcaster := &MockBroadcaster{}
		tx := &MockTxManager{}

		s := NewFacilitatorAuthService(camps, tracks, devices, sessions, auditLogs, broadcaster, tx)
		s.nowFn = func() time.Time { return now }

		// Act
		_, _, err := s.Login(context.Background(), deviceToken, "123456")

		// Assert
		if err != domain.ErrDeviceNotApproved {
			t.Errorf("expected ErrDeviceNotApproved, got %v", err)
		}
	})

	t.Run("ShouldFailLoginWhenDeviceIsLocked", func(t *testing.T) {
		// Arrange
		now := time.Now()
		camps := NewMockCampRepository()
		camp := &domain.Camp{ID: "camp-1", Status: domain.CampActive}
		camps.Save(context.Background(), camp)

		tracks := NewMockTrackRepository()
		pinHash, _ := hashPassword("123456")
		track := &domain.Track{
			ID:       "track-1",
			CornerID: "corner-1",
			Status:   domain.TrackActive,
			PINHash:  pinHash,
		}
		tracks.Save(context.Background(), track)

		devices := NewMockDeviceRegistrationRepository()
		deviceToken := "device-token-1"
		deviceTokenHash := hashSHA256(deviceToken)
		device := &domain.DeviceRegistration{
			ID:          "device-1",
			CampID:      "camp-1",
			Status:      domain.DeviceApproved,
			TokenHash:   deviceTokenHash,
			LockedUntil: domain.Some(now.Add(5 * time.Minute)),
		}
		devices.Save(context.Background(), device)

		sessions := NewMockFacilitatorSessionRepository()
		auditLogs := &MockAuditLogRepository{}
		broadcaster := &MockBroadcaster{}
		tx := &MockTxManager{}

		s := NewFacilitatorAuthService(camps, tracks, devices, sessions, auditLogs, broadcaster, tx)
		s.nowFn = func() time.Time { return now }

		// Act
		_, _, err := s.Login(context.Background(), deviceToken, "123456")

		// Assert
		if err != domain.ErrDeviceLocked {
			t.Errorf("expected ErrDeviceLocked, got %v", err)
		}
	})

	t.Run("ShouldTriggerLockoutAlertOnFifthPinFailure", func(t *testing.T) {
		// Arrange
		now := time.Now()
		camps := NewMockCampRepository()
		camp := &domain.Camp{ID: "camp-1", Status: domain.CampActive}
		camps.Save(context.Background(), camp)

		tracks := NewMockTrackRepository()
		pinHash, _ := hashPassword("123456")
		track := &domain.Track{
			ID:       "track-1",
			CornerID: "corner-1",
			Status:   domain.TrackActive,
			PINHash:  pinHash,
		}
		tracks.Save(context.Background(), track)

		devices := NewMockDeviceRegistrationRepository()
		deviceToken := "device-token-1"
		deviceTokenHash := hashSHA256(deviceToken)
		device := &domain.DeviceRegistration{
			ID:                "device-1",
			CampID:            "camp-1",
			Status:            domain.DeviceApproved,
			TokenHash:         deviceTokenHash,
			FailedPinAttempts: 4, // 5번째 실패 유도
		}
		devices.Save(context.Background(), device)

		sessions := NewMockFacilitatorSessionRepository()
		auditLogs := &MockAuditLogRepository{}
		broadcaster := &MockBroadcaster{}
		tx := &MockTxManager{}

		s := NewFacilitatorAuthService(camps, tracks, devices, sessions, auditLogs, broadcaster, tx)
		s.nowFn = func() time.Time { return now }

		// Act
		_, _, err := s.Login(context.Background(), deviceToken, "wrong-pin")

		// Assert
		if err == nil || err.Error() != "invalid pin" {
			t.Fatalf("expected 'invalid pin' error, got %v", err)
		}

		if len(broadcaster.Broadcasts) != 1 || 
			broadcaster.Broadcasts[0].CampID != "camp-1" ||
			broadcaster.Broadcasts[0].Event != EventLockoutAlert ||
			broadcaster.Broadcasts[0].Scope != "device:device-1" {
			t.Errorf("expected EventLockoutAlert broadcast, got %v", broadcaster.Broadcasts)
		}
	})
}
