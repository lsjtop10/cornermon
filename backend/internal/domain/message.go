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

type Message struct {
	ID          MessageID
	ChannelType MessageChannelType
	TrackID     Optional[TrackID]
	SenderRole  SenderRole
	Content     string
	SentAt      time.Time
}

type BroadcastReceipt struct {
	MessageID MessageID
	TrackID   TrackID
	ReadAt    Optional[time.Time]
}

// MarkRead는 공지 메시지의 읽음 상태를 기록합니다. 이미 읽은 경우 최초 시각을 유지합니다.
func (r *BroadcastReceipt) MarkRead(now time.Time) error {
	if r.ReadAt.IsSet() {
		return nil
	}
	r.ReadAt = Some(now)
	return nil
}
