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
	id                 TrackID
	cornerID           CornerID
	trackNo            int
	status             TrackStatus
	pINHash            string
	pINCiphertext      string
	currentVisitID     Optional[VisitID]
	deletedAt          Optional[time.Time]
	unreadByAdminCount int
	unreadByTrackCount int
}

// StartVisit은 트랙에 방문(Visit)이 시작되었음을 기록합니다.
func (t *Track) StartVisit(visitID VisitID) error {
	if t.status != TrackActive {
		return ErrTrackNotActive
	}
	if t.currentVisitID.IsSet() {
		return ErrTrackBusy
	}
	t.currentVisitID = Some(visitID)
	return nil
}

// CompleteVisit은 진행 중이던 방문을 트랙에서 완료 처리하여 해제합니다.
func (t *Track) CompleteVisit(now time.Time) (TrackFreedEvent, error) {
	if t.status != TrackActive {
		return TrackFreedEvent{}, ErrTrackNotActive
	}
	if !t.currentVisitID.IsSet() {
		return TrackFreedEvent{}, ErrTrackNotBusy
	}

	t.currentVisitID = None[VisitID]()

	return TrackFreedEvent{
		trackID:    t.id,
		occurredAt: now,
	}, nil
}

// OperationalStatus는 트랙의 현재 가동 상태를 반환합니다.
func (t *Track) OperationalStatus() TrackOperationalStatus {
	if t.currentVisitID.IsSet() {
		return TrackBusy
	}
	return TrackIdle
}

// Delete는 진행 중인 방문이 없을 때 트랙을 비활성화(DELETED) 처리합니다.
func (t *Track) Delete(now time.Time) (TrackDeletedEvent, error) {
	if t.status == TrackDeleted {
		return TrackDeletedEvent{}, ErrTrackAlreadyDeleted
	}
	if t.currentVisitID.IsSet() {
		return TrackDeletedEvent{}, ErrTrackDeleteBlocked
	}

	t.status = TrackDeleted
	t.deletedAt = Some(now)

	return TrackDeletedEvent{
		trackID:    t.id,
		occurredAt: now,
	}, nil
}

// RegeneratePIN은 트랙의 PIN 값을 해시로 갱신하고 관련 이벤트를 반환합니다.
func (t *Track) RegeneratePIN(newHash string, now time.Time) (TrackPINRegeneratedEvent, error) {
	if t.status != TrackActive {
		return TrackPINRegeneratedEvent{}, ErrTrackNotActive
	}

	t.pINHash = newHash

	return TrackPINRegeneratedEvent{
		trackID:    t.id,
		occurredAt: now,
	}, nil
}

func (tr *Track) ID() TrackID {
	return tr.id
}

func (tr *Track) CornerID() CornerID {
	return tr.cornerID
}

func (tr *Track) TrackNo() int {
	return tr.trackNo
}

func (tr *Track) Status() TrackStatus {
	return tr.status
}

func (tr *Track) PINHash() string {
	return tr.pINHash
}

func (tr *Track) PINCiphertext() string {
	return tr.pINCiphertext
}

func (tr *Track) CurrentVisitID() Optional[VisitID] {
	return tr.currentVisitID
}
func (tr *Track) SetCurrentVisitID(id Optional[VisitID]) {
	tr.currentVisitID = id
}

func (tr *Track) DeletedAt() Optional[time.Time] {
	return tr.deletedAt
}
func (tr *Track) SetDeletedAt(t Optional[time.Time]) {
	tr.deletedAt = t
}

func (tr *Track) UnreadByAdminCount() int {
	return tr.unreadByAdminCount
}

func (tr *Track) UnreadByTrackCount() int {
	return tr.unreadByTrackCount
}

type TrackProps struct {
	ID TrackID
	CornerID CornerID
	TrackNo int
	Status TrackStatus
	PINHash string
	PINCiphertext string
	CurrentVisitID Optional[VisitID]
	DeletedAt Optional[time.Time]
	UnreadByAdminCount int
	UnreadByTrackCount int
}
func NewTrackFromProps(p TrackProps) *Track {
	return &Track{
		id: p.ID,
		cornerID: p.CornerID,
		trackNo: p.TrackNo,
		status: p.Status,
		pINHash: p.PINHash,
		pINCiphertext: p.PINCiphertext,
		currentVisitID: p.CurrentVisitID,
		deletedAt: p.DeletedAt,
		unreadByAdminCount: p.UnreadByAdminCount,
		unreadByTrackCount: p.UnreadByTrackCount,
	}
}
func NewTrackValFromProps(p TrackProps) Track {
	return Track{
		id: p.ID,
		cornerID: p.CornerID,
		trackNo: p.TrackNo,
		status: p.Status,
		pINHash: p.PINHash,
		pINCiphertext: p.PINCiphertext,
		currentVisitID: p.CurrentVisitID,
		deletedAt: p.DeletedAt,
		unreadByAdminCount: p.UnreadByAdminCount,
		unreadByTrackCount: p.UnreadByTrackCount,
	}
}

func (t *Track) SetPINCiphertext(hash string) {
	t.pINCiphertext = hash
}
