package domain

type GroupStatus string

const (
	GroupIdleMoving GroupStatus = "IDLE_MOVING"
	GroupAtCorner   GroupStatus = "AT_CORNER"
	GroupFinished   GroupStatus = "FINISHED"
)

type VisitStatusPerCorner string

const (
	VisitNotVisited VisitStatusPerCorner = "NOT_VISITED"
	VisitInProgress VisitStatusPerCorner = "IN_PROGRESS"
	VisitCompleted  VisitStatusPerCorner = "COMPLETED"
)

type CornerProgress struct {
	cornerID CornerID
	status   VisitStatusPerCorner
}

type Group struct {
	id        GroupID
	campID    CampID
	name      string
	badgeID   BadgeID
	itinerary []CornerProgress // 10개 코너 순회표, 캠프의 코너 목록으로 초기화
}

// IsFinished는 조가 순회표 상의 모든 코너를 완주했는지 확인합니다.
func (g *Group) IsFinished() bool {
	if len(g.itinerary) == 0 {
		return false
	}
	for _, progress := range g.itinerary {
		if progress.status != VisitCompleted {
			return false
		}
	}
	return true
}

// Status는 조의 현재 진행 상태를 계산합니다.
func (g *Group) Status() GroupStatus {
	if g.IsFinished() {
		return GroupFinished
	}
	for _, progress := range g.itinerary {
		if progress.status == VisitInProgress {
			return GroupAtCorner
		}
	}
	return GroupIdleMoving
}

// MarkVisitStarted는 특정 코너에서의 방문이 시작되었음을 순회표에 기록합니다.
func (g *Group) MarkVisitStarted(cornerID CornerID) error {
	var targetIdx = -1
	for i, progress := range g.itinerary {
		if progress.status == VisitInProgress {
			return ErrGroupBusy
		}
		if progress.cornerID == cornerID {
			targetIdx = i
		}
	}

	if targetIdx == -1 {
		return ErrCornerNotInItinerary
	}

	if g.itinerary[targetIdx].status == VisitCompleted {
		return ErrDuplicateVisit
	}

	g.itinerary[targetIdx].status = VisitInProgress
	return nil
}

// MarkVisitCompleted는 특정 코너에서의 방문이 종료되었음을 순회표에 기록합니다.
func (g *Group) MarkVisitCompleted(cornerID CornerID) error {
	var targetIdx = -1
	for i, progress := range g.itinerary {
		if progress.cornerID == cornerID {
			targetIdx = i
			break
		}
	}

	if targetIdx == -1 {
		return ErrCornerNotInItinerary
	}

	if g.itinerary[targetIdx].status != VisitInProgress {
		return ErrVisitNotInProgress
	}

	g.itinerary[targetIdx].status = VisitCompleted
	return nil
}

func (c *CornerProgress) CornerID() CornerID {
	return c.cornerID
}

func (c *CornerProgress) Status() VisitStatusPerCorner {
	return c.status
}

type CornerProgressProps struct {
	CornerID CornerID
	Status VisitStatusPerCorner
}
func NewCornerProgressFromProps(p CornerProgressProps) *CornerProgress {
	return &CornerProgress{
		cornerID: p.CornerID,
		status: p.Status,
	}
}
func NewCornerProgressValFromProps(p CornerProgressProps) CornerProgress {
	return CornerProgress{
		cornerID: p.CornerID,
		status: p.Status,
	}
}

func (grp *Group) ID() GroupID {
	return grp.id
}

func (grp *Group) CampID() CampID {
	return grp.campID
}

func (grp *Group) Name() string {
	return grp.name
}

func (grp *Group) BadgeID() BadgeID {
	return grp.badgeID
}

func (g *Group) Itinerary() []CornerProgress {
	return g.itinerary
}

func (g *Group) SetItinerary(itinerary []CornerProgress) {
	g.itinerary = itinerary
}

type GroupProps struct {
	ID GroupID
	CampID CampID
	Name string
	BadgeID BadgeID
	Itinerary []CornerProgress
}
func NewGroupFromProps(p GroupProps) *Group {
	return &Group{
		id: p.ID,
		campID: p.CampID,
		name: p.Name,
		badgeID: p.BadgeID,
		itinerary: p.Itinerary,
	}
}
func NewGroupValFromProps(p GroupProps) Group {
	return Group{
		id: p.ID,
		campID: p.CampID,
		name: p.Name,
		badgeID: p.BadgeID,
		itinerary: p.Itinerary,
	}
}

func (g *Group) SetBadgeID(id BadgeID) {
	g.badgeID = id
}
