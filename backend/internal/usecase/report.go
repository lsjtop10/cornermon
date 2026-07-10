package usecase

import (
	"context"

	"cornermon/backend/internal/domain"
)

type ReportService struct {
	camps   CampRepository
	querier ReportQuerier
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
		return nil, err
	}
	if camp == nil {
		return nil, domain.ErrCampInvalidTransition
	}

	if camp.Status != domain.CampEnded {
		return nil, domain.ErrCampInvalidTransition
	}

	return s.querier.QueryCampReport(ctx, campID)
}
