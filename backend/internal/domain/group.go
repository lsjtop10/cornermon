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
	CornerID CornerID
	Status   VisitStatusPerCorner
}

type Group struct {
	ID        GroupID
	CampID    CampID
	Name      string
	BadgeID   BadgeID
	Itinerary []CornerProgress // 10개 코너 순회표, 캠프의 코너 목록으로 초기화
}

// IsFinished는 조가 순회표 상의 모든 코너를 완주했는지 확인합니다.
func (g *Group) IsFinished() bool {
	if len(g.Itinerary) == 0 {
		return false
	}
	for _, progress := range g.Itinerary {
		if progress.Status != VisitCompleted {
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
	for _, progress := range g.Itinerary {
		if progress.Status == VisitInProgress {
			return GroupAtCorner
		}
	}
	return GroupIdleMoving
}

// MarkVisitStarted는 특정 코너에서의 방문이 시작되었음을 순회표에 기록합니다.
func (g *Group) MarkVisitStarted(cornerID CornerID) error {
	var targetIdx = -1
	for i, progress := range g.Itinerary {
		if progress.Status == VisitInProgress {
			return ErrGroupBusy
		}
		if progress.CornerID == cornerID {
			targetIdx = i
		}
	}

	if targetIdx == -1 {
		return ErrCornerNotInItinerary
	}

	if g.Itinerary[targetIdx].Status == VisitCompleted {
		return ErrDuplicateVisit
	}

	g.Itinerary[targetIdx].Status = VisitInProgress
	return nil
}

// MarkVisitCompleted는 특정 코너에서의 방문이 종료되었음을 순회표에 기록합니다.
func (g *Group) MarkVisitCompleted(cornerID CornerID) error {
	var targetIdx = -1
	for i, progress := range g.Itinerary {
		if progress.CornerID == cornerID {
			targetIdx = i
			break
		}
	}

	if targetIdx == -1 {
		return ErrCornerNotInItinerary
	}

	if g.Itinerary[targetIdx].Status != VisitInProgress {
		return ErrVisitNotInProgress
	}

	g.Itinerary[targetIdx].Status = VisitCompleted
	return nil
}
