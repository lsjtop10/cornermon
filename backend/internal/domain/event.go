package domain

import "time"

// Track.Delete 성공 시 반환 — 해당 트랙의 진행자 세션은 즉시 무효화되어야 한다 (§domain-model.md 2.4, 5-8)
type TrackDeletedEvent struct {
	trackID    TrackID
	occurredAt time.Time
}

// Track.RegeneratePIN 성공 시 반환 — 기존 진행자 세션은 즉시 무효화되어야 한다 (§domain-model.md 2.5)
type TrackPINRegeneratedEvent struct {
	trackID    TrackID
	occurredAt time.Time
}

// Camp.End 성공 시 반환 — 이 캠프에 속한 모든 트랙의 진행자 세션이 무효화되어야 한다 (§domain-model.md 2.4, 5-10)
// Camp는 소속 Track 목록을 모르므로(애그리게잇 분리), 실제 트랙 조회·전파는 usecase가 수행한다.
type CampEndedEvent struct {
	campID     CampID
	occurredAt time.Time
}

// Track.CompleteVisit 성공 시 반환 — 세션 무효화와는 무관하지만, usecase가 감사 로그/SSE 스냅샷을
// Visit.Complete(now)와 동일한 시각으로 정합성 있게 구성할 수 있도록 트랙이 비워진 시각을 함께 돌려준다.
type TrackFreedEvent struct {
	trackID    TrackID
	occurredAt time.Time
}

func (t *TrackDeletedEvent) TrackID() TrackID {
	return t.trackID
}

func (t *TrackDeletedEvent) OccurredAt() time.Time {
	return t.occurredAt
}

type TrackDeletedEventProps struct {
	TrackID TrackID
	OccurredAt time.Time
}
func NewTrackDeletedEventFromProps(p TrackDeletedEventProps) *TrackDeletedEvent {
	return &TrackDeletedEvent{
		trackID: p.TrackID,
		occurredAt: p.OccurredAt,
	}
}
func NewTrackDeletedEventValFromProps(p TrackDeletedEventProps) TrackDeletedEvent {
	return TrackDeletedEvent{
		trackID: p.TrackID,
		occurredAt: p.OccurredAt,
	}
}

func (t *TrackPINRegeneratedEvent) TrackID() TrackID {
	return t.trackID
}

func (t *TrackPINRegeneratedEvent) OccurredAt() time.Time {
	return t.occurredAt
}

type TrackPINRegeneratedEventProps struct {
	TrackID TrackID
	OccurredAt time.Time
}
func NewTrackPINRegeneratedEventFromProps(p TrackPINRegeneratedEventProps) *TrackPINRegeneratedEvent {
	return &TrackPINRegeneratedEvent{
		trackID: p.TrackID,
		occurredAt: p.OccurredAt,
	}
}
func NewTrackPINRegeneratedEventValFromProps(p TrackPINRegeneratedEventProps) TrackPINRegeneratedEvent {
	return TrackPINRegeneratedEvent{
		trackID: p.TrackID,
		occurredAt: p.OccurredAt,
	}
}

func (c *CampEndedEvent) CampID() CampID {
	return c.campID
}

func (c *CampEndedEvent) OccurredAt() time.Time {
	return c.occurredAt
}

type CampEndedEventProps struct {
	CampID CampID
	OccurredAt time.Time
}
func NewCampEndedEventFromProps(p CampEndedEventProps) *CampEndedEvent {
	return &CampEndedEvent{
		campID: p.CampID,
		occurredAt: p.OccurredAt,
	}
}
func NewCampEndedEventValFromProps(p CampEndedEventProps) CampEndedEvent {
	return CampEndedEvent{
		campID: p.CampID,
		occurredAt: p.OccurredAt,
	}
}

func (t *TrackFreedEvent) TrackID() TrackID {
	return t.trackID
}

func (t *TrackFreedEvent) OccurredAt() time.Time {
	return t.occurredAt
}

type TrackFreedEventProps struct {
	TrackID TrackID
	OccurredAt time.Time
}
func NewTrackFreedEventFromProps(p TrackFreedEventProps) *TrackFreedEvent {
	return &TrackFreedEvent{
		trackID: p.TrackID,
		occurredAt: p.OccurredAt,
	}
}
func NewTrackFreedEventValFromProps(p TrackFreedEventProps) TrackFreedEvent {
	return TrackFreedEvent{
		trackID: p.TrackID,
		occurredAt: p.OccurredAt,
	}
}
