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
		camp := domain.NewCampFromProps(domain.CampProps{ID: "camp-1", Status: domain.CampEnded})
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
		camp := domain.NewCampFromProps(domain.CampProps{ID: "camp-1", Status: domain.CampActive})
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

func TestGetCampReportShoudQueryExplicitCampWhenAnyState(t *testing.T) {
	states := []domain.CampStatus{domain.CampPending, domain.CampActive, domain.CampEnded}
	for _, state := range states {
		t.Run(string(state), func(t *testing.T) {
			// Arrange
			camps := NewMockCampRepository()
			camps.Camps["camp-selected"] = domain.NewCampFromProps(domain.CampProps{ID: "camp-selected", Status: state})
			querier := &MockReportQuerier{ReportToReturn: &CampReport{CampID: "camp-selected"}}
			service := NewReportService(camps, querier)

			// Act
			report, err := service.GetCampReport(context.Background(), "camp-selected")

			// Assert
			if err != nil {
				t.Fatalf("unexpected error: %v", err)
			}
			if report.CampID != "camp-selected" {
				t.Fatalf("unexpected camp report: %s", report.CampID)
			}
		})
	}
}

func TestGetCampReportShoudReturnNotFoundWhenCampDoesNotExist(t *testing.T) {
	// Arrange
	service := NewReportService(NewMockCampRepository(), &MockReportQuerier{})

	// Act
	_, err := service.GetCampReport(context.Background(), "missing")

	// Assert
	if err != domain.ErrCampNotFound {
		t.Fatalf("expected ErrCampNotFound, got %v", err)
	}
}
