package usecase

import (
	"context"
	"time"

	"cornermon/backend/internal/domain"

	"github.com/google/uuid"
)

type DeviceTrustService struct {
	camps       CampRepository
	devices     DeviceRegistrationRepository
	admins      AdminRepository
	auditLogs   AuditLogRepository
	broadcaster Broadcaster
	tx          TxManager

	nowFn  func() time.Time
	uuidFn func() string
}

type DeviceRegistrationStatusView struct {
	Registration *domain.DeviceRegistration
	CampStatus   domain.CampStatus
}

func NewDeviceTrustService(
	camps CampRepository,
	devices DeviceRegistrationRepository,
	admins AdminRepository,
	auditLogs AuditLogRepository,
	broadcaster Broadcaster,
	tx TxManager,
) *DeviceTrustService {
	return &DeviceTrustService{
		camps:       camps,
		devices:     devices,
		admins:      admins,
		auditLogs:   auditLogs,
		broadcaster: broadcaster,
		tx:          tx,
		nowFn:       func() time.Time { return time.Now().UTC() },
		uuidFn:      uuid.NewString,
	}
}

// RequestRegistration - UC-8
func (s *DeviceTrustService) RequestRegistration(
	ctx context.Context,
	registrationCode string,
	deviceName, deviceModel, displayName string,
) (string, *domain.DeviceRegistration, error) {

	camp, err := s.camps.GetByRegistrationCode(ctx, registrationCode)
	if err != nil {
		return "", nil, withErrorContext("device.request_registration", "repository.get_camp_by_code", err, nil)
	}
	if camp == nil {
		return "", nil, withErrorContext("device.request_registration", "validate_camp", domain.ErrCampNotFound, map[string]any{"camp_found": false})
	}
	if camp.Status() == domain.CampEnded {
		return "", nil, withErrorContext("device.request_registration", "validate_camp_status", domain.ErrCampInvalidTransition, map[string]any{"camp_id": string(camp.ID()), "camp_status": string(camp.Status())})
	}
	campID := camp.ID

	plainToken, tokenHash, err := generateOpaqueToken()
	if err != nil {
		return "", nil, withErrorContext("device.request_registration", "generate_token", err, nil)
	}

	regID := domain.DeviceRegistrationID(s.uuidFn())
	reg := domain.NewDeviceRegistrationFromProps(domain.DeviceRegistrationProps{
		ID:                regID,
		CampID:            campID(),
		DeviceName:        deviceName,
		DeviceModel:       deviceModel,
		DisplayName:       displayName,
		Status:            domain.DevicePending,
		TokenHash:         tokenHash,
		FailedPinAttempts: 0,
		LockedUntil:       domain.None[time.Time](),
		ApprovedAt:        domain.None[time.Time](),
		CreatedAt:         s.nowFn(),
	})

	err = s.tx.RunInTx(ctx, func(ctx context.Context) error {
		if err := s.devices.Save(ctx, reg); err != nil {
			return withErrorContext("device.request_registration", "repository.save_device", err, map[string]any{"device_id": string(reg.ID())})
		}
		return nil
	})

	if err != nil {
		s.recordAuditLog(ctx, "anonymous", "anonymous", ActionDeviceRequest, "", false, errorAuditMetadata(err, nil))
		return "", nil, err
	}

	s.recordAuditLog(ctx, "anonymous", "anonymous", ActionDeviceRequest, string(reg.ID()), true, map[string]any{"campID": string(campID())})
	_ = s.broadcaster.Broadcast(ctx, campID(), EventDeviceRegistrationUpdated, CampScope())
	return plainToken, reg, nil
}

// GetMyRegistrationStatus - UC-1 (이슈 #32)
func (s *DeviceTrustService) GetMyRegistrationStatus(
	ctx context.Context,
	deviceToken string,
) (*DeviceRegistrationStatusView, error) {

	deviceTokenHash := hashSHA256(deviceToken)
	device, err := s.devices.GetByTokenHash(ctx, deviceTokenHash)
	if err != nil {
		return nil, withErrorContext("device.get_status", "repository.get_device_by_token", err, nil)
	}
	if device == nil {
		return nil, withErrorContext("device.get_status", "validate_device", domain.ErrDeviceNotApproved, map[string]any{"device_found": false})
	}

	camp, err := s.camps.Get(ctx, device.CampID())
	if err != nil {
		return nil, withErrorContext("device.get_status", "repository.get_camp", err, map[string]any{"camp_id": string(device.CampID())})
	}
	if camp == nil {
		return nil, withErrorContext("device.get_status", "validate_camp", domain.ErrCampNotFound, map[string]any{"camp_id": string(device.CampID()), "camp_found": false})
	}

	return &DeviceRegistrationStatusView{Registration: device, CampStatus: camp.Status()}, nil
}

