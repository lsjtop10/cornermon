package usecase

import (
	"context"
	"time"

	"cornermon/backend/internal/domain"

	"github.com/google/uuid"
)

type DeviceTrustService struct {
	camps     CampRepository
	devices   DeviceRegistrationRepository
	auditLogs AuditLogRepository
	tx        TxManager

	nowFn  func() time.Time
	uuidFn func() string
}

func NewDeviceTrustService(
	camps CampRepository,
	devices DeviceRegistrationRepository,
	auditLogs AuditLogRepository,
	tx TxManager,
) *DeviceTrustService {
	return &DeviceTrustService{
		camps:     camps,
		devices:   devices,
		auditLogs: auditLogs,
		tx:        tx,
		nowFn:     time.Now,
		uuidFn:    uuid.NewString,
	}
}

// RequestRegistration - UC-8
func (s *DeviceTrustService) RequestRegistration(
	ctx context.Context,
	campID domain.CampID,
	deviceName string,
) (string, *domain.DeviceRegistration, error) {
	camp, err := s.camps.Get(ctx, campID)
	if err != nil {
		return "", nil, err
	}
	if camp == nil || !camp.IsActive() {
		return "", nil, domain.ErrCampInvalidTransition
	}

	plainToken, tokenHash, err := generateOpaqueToken()
	if err != nil {
		return "", nil, err
	}

	regID := domain.DeviceRegistrationID(s.uuidFn())
	reg := &domain.DeviceRegistration{
		ID:                regID,
		DeviceName:        deviceName,
		Status:            domain.DevicePending,
		TokenHash:         tokenHash,
		FailedPinAttempts: 0,
		LockedUntil:       domain.None[time.Time](),
		ApprovedAt:        domain.None[time.Time](),
	}

	err = s.tx.RunInTx(ctx, func(ctx context.Context) error {
		return s.devices.Save(ctx, reg)
	})

	if err != nil {
		s.recordAuditLog(ctx, "anonymous", "DEVICE_REQUEST", "", false, map[string]any{"error": err.Error()})
		return "", nil, err
	}

	s.recordAuditLog(ctx, "anonymous", "DEVICE_REQUEST", string(reg.ID), true, map[string]any{"campID": string(campID)})
	return plainToken, reg, nil
}

// ApproveDevice - UC-14 (승인)
func (s *DeviceTrustService) ApproveDevice(
	ctx context.Context,
	regID domain.DeviceRegistrationID,
	actorAdminID domain.AdminID,
) error {
	now := s.nowFn()
	device, err := s.devices.Get(ctx, regID)
	if err != nil {
		return err
	}
	if device == nil {
		return domain.ErrDeviceInvalidTransition
	}

	if err := device.Approve(now); err != nil {
		return err
	}

	err = s.tx.RunInTx(ctx, func(ctx context.Context) error {
		return s.devices.Save(ctx, device)
	})

	if err != nil {
		s.recordAuditLog(ctx, string(actorAdminID), "DEVICE_APPROVED", string(regID), false, map[string]any{"error": err.Error()})
		return err
	}

	s.recordAuditLog(ctx, string(actorAdminID), "DEVICE_APPROVED", string(regID), true, nil)
	return nil
}

// RejectDevice - UC-14 (거부)
func (s *DeviceTrustService) RejectDevice(
	ctx context.Context,
	regID domain.DeviceRegistrationID,
	actorAdminID domain.AdminID,
) error {
	device, err := s.devices.Get(ctx, regID)
	if err != nil {
		return err
	}
	if device == nil {
		return domain.ErrDeviceInvalidTransition
	}

	if err := device.Reject(); err != nil {
		return err
	}

	err = s.tx.RunInTx(ctx, func(ctx context.Context) error {
		return s.devices.Save(ctx, device)
	})

	if err != nil {
		s.recordAuditLog(ctx, string(actorAdminID), "DEVICE_REJECTED", string(regID), false, map[string]any{"error": err.Error()})
		return err
	}

	s.recordAuditLog(ctx, string(actorAdminID), "DEVICE_REJECTED", string(regID), true, nil)
	return nil
}

// RevokeDevice - UC-15
func (s *DeviceTrustService) RevokeDevice(
	ctx context.Context,
	regID domain.DeviceRegistrationID,
	actorAdminID domain.AdminID,
) error {
	device, err := s.devices.Get(ctx, regID)
	if err != nil {
		return err
	}
	if device == nil {
		return domain.ErrDeviceNotApproved
	}

	if err := device.Revoke(); err != nil {
		return err
	}

	err = s.tx.RunInTx(ctx, func(ctx context.Context) error {
		return s.devices.Save(ctx, device)
	})

	if err != nil {
		s.recordAuditLog(ctx, string(actorAdminID), "DEVICE_REVOKED", string(regID), false, map[string]any{"error": err.Error()})
		return err
	}

	s.recordAuditLog(ctx, string(actorAdminID), "DEVICE_REVOKED", string(regID), true, nil)
	return nil
}

// ResetPinFailures - UC-16
func (s *DeviceTrustService) ResetPinFailures(
	ctx context.Context,
	regID domain.DeviceRegistrationID,
	actorAdminID domain.AdminID,
) error {
	device, err := s.devices.Get(ctx, regID)
	if err != nil {
		return err
	}
	if device == nil {
		return domain.ErrDeviceInvalidTransition
	}

	device.ResetPinFailures()

	err = s.tx.RunInTx(ctx, func(ctx context.Context) error {
		return s.devices.Save(ctx, device)
	})

	if err != nil {
		s.recordAuditLog(ctx, string(actorAdminID), "PIN_LOCK_RESET", string(regID), false, map[string]any{"error": err.Error()})
		return err
	}

	s.recordAuditLog(ctx, string(actorAdminID), "PIN_LOCK_RESET", string(regID), true, nil)
	return nil
}

// ListPending
func (s *DeviceTrustService) ListPending(
	ctx context.Context,
	campID domain.CampID,
) ([]*domain.DeviceRegistration, error) {
	return s.devices.ListPendingByCamp(ctx, campID)
}

func (s *DeviceTrustService) recordAuditLog(ctx context.Context, actor, action, target string, success bool, metadata map[string]any) {
	log := domain.NewAuditLog(
		domain.AuditLogID(s.uuidFn()),
		actor,
		action,
		target,
		success,
		s.nowFn(),
		metadata,
	)
	_ = s.auditLogs.Save(ctx, log)
}
