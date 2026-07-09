package domain

import (
	"time"
)

type AuditLog struct {
	ID         AuditLogID
	Actor      string
	Action     string
	Target     string
	Success    bool
	OccurredAt time.Time
	Metadata   map[string]any
}

// NewAuditLog는 감사 로그 불변 객체를 생성하여 반환합니다.
func NewAuditLog(id AuditLogID, actor, action, target string, success bool, occurredAt time.Time, metadata map[string]any) *AuditLog {
	return &AuditLog{
		ID:         id,
		Actor:      actor,
		Action:     action,
		Target:     target,
		Success:    success,
		OccurredAt: occurredAt,
		Metadata:   metadata,
	}
}
