package domain

type BadgeStatus string

const (
	BadgeUnassigned BadgeStatus = "UNASSIGNED"
	BadgeAssigned   BadgeStatus = "ASSIGNED"
)

type Badge struct {
	ID              BadgeID
	ShortID         string
	QRPayload       string
	Status          BadgeStatus
	AssignedGroupID Optional[GroupID] // 미배정(UNASSIGNED)이면 None
}

// AssignTo는 배지를 조에 할당합니다.
func (b *Badge) AssignTo(groupID GroupID) error {
	if b.Status == BadgeAssigned {
		return ErrBadgeAlreadyAssigned
	}
	b.Status = BadgeAssigned
	b.AssignedGroupID = Some(groupID)
	return nil
}

// Release는 배지의 조 할당을 해제하여 재사용 가능하게 만듭니다.
func (b *Badge) Release() error {
	if b.Status == BadgeUnassigned {
		return ErrBadgeNotAssigned
	}
	b.Status = BadgeUnassigned
	b.AssignedGroupID = None[GroupID]()
	return nil
}
