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

func (t *TrackDeletedEvent) TrackID() TrackID {
	return t.trackID
}

func (t *TrackDeletedEvent) OccurredAt() time.Time {
	return t.occurredAt
}

type TrackDeletedEventProps struct {
	TrackID    TrackID
	OccurredAt time.Time
}

func NewTrackDeletedEventFromProps(p TrackDeletedEventProps) *TrackDeletedEvent {
	return &TrackDeletedEvent{
		trackID:    p.TrackID,
		occurredAt: p.OccurredAt,
	}
}
func NewTrackDeletedEventValFromProps(p TrackDeletedEventProps) TrackDeletedEvent {
	return TrackDeletedEvent{
		trackID:    p.TrackID,
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
	TrackID    TrackID
	OccurredAt time.Time
}

func NewTrackPINRegeneratedEventFromProps(p TrackPINRegeneratedEventProps) *TrackPINRegeneratedEvent {
	return &TrackPINRegeneratedEvent{
		trackID:    p.TrackID,
		occurredAt: p.OccurredAt,
	}
}
func NewTrackPINRegeneratedEventValFromProps(p TrackPINRegeneratedEventProps) TrackPINRegeneratedEvent {
	return TrackPINRegeneratedEvent{
		trackID:    p.TrackID,
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
	CampID     CampID
	OccurredAt time.Time
}

func NewCampEndedEventFromProps(p CampEndedEventProps) *CampEndedEvent {
	return &CampEndedEvent{
		campID:     p.CampID,
		occurredAt: p.OccurredAt,
	}
}
func NewCampEndedEventValFromProps(p CampEndedEventProps) CampEndedEvent {
	return CampEndedEvent{
		campID:     p.CampID,
		occurredAt: p.OccurredAt,
	}
}
