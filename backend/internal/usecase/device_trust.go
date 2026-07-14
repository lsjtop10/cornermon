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
	auditLogs   AuditLogRepository
	broadcaster Broadcaster
	tx          TxManager

	nowFn  func() time.Time
	uuidFn func() string
}

func NewDeviceTrustService(
	camps CampRepository,
	devices DeviceRegistrationRepository,
	auditLogs AuditLogRepository,
	broadcaster Broadcaster,
	tx TxManager,
) *DeviceTrustService {
	return &DeviceTrustService{
		camps:       camps,
		devices:     devices,
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
		CampID:            campID,
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
	_ = s.broadcaster.Broadcast(ctx, campID, EventDeviceRegistrationUpdated, CampScope())
	return plainToken, reg, nil
}

// GetMyRegistrationStatus - UC-1 (이슈 #32)
func (s *DeviceTrustService) GetMyRegistrationStatus(
	ctx context.Context,
	deviceToken string,
) (*domain.DeviceRegistrationStatus, error) {
	deviceTokenHash := hashSHA256(deviceToken)
	device, err := s.devices.GetByTokenHash(ctx, deviceTokenHash)
	if err != nil {
		return nil, err
	}
	if device == nil {
		return nil, domain.ErrDeviceNotApproved // 혹은 NotFound 처리
	}
	return &device.Status, nil
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
	_ = s.broadcaster.Broadcast(ctx, device.CampID, EventDeviceRegistrationUpdated, CampScope())
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
	_ = s.broadcaster.Broadcast(ctx, device.CampID, EventDeviceRegistrationUpdated, CampScope())
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
	_ = s.broadcaster.Broadcast(ctx, device.CampID, EventDeviceRegistrationUpdated, CampScope())
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
	_ = s.broadcaster.Broadcast(ctx, device.CampID, EventDeviceRegistrationUpdated, CampScope())
	return nil
}

// ListPending
func (s *DeviceTrustService) ListPending(
	ctx context.Context,
	campID domain.CampID,
) ([]*domain.DeviceRegistration, error) {
	return s.devices.ListPendingByCamp(ctx, campID)
}

// ReviewDeviceTrustRequests
func (s *DeviceTrustService) ReviewDeviceTrustRequests(ctx context.Context, campID domain.CampID, status *domain.DeviceRegistrationStatus) ([]*domain.DeviceRegistration, error) {
	if status == nil {
		// 만약 전체 조회를 지원한다면 ListByCamp 등을 호출하겠지만, 요구사항 상 상태 필터링 조회가 주 목적이므로
		// 현재 포트에서는 상태를 넣어서 조회하도록 작성되었습니다.
		// 만약 status가 nil이면 전체 상태를 불러오는 메서드가 포트에 추가되어야 합니다.
		// 일단 편의상 ListPendingByCamp를 재활용하거나 별도의 ListByCamp 호출이 필요할 수 있습니다.
		// 여기서는 null 처리를 하지 않고 포트로 바로 넘깁니다.
		return s.devices.ListByCampAndStatus(ctx, campID, nil)
	}
	return s.devices.ListByCampAndStatus(ctx, campID, status)
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
