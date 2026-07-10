# Phase C: 인증·세션 서비스

> 파일:
> - `backend/internal/usecase/auth_facilitator.go` (신규)
> - `backend/internal/usecase/auth_admin.go` (신규)
> - `backend/internal/usecase/device_trust.go` (신규)

---

## 유스케이스 목록

| 우선순위 | 유스케이스 | 설명 | 용도 |
|---|---|---|---|
| **P0** | UC-8: 기기 등록 요청 | 미등록 기기가 등록 코드로 PENDING 요청 생성 | 프로덕션 핵심 |
| **P0** | UC-9: 진행자 PIN 로그인 | 신뢰 기기 + PIN → FacilitatorSession 발급 | 프로덕션 핵심 |
| **P0** | UC-10: 진행자 세션 검증 | 요청마다 토큰 해시 조회 → 활성 여부 확인 | 프로덕션 핵심 |
| **P0** | UC-11: 관리자 로그인 | ID/비밀번호 → 액세스+리프레시 토큰 발급 | 프로덕션 핵심 |
| **P0** | UC-12: 관리자 액세스 토큰 갱신 | 리프레시 토큰 → 신규 액세스 토큰 | 프로덕션 핵심 |
| **P0** | UC-13: 관리자 토큰 검증 | 액세스 토큰 해시 → AdminID + 만료 여부 | 프로덕션 핵심 |
| **P1** | UC-14: 기기 승인/거부 | 관리자가 PENDING 기기를 APPROVED/REJECTED | 운영 |
| **P1** | UC-15: 기기 신뢰 회수 | 관리자가 APPROVED 기기를 REVOKED | 보안 대응 |
| **P1** | UC-16: PIN 실패 잠금 해제 | 관리자가 특정 기기 PIN 실패 카운터 리셋 | 운영 보조 |
| **P1** | UC-17: 관리자 세션 회수 | 관리자가 자신/상대방 세션 강제 만료 | 보안 대응 |

---

## C-1. FacilitatorAuthService

```go
// usecase/auth_facilitator.go

type FacilitatorAuthService struct {
    camps     CampRepository
    tracks    TrackRepository
    devices   DeviceRegistrationRepository
    sessions  FacilitatorSessionRepository
    auditLogs AuditLogRepository
    tx        TxManager
    // 토큰 발급: crypto/rand → hex(plain) + SHA-256(hash) — 헬퍼 함수
    // PIN 검증: bcrypt.CompareHashAndPassword 직접 호출
}

// Login — UC-9
// 흐름:
//   1. deviceToken 해시 조회 → DeviceRegistration 상태 확인
//      - NOT APPROVED → ErrDeviceNotApproved
//      - IsLocked(now) == true → ErrDeviceLocked
//   2. trackID에 해당하는 Track 조회 → ACTIVE 확인
//   3. 캠프 ACTIVE 확인 (진행자 로그인은 ACTIVE 캠프에서만 가능, §domain-model.md 2.0)
//   4. PIN 해시 검증: bcrypt.CompareHashAndPassword(track.PINHash, pin)
//      - 실패 → DeviceRegistration.RecordPinFailure(now) → 저장 → 감사 로그 → 에러 반환
//      - 성공 → DeviceRegistration.ResetPinFailures() → 저장
//   5. 신규 FacilitatorSession 생성 (crypto/rand 토큰 발급, uuid로 ID 생성)
//   6. tx.RunInTx: DeviceRegistration 저장 + FacilitatorSession 저장
//   7. 감사 로그(action="FACILITATOR_LOGIN") → 평문 토큰 반환
// 반환: (plainToken string, session *domain.FacilitatorSession, err error)
func (s *FacilitatorAuthService) Login(
    ctx context.Context,
    campID domain.CampID,
    trackID domain.TrackID,
    deviceToken string,
    pin string,
) (string, *domain.FacilitatorSession, error)

// ValidateSession — UC-10
// 흐름: 토큰 해시 조회 → FacilitatorSession.IsActive() 확인
// HTTP 핸들러 미들웨어에서 매 요청마다 호출
// 반환: (*domain.FacilitatorSession, error) — 세션에서 TrackID를 꺼내 권한 범위 확인
func (s *FacilitatorAuthService) ValidateSession(
    ctx context.Context,
    plainToken string,
) (*domain.FacilitatorSession, error)
```

