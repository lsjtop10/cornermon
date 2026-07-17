
package postgres

import (
	"testing"
	"time"

	"cornermon/backend/internal/infrastructure/postgres/db"

	"github.com/jackc/pgx/v5/pgtype"
)

func TestShouldPreserveCreatedAtWhenMappingDeviceRegistrationRow(t *testing.T) {
	// Arrange
	createdAt := time.Date(2026, 7, 15, 9, 30, 0, 0, time.UTC)
	row := db.DeviceRegistration{
		ID:         "device-1",
		CampID:     "camp-1",
		DeviceName: "iPad",
		Status:     "PENDING",
		TokenHash:  "hash",
		CreatedAt:  pgtype.Timestamptz{Time: createdAt, Valid: true},
	}

	// Act
	got := mapDeviceRegistration(row)

	// Assert
	if !got.CreatedAt().Equal(createdAt) {
		t.Fatalf("expected CreatedAt %v, got %v", createdAt, got.CreatedAt())
	}
}
