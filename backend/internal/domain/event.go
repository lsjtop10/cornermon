package domain

import "time"

// Track.Delete 성공 시 반환 — 해당 트랙의 진행자 세션은 즉시 무효화되어야 한다 (§domain-model.md 2.4, 5-8)
type TrackDeletedEvent struct {
	TrackID    TrackID
	OccurredAt time.Time
}

// Track.RegeneratePIN 성공 시 반환 — 기존 진행자 세션은 즉시 무효화되어야 한다 (§domain-model.md 2.5)
type TrackPINRegeneratedEvent struct {
	TrackID    TrackID
	OccurredAt time.Time
}

// Camp.End 성공 시 반환 — 이 캠프에 속한 모든 트랙의 진행자 세션이 무효화되어야 한다 (§domain-model.md 2.4, 5-10)
// Camp는 소속 Track 목록을 모르므로(애그리게잇 분리), 실제 트랙 조회·전파는 usecase가 수행한다.
type CampEndedEvent struct {
	CampID     CampID
	OccurredAt time.Time
}

// Track.CompleteVisit 성공 시 반환 — 세션 무효화와는 무관하지만, usecase가 감사 로그/SSE 스냅샷을
// Visit.Complete(now)와 동일한 시각으로 정합성 있게 구성할 수 있도록 트랙이 비워진 시각을 함께 돌려준다.
type TrackFreedEvent struct {
	TrackID    TrackID
	OccurredAt time.Time
}
