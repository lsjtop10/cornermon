package domain

import (
	"time"
)

type DeviceRegistrationStatus string

const (
	DevicePending  DeviceRegistrationStatus = "PENDING"
	DeviceApproved DeviceRegistrationStatus = "APPROVED"
	DeviceRejected DeviceRegistrationStatus = "REJECTED"
	DeviceRevoked  DeviceRegistrationStatus = "REVOKED"
)

type DeviceRegistration struct {
	ID                DeviceRegistrationID
	CampID            CampID
	DeviceName        string
	Status            DeviceRegistrationStatus
	TokenHash         string
	FailedPinAttempts int
	LockedUntil       Optional[time.Time]
	ApprovedAt        Optional[time.Time]
	CreatedAt         time.Time
}

// Approve는 대기 중인 기기 등록 요청을 승인합니다.
func (d *DeviceRegistration) Approve(now time.Time) error {
	if d.Status != DevicePending {
		return ErrDeviceInvalidTransition
	}
	d.Status = DeviceApproved
	d.ApprovedAt = Some(now)
	return nil
}

// Reject는 대기 중인 기기 등록 요청을 거절합니다.
func (d *DeviceRegistration) Reject() error {
	if d.Status != DevicePending {
		return ErrDeviceInvalidTransition
	}
	d.Status = DeviceRejected
	return nil
}

// Revoke는 승인된 기기의 신뢰 관계를 철회합니다.
func (d *DeviceRegistration) Revoke() error {
	if d.Status != DeviceApproved {
		return ErrDeviceNotApproved
	}
	d.Status = DeviceRevoked
	return nil
}

// RecordPinFailure는 PIN 입력 실패를 기록하고 점증형 지연 시간을 계산해 설정합니다.
func (d *DeviceRegistration) RecordPinFailure(now time.Time) (time.Duration, bool) {
	d.FailedPinAttempts++

	var delay time.Duration
	needsAdminAlert := false

	switch d.FailedPinAttempts {
	case 1, 2:
		delay = 0
	case 3:
		delay = 5 * time.Second
	case 4:
		delay = 30 * time.Second
	default:
		delay = 2 * time.Minute
		needsAdminAlert = true
	}

	if delay > 0 {
		d.LockedUntil = Some(now.Add(delay))
	} else {
		d.LockedUntil = None[time.Time]()
	}

	return delay, needsAdminAlert
}

// ResetPinFailures는 PIN 실패 횟수와 지연 상태를 초기화합니다.
func (d *DeviceRegistration) ResetPinFailures() {
	d.FailedPinAttempts = 0
	d.LockedUntil = None[time.Time]()
}

// IsLocked는 현재 기기가 PIN 실패 정책으로 인해 잠겨 있는 상태인지 확인합니다.
func (d *DeviceRegistration) IsLocked(now time.Time) bool {
	lockedUntil, ok := d.LockedUntil.Value()
	if !ok {
		return false
	}
	return now.Before(lockedUntil)
}
