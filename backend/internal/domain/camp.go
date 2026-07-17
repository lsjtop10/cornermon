package domain

import (
	"strings"
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
	RegistrationCode     string
	Name                 string
	StartAt              time.Time
	EndAt                time.Time
	ActivatedAt          Optional[time.Time]
	EndedAt              Optional[time.Time]
	Status               CampStatus
	BottleneckMinSamples int // 기본값 3
	BottleneckRatioPct   int // 기본값 20
}

// NewCamp는 필수 설정값을 검증한 뒤 PENDING 상태의 새 캠프를 생성합니다.
func NewCamp(id CampID, name string, startAt, endAt time.Time) (*Camp, error) {
	name = strings.TrimSpace(name)
	if name == "" || startAt.IsZero() || endAt.IsZero() || !startAt.Before(endAt) {
		return nil, ErrCampInvalidSettings
	}
	return &Camp{
		ID:                   id,
		RegistrationCode:     GenerateRegistrationCode(id),
		Name:                 name,
		StartAt:              startAt,
		EndAt:                endAt,
		Status:               CampPending,
		BottleneckMinSamples: 3,
		BottleneckRatioPct:   20,
	}, nil
}

type CampSettingsPatch struct {
	Name                 Optional[string]
	StartAt              Optional[time.Time]
	EndAt                Optional[time.Time]
	BottleneckMinSamples Optional[int]
	BottleneckRatioPct   Optional[int]
}

func (c *Camp) UpdateSettings(patch CampSettingsPatch) error {
	if c.Status == CampEnded {
		return ErrCampSettingsLocked
	}

	name := c.Name
	startAt := c.StartAt
	endAt := c.EndAt
	minSamples := c.BottleneckMinSamples
	ratioPct := c.BottleneckRatioPct

	if value, ok := patch.Name.Value(); ok {
		name = strings.TrimSpace(value)
	}
	if value, ok := patch.StartAt.Value(); ok {
		startAt = value
	}
	if value, ok := patch.EndAt.Value(); ok {
		endAt = value
	}
	if value, ok := patch.BottleneckMinSamples.Value(); ok {
		minSamples = value
	}
	if value, ok := patch.BottleneckRatioPct.Value(); ok {
		ratioPct = value
	}

	if name == "" || minSamples < 1 || ratioPct < 0 || ratioPct > 100 {
		return ErrCampInvalidSettings
	}
	if !startAt.IsZero() && !endAt.IsZero() && !startAt.Before(endAt) {
		return ErrCampInvalidSettings
	}

	c.Name = name
	c.StartAt = startAt
	c.EndAt = endAt
	c.BottleneckMinSamples = minSamples
	c.BottleneckRatioPct = ratioPct
	return nil
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
