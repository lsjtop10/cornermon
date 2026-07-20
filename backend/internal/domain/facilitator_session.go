package domain

import (
	"time"
)

type FacilitatorSession struct {
	id                     FacilitatorSessionID
	trackID                TrackID
	tokenHash              string
	createdAt              time.Time
	revokedAt              Optional[time.Time]
	migrationTargetTrackID Optional[TrackID]
}

// SetMigrationTarget은 트랙 교체 시 마이그레이션할 대상 트랙 ID를 기록합니다.
func (s *FacilitatorSession) SetMigrationTarget(newTrackID TrackID) {
	s.migrationTargetTrackID = Some(newTrackID)
}

// Revoke는 세션을 즉시 무효화 처리합니다.
func (s *FacilitatorSession) Revoke(now time.Time) error {
	if s.revokedAt.IsSet() {
		return ErrSessionRevoked
	}
	s.revokedAt = Some(now)
	return nil
}

// IsActive는 세션이 여전히 유효(활성)한 상태인지 확인합니다.
func (s *FacilitatorSession) IsActive() bool {
	return !s.revokedAt.IsSet()
}

func (f *FacilitatorSession) ID() FacilitatorSessionID {
	return f.id
}

func (f *FacilitatorSession) TrackID() TrackID {
	return f.trackID
}

func (f *FacilitatorSession) TokenHash() string {
	return f.tokenHash
}

func (f *FacilitatorSession) CreatedAt() time.Time {
	return f.createdAt
}

func (s *FacilitatorSession) RevokedAt() Optional[time.Time] {
	return s.revokedAt
}
func (s *FacilitatorSession) SetRevokedAt(t Optional[time.Time]) {
	s.revokedAt = t
}

func (f *FacilitatorSession) MigrationTargetTrackID() Optional[TrackID] {
	return f.migrationTargetTrackID
}

type FacilitatorSessionProps struct {
	ID                     FacilitatorSessionID
	TrackID                TrackID
	TokenHash              string
	CreatedAt              time.Time
	RevokedAt              Optional[time.Time]
	MigrationTargetTrackID Optional[TrackID]
}

func NewFacilitatorSessionFromProps(p FacilitatorSessionProps) *FacilitatorSession {
	return &FacilitatorSession{
		id:                     p.ID,
		trackID:                p.TrackID,
		tokenHash:              p.TokenHash,
		createdAt:              p.CreatedAt,
		revokedAt:              p.RevokedAt,
		migrationTargetTrackID: p.MigrationTargetTrackID,
	}
}
func NewFacilitatorSessionValFromProps(p FacilitatorSessionProps) FacilitatorSession {
	return FacilitatorSession{
		id:                     p.ID,
		trackID:                p.TrackID,
		tokenHash:              p.TokenHash,
		createdAt:              p.CreatedAt,
		revokedAt:              p.RevokedAt,
		migrationTargetTrackID: p.MigrationTargetTrackID,
	}
}
