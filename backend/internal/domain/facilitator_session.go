package domain

import (
	"time"
)

type FacilitatorSession struct {
	ID        FacilitatorSessionID
	TrackID   TrackID
	TokenHash string
	CreatedAt time.Time
	RevokedAt Optional[time.Time]
}

// Revoke는 세션을 즉시 무효화 처리합니다.
func (s *FacilitatorSession) Revoke(now time.Time) error {
	if s.RevokedAt.IsSet() {
		return ErrSessionRevoked
	}
	s.RevokedAt = Some(now)
	return nil
}

// IsActive는 세션이 여전히 유효(활성)한 상태인지 확인합니다.
func (s *FacilitatorSession) IsActive() bool {
	return !s.RevokedAt.IsSet()
}
