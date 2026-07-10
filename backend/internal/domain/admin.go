package domain

import (
	"time"
)

type Admin struct {
	ID           AdminID
	Username     string
	PasswordHash string
}

type AdminSession struct {
	ID               AdminSessionID
	AdminID          AdminID
	AccessTokenHash  string
	RefreshTokenHash string
	DeviceInfo       string
	CreatedAt        time.Time
	LastUsedAt       time.Time
	RevokedAt        Optional[time.Time]
}

// TouchRefresh는 세션의 마지막 사용 시각을 갱신하여 슬라이딩 만료 처리를 수행합니다.
func (s *AdminSession) TouchRefresh(now time.Time) {
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

// IsRefreshExpired는 리프레시 세션이 비활성 만료 시간(idleTTL) 또는 취소 여부에 의해 만료되었는지 확인합니다.
func (s *AdminSession) IsRefreshExpired(now time.Time, idleTTL time.Duration) bool {
	if s.RevokedAt.IsSet() {
		return true
	}
	return now.After(s.LastUsedAt.Add(idleTTL))
}
