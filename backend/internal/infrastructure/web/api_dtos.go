package web

import (
	"time"
)

type ErrorResponse struct {
	Code    string                 `json:"code" example:"INVALID_REQUEST"`
	Message string                 `json:"message" example:"잘못된 요청입니다."`
	Details map[string]interface{} `json:"details,omitempty"`
}

type Camp struct {
	ID                   string    `json:"id" format:"uuid"`
	Name                 string    `json:"name" example:"2026 여름 코너학습"`
	StartAt              time.Time `json:"startAt" format:"date-time"`
	EndAt                time.Time `json:"endAt" format:"date-time"`
	Status               string    `json:"status" enums:"PENDING,ACTIVE,ENDED"`
	BottleneckMinSamples int       `json:"bottleneckMinSamples" example:"3"`
	BottleneckRatioPct   int       `json:"bottleneckRatioPct" example:"20"`
}

type Corner struct {
	ID            string         `json:"id" format:"uuid"`
	Name          string         `json:"name" example:"코너 1"`
	TargetMinutes int            `json:"targetMinutes" example:"10"`
	Status        string         `json:"status" enums:"INACTIVE,IDLE,BUSY"`
	IsBottleneck  bool           `json:"isBottleneck"`
	ActiveTracks  []TrackSummary `json:"activeTracks"`
}

type TrackSummary struct {
	ID                string `json:"id" format:"uuid"`
	CornerID          string `json:"cornerId" format:"uuid"`
	TrackNo           int    `json:"trackNo"`
	Status            string `json:"status" enums:"ACTIVE,DELETED"`
	OperationalStatus string `json:"operationalStatus" enums:"IDLE,BUSY"`
}

type Track struct {
	TrackSummary
	PIN          string        `json:"pin" example:"482910"`
	CurrentVisit *VisitSummary `json:"currentVisit,omitempty"`
}

type CornerProgress struct {
	CornerID   string `json:"cornerId" format:"uuid"`
	CornerName string `json:"cornerName"`
	Status     string `json:"status" enums:"NOT_VISITED,IN_PROGRESS,COMPLETED"`
}

type Group struct {
	ID         string           `json:"id" format:"uuid"`
	Name       string           `json:"name" example:"1조"`
	BadgeID    string           `json:"badgeId" format:"uuid"`
	Status     string           `json:"status" enums:"IDLE_MOVING,AT_CORNER,FINISHED"`
	IsFinished bool             `json:"isFinished"`
	Itinerary  []CornerProgress `json:"itinerary"`
}

type VisitSummary struct {
	ID               string     `json:"id" format:"uuid"`
	GroupID          string     `json:"groupId" format:"uuid"`
	CornerID         string     `json:"cornerId" format:"uuid"`
	TrackID          string     `json:"trackId" format:"uuid"`
	Status           string     `json:"status" enums:"IN_PROGRESS,COMPLETED"`
	InputMethod      string     `json:"inputMethod" enums:"QR_SCAN,MANUAL"`
	StartedAt        time.Time  `json:"startedAt" format:"date-time"`
	EndedAt          *time.Time `json:"endedAt,omitempty" format:"date-time"`
	DurationSeconds  *int       `json:"durationSeconds,omitempty"`
	DeviationSeconds *int       `json:"deviationSeconds,omitempty"`
}

type Badge struct {
	ID              string  `json:"id" format:"uuid"`
	ShortID         string  `json:"shortId" example:"B-0042"`
	QRPayload       string  `json:"qrPayload"`
	Status          string  `json:"status" enums:"UNASSIGNED,ASSIGNED"`
	AssignedGroupID *string `json:"assignedGroupId,omitempty" format:"uuid"`
}

type DeviceRegistration struct {
	ID         string     `json:"id" format:"uuid"`
	DeviceName string     `json:"deviceName" example:"iPad Pro #3"`
	Status     string     `json:"status" enums:"PENDING,APPROVED,REJECTED,REVOKED"`
	CreatedAt  time.Time  `json:"createdAt" format:"date-time"`
	ApprovedAt *time.Time `json:"approvedAt,omitempty" format:"date-time"`
}

type Message struct {
	ID          string     `json:"id" format:"uuid"`
	ChannelType string     `json:"channelType" enums:"BROADCAST,DIRECT"`
	TrackID     *string    `json:"trackId,omitempty" format:"uuid"`
	SenderRole  string     `json:"senderRole" enums:"ADMIN,TRACK"`
	Content     string     `json:"content"`
	SentAt      time.Time  `json:"sentAt" format:"date-time"`
	IsRead      bool       `json:"isRead"`
	ReadAt      *time.Time `json:"readAt,omitempty" format:"date-time"`
}

type BroadcastReceipt struct {
	TrackID    string     `json:"trackId" format:"uuid"`
	TrackNo    int        `json:"trackNo"`
	CornerName string     `json:"cornerName"`
	IsRead     bool       `json:"isRead"`
	ReadAt     *time.Time `json:"readAt,omitempty" format:"date-time"`
}

type AuditLog struct {
	ID         string                 `json:"id" format:"uuid"`
	Actor      string                 `json:"actor"`
	Action     string                 `json:"action"`
	Target     string                 `json:"target"`
	Success    bool                   `json:"success"`
	OccurredAt time.Time              `json:"occurredAt" format:"date-time"`
	Metadata   map[string]interface{} `json:"metadata,omitempty"`
}

type AdminSession struct {
	ID         string    `json:"id" format:"uuid"`
	AdminID    string    `json:"adminId"`
	DeviceInfo *string   `json:"deviceInfo,omitempty"`
	CreatedAt  time.Time `json:"createdAt" format:"date-time"`
	LastUsedAt time.Time `json:"lastUsedAt" format:"date-time"`
}
