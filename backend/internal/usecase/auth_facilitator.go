package usecase

import (
	"context"
	"errors"
	"time"

	"cornermon/backend/internal/domain"

	"github.com/google/uuid"
)

type TrackLoginResult struct {
	TrackToken string
	Track      *domain.Track
	Corner     *domain.Corner
}

type FacilitatorAuthService struct {
	camps       CampRepository
	corners     CornerRepository
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
	corners CornerRepository,
	tracks TrackRepository,
	devices DeviceRegistrationRepository,
	sessions FacilitatorSessionRepository,
	auditLogs AuditLogRepository,
	broadcaster Broadcaster,
	tx TxManager,
) *FacilitatorAuthService {
	return &FacilitatorAuthService{
		camps:       camps,
		corners:     corners,
		tracks:      tracks,
		devices:     devices,
		sessions:    sessions,
		auditLogs:   auditLogs,
		broadcaster: broadcaster,
		tx:          tx,
		nowFn:       func() time.Time { return time.Now().UTC() },
		uuidFn:      uuid.NewString,
	}
}

// Login - UC-9
func (s *FacilitatorAuthService) Login(
	ctx context.Context,
	deviceToken string,
	pin string,
) (*TrackLoginResult, error) {
	now := s.nowFn()
	deviceTokenHash := hashSHA256(deviceToken)

	// 1. 기기 정보 조회 및 검증
	device, err := s.devices.GetByTokenHash(ctx, deviceTokenHash)
	if err != nil {
		return nil, err
	}
	if device == nil || device.Status != domain.DeviceApproved {
		s.recordAuditLog(ctx, "anonymous", "FACILITATOR_LOGIN", "", false, map[string]any{"error": domain.ErrDeviceNotApproved.Error()})
		return nil, domain.ErrDeviceNotApproved
	}

	if device.IsLocked(now) {
		s.recordAuditLog(ctx, "anonymous", "FACILITATOR_LOGIN", "", false, map[string]any{"error": domain.ErrDeviceLocked.Error()})
		lockedUntil, _ := device.LockedUntil.Value()
		return nil, &domain.DeviceLockedError{LockedUntil: lockedUntil}
	}

	campID := device.CampID

	// 2. 캠프 정보 조회 및 검증
	camp, err := s.camps.Get(ctx, campID)
	if err != nil {
		return nil, err
	}
	if camp == nil || !camp.IsActive() {
		s.recordAuditLog(ctx, "anonymous", "FACILITATOR_LOGIN", "", false, map[string]any{"error": domain.ErrCampInvalidTransition.Error()})
		return nil, domain.ErrCampInvalidTransition
	}

	// 3. 트랙 찾기 및 PIN 검증
	activeTracks, err := s.tracks.ListActiveByCamp(ctx, campID)
	if err != nil {
		return nil, err
	}

	var track *domain.Track
	for _, t := range activeTracks {
		if err := verifyPassword(t.PINHash, pin); err == nil {
			track = t
			break
		}
	}

	if track == nil {
		// PIN 검증 실패 시
		delay, needsAdminAlert := device.RecordPinFailure(now)
		_ = s.devices.Save(ctx, device)

		if needsAdminAlert {
			_ = s.broadcaster.Broadcast(ctx, device.CampID, EventLockoutAlert, "device:"+string(device.ID))
		}

		s.recordAuditLog(ctx, "anonymous", "FACILITATOR_LOGIN", "", false, map[string]any{"error": "invalid pin", "device_failures": device.FailedPinAttempts})

		var optLocked domain.Optional[time.Time]
		if delay > 0 {
			lockedUntil, _ := device.LockedUntil.Value()
			optLocked = domain.Some(lockedUntil)
		} else {
			optLocked = domain.None[time.Time]()
		}
		return nil, &domain.InvalidPinError{LockedUntil: optLocked}
	}

	trackID := track.ID

	// 4. 코너 정보 조회
	corner, err := s.corners.Get(ctx, track.CornerID)
	if err != nil {
		return nil, err
	}
	if corner == nil {
		return nil, domain.ErrCornerNotInItinerary
	}

	// PIN 검증 성공 시 실패 횟수 리셋
	device.ResetPinFailures()

	// 5. 신규 세션 토큰 및 세션 정보 생성
	plainToken, sessionTokenHash, err := generateOpaqueToken()
	if err != nil {
		return nil, err
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
		return nil, err
	}

	s.recordAuditLog(ctx, string(trackID), "FACILITATOR_LOGIN", string(session.ID), true, nil)
	return &TrackLoginResult{
		TrackToken: plainToken,
		Track:      track,
		Corner:     corner,
	}, nil
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

func (s *FacilitatorAuthService) Logout(
	ctx context.Context,
	sessionID domain.FacilitatorSessionID,
) error {
	now := s.nowFn()

	session, err := s.sessions.Get(ctx, sessionID)
	if err != nil {
		return err
	}
	if session == nil {
		return errors.New("session not found")
	}

	if err := session.Revoke(now); err != nil {
		return err
	}

	err = s.tx.RunInTx(ctx, func(ctx context.Context) error {
		return s.sessions.Save(ctx, session)
	})

	if err != nil {
		s.recordAuditLog(ctx, string(session.TrackID), "FACILITATOR_LOGOUT", string(sessionID), false, map[string]any{"error": err.Error()})
		return err
	}

	s.recordAuditLog(ctx, string(session.TrackID), "FACILITATOR_LOGOUT", string(sessionID), true, nil)
	return nil
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
