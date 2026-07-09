package usecase

import (
	"context"
	"testing"

	"cornermon/backend/internal/domain"
)

func TestReportService_GenerateCampReport(t *testing.T) {
	t.Run("ShouldGenerateReportSuccessfullyWhenCampIsEnded", func(t *testing.T) {
		// Arrange
		camps := NewMockCampRepository()
		camp := &domain.Camp{ID: "camp-1", Status: domain.CampEnded}
		camps.Save(context.Background(), camp)

		querier := &MockReportQuerier{
			ReportToReturn: &CampReport{
				CampID:      "camp-1",
				TotalGroups: 5,
			},
		}

		s := NewReportService(camps, querier)

		// Act
		report, err := s.GenerateCampReport(context.Background(), "camp-1")

		// Assert
		if err != nil {
			t.Fatalf("expected no error, got %v", err)
		}
		if report == nil {
			t.Fatal("expected report, got nil")
		}
		if report.TotalGroups != 5 {
			t.Errorf("expected TotalGroups 5, got %d", report.TotalGroups)
		}
	})

	t.Run("ShouldFailGenerateReportWhenCampIsActive", func(t *testing.T) {
		// Arrange
		camps := NewMockCampRepository()
		camp := &domain.Camp{ID: "camp-1", Status: domain.CampActive}
		camps.Save(context.Background(), camp)

		s := NewReportService(camps, &MockReportQuerier{})

		// Act
		_, err := s.GenerateCampReport(context.Background(), "camp-1")

		// Assert
		if err != domain.ErrCampInvalidTransition {
			t.Errorf("expected ErrCampInvalidTransition, got %v", err)
		}
	})
}
