package postgres

import (
	"testing"
	"time"

	"cornermon/backend/internal/infrastructure/postgres/db"
	"github.com/jackc/pgx/v5/pgtype"
)

func TestMapBroadcastNoticeView_ShouldReturnUnreadWhenReceiptReadAtIsNull(t *testing.T) {
	// Arrange
	row := db.ListAnnouncementViewsByCampAndTrackRow{
		ID: "notice-1", CampID: "camp-1", SenderRole: "ADMIN", Content: "notice",
		SentAt: pgtype.Timestamptz{Time: time.Date(2026, 7, 20, 0, 0, 0, 0, time.UTC), Valid: true},
		ReadAt: pgtype.Timestamptz{Valid: false},
	}

	// Act
	view := mapBroadcastNoticeView(row)

	// Assert
	if view.ReadAt.IsSet() {
		t.Fatalf("ReadAt = %#v, want unset", view.ReadAt)
	}
}

func TestMapBroadcastNoticeView_ShouldReturnReadAtWhenReceiptIsRead(t *testing.T) {
	// Arrange
	readAt := time.Date(2026, 7, 20, 1, 2, 3, 0, time.UTC)
	row := db.ListAnnouncementViewsByCampAndTrackRow{ID: "notice-1", CampID: "camp-1", ReadAt: pgtype.Timestamptz{Time: readAt, Valid: true}}

	// Act
	view := mapBroadcastNoticeView(row)

	// Assert
	actual, ok := view.ReadAt.Value()
	if !ok || !actual.Equal(readAt) {
		t.Fatalf("ReadAt = %v, %v; want %v", actual, ok, readAt)
	}
}
