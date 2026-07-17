package domain_test

import (
	"errors"
	"testing"
	"time"

	"cornermon/backend/internal/domain"
)

func TestDeviceRegistration_ApproveRejectRevoke(t *testing.T) {
	now := time.Date(2026, 7, 9, 15, 0, 0, 0, time.UTC)

	t.Run("Approve on PENDING succeeds", func(t *testing.T) {
		device := domain.NewDeviceRegistrationFromProps(domain.DeviceRegistrationProps{ID:     domain.DeviceRegistrationID("device-1"),
			Status: domain.DevicePending,
		})

		err := device.Approve(now)
		if err != nil {
			t.Fatalf("expected no error, got %v", err)
		}

		if device.Status != domain.DeviceApproved {
			t.Errorf("expected APPROVED, got %v", device.Status)
		}

		approvedAt, ok := device.ApprovedAt.Value()
		if !ok || !approvedAt.Equal(now) {
			t.Errorf("expected ApprovedAt to be %v, got %v", now, approvedAt)
		}
	})

	t.Run("Approve on APPROVED fails with ErrDeviceInvalidTransition", func(t *testing.T) {
		device := domain.NewDeviceRegistrationFromProps(domain.DeviceRegistrationProps{ID:     domain.DeviceRegistrationID("device-1"),
			Status: domain.DeviceApproved,
		})

		err := device.Approve(now)
		if !errors.Is(err, domain.ErrDeviceInvalidTransition) {
			t.Errorf("expected %v, got %v", domain.ErrDeviceInvalidTransition, err)
		}
	})

	t.Run("Reject on PENDING succeeds", func(t *testing.T) {
		device := domain.NewDeviceRegistrationFromProps(domain.DeviceRegistrationProps{ID:     domain.DeviceRegistrationID("device-1"),
			Status: domain.DevicePending,
		})

		err := device.Reject()
		if err != nil {
			t.Fatalf("expected no error, got %v", err)
		}

		if device.Status != domain.DeviceRejected {
			t.Errorf("expected REJECTED, got %v", device.Status)
		}
	})

	t.Run("Reject on REJECTED fails with ErrDeviceInvalidTransition", func(t *testing.T) {
		device := domain.NewDeviceRegistrationFromProps(domain.DeviceRegistrationProps{ID:     domain.DeviceRegistrationID("device-1"),
			Status: domain.DeviceRejected,
		})

		err := device.Reject()
		if !errors.Is(err, domain.ErrDeviceInvalidTransition) {
			t.Errorf("expected %v, got %v", domain.ErrDeviceInvalidTransition, err)
		}
	})

	t.Run("Revoke on APPROVED succeeds", func(t *testing.T) {
		device := domain.NewDeviceRegistrationFromProps(domain.DeviceRegistrationProps{ID:     domain.DeviceRegistrationID("device-1"),
			Status: domain.DeviceApproved,
		})

		err := device.Revoke()
		if err != nil {
			t.Fatalf("expected no error, got %v", err)
		}

		if device.Status != domain.DeviceRevoked {
			t.Errorf("expected REVOKED, got %v", device.Status)
		}
	})

	t.Run("Revoke on PENDING fails with ErrDeviceNotApproved", func(t *testing.T) {
		device := domain.NewDeviceRegistrationFromProps(domain.DeviceRegistrationProps{ID:     domain.DeviceRegistrationID("device-1"),
			Status: domain.DevicePending,
		})

		err := device.Revoke()
		if !errors.Is(err, domain.ErrDeviceNotApproved) {
			t.Errorf("expected %v, got %v", domain.ErrDeviceNotApproved, err)
		}
	})
}

func TestDeviceRegistration_PinFailuresLockPolicies(t *testing.T) {
	now := time.Date(2026, 7, 9, 15, 0, 0, 0, time.UTC)
	device := domain.NewDeviceRegistrationFromProps(domain.DeviceRegistrationProps{ID:     domain.DeviceRegistrationID("device-1"),
		Status: domain.DeviceApproved,
	})

	t.Run("Progressive failure lock steps", func(t *testing.T) {
		// 1st failure: 0 delay
		delay, alert := device.RecordPinFailure(now)
		if delay != 0 || alert {
			t.Errorf("expected 0 delay and false alert, got %v and %v", delay, alert)
		}
		if device.IsLocked(now) {
			t.Error("expected not locked")
		}

		// 2nd failure: 0 delay
		delay, alert = device.RecordPinFailure(now)
		if delay != 0 || alert {
			t.Errorf("expected 0 delay and false alert, got %v and %v", delay, alert)
		}

		// 3rd failure: 5 seconds delay
		delay, alert = device.RecordPinFailure(now)
		if delay != 5*time.Second || alert {
			t.Errorf("expected 5s delay and false alert, got %v and %v", delay, alert)
		}
		if !device.IsLocked(now) {
			t.Error("expected locked now")
		}
		if device.IsLocked(now.Add(6 * time.Second)) {
			t.Error("expected unlocked after 6 seconds")
		}

		// 4th failure: 30 seconds delay
		delay, alert = device.RecordPinFailure(now)
		if delay != 30*time.Second || alert {
			t.Errorf("expected 30s delay and false alert, got %v and %v", delay, alert)
		}
		if !device.IsLocked(now) {
			t.Error("expected locked now")
		}
		if device.IsLocked(now.Add(31 * time.Second)) {
			t.Error("expected unlocked after 31 seconds")
		}

		// 5th failure: 2 minutes delay + Alert
		delay, alert = device.RecordPinFailure(now)
		if delay != 2*time.Minute || !alert {
			t.Errorf("expected 2m delay and true alert, got %v and %v", delay, alert)
		}
		if !device.IsLocked(now) {
			t.Error("expected locked now")
		}

		// 6th failure: 2 minutes delay + Alert
		delay, alert = device.RecordPinFailure(now)
		if delay != 2*time.Minute || !alert {
			t.Errorf("expected 2m delay and true alert, got %v and %v", delay, alert)
		}

		// Reset failures
		device.ResetPinFailures()
		if device.FailedPinAttempts != 0 {
			t.Errorf("expected 0 attempts, got %d", device.FailedPinAttempts)
		}
		if device.IsLocked(now) {
			t.Error("expected unlocked after reset")
		}
	})
}
