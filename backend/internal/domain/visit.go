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
	ID          VisitID
	GroupID     GroupID
	CornerID    CornerID
	TrackID     TrackID
	Status      VisitStatus
	InputMethod VisitInputMethod
	StartedAt   time.Time
	EndedAt     Optional[time.Time]
}

// NewVisit은 신규 방문 엔티티를 생성합니다.
func NewVisit(id VisitID, groupID GroupID, cornerID CornerID, trackID TrackID, method VisitInputMethod, startedAt time.Time) *Visit {
	return &Visit{
		ID:          id,
		GroupID:     groupID,
		CornerID:    cornerID,
		TrackID:     trackID,
		Status:      VisitStatusInProgress,
		InputMethod: method,
		StartedAt:   startedAt,
		EndedAt:     None[time.Time](),
	}
}

// Complete는 방문을 완료 처리합니다.
func (v *Visit) Complete(endedAt time.Time) error {
	if v.Status == VisitStatusCompleted {
		return ErrVisitAlreadyCompleted
	}
	if endedAt.Before(v.StartedAt) {
		return ErrVisitEndBeforeStart
	}

	v.Status = VisitStatusCompleted
	v.EndedAt = Some(endedAt)
	return nil
}

// DurationSeconds는 완료된 방문의 실제 소요 시간(초)을 계산합니다.
func (v *Visit) DurationSeconds() Optional[int] {
	endedAtVal, ok := v.EndedAt.Value()
	if !ok {
		return None[int]()
	}

	duration := int(endedAtVal.Sub(v.StartedAt).Seconds())
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
