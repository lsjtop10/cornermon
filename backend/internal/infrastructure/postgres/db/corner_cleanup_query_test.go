package db

import (
	"strings"
	"testing"
)

func TestShouldExcludeActiveCornersWhenPurgingDeletedCorners(t *testing.T) {
	// Arrange
	query := purgeDeletedCorners

	// Act
	hasSoftDeleteCutoff := strings.Contains(query, "c.deleted_at <= $1")
	hasTrackHistoryGuard := strings.Contains(query, "NOT EXISTS (SELECT 1 FROM tracks")
	hasVisitHistoryGuard := strings.Contains(query, "NOT EXISTS (SELECT 1 FROM visits")

	// Assert
	if !hasSoftDeleteCutoff || !hasTrackHistoryGuard || !hasVisitHistoryGuard {
		t.Fatalf("purge query must require expiry and protect track/visit history: %s", query)
	}
}
