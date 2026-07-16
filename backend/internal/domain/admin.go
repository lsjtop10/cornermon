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
	ID           AdminID
	Username     string
	PasswordHash string
	Role         AdminRole
}

func (a *Admin) IsSystemAdmin() bool { return a.Role == AdminRoleSystemAdmin }

type AdminSession struct {
	ID              AdminSessionID
	AdminID         AdminID
	AccessTokenHash string
	DeviceInfo      string
	CreatedAt       time.Time
	LastUsedAt      time.Time
	RevokedAt       Optional[time.Time]
}

// TouchActivity는 세션의 마지막 사용 시각을 갱신하여 슬라이딩 만료 처리를 수행합니다.
func (s *AdminSession) TouchActivity(now time.Time) {
	s.LastUsedAt = now
}

// Revoke는 관리자 세션을 즉시 무효화 처리합니다.
func (s *AdminSession) Revoke(now time.Time) error {
	if s.RevokedAt.IsSet() {
		return ErrSessionRevoked
	}
	s.RevokedAt = Some(now)
	return nil
}

// IsExpired는 세션이 비활성 만료 시간(idleTTL) 또는 취소 여부에 의해 만료되었는지 확인합니다.
func (s *AdminSession) IsExpired(now time.Time, idleTTL time.Duration) bool {
	if s.RevokedAt.IsSet() {
		return true
	}
	return now.After(s.LastUsedAt.Add(idleTTL))
}
