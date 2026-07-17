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
	id                   CampID
	registrationCode     string
	name                 string
	startAt              time.Time
	endAt                time.Time
	activatedAt          Optional[time.Time]
	endedAt              Optional[time.Time]
	status               CampStatus
	bottleneckMinSamples int // 기본값 3
	bottleneckRatioPct   int // 기본값 20
}

// NewCamp는 필수 설정값을 검증한 뒤 PENDING 상태의 새 캠프를 생성합니다.
func NewCamp(id CampID, name string, startAt, endAt time.Time) (*Camp, error) {
	name = strings.TrimSpace(name)
	if name == "" || startAt.IsZero() || endAt.IsZero() || !startAt.Before(endAt) {
		return nil, ErrCampInvalidSettings
	}
	return &Camp{
		id:                   id,
		registrationCode:     GenerateRegistrationCode(id),
		name:                 name,
		startAt:              startAt,
		endAt:                endAt,
		status:               CampPending,
		bottleneckMinSamples: 3,
		bottleneckRatioPct:   20,
	}, nil
}

type CampSettingsPatch struct {
	name                 Optional[string]
	startAt              Optional[time.Time]
	endAt                Optional[time.Time]
	bottleneckMinSamples Optional[int]
	bottleneckRatioPct   Optional[int]
}

func (c *Camp) UpdateSettings(patch CampSettingsPatch) error {
	if c.status == CampEnded {
		return ErrCampSettingsLocked
	}

	name := c.name
	startAt := c.startAt
	endAt := c.endAt
	minSamples := c.bottleneckMinSamples
	ratioPct := c.bottleneckRatioPct

	if value, ok := patch.name.Value(); ok {
		name = strings.TrimSpace(value)
	}
	if value, ok := patch.startAt.Value(); ok {
		startAt = value
	}
	if value, ok := patch.endAt.Value(); ok {
		endAt = value
	}
	if value, ok := patch.bottleneckMinSamples.Value(); ok {
		minSamples = value
	}
	if value, ok := patch.bottleneckRatioPct.Value(); ok {
		ratioPct = value
	}

	if name == "" || minSamples < 1 || ratioPct < 0 || ratioPct > 100 {
		return ErrCampInvalidSettings
	}
	if !startAt.IsZero() && !endAt.IsZero() && !startAt.Before(endAt) {
		return ErrCampInvalidSettings
	}

	c.name = name
	c.startAt = startAt
	c.endAt = endAt
	c.bottleneckMinSamples = minSamples
	c.bottleneckRatioPct = ratioPct
	return nil
}

// Activate는 캠프 상태를 PENDING에서 ACTIVE로 변경합니다.
func (c *Camp) Activate(now time.Time) error {
	if c.status != CampPending {
		return ErrCampInvalidTransition
	}
	c.status = CampActive
	c.activatedAt = Some(now)
	return nil
}

// End는 캠프 상태를 ACTIVE에서 ENDED로 변경하고, CampEndedEvent를 반환합니다.
func (c *Camp) End(now time.Time) (CampEndedEvent, error) {
	if c.status != CampActive {
		return CampEndedEvent{}, ErrCampInvalidTransition
	}
	c.status = CampEnded
	c.endedAt = Some(now)

	return CampEndedEvent{
		campID:     c.id,
		occurredAt: now,
	}, nil
}

// IsActive는 캠프가 활성화 상태인지 확인합니다.
func (c *Camp) IsActive() bool {
	return c.status == CampActive
}

func (c *Camp) ID() CampID {
	return c.id
}

func (c *Camp) RegistrationCode() string {
	return c.registrationCode
}

func (c *Camp) Name() string {
	return c.name
}

func (c *Camp) StartAt() time.Time {
	return c.startAt
}

func (c *Camp) EndAt() time.Time {
	return c.endAt
}

func (c *Camp) ActivatedAt() Optional[time.Time] {
	return c.activatedAt
}

