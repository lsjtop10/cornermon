package domain

import (
	"time"
)

type VisitInputMethod string

const (
	VisitQRScan VisitInputMethod = "QR_SCAN"
	VisitManual VisitInputMethod = "MANUAL"
)

type VisitStatus string

const (
	VisitStatusInProgress VisitStatus = "IN_PROGRESS"
	VisitStatusCompleted  VisitStatus = "COMPLETED"
)

type Visit struct {
	id          VisitID
	groupID     GroupID
	cornerID    CornerID
	trackID     TrackID
	status      VisitStatus
	inputMethod VisitInputMethod
	startedAt   time.Time
	endedAt     Optional[time.Time]
}

// NewVisit은 신규 방문 엔티티를 생성합니다.
func NewVisit(id VisitID, groupID GroupID, cornerID CornerID, trackID TrackID, method VisitInputMethod, startedAt time.Time) *Visit {
	return &Visit{
		id:          id,
		groupID:     groupID,
		cornerID:    cornerID,
		trackID:     trackID,
		status:      VisitStatusInProgress,
		inputMethod: method,
		startedAt:   startedAt,
		endedAt:     None[time.Time](),
	}
}

// Complete는 방문을 완료 처리합니다.
func (v *Visit) Complete(endedAt time.Time) error {
	if v.status == VisitStatusCompleted {
		return ErrVisitAlreadyCompleted
	}
	if endedAt.Before(v.startedAt) {
		return ErrVisitEndBeforeStart
	}

	v.status = VisitStatusCompleted
	v.endedAt = Some(endedAt)
	return nil
}

// DurationSeconds는 완료된 방문의 실제 소요 시간(초)을 계산합니다.
func (v *Visit) DurationSeconds() Optional[int] {
	endedAtVal, ok := v.endedAt.Value()
	if !ok {
		return None[int]()
	}

	duration := int(endedAtVal.Sub(v.startedAt).Seconds())
	return Some(duration)
}

// DeviationSeconds는 목표 시간(분) 대비 소요 시간 편차(초)를 계산합니다.
func (v *Visit) DeviationSeconds(targetMinutes int) Optional[int] {
	durationOpt := v.DurationSeconds()
	duration, ok := durationOpt.Value()
	if !ok {
		return None[int]()
	}

	deviation := duration - (targetMinutes * 60)
	return Some(deviation)
}

func (v *Visit) ID() VisitID {
	return v.id
}

func (v *Visit) GroupID() GroupID {
	return v.groupID
}

func (v *Visit) CornerID() CornerID {
	return v.cornerID
}

func (v *Visit) TrackID() TrackID {
	return v.trackID
}

func (v *Visit) Status() VisitStatus {
	return v.status
}

func (v *Visit) InputMethod() VisitInputMethod {
	return v.inputMethod
}

func (v *Visit) StartedAt() time.Time {
	return v.startedAt
}

func (v *Visit) EndedAt() Optional[time.Time] {
	return v.endedAt
}
func (v *Visit) SetEndedAt(t Optional[time.Time]) {
	v.endedAt = t
}

type VisitProps struct {
	ID          VisitID
	GroupID     GroupID
	CornerID    CornerID
	TrackID     TrackID
	Status      VisitStatus
	InputMethod VisitInputMethod
	StartedAt   time.Time
	EndedAt     Optional[time.Time]
}

func NewVisitFromProps(p VisitProps) *Visit {
	return &Visit{
		id:          p.ID,
		groupID:     p.GroupID,
		cornerID:    p.CornerID,
		trackID:     p.TrackID,
		status:      p.Status,
		inputMethod: p.InputMethod,
		startedAt:   p.StartedAt,
		endedAt:     p.EndedAt,
	}
}
func NewVisitValFromProps(p VisitProps) Visit {
	return Visit{
		id:          p.ID,
		groupID:     p.GroupID,
		cornerID:    p.CornerID,
		trackID:     p.TrackID,
		status:      p.Status,
		inputMethod: p.InputMethod,
		startedAt:   p.StartedAt,
		endedAt:     p.EndedAt,
	}
}
