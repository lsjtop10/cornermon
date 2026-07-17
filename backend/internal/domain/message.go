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
	id          MessageID
	channelType MessageChannelType
	campID      Optional[CampID]
	trackID     TrackID
	senderRole  SenderRole
	content     string
	sentAt      time.Time
	readAt      Optional[time.Time]
}

// MarkRead는 공지 메시지의 읽음 상태를 기록합니다. 이미 읽은 경우 최초 시각을 유지합니다.
func (r *Message) MarkRead(now time.Time) error {
	if r.readAt.IsSet() {
		return nil
	}
	r.readAt = Some(now)
	return nil
}

func (m *Message) ID() MessageID {
	return m.id
}

func (m *Message) ChannelType() MessageChannelType {
	return m.channelType
}

func (m *Message) CampID() Optional[CampID] {
	return m.campID
}

func (m *Message) TrackID() TrackID {
	return m.trackID
}

func (m *Message) SenderRole() SenderRole {
	return m.senderRole
}

func (m *Message) Content() string {
	return m.content
}

func (m *Message) SentAt() time.Time {
	return m.sentAt
}

func (m *Message) ReadAt() Optional[time.Time] {
	return m.readAt
}
func (m *Message) SetReadAt(t Optional[time.Time]) {
	m.readAt = t
}

type MessageProps struct {
	ID MessageID
	ChannelType MessageChannelType
	CampID Optional[CampID]
	TrackID TrackID
	SenderRole SenderRole
	Content string
	SentAt time.Time
	ReadAt Optional[time.Time]
}
func NewMessageFromProps(p MessageProps) *Message {
	return &Message{
		id: p.ID,
		channelType: p.ChannelType,
		campID: p.CampID,
		trackID: p.TrackID,
		senderRole: p.SenderRole,
		content: p.Content,
		sentAt: p.SentAt,
		readAt: p.ReadAt,
	}
}
func NewMessageValFromProps(p MessageProps) Message {
	return Message{
		id: p.ID,
		channelType: p.ChannelType,
		campID: p.CampID,
		trackID: p.TrackID,
		senderRole: p.SenderRole,
		content: p.Content,
		sentAt: p.SentAt,
		readAt: p.ReadAt,
	}
}
