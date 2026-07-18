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
	id                DeviceRegistrationID
	campID            CampID
	deviceName        string
	deviceModel       string
	displayName       string
	status            DeviceRegistrationStatus
	tokenHash         string
	failedPinAttempts int
	lockedUntil       Optional[time.Time]
	approvedAt        Optional[time.Time]
	createdAt         time.Time
}

// Approve는 대기 중인 기기 등록 요청을 승인합니다.
func (d *DeviceRegistration) Approve(now time.Time) error {
	if d.status != DevicePending {
		return ErrDeviceInvalidTransition
	}
	d.status = DeviceApproved
	d.approvedAt = Some(now)
	return nil
}

// Reject는 대기 중인 기기 등록 요청을 거절합니다.
func (d *DeviceRegistration) Reject() error {
	if d.status != DevicePending {
		return ErrDeviceInvalidTransition
	}
	d.status = DeviceRejected
	return nil
}

// Revoke는 승인된 기기의 신뢰 관계를 철회합니다.
func (d *DeviceRegistration) Revoke() error {
	if d.status != DeviceApproved {
		return ErrDeviceNotApproved
	}
	d.status = DeviceRevoked
	return nil
}

// RecordPinFailure는 PIN 입력 실패를 기록하고 점증형 지연 시간을 계산해 설정합니다.
func (d *DeviceRegistration) RecordPinFailure(now time.Time) (time.Duration, bool) {
	d.failedPinAttempts++

	var delay time.Duration
	needsAdminAlert := false

	switch d.failedPinAttempts {
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
		d.lockedUntil = Some(now.Add(delay))
	} else {
		d.lockedUntil = None[time.Time]()
	}

	return delay, needsAdminAlert
}

// ResetPinFailures는 PIN 실패 횟수와 지연 상태를 초기화합니다.
func (d *DeviceRegistration) ResetPinFailures() {
	d.failedPinAttempts = 0
	d.lockedUntil = None[time.Time]()
}

// IsLocked는 현재 기기가 PIN 실패 정책으로 인해 잠겨 있는 상태인지 확인합니다.
func (d *DeviceRegistration) IsLocked(now time.Time) bool {
	lockedUntil, ok := d.lockedUntil.Value()
	if !ok {
		return false
	}
	return now.Before(lockedUntil)
}

func (d *DeviceRegistration) ID() DeviceRegistrationID {
	return d.id
}

func (d *DeviceRegistration) CampID() CampID {
	return d.campID
}

func (d *DeviceRegistration) DeviceName() string {
	return d.deviceName
}

func (d *DeviceRegistration) DeviceModel() string {
	return d.deviceModel
}

func (d *DeviceRegistration) DisplayName() string {
	return d.displayName
}

func (d *DeviceRegistration) Status() DeviceRegistrationStatus {
	return d.status
}

func (d *DeviceRegistration) TokenHash() string {
	return d.tokenHash
}

func (d *DeviceRegistration) FailedPinAttempts() int {
	return d.failedPinAttempts
}

func (r *DeviceRegistration) LockedUntil() Optional[time.Time] {
	return r.lockedUntil
}
func (r *DeviceRegistration) SetLockedUntil(t Optional[time.Time]) {
	r.lockedUntil = t
}

func (r *DeviceRegistration) ApprovedAt() Optional[time.Time] {
	return r.approvedAt
}
func (r *DeviceRegistration) SetApprovedAt(t Optional[time.Time]) {
	r.approvedAt = t
}

func (d *DeviceRegistration) CreatedAt() time.Time {
	return d.createdAt
}

type DeviceRegistrationProps struct {
	ID DeviceRegistrationID
	CampID CampID
	DeviceName string
	DeviceModel string
	DisplayName string
	Status DeviceRegistrationStatus
	TokenHash string
	FailedPinAttempts int
	LockedUntil Optional[time.Time]
	ApprovedAt Optional[time.Time]
	CreatedAt time.Time
}
func NewDeviceRegistrationFromProps(p DeviceRegistrationProps) *DeviceRegistration {
	return &DeviceRegistration{
		id: p.ID,
		campID: p.CampID,
		deviceName: p.DeviceName,
		deviceModel: p.DeviceModel,
		displayName: p.DisplayName,
		status: p.Status,
		tokenHash: p.TokenHash,
		failedPinAttempts: p.FailedPinAttempts,
		lockedUntil: p.LockedUntil,
		approvedAt: p.ApprovedAt,
		createdAt: p.CreatedAt,
	}
}
func NewDeviceRegistrationValFromProps(p DeviceRegistrationProps) DeviceRegistration {
	return DeviceRegistration{
		id: p.ID,
		campID: p.CampID,
		deviceName: p.DeviceName,
		deviceModel: p.DeviceModel,
		displayName: p.DisplayName,
		status: p.Status,
		tokenHash: p.TokenHash,
		failedPinAttempts: p.FailedPinAttempts,
		lockedUntil: p.LockedUntil,
		approvedAt: p.ApprovedAt,
		createdAt: p.CreatedAt,
	}
}
