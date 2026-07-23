package domain_test

import (
	"testing"
	"time"

	"cornermon/backend/internal/domain"
)

func TestNewAuditLogFromPropsShoudInitializeAllFieldsWhenCalled(t *testing.T) {
	// arrange
	now := time.Date(2026, 7, 9, 15, 0, 0, 0, time.UTC)
	metadata := map[string]any{"ip": "127.0.0.1"}
	props := domain.AuditLogProps{
		ID:         domain.AuditLogID("log-1"),
		Actor:      "admin-1",
		ActorName:  "김관리",
		Action:     "CAMP_ACTIVATE",
		Target:     "camp-1",
		TargetName: "여름 캠프",
		CampID:     domain.Some(domain.CampID("camp-1")),
		Success:    true,
		OccurredAt: now,
		Metadata:   metadata,
	}

	// act
	log := domain.NewAuditLogFromProps(props)

	// assert
	if log.ID() != domain.AuditLogID("log-1") {
		t.Errorf("expected ID 'log-1', got %q", log.ID())
	}
	if log.Actor() != "admin-1" {
		t.Errorf("expected Actor 'admin-1', got %q", log.Actor())
	}
	if log.ActorName() != "김관리" {
		t.Errorf("expected ActorName '김관리', got %q", log.ActorName())
	}
	if log.Action() != "CAMP_ACTIVATE" {
		t.Errorf("expected Action 'CAMP_ACTIVATE', got %q", log.Action())
	}
	if log.Target() != "camp-1" {
		t.Errorf("expected Target 'camp-1', got %q", log.Target())
	}
	if log.TargetName() != "여름 캠프" {
		t.Errorf("expected TargetName '여름 캠프', got %q", log.TargetName())
	}
	if campID, ok := log.CampID().Value(); !ok || campID != domain.CampID("camp-1") {
		t.Errorf("expected CampID Some('camp-1'), got %v (set=%v)", campID, ok)
	}
	if !log.Success() {
		t.Error("expected Success to be true")
	}
	if !log.OccurredAt().Equal(now) {
		t.Errorf("expected OccurredAt %v, got %v", now, log.OccurredAt())
	}
	if log.Metadata()["ip"] != "127.0.0.1" {
		t.Errorf("expected metadata ip to be '127.0.0.1', got %v", log.Metadata()["ip"])
	}
}

func TestAuditLogCampIDShoudReturnNoneWhenNotSet(t *testing.T) {
	// arrange
	props := domain.AuditLogProps{
		ID:     domain.AuditLogID("log-2"),
		Actor:  "anonymous",
		Action: "ADMIN_LOGIN",
	}

	// act
	log := domain.NewAuditLogFromProps(props)

	// assert
	if _, ok := log.CampID().Value(); ok {
		t.Error("expected CampID to be None when not set in props")
	}
}
