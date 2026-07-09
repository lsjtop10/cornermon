package domain

import (
	"time"
)

type CampStatus string

const (
	CampPending CampStatus = "PENDING"
	CampActive  CampStatus = "ACTIVE"
	CampEnded   CampStatus = "ENDED"
)

type Camp struct {
	ID                   CampID
	Name                 string
	StartAt              time.Time
	EndAt                time.Time
	ActivatedAt          Optional[time.Time]
	EndedAt              Optional[time.Time]
	Status               CampStatus
	BottleneckMinSamples int // 기본값 3
	BottleneckRatioPct   int // 기본값 20
}

// Activate는 캠프 상태를 PENDING에서 ACTIVE로 변경합니다.
func (c *Camp) Activate(now time.Time) error {
	if c.Status != CampPending {
		return ErrCampInvalidTransition
	}
	c.Status = CampActive
	c.ActivatedAt = Some(now)
	return nil
}

// End는 캠프 상태를 ACTIVE에서 ENDED로 변경하고, CampEndedEvent를 반환합니다.
func (c *Camp) End(now time.Time) (CampEndedEvent, error) {
	if c.Status != CampActive {
		return CampEndedEvent{}, ErrCampInvalidTransition
	}
	c.Status = CampEnded
	c.EndedAt = Some(now)

	return CampEndedEvent{
		CampID:     c.ID,
		OccurredAt: now,
	}, nil
}

// IsActive는 캠프가 활성화 상태인지 확인합니다.
func (c *Camp) IsActive() bool {
	return c.Status == CampActive
}
