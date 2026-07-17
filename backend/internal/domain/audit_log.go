package domain

import (
	"time"
)

type AuditLog struct {
	id         AuditLogID
	actor      string
	action     string
	target     string
	success    bool
	occurredAt time.Time
	metadata   map[string]any
}

// NewAuditLog는 감사 로그 불변 객체를 생성하여 반환합니다.
func NewAuditLog(id AuditLogID, actor, action, target string, success bool, occurredAt time.Time, metadata map[string]any) *AuditLog {
	return &AuditLog{
		id:         id,
		actor:      actor,
		action:     action,
		target:     target,
		success:    success,
		occurredAt: occurredAt,
		metadata:   metadata,
	}
}

func (a *AuditLog) ID() AuditLogID {
	return a.id
}

func (a *AuditLog) Actor() string {
	return a.actor
}

func (a *AuditLog) Action() string {
	return a.action
}

func (a *AuditLog) Target() string {
	return a.target
}

func (a *AuditLog) Success() bool {
	return a.success
}

func (a *AuditLog) OccurredAt() time.Time {
	return a.occurredAt
}

func (a *AuditLog) Metadata() map[string]any {
	return a.metadata
}

type AuditLogProps struct {
	ID AuditLogID
	Actor string
	Action string
	Target string
	Success bool
	OccurredAt time.Time
	Metadata map[string]any
}
func NewAuditLogFromProps(p AuditLogProps) *AuditLog {
	return &AuditLog{
		id: p.ID,
		actor: p.Actor,
		action: p.Action,
		target: p.Target,
		success: p.Success,
		occurredAt: p.OccurredAt,
		metadata: p.Metadata,
	}
}
func NewAuditLogValFromProps(p AuditLogProps) AuditLog {
	return AuditLog{
		id: p.ID,
		actor: p.Actor,
		action: p.Action,
		target: p.Target,
		success: p.Success,
		occurredAt: p.OccurredAt,
		metadata: p.Metadata,
	}
}
