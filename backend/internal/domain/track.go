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
	deletedAt          Optional[time.Time]
	unreadByAdminCount int
	unreadByTrackCount int
}

// Delete는 트랙을 비활성화(DELETED) 처리합니다. 진행 중인 방문이 있는지는
// Visit이 단일 진실 공급원이므로 호출자(usecase)가 사전에 확인해야 합니다.
func (t *Track) Delete(now time.Time) (TrackDeletedEvent, error) {
	if t.status == TrackDeleted {
		return TrackDeletedEvent{}, ErrTrackAlreadyDeleted
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
	ID                 TrackID
	CornerID           CornerID
	TrackNo            int
	Status             TrackStatus
	PINHash            string
	PINCiphertext      string
	DeletedAt          Optional[time.Time]
	UnreadByAdminCount int
	UnreadByTrackCount int
}

func NewTrackFromProps(p TrackProps) *Track {
	return &Track{
		id:                 p.ID,
		cornerID:           p.CornerID,
		trackNo:            p.TrackNo,
		status:             p.Status,
		pINHash:            p.PINHash,
		pINCiphertext:      p.PINCiphertext,
		deletedAt:          p.DeletedAt,
		unreadByAdminCount: p.UnreadByAdminCount,
		unreadByTrackCount: p.UnreadByTrackCount,
	}
}
func NewTrackValFromProps(p TrackProps) Track {
	return Track{
		id:                 p.ID,
		cornerID:           p.CornerID,
		trackNo:            p.TrackNo,
		status:             p.Status,
		pINHash:            p.PINHash,
		pINCiphertext:      p.PINCiphertext,
		deletedAt:          p.DeletedAt,
		unreadByAdminCount: p.UnreadByAdminCount,
		unreadByTrackCount: p.UnreadByTrackCount,
	}
}

func (t *Track) SetPINCiphertext(hash string) {
	t.pINCiphertext = hash
}

func (tr *Track) IncrementUnreadByAdmin() {
	tr.unreadByAdminCount++
}

func (tr *Track) IncrementUnreadByTrack() {
	tr.unreadByTrackCount++
}

func (tr *Track) ResetUnreadByAdmin() {
	tr.unreadByAdminCount = 0
}

func (tr *Track) ResetUnreadByTrack() {
	tr.unreadByTrackCount = 0
}
