package postgres

import (
	"testing"
	"time"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/infrastructure/postgres/db"

	"github.com/jackc/pgx/v5/pgtype"
)

func TestShouldMapNameAndStatusWhenMappingCampRow(t *testing.T) {
	// Arrange - Get/GetByRegistrationCode/GetByName은 모두 이 mapCamp 헬퍼를 공유하므로,
	// 헬퍼 하나만 검증하면 세 조회 경로 모두 동일하게 검증된다.
	row := db.Camp{
		ID:                   "camp-1",
		Name:                 "App Store Review Demo",
		RegistrationCode:     "REGCODE1",
		StartAt:              pgtype.Timestamptz{Time: time.Date(2026, 8, 1, 0, 0, 0, 0, time.UTC), Valid: true},
		EndAt:                pgtype.Timestamptz{Time: time.Date(2026, 8, 2, 0, 0, 0, 0, time.UTC), Valid: true},
		Status:               "ACTIVE",
		BottleneckMinSamples: 3,
		BottleneckRatioPct:   20,
	}

	// Act
	got := mapCamp(row)

	// Assert
	if got.Name() != "App Store Review Demo" {
		t.Errorf("expected Name 'App Store Review Demo', got %q", got.Name())
	}
	if got.Status() != domain.CampActive {
		t.Errorf("expected Status ACTIVE, got %q", got.Status())
	}
	if _, ok := got.ActivatedAt().Value(); ok {
		t.Errorf("expected ActivatedAt None when row.ActivatedAt is invalid, got Some")
	}
}

func TestShouldMapActivatedAtWhenRowHasValidActivatedAt(t *testing.T) {
	// Arrange
	activatedAt := time.Date(2026, 8, 1, 9, 0, 0, 0, time.UTC)
	row := db.Camp{
		ID:          "camp-1",
		Name:        "캠프",
		Status:      "ACTIVE",
		ActivatedAt: pgtype.Timestamptz{Time: activatedAt, Valid: true},
	}

	// Act
	got := mapCamp(row)

	// Assert
	value, ok := got.ActivatedAt().Value()
	if !ok || !value.Equal(activatedAt) {
		t.Errorf("expected ActivatedAt Some(%v), got ok=%v value=%v", activatedAt, ok, value)
	}
}
