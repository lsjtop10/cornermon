package usecase

import (
	"context"
	"errors"
	"time"

	"cornermon/backend/internal/domain"

	"github.com/google/uuid"
)

type FacilitatorAuthService struct {
	camps       CampRepository
	tracks      TrackRepository
	devices     DeviceRegistrationRepository
	sessions    FacilitatorSessionRepository
	auditLogs   AuditLogRepository
	broadcaster Broadcaster
	tx          TxManager

	nowFn  func() time.Time
	uuidFn func() string
}

func NewFacilitatorAuthService(
	camps CampRepository,
	tracks TrackRepository,
	devices DeviceRegistrationRepository,
	sessions FacilitatorSessionRepository,
	auditLogs AuditLogRepository,
	broadcaster Broadcaster,
	tx TxManager,
) *FacilitatorAuthService {
	return &FacilitatorAuthService{
		camps:       camps,
		tracks:      tracks,
		devices:     devices,
		sessions:    sessions,
		auditLogs:   auditLogs,
		broadcaster: broadcaster,
		tx:          tx,
		nowFn:       time.Now,
		uuidFn:      uuid.NewString,
	}
}

// Login - UC-9
func (s *FacilitatorAuthService) Login(
	ctx context.Context,
	campID domain.CampID,
	trackID domain.TrackID,
	deviceToken string,
	pin string,
) (string, *domain.FacilitatorSession, error) {
	now := s.nowFn()
	deviceTokenHash := hashSHA256(deviceToken)

	// 1. 기기 정보 조회 및 검증
	device, err := s.devices.GetByTokenHash(ctx, deviceTokenHash)
	if err != nil {
		return "", nil, err
	}
	if device == nil || device.Status != domain.DeviceApproved {
		s.recordAuditLog(ctx, "anonymous", "FACILITATOR_LOGIN", string(trackID), false, map[string]any{"error": domain.ErrDeviceNotApproved.Error()})
		return "", nil, domain.ErrDeviceNotApproved
	}

	if device.IsLocked(now) {
		s.recordAuditLog(ctx, "anonymous", "FACILITATOR_LOGIN", string(trackID), false, map[string]any{"error": domain.ErrDeviceLocked.Error()})
		return "", nil, domain.ErrDeviceLocked
	}

	// 2. 트랙 정보 조회 및 검증
	track, err := s.tracks.Get(ctx, trackID)
	if err != nil {
		return "", nil, err
	}
	if track == nil || track.Status != domain.TrackActive {
		s.recordAuditLog(ctx, "anonymous", "FACILITATOR_LOGIN", string(trackID), false, map[string]any{"error": domain.ErrTrackNotActive.Error()})
		return "", nil, domain.ErrTrackNotActive
	}

	// 3. 캠프 정보 조회 및 검증
	camp, err := s.camps.Get(ctx, campID)
	if err != nil {
		return "", nil, err
	}
	if camp == nil || !camp.IsActive() {
		s.recordAuditLog(ctx, "anonymous", "FACILITATOR_LOGIN", string(trackID), false, map[string]any{"error": domain.ErrCampInvalidTransition.Error()})
		return "", nil, domain.ErrCampInvalidTransition
	}

	// 4. PIN 검증
	if err := verifyPassword(track.PINHash, pin); err != nil {
		// PIN 검증 실패 시
		_, needsAdminAlert := device.RecordPinFailure(now)
		_ = s.devices.Save(ctx, device)

		if needsAdminAlert {
			_ = s.broadcaster.Broadcast(ctx, device.CampID, EventLockoutAlert, "device:"+string(device.ID))
		}

		s.recordAuditLog(ctx, "anonymous", "FACILITATOR_LOGIN", string(trackID), false, map[string]any{"error": "invalid pin", "device_failures": device.FailedPinAttempts})
		return "", nil, errors.New("invalid pin")
	}

	// PIN 검증 성공 시 실패 횟수 리셋
	device.ResetPinFailures()

	// 5. 신규 세션 토큰 및 세션 정보 생성
	plainToken, sessionTokenHash, err := generateOpaqueToken()
	if err != nil {
		return "", nil, err
	}

	sessionID := domain.FacilitatorSessionID(s.uuidFn())
	session := &domain.FacilitatorSession{
		ID:        sessionID,
		TrackID:   trackID,
		TokenHash: sessionTokenHash,
		CreatedAt: now,
		RevokedAt: domain.None[time.Time](),
	}

	// 6. DB 트랜잭션 내에서 기기 상태 및 세션 정보 저장
	err = s.tx.RunInTx(ctx, func(ctx context.Context) error {
		if err := s.devices.Save(ctx, device); err != nil {
			return err
		}
		return s.sessions.Save(ctx, session)
	})

	if err != nil {
		s.recordAuditLog(ctx, "anonymous", "FACILITATOR_LOGIN", string(trackID), false, map[string]any{"error": err.Error()})
		return "", nil, err
	}

	s.recordAuditLog(ctx, string(trackID), "FACILITATOR_LOGIN", string(session.ID), true, nil)
	return plainToken, session, nil
}

// ValidateSession - UC-10
func (s *FacilitatorAuthService) ValidateSession(
	ctx context.Context,
	plainToken string,
) (*domain.FacilitatorSession, error) {
	tokenHash := hashSHA256(plainToken)

	session, err := s.sessions.GetByTokenHash(ctx, tokenHash)
	if err != nil {
		return nil, err
	}
	if session == nil || !session.IsActive() {
		return nil, domain.ErrSessionRevoked
	}

	return session, nil
}

func (s *FacilitatorAuthService) recordAuditLog(ctx context.Context, actor, action, target string, success bool, metadata map[string]any) {
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
