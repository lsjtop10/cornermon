package domain

import (
	"time"
)

type TrackStatus string

const (
	TrackActive  TrackStatus = "ACTIVE"
	TrackDeleted TrackStatus = "DELETED"
)

type TrackOperationalStatus string

const (
	TrackIdle TrackOperationalStatus = "IDLE"
	TrackBusy TrackOperationalStatus = "BUSY"
)

type Track struct {
	ID             TrackID
	CornerID       CornerID
	TrackNo        int
	Status         TrackStatus
	PINHash        string
	PINCiphertext  string
	CurrentVisitID Optional[VisitID]
	DeletedAt      Optional[time.Time]
}

// StartVisit은 트랙에 방문(Visit)이 시작되었음을 기록합니다.
func (t *Track) StartVisit(visitID VisitID) error {
	if t.Status != TrackActive {
		return ErrTrackNotActive
	}
	if t.CurrentVisitID.IsSet() {
		return ErrTrackBusy
	}
	t.CurrentVisitID = Some(visitID)
	return nil
}

// CompleteVisit은 진행 중이던 방문을 트랙에서 완료 처리하여 해제합니다.
func (t *Track) CompleteVisit(now time.Time) (TrackFreedEvent, error) {
	if t.Status != TrackActive {
		return TrackFreedEvent{}, ErrTrackNotActive
	}
	if !t.CurrentVisitID.IsSet() {
		return TrackFreedEvent{}, ErrTrackNotBusy
	}

	t.CurrentVisitID = None[VisitID]()

	return TrackFreedEvent{
		TrackID:    t.ID,
		OccurredAt: now,
	}, nil
}

// OperationalStatus는 트랙의 현재 가동 상태를 반환합니다.
func (t *Track) OperationalStatus() TrackOperationalStatus {
	if t.CurrentVisitID.IsSet() {
		return TrackBusy
	}
	return TrackIdle
}

// Delete는 진행 중인 방문이 없을 때 트랙을 비활성화(DELETED) 처리합니다.
func (t *Track) Delete(now time.Time) (TrackDeletedEvent, error) {
	if t.Status == TrackDeleted {
		return TrackDeletedEvent{}, ErrTrackAlreadyDeleted
	}
	if t.CurrentVisitID.IsSet() {
		return TrackDeletedEvent{}, ErrTrackDeleteBlocked
	}

	t.Status = TrackDeleted
	t.DeletedAt = Some(now)

	return TrackDeletedEvent{
		TrackID:    t.ID,
		OccurredAt: now,
	}, nil
}

// RegeneratePIN은 트랙의 PIN 값을 해시로 갱신하고 관련 이벤트를 반환합니다.
func (t *Track) RegeneratePIN(newHash string, now time.Time) (TrackPINRegeneratedEvent, error) {
	if t.Status != TrackActive {
		return TrackPINRegeneratedEvent{}, ErrTrackNotActive
	}

	t.PINHash = newHash

	return TrackPINRegeneratedEvent{
		TrackID:    t.ID,
		OccurredAt: now,
	}, nil
}
