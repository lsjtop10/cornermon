package domain

import (
	"time"
)

type AdminRole string

const (
	AdminRoleSystemAdmin    AdminRole = "SYSTEM_ADMIN"
	AdminRoleCornerOperator AdminRole = "CORNER_OPERATOR"
)

type Admin struct {
	id           AdminID
	username     string
	passwordHash string
	role         AdminRole
}

func (a *Admin) IsSystemAdmin() bool { return a.role == AdminRoleSystemAdmin }

func (a *Admin) IsCornerOperator() bool { return a.role == AdminRoleCornerOperator }

type AdminSession struct {
	id              AdminSessionID
	adminID         AdminID
	accessTokenHash string
	deviceInfo      string
	createdAt       time.Time
	lastUsedAt      time.Time
	revokedAt       Optional[time.Time]
}

// TouchActivity는 세션의 마지막 사용 시각을 갱신하여 슬라이딩 만료 처리를 수행합니다.
func (s *AdminSession) TouchActivity(now time.Time) {
	s.lastUsedAt = now
}

// Revoke는 관리자 세션을 즉시 무효화 처리합니다.
func (s *AdminSession) Revoke(now time.Time) error {
	if s.revokedAt.IsSet() {
		return ErrSessionRevoked
	}
	s.revokedAt = Some(now)
	return nil
}

// IsExpired는 세션이 비활성 만료 시간(idleTTL) 또는 취소 여부에 의해 만료되었는지 확인합니다.
func (s *AdminSession) IsExpired(now time.Time, idleTTL time.Duration) bool {
	if s.revokedAt.IsSet() {
		return true
	}
	return now.After(s.lastUsedAt.Add(idleTTL))
}

func (a *Admin) ID() AdminID {
	return a.id
}

func (a *Admin) Username() string {
	return a.username
}

func (a *Admin) PasswordHash() string {
	return a.passwordHash
}

func (a *Admin) Role() AdminRole {
	return a.role
}

type AdminProps struct {
	ID           AdminID
	Username     string
	PasswordHash string
	Role         AdminRole
}

func NewAdminFromProps(p AdminProps) *Admin {
	return &Admin{
		id:           p.ID,
		username:     p.Username,
		passwordHash: p.PasswordHash,
		role:         p.Role,
	}
}
func NewAdminValFromProps(p AdminProps) Admin {
	return Admin{
		id:           p.ID,
		username:     p.Username,
		passwordHash: p.PasswordHash,
		role:         p.Role,
	}
}

func (a *AdminSession) ID() AdminSessionID {
	return a.id
}

func (a *AdminSession) AdminID() AdminID {
	return a.adminID
}

func (a *AdminSession) AccessTokenHash() string {
	return a.accessTokenHash
}

func (a *AdminSession) DeviceInfo() string {
	return a.deviceInfo
}

func (a *AdminSession) CreatedAt() time.Time {
	return a.createdAt
}

func (a *AdminSession) LastUsedAt() time.Time {
	return a.lastUsedAt
}

func (a *AdminSession) RevokedAt() Optional[time.Time] {
	return a.revokedAt
}

type AdminSessionProps struct {
	ID              AdminSessionID
	AdminID         AdminID
	AccessTokenHash string
	DeviceInfo      string
	CreatedAt       time.Time
	LastUsedAt      time.Time
	RevokedAt       Optional[time.Time]
}

func NewAdminSessionFromProps(p AdminSessionProps) *AdminSession {
	return &AdminSession{
		id:              p.ID,
		adminID:         p.AdminID,
		accessTokenHash: p.AccessTokenHash,
		deviceInfo:      p.DeviceInfo,
		createdAt:       p.CreatedAt,
		lastUsedAt:      p.LastUsedAt,
		revokedAt:       p.RevokedAt,
	}
}
func NewAdminSessionValFromProps(p AdminSessionProps) AdminSession {
	return AdminSession{
		id:              p.ID,
		adminID:         p.AdminID,
		accessTokenHash: p.AccessTokenHash,
		deviceInfo:      p.DeviceInfo,
		createdAt:       p.CreatedAt,
		lastUsedAt:      p.LastUsedAt,
		revokedAt:       p.RevokedAt,
	}
}

func (a *Admin) SetPasswordHash(hash string) {
	a.passwordHash = hash
}
