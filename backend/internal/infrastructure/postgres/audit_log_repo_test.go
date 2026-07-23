package postgres

import (
	"encoding/json"
	"testing"
	"time"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/infrastructure/postgres/db"

	"github.com/jackc/pgx/v5/pgtype"
)

func TestMapAuditLogShoudReturnSnapshotFieldsWhenColumnsValid(t *testing.T) {
	// arrange
	occurredAt := time.Date(2026, 7, 22, 9, 0, 0, 0, time.UTC)
	metadata, _ := json.Marshal(map[string]any{"count": float64(3)})
	row := db.AuditLog{
		ID:         "audit-1",
		Actor:      "admin-uuid",
		Action:     "CORNER_DELETE",
		Target:     "corner-1",
		Success:    true,
		OccurredAt: pgtype.Timestamptz{Time: occurredAt, Valid: true},
		Metadata:   metadata,
		CampID:     pgtype.Text{String: "camp-1", Valid: true},
		TargetName: pgtype.Text{String: "체험 코너", Valid: true},
		ActorName:  pgtype.Text{String: "김관리", Valid: true},
	}

	// act
	got, err := mapAuditLog(row)

	// assert
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if got.ActorName() != "김관리" {
		t.Errorf("expected ActorName '김관리', got %q", got.ActorName())
	}
	if got.TargetName() != "체험 코너" {
		t.Errorf("expected TargetName '체험 코너', got %q", got.TargetName())
	}
	campID, ok := got.CampID().Value()
	if !ok || campID != domain.CampID("camp-1") {
		t.Errorf("expected CampID Some('camp-1'), got %v (set=%v)", campID, ok)
	}
	if got.Metadata()["count"] != float64(3) {
		t.Errorf("expected metadata count 3, got %v", got.Metadata()["count"])
	}
}

func TestMapAuditLogShoudReturnNoneCampIDWhenColumnNull(t *testing.T) {
	// arrange
	row := db.AuditLog{
		ID:         "audit-2",
		Actor:      "anonymous",
		Action:     "ADMIN_LOGIN",
		Success:    false,
		OccurredAt: pgtype.Timestamptz{Time: time.Now(), Valid: true},
		CampID:     pgtype.Text{Valid: false},
		TargetName: pgtype.Text{Valid: false},
		ActorName:  pgtype.Text{Valid: false},
	}

	// act
	got, err := mapAuditLog(row)

	// assert
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if _, ok := got.CampID().Value(); ok {
		t.Error("expected CampID to be None when camp_id column is NULL")
	}
	if got.ActorName() != "" || got.TargetName() != "" {
		t.Errorf("expected empty snapshot fields when NULL, got actorName=%q targetName=%q", got.ActorName(), got.TargetName())
	}
}
