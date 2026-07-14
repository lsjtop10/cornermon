package domain

import (
	"time"
)

type MessageChannelType string

const (
	MessageBroadcast MessageChannelType = "BROADCAST"
	MessageDirect    MessageChannelType = "DIRECT"
)

type SenderRole string

const (
	RoleAdmin SenderRole = "ADMIN"
	RoleTrack SenderRole = "TRACK"
)

// Message는 운영자와 진행자 간 1대1 스레드에서 오가는 단위 메시지입니다.
type Message struct {
	// ChannelType and CampID are deprecated compatibility fields for the old API.
	ID          MessageID
	ChannelType MessageChannelType
	CampID      Optional[CampID]
	TrackID     TrackID
	SenderRole  SenderRole
	Content     string
	SentAt      time.Time
	ReadAt      Optional[time.Time]
}

// MarkRead는 공지 메시지의 읽음 상태를 기록합니다. 이미 읽은 경우 최초 시각을 유지합니다.
func (r *Message) MarkRead(now time.Time) error {
	if r.ReadAt.IsSet() {
		return nil
	}
	r.ReadAt = Some(now)
	return nil
}
