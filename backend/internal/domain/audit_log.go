package domain

import (
	"time"
)

type AuditLog struct {
	id         AuditLogID
	actor      string // 행위자 식별자: admin UUID 또는 트랙ID/anonymous — 조회·통계 기준
	actorName  string // 행위자 표시 이름 스냅샷("" = 스냅샷 없음, 과거 로그 등)
	action     string
	target     string
	targetName string           // "" = 스냅샷 없음(과거 로그 또는 이름 없는 target)
	campID     Optional[CampID] // None = 캠프 무관 행위
	success    bool
	occurredAt time.Time
	metadata   map[string]any
}

func (a *AuditLog) ID() AuditLogID {
	return a.id
}

func (a *AuditLog) Actor() string {
	return a.actor
}

func (a *AuditLog) ActorName() string {
	return a.actorName
}

func (a *AuditLog) Action() string {
	return a.action
}

func (a *AuditLog) Target() string {
	return a.target
}

func (a *AuditLog) TargetName() string {
	return a.targetName
}

func (a *AuditLog) CampID() Optional[CampID] {
	return a.campID
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
	ID         AuditLogID
	Actor      string
	ActorName  string
	Action     string
	Target     string
	TargetName string
	CampID     Optional[CampID]
	Success    bool
	OccurredAt time.Time
	Metadata   map[string]any
}

func NewAuditLogFromProps(p AuditLogProps) *AuditLog {
	return &AuditLog{
		id:         p.ID,
		actor:      p.Actor,
		actorName:  p.ActorName,
		action:     p.Action,
		target:     p.Target,
		targetName: p.TargetName,
		campID:     p.CampID,
		success:    p.Success,
		occurredAt: p.OccurredAt,
		metadata:   p.Metadata,
	}
}
func NewAuditLogValFromProps(p AuditLogProps) AuditLog {
	return AuditLog{
		id:         p.ID,
		actor:      p.Actor,
		actorName:  p.ActorName,
		action:     p.Action,
		target:     p.Target,
		targetName: p.TargetName,
		campID:     p.CampID,
		success:    p.Success,
		occurredAt: p.OccurredAt,
		metadata:   p.Metadata,
	}
}
