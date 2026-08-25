package domain

type CornerOperationalStatus string

const (
	CornerInactive CornerOperationalStatus = "INACTIVE"
	CornerIdle     CornerOperationalStatus = "IDLE"
	CornerBusy     CornerOperationalStatus = "BUSY"
)

type Corner struct {
	id            CornerID
	campID        CampID
	name          string
	targetMinutes int // 기본값 10
	isMandatory   bool
}

// EffectiveTargetMinutes는 코너의 목표 소요 시간을 반환합니다.
func (c *Corner) EffectiveTargetMinutes(track *Track) int {
	return c.targetMinutes
}

func (c *Corner) ID() CornerID {
	return c.id
}

func (c *Corner) CampID() CampID {
	return c.campID
}

func (c *Corner) Name() string {
	return c.name
}

func (c *Corner) SetName(name string) {
	c.name = name
}

func (c *Corner) SetTargetMinutes(minutes int) {
	c.targetMinutes = minutes
}

func (c *Corner) TargetMinutes() int {
	return c.targetMinutes
}

func (c *Corner) IsMandatory() bool {
	return c.isMandatory
}

type CornerProps struct {
	ID            CornerID
	CampID        CampID
	Name          string
	TargetMinutes int
	IsMandatory   bool
}

func NewCornerFromProps(p CornerProps) *Corner {
	return &Corner{
		id:            p.ID,
		campID:        p.CampID,
		name:          p.Name,
		targetMinutes: p.TargetMinutes,
		isMandatory:   p.IsMandatory,
	}
}
func NewCornerValFromProps(p CornerProps) Corner {
	return Corner{
		id:            p.ID,
		campID:        p.CampID,
		name:          p.Name,
		targetMinutes: p.TargetMinutes,
		isMandatory:   p.IsMandatory,
	}
}
