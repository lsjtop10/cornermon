package usecase

import (
	"context"

	"cornermon/backend/internal/domain"
)

type ReportService struct {
	camps   CampRepository
	querier ReportQuerier
}

// GetCampReport returns the aggregate for the explicitly selected camp.
// Report reads are available for every camp state; only final report generation
// is restricted to ended camps.
func (s *ReportService) GetCampReport(
	ctx context.Context,
	campID domain.CampID,
) (*CampReport, error) {

	camp, err := s.camps.Get(ctx, campID)
	if err != nil {
		return nil, withErrorContext("report.get", "repository.get_camp", err, map[string]any{"camp_id": string(campID)})
	}
	if camp == nil {
		return nil, withErrorContext("report.get", "validate_camp", domain.ErrCampNotFound, map[string]any{"camp_id": string(campID), "camp_found": false})
	}
	report, err := s.querier.QueryCampReport(ctx, campID)
	if err != nil {
		return nil, withErrorContext("report.get", "query.camp_report", err, map[string]any{"camp_id": string(campID)})
	}
	return report, nil
}

func NewReportService(
	camps CampRepository,
	querier ReportQuerier,
) *ReportService {
	return &ReportService{
		camps:   camps,
		querier: querier,
	}
}

// GenerateCampReport - UC-24
func (s *ReportService) GenerateCampReport(
	ctx context.Context,
	campID domain.CampID,
) (*CampReport, error) {

	camp, err := s.camps.Get(ctx, campID)
	if err != nil {
		return nil, withErrorContext("report.generate", "repository.get_camp", err, map[string]any{"camp_id": string(campID)})
	}
	if camp == nil {
		return nil, withErrorContext("report.generate", "validate_camp", domain.ErrCampNotFound, map[string]any{"camp_id": string(campID), "camp_found": false})
	}

	if camp.Status() != domain.CampEnded {
		return nil, withErrorContext("report.generate", "validate_camp_status", domain.ErrCampInvalidTransition, map[string]any{"camp_id": string(campID), "camp_status": string(camp.Status())})
	}

	report, err := s.querier.QueryCampReport(ctx, campID)
	if err != nil {
		return nil, withErrorContext("report.generate", "query.camp_report", err, map[string]any{"camp_id": string(campID)})
	}
	return report, nil
}