// ApproveDevice - UC-14 (승인)
func (s *DeviceTrustService) ApproveDevice(
	ctx context.Context,
	regID domain.DeviceRegistrationID,
	actorAdminID domain.AdminID,
) (*domain.DeviceRegistration, error) {

	now := s.nowFn()
	device, err := s.devices.Get(ctx, regID)
	if err != nil {
		return nil, withErrorContext("device.approve", "repository.get_device", err, map[string]any{"device_id": string(regID)})
	}
	if device == nil {
		return nil, withErrorContext("device.approve", "validate_device", domain.ErrDeviceInvalidTransition, map[string]any{"device_id": string(regID), "device_found": false})
	}

	if err := device.Approve(now); err != nil {
		return nil, withErrorContext("device.approve", "domain.approve", err, map[string]any{"device_id": string(regID), "device_status": string(device.Status())})
	}

	err = s.tx.RunInTx(ctx, func(ctx context.Context) error {
		if err := s.devices.Save(ctx, device); err != nil {
			return withErrorContext("device.approve", "repository.save_device", err, map[string]any{"device_id": string(regID)})
		}
		return nil
	})

	if err != nil {
		s.recordAuditLog(ctx, string(actorAdminID), adminActorLabel(ctx, s.admins, actorAdminID, nil), ActionDeviceApproved, string(regID), false, errorAuditMetadata(err, nil))
		return nil, err
	}

	s.recordAuditLog(ctx, string(actorAdminID), adminActorLabel(ctx, s.admins, actorAdminID, nil), ActionDeviceApproved, string(regID), true, nil)
	_ = s.broadcaster.Broadcast(ctx, device.CampID(), EventDeviceRegistrationUpdated, CampScope())
	return device, nil
}

// RejectDevice - UC-14 (거부)
func (s *DeviceTrustService) RejectDevice(
	ctx context.Context,
	regID domain.DeviceRegistrationID,
	actorAdminID domain.AdminID,
) (*domain.DeviceRegistration, error) {

	device, err := s.devices.Get(ctx, regID)
	if err != nil {
		return nil, withErrorContext("device.reject", "repository.get_device", err, map[string]any{"device_id": string(regID)})
	}
	if device == nil {
		return nil, withErrorContext("device.reject", "validate_device", domain.ErrDeviceInvalidTransition, map[string]any{"device_id": string(regID), "device_found": false})
	}

	if err := device.Reject(); err != nil {
		return nil, withErrorContext("device.reject", "domain.reject", err, map[string]any{"device_id": string(regID), "device_status": string(device.Status())})
	}

	err = s.tx.RunInTx(ctx, func(ctx context.Context) error {
		if err := s.devices.Save(ctx, device); err != nil {
			return withErrorContext("device.reject", "repository.save_device", err, map[string]any{"device_id": string(regID)})
		}
		return nil
	})

	if err != nil {
		s.recordAuditLog(ctx, string(actorAdminID), adminActorLabel(ctx, s.admins, actorAdminID, nil), ActionDeviceRejected, string(regID), false, errorAuditMetadata(err, nil))
		return nil, err
	}

	s.recordAuditLog(ctx, string(actorAdminID), adminActorLabel(ctx, s.admins, actorAdminID, nil), ActionDeviceRejected, string(regID), true, nil)
	_ = s.broadcaster.Broadcast(ctx, device.CampID(), EventDeviceRegistrationUpdated, CampScope())
	return device, nil
}

// RevokeDevice - UC-15
func (s *DeviceTrustService) RevokeDevice(
	ctx context.Context,
	regID domain.DeviceRegistrationID,
	actorAdminID domain.AdminID,
) (*domain.DeviceRegistration, error) {

	device, err := s.devices.Get(ctx, regID)
	if err != nil {
		return nil, withErrorContext("device.revoke", "repository.get_device", err, map[string]any{"device_id": string(regID)})
	}
	if device == nil {
		return nil, withErrorContext("device.revoke", "validate_device", domain.ErrDeviceNotApproved, map[string]any{"device_id": string(regID), "device_found": false})
	}

	if err := device.Revoke(); err != nil {
		return nil, withErrorContext("device.revoke", "domain.revoke", err, map[string]any{"device_id": string(regID), "device_status": string(device.Status())})
	}

	err = s.tx.RunInTx(ctx, func(ctx context.Context) error {
		if err := s.devices.Save(ctx, device); err != nil {
			return withErrorContext("device.revoke", "repository.save_device", err, map[string]any{"device_id": string(regID)})
		}
		return nil
	})

	if err != nil {
		s.recordAuditLog(ctx, string(actorAdminID), adminActorLabel(ctx, s.admins, actorAdminID, nil), ActionDeviceRevoked, string(regID), false, errorAuditMetadata(err, nil))
		return nil, err
	}

	s.recordAuditLog(ctx, string(actorAdminID), adminActorLabel(ctx, s.admins, actorAdminID, nil), ActionDeviceRevoked, string(regID), true, nil)
	_ = s.broadcaster.Broadcast(ctx, device.CampID(), EventDeviceRegistrationUpdated, CampScope())
	return device, nil
}