func (c *Camp) EndedAt() Optional[time.Time] {
	return c.endedAt
}

func (c *Camp) SetActivatedAt(t Optional[time.Time]) {
	c.activatedAt = t
}

func (c *Camp) SetEndedAt(t Optional[time.Time]) {
	c.endedAt = t
}

func (c *Camp) Status() CampStatus {
	return c.status
}

func (c *Camp) BottleneckMinSamples() int {
	return c.bottleneckMinSamples
}

func (c *Camp) BottleneckRatioPct() int {
	return c.bottleneckRatioPct
}

type CampProps struct {
	ID CampID
	RegistrationCode string
	Name string
	StartAt time.Time
	EndAt time.Time
	ActivatedAt Optional[time.Time]
	EndedAt Optional[time.Time]
	Status CampStatus
	BottleneckMinSamples int
	BottleneckRatioPct int
}
func NewCampFromProps(p CampProps) *Camp {
	return &Camp{
		id: p.ID,
		registrationCode: p.RegistrationCode,
		name: p.Name,
		startAt: p.StartAt,
		endAt: p.EndAt,
		activatedAt: p.ActivatedAt,
		endedAt: p.EndedAt,
		status: p.Status,
		bottleneckMinSamples: p.BottleneckMinSamples,
		bottleneckRatioPct: p.BottleneckRatioPct,
	}
}
func NewCampValFromProps(p CampProps) Camp {
	return Camp{
		id: p.ID,
		registrationCode: p.RegistrationCode,
		name: p.Name,
		startAt: p.StartAt,
		endAt: p.EndAt,
		activatedAt: p.ActivatedAt,
		endedAt: p.EndedAt,
		status: p.Status,
		bottleneckMinSamples: p.BottleneckMinSamples,
		bottleneckRatioPct: p.BottleneckRatioPct,
	}
}

func (c *CampSettingsPatch) Name() Optional[string] {
	return c.name
}
func (c *CampSettingsPatch) SetName(name Optional[string]) {
	c.name = name
}

func (c *CampSettingsPatch) StartAt() Optional[time.Time] {
	return c.startAt
}
func (c *CampSettingsPatch) SetStartAt(t Optional[time.Time]) {
	c.startAt = t
}

func (c *CampSettingsPatch) EndAt() Optional[time.Time] {
	return c.endAt
}
func (c *CampSettingsPatch) SetEndAt(t Optional[time.Time]) {
	c.endAt = t
}

func (c *CampSettingsPatch) BottleneckMinSamples() Optional[int] {
	return c.bottleneckMinSamples
}
func (c *CampSettingsPatch) SetBottleneckMinSamples(n Optional[int]) {
	c.bottleneckMinSamples = n
}

func (c *CampSettingsPatch) BottleneckRatioPct() Optional[int] {
	return c.bottleneckRatioPct
}
func (c *CampSettingsPatch) SetBottleneckRatioPct(n Optional[int]) {
	c.bottleneckRatioPct = n
}

type CampSettingsPatchProps struct {
	Name Optional[string]
	StartAt Optional[time.Time]
	EndAt Optional[time.Time]
	BottleneckMinSamples Optional[int]
	BottleneckRatioPct Optional[int]
}
func NewCampSettingsPatchFromProps(p CampSettingsPatchProps) *CampSettingsPatch {
	return &CampSettingsPatch{
		name: p.Name,
		startAt: p.StartAt,
		endAt: p.EndAt,
		bottleneckMinSamples: p.BottleneckMinSamples,
		bottleneckRatioPct: p.BottleneckRatioPct,
	}
}
func NewCampSettingsPatchValFromProps(p CampSettingsPatchProps) CampSettingsPatch {
	return CampSettingsPatch{
		name: p.Name,
		startAt: p.StartAt,
		endAt: p.EndAt,
		bottleneckMinSamples: p.BottleneckMinSamples,
		bottleneckRatioPct: p.BottleneckRatioPct,
	}
}