---

## C-2. AdminAuthService

```go
// usecase/auth_admin.go

// AdminAccessTokenTTL — 액세스 토큰 유효 기간 (§technical-design.md 2.2-b)
const AdminAccessTokenTTL = 30 * time.Minute

// AdminRefreshTokenIdleTTL — 리프레시 슬라이딩 만료 기간
const AdminRefreshTokenIdleTTL = 12 * time.Hour

type AdminAuthService struct {
    admins    AdminRepository
    sessions  AdminSessionRepository
    auditLogs AuditLogRepository
    tx        TxManager
    // 비밀번호 검증: bcrypt.CompareHashAndPassword 직접 호출
    // 토큰 발급: crypto/rand → hex(plain) + SHA-256(hash) — 헬퍼 함수
}

// Login — UC-11
// 흐름: username으로 Admin 조회 → PasswordHasher.Verify → 액세스+리프레시 토큰 발급 →
//        AdminSession 생성 → 트랜잭션(저장) → 감사 로그
// 반환: (accessToken string, refreshToken string, session *domain.AdminSession, err error)
func (s *AdminAuthService) Login(
    ctx context.Context,
    username string,
    password string,
    deviceInfo string,
) (string, string, *domain.AdminSession, error)

// RefreshToken — UC-12
// 흐름: refreshToken 해시 조회 → AdminSession.IsRefreshExpired 확인 →
//        신규 액세스 토큰 발급 → AdminSession.TouchRefresh(now) →
//        트랜잭션(기존 세션에 새 accessTokenHash 갱신 + LastUsedAt 갱신 + 저장)
// 반환: (newAccessToken string, err error)
func (s *AdminAuthService) RefreshToken(
    ctx context.Context,
    refreshToken string,
) (string, error)

// ValidateAccessToken — UC-13
// 흐름: accessToken 해시 조회 → RevokedAt 체크 → LastUsedAt + TTL로 만료 체크
// HTTP 미들웨어에서 호출. 만료 시 클라이언트가 RefreshToken 호출로 재발급
// 반환: (*domain.AdminSession, error)
func (s *AdminAuthService) ValidateAccessToken(
    ctx context.Context,
    accessToken string,
) (*domain.AdminSession, error)

// RevokeSession — UC-17
// 흐름: sessionID로 AdminSession 조회 → AdminSession.Revoke(now) →
//        트랜잭션(저장) → 감사 로그
// 관리자 2명은 서로의 세션도 회수 가능 (§domain-model.md 2.5-b)
func (s *AdminAuthService) RevokeSession(
    ctx context.Context,
    sessionID domain.AdminSessionID,
    actorAdminID domain.AdminID,
) error
```

---

## C-3. DeviceTrustService

