package domain

import (
	"time"
)

type AnnouncementID string
type NoticeID = AnnouncementID

// Notice란
type Announcement struct {
	ID          AnnouncementID
	ChannelType MessageChannelType
	CampID      CampID
	SenderRole  SenderRole
	Content     string
	SentAt      time.Time
}

// Notice is kept as the concise name used by the usecase contract.
type Notice = Announcement

type NoteceReceipt struct {
	NoticeID AnnouncementID
	TrackID  TrackID
	ReadAt   Optional[time.Time]
}

// AnnouncementReceipt is the correctly-spelled public name.
type AnnouncementReceipt = NoteceReceipt

// BroadcastReceipt preserves the pre-split API contract.
type BroadcastReceipt struct {
	MessageID MessageID
	TrackID   TrackID
	ReadAt    Optional[time.Time]
}

// MarkRead는 공지 메시지의 읽음 상태를 기록합니다. 이미 읽은 경우 최초 시각을 유지합니다.
func (r *NoteceReceipt) MarkRead(now time.Time) error {
	if r.ReadAt.IsSet() {
		return nil
	}

	r.ReadAt = Some(now)
	return nil
}

func (r *BroadcastReceipt) MarkRead(now time.Time) error {
	if r.ReadAt.IsSet() {
		return nil
	}
	r.ReadAt = Some(now)
	return nil
}
