//go:build ignore

package postgres

import (
	"encoding/json"
	"testing"
	"time"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/infrastructure/postgres/db"
	"cornermon/backend/internal/usecase"
	"github.com/jackc/pgx/v5/pgtype"
)

func TestCalculateCampReport(t *testing.T) {
	t.Run("ShouldCalculateReportSuccessfullyWhenMockDataProvided", func(t *testing.T) {
		// Arrange
		campID := domain.CampID("camp-1")

		iti1, _ := json.Marshal([]domain.CornerProgress{
			{CornerID: "corner-1", Status: domain.VisitCompleted},
			{CornerID: "corner-2", Status: domain.VisitCompleted},
		})
		iti2, _ := json.Marshal([]domain.CornerProgress{
			{CornerID: "corner-1", Status: domain.VisitCompleted},
			{CornerID: "corner-2", Status: domain.VisitInProgress},
		})

		dbGroups := []db.Group{
			{ID: "group-1", CampID: "camp-1", Name: "조 1", BadgeID: "badge-1", Itinerary: iti1},
			{ID: "group-2", CampID: "camp-1", Name: "조 2", BadgeID: "badge-2", Itinerary: iti2},
		}

		dbCorners := []db.Corner{
			{ID: "corner-1", CampID: "camp-1", Name: "코너 1", TargetMinutes: 10},
			{ID: "corner-2", CampID: "camp-1", Name: "코너 2", TargetMinutes: 15},
		}

		now := time.Now()
		dbVisits := []db.ListVisitsByCampRow{
			{
				ID:            "visit-1",
				GroupID:       "group-1",
				CornerID:      "corner-1",
				TrackID:       "track-1",
				Status:        "COMPLETED",
				InputMethod:   "QR_SCAN",
				StartedAt:     pgtype.Timestamptz{Time: now.Add(-15 * time.Minute), Valid: true},
				EndedAt:       pgtype.Timestamptz{Time: now.Add(-5 * time.Minute), Valid: true},
				TargetMinutes: 10,
				CornerName:    "코너 1",
			},
			{
				ID:            "visit-2",
				GroupID:       "group-1",
				CornerID:      "corner-2",
				TrackID:       "track-2",
				Status:        "COMPLETED",
				InputMethod:   "MANUAL",
				StartedAt:     pgtype.Timestamptz{Time: now.Add(-20 * time.Minute), Valid: true},
				EndedAt:       pgtype.Timestamptz{Time: now.Add(-2 * time.Minute), Valid: true},
				TargetMinutes: 15,
				CornerName:    "코너 2",
			},
			{
				ID:            "visit-3",
				GroupID:       "group-2",
				CornerID:      "corner-1",
				TrackID:       "track-1",
				Status:        "COMPLETED",
				InputMethod:   "QR_SCAN",
				StartedAt:     pgtype.Timestamptz{Time: now.Add(-10 * time.Minute), Valid: true},
				EndedAt:       pgtype.Timestamptz{Time: now.Add(-2 * time.Minute), Valid: true},
				TargetMinutes: 10,
				CornerName:    "코너 1",
			},
		}

		// Act
		report, err := calculateCampReport(campID, dbGroups, dbCorners, dbVisits)

		// Assert
		if err != nil {
			t.Fatalf("expected no error, got %v", err)
		}
		if report == nil {
			t.Fatal("expected report, got nil")
		}

		if report.TotalGroups != 2 {
			t.Errorf("expected TotalGroups 2, got %d", report.TotalGroups)
		}
		if report.FinishedGroups != 1 {
			t.Errorf("expected FinishedGroups 1, got %d", report.FinishedGroups)
		}

		if report.TotalVisits != 3 {
			t.Errorf("expected TotalVisits 3, got %d", report.TotalVisits)
		}
		if report.CompletedVisits != 3 {
			t.Errorf("expected CompletedVisits 3, got %d", report.CompletedVisits)
		}
		if report.ManualVisits != 1 {
			t.Errorf("expected ManualVisits 1, got %d", report.ManualVisits)
		}

		var c1Report usecase.CornerReport
		for _, cr := range report.CornerReports {
			if cr.CornerID == "corner-1" {
				c1Report = cr
			}
		}
		if c1Report.CompletedCount != 2 {
			t.Errorf("expected corner-1 CompletedCount 2, got %d", c1Report.CompletedCount)
		}
		if c1Report.AvgDurationSec != 540 {
			t.Errorf("expected AvgDurationSec 540, got %f", c1Report.AvgDurationSec)
		}
		if c1Report.AvgDeviationSec != -60 {
			t.Errorf("expected AvgDeviationSec -60, got %f", c1Report.AvgDeviationSec)
		}
	})
}
