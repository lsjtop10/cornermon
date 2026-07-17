package domain

type BadgeStatus string

const (
	BadgeUnassigned BadgeStatus = "UNASSIGNED"
	BadgeAssigned   BadgeStatus = "ASSIGNED"
)

type Badge struct {
	id              BadgeID
	shortID         string
	qrPayload       string
	status          BadgeStatus
	assignedGroupID Optional[GroupID] // 미배정(UNASSIGNED)이면 None
}

// AssignTo는 배지를 조에 할당합니다.
func (b *Badge) AssignTo(groupID GroupID) error {
	if b.status == BadgeAssigned {
		return ErrBadgeAlreadyAssigned
	}
	b.status = BadgeAssigned
	b.assignedGroupID = Some(groupID)
	return nil
}

// Release는 배지의 조 할당을 해제하여 재사용 가능하게 만듭니다.
func (b *Badge) Release() error {
	if b.status == BadgeUnassigned {
		return ErrBadgeNotAssigned
	}
	b.status = BadgeUnassigned
	b.assignedGroupID = None[GroupID]()
	return nil
}

func (b *Badge) ID() BadgeID {
	return b.id
}

func (b *Badge) ShortID() string {
	return b.shortID
}

func (b *Badge) QRPayload() string {
	return b.qrPayload
}

func (b *Badge) Status() BadgeStatus {
	return b.status
}

func (b *Badge) AssignedGroupID() Optional[GroupID] {
	return b.assignedGroupID
}

func (b *Badge) SetAssignedGroupID(g Optional[GroupID]) {
	b.assignedGroupID = g
}

type BadgeProps struct {
	ID BadgeID
	ShortID string
	QRPayload string
	Status BadgeStatus
	AssignedGroupID Optional[GroupID]
}
func NewBadgeFromProps(p BadgeProps) *Badge {
	return &Badge{
		id: p.ID,
		shortID: p.ShortID,
		qrPayload: p.QRPayload,
		status: p.Status,
		assignedGroupID: p.AssignedGroupID,
	}
}
func NewBadgeValFromProps(p BadgeProps) Badge {
	return Badge{
		id: p.ID,
		shortID: p.ShortID,
		qrPayload: p.QRPayload,
		status: p.Status,
		assignedGroupID: p.AssignedGroupID,
	}
}