```go
// usecase/device_trust.go

type DeviceTrustService struct {
    camps     CampRepository
    devices   DeviceRegistrationRepository
    auditLogs AuditLogRepository
    tx        TxManager
    // 토큰 발급: crypto/rand → hex(plain) + SHA-256(hash) — 헬퍼 함수
}

// RequestRegistration — UC-8
// 흐름: 캠프 ACTIVE 확인 → crypto/rand 토큰 발급 → DeviceRegistration(PENDING) 생성 →
//        postgres.RunInTx(저장) → 감사 로그
// 반환: (plainToken string, reg *domain.DeviceRegistration, err error)
// plainToken은 기기가 보관하는 신뢰 토큰. 이후 PIN 로그인 시 제시
func (s *DeviceTrustService) RequestRegistration(
    ctx context.Context,
    campID domain.CampID,
    deviceName string,
) (string, *domain.DeviceRegistration, error)

// ApproveDevice — UC-14 (승인)
// 흐름: DeviceRegistration 조회 → DeviceRegistration.Approve(now) →
//        트랜잭션(저장) → 감사 로그(action="DEVICE_APPROVED")
func (s *DeviceTrustService) ApproveDevice(
    ctx context.Context,
    regID domain.DeviceRegistrationID,
    actorAdminID domain.AdminID,
) error

// RejectDevice — UC-14 (거부)
// 흐름: DeviceRegistration.Reject → 저장 → 감사 로그(action="DEVICE_REJECTED")
func (s *DeviceTrustService) RejectDevice(
    ctx context.Context,
    regID domain.DeviceRegistrationID,
    actorAdminID domain.AdminID,
) error

// RevokeDevice — UC-15
// 흐름: DeviceRegistration.Revoke → 저장 → 감사 로그(action="DEVICE_REVOKED")
// 다음 PIN 로그인 시도 또는 ValidateSession에서 ErrDeviceNotApproved 반환
func (s *DeviceTrustService) RevokeDevice(
    ctx context.Context,
    regID domain.DeviceRegistrationID,
    actorAdminID domain.AdminID,
) error

// ResetPinFailures — UC-16
// 흐름: DeviceRegistration.ResetPinFailures → 저장 → 감사 로그(action="PIN_LOCK_RESET")
func (s *DeviceTrustService) ResetPinFailures(
    ctx context.Context,
    regID domain.DeviceRegistrationID,
    actorAdminID domain.AdminID,
) error

// ListPending — 관리자 대시보드 기기 승인 목록 조회
func (s *DeviceTrustService) ListPending(
    ctx context.Context,
    campID domain.CampID,
) ([]*domain.DeviceRegistration, error)
```

---

## C-4. 검증 체크리스트

### 아키텍처
- [ ] `domain` 패키지 외 infrastructure import 없음 (bcrypt, crypto/rand은 표준/준표준 라이브러리라 허용)
- [ ] 모든 다중 엔티티 쓰기는 `postgres.RunInTx` 안에서 처리

### UC-9 (PIN 로그인)
- [ ] 미등록 기기(deviceToken 해시 미존재) → 401 반환
- [ ] PENDING/REJECTED/REVOKED 기기 → `ErrDeviceNotApproved` → 403 반환
- [ ] 잠금 상태(IsLocked) 기기 → `ErrDeviceLocked` → 429 반환
- [ ] PIN 틀림 → RecordPinFailure 후 감사 로그(success=false) → 401 반환
- [ ] 5회 이상 실패 → needsAdminAlert=true → (Phase D 브로드캐스트 또는 별도 알림 채널로 관리자에게 전달)
- [ ] PIN 성공 → 직전 실패 횟수 ResetPinFailures + 감사 로그(success=true)
- [ ] ENDED 캠프에서 로그인 시도 → 캠프 상태 체크에서 거부

### UC-12 (RefreshToken)
- [ ] 만료된 리프레시 토큰 → 401 (재로그인 필요)
- [ ] Revoke된 세션의 리프레시 토큰 사용 → 401
- [ ] 슬라이딩 만료: 성공 시 LastUsedAt 갱신

### UC-13 (ValidateAccessToken)
- [ ] Revoke된 세션 → 401 즉시
- [ ] LastUsedAt + TTL 초과 → 401 (클라이언트가 RefreshToken 재시도)
- [ ] 유효 토큰 → AdminSession 반환 (AdminID 포함)

### 감사 로그 공통
- [ ] 모든 인증 시도(성공/실패)는 감사 로그 적재 — `success` 필드로 구분
- [ ] `actor`는 가능한 경우 AdminID 또는 TrackID로, 미인증 요청은 "anonymous"