// ResetPinFailures - UC-16
func (s *DeviceTrustService) ResetPinFailures(
	ctx context.Context,
	regID domain.DeviceRegistrationID,
	actorAdminID domain.AdminID,
) error {

	device, err := s.devices.Get(ctx, regID)
	if err != nil {
		return withErrorContext("device.reset_failures", "repository.get_device", err, map[string]any{"device_id": string(regID)})
	}
	if device == nil {
		return withErrorContext("device.reset_failures", "validate_device", domain.ErrDeviceInvalidTransition, map[string]any{"device_id": string(regID), "device_found": false})
	}

	device.ResetPinFailures()

	err = s.tx.RunInTx(ctx, func(ctx context.Context) error {
		if err := s.devices.Save(ctx, device); err != nil {
			return withErrorContext("device.reset_failures", "repository.save_device", err, map[string]any{"device_id": string(regID)})
		}
		return nil
	})

	if err != nil {
		s.recordAuditLog(ctx, string(actorAdminID), adminActorLabel(ctx, s.admins, actorAdminID, nil), ActionPinLockReset, string(regID), false, errorAuditMetadata(err, nil))
		return err // D-2 allowed: already wrapped or handled
	}

	s.recordAuditLog(ctx, string(actorAdminID), adminActorLabel(ctx, s.admins, actorAdminID, nil), ActionPinLockReset, string(regID), true, nil)
	_ = s.broadcaster.Broadcast(ctx, device.CampID(), EventDeviceRegistrationUpdated, CampScope())
	return nil
}

// ListPending
func (s *DeviceTrustService) ListPending(
	ctx context.Context,
	campID domain.CampID,
) ([]*domain.DeviceRegistration, error) {

	devices, err := s.devices.ListPendingByCamp(ctx, campID)
	if err != nil {
		return nil, withErrorContext("device.list_pending", "repository.list_pending_devices", err, map[string]any{"camp_id": string(campID)})
	}
	return devices, nil
}

// ReviewDeviceTrustRequests
func (s *DeviceTrustService) ReviewDeviceTrustRequests(ctx context.Context, campID domain.CampID, status *domain.DeviceRegistrationStatus) ([]*domain.DeviceRegistration, error) {

	devices, err := s.devices.ListByCampAndStatus(ctx, campID, status)
	if err != nil {
		var statusStr string
		if status != nil {
			statusStr = string(*status)
		}
		return nil, withErrorContext("device.review_requests", "repository.list_devices", err, map[string]any{"camp_id": string(campID), "status": statusStr})
	}
	return devices, nil
}

// ListLockedDevices returns approved devices whose lockout window has not expired.
func (s *DeviceTrustService) ListLockedDevices(ctx context.Context, campID domain.CampID) ([]*domain.DeviceRegistration, error) {

	status := domain.DeviceApproved
	devices, err := s.devices.ListByCampAndStatus(ctx, campID, &status)
	if err != nil {
		return nil, withErrorContext("device.list_locked", "repository.list_devices", err, map[string]any{"camp_id": string(campID)})
	}
	now := s.nowFn()
	locked := make([]*domain.DeviceRegistration, 0, len(devices))
	for _, device := range devices {
		if device.IsLocked(now) {
			locked = append(locked, device)
		}
	}
	return locked, nil
}

func (s *DeviceTrustService) recordAuditLog(ctx context.Context, actor, actorName string, action AuditAction, target string, success bool, metadata map[string]any) {
	log := domain.NewAuditLogFromProps(domain.AuditLogProps{
		ID:         domain.AuditLogID(s.uuidFn()),
		Actor:      actor,
		ActorName:  actorName,
		Action:     string(action),
		Target:     target,
		Success:    success,
		OccurredAt: s.nowFn(),
		Metadata:   metadata,
	})
	_ = s.auditLogs.Save(ctx, log)
}
