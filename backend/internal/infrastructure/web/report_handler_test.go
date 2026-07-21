package web

import (
	"context"
	"net/http"
	"net/http/httptest"
	"sync"
	"testing"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/usecase"
	"github.com/labstack/echo/v4"
)

type campRepositoryStub struct {
	camps map[domain.CampID]*domain.Camp
}

func (s *campRepositoryStub) Get(_ context.Context, id domain.CampID) (*domain.Camp, error) {
	return s.camps[id], nil
}

func (s *campRepositoryStub) GetByRegistrationCode(_ context.Context, code string) (*domain.Camp, error) {
	for _, camp := range s.camps {
		if camp.RegistrationCode() == code {
			return camp, nil
		}
	}
	return nil, nil
}

func (s *campRepositoryStub) List(context.Context) ([]*domain.Camp, error) { return nil, nil }
func (s *campRepositoryStub) Save(context.Context, *domain.Camp) error     { return nil }

type reportQuerierSpy struct {
	mu      sync.Mutex
	queried map[domain.CampID]int
}

func (s *reportQuerierSpy) QueryCampReport(_ context.Context, campID domain.CampID) (*usecase.CampReport, error) {
	s.mu.Lock()
	s.queried[campID]++
	s.mu.Unlock()
	return &usecase.CampReport{CampID: campID}, nil
}

func TestMapReportShouldMapOverDeviationRatioWhenCornerReportsProvided(t *testing.T) {
	// Arrange
	report := &usecase.CampReport{
		CampID: "camp-1",
		CornerReports: []usecase.CornerReport{
			{CornerID: "corner-1", CornerName: "코너 1", CompletedCount: 3, PositiveDeviationRatio: 2.0 / 3.0},
			{CornerID: "corner-2", CornerName: "코너 2", CompletedCount: 0, PositiveDeviationRatio: 0},
		},
	}

	// Act
	res := mapReport(report)

	// Assert
	if len(res.CornerStats) != 2 {
		t.Fatalf("expected 2 corner stats, got %d", len(res.CornerStats))
	}
	if got := res.CornerStats[0].OverDeviationRatio; got != float32(2.0/3.0) {
		t.Errorf("expected corner-1 OverDeviationRatio %f, got %f", float32(2.0/3.0), got)
	}
	if got := res.CornerStats[1].OverDeviationRatio; got != 0 {
		t.Errorf("expected corner-2 OverDeviationRatio 0, got %f", got)
	}
}

func TestMapReportShouldMapCampAndGroupAggregatesWhenReportProvided(t *testing.T) {
	// Arrange
	report := &usecase.CampReport{
		CampID:             "camp-1",
		ProgramDurationSec: 1200,
		AvgDeviationSec:    60,
		GroupReports: []usecase.GroupReport{
			{GroupID: "group-1", GroupName: "조 1", CompletedCount: 2, TotalDurationSec: 1680},
		},
	}

	// Act
	res := mapReport(report)
	summary := mapSummary(report)

	// Assert
	if summary.ProgramDurationSeconds != 1200 {
		t.Errorf("expected ProgramDurationSeconds 1200, got %d", summary.ProgramDurationSeconds)
	}
	if summary.AvgDeviationSeconds != 60 {
		t.Errorf("expected AvgDeviationSeconds 60, got %f", summary.AvgDeviationSeconds)
	}
	if len(res.GroupStats) != 1 {
		t.Fatalf("expected 1 group stat, got %d", len(res.GroupStats))
	}
	if got := res.GroupStats[0].TotalDurationSeconds; got != 1680 {
		t.Errorf("expected group-1 TotalDurationSeconds 1680, got %d", got)
	}
}

func TestGetCurrentReportShoudKeepCampScopeWhenRequestsRunConcurrently(t *testing.T) {
	// Arrange
	camps := &campRepositoryStub{camps: map[domain.CampID]*domain.Camp{
		"camp-a": domain.NewCampFromProps(domain.CampProps{ID: "camp-a", Status: domain.CampActive}),
		"camp-b": domain.NewCampFromProps(domain.CampProps{ID: "camp-b", Status: domain.CampEnded}),
	}}
	querier := &reportQuerierSpy{queried: make(map[domain.CampID]int)}
	handler := NewReportHandler(usecase.NewReportService(camps, querier), querier, camps)
	e := echo.New()
	var wg sync.WaitGroup

	// Act
	for _, campID := range []string{"camp-a", "camp-b"} {
		campID := campID
		wg.Add(1)
		go func() {
			defer wg.Done()
			req := httptest.NewRequest(http.MethodGet, "/camps/"+campID+"/reports/current", nil)
			rec := httptest.NewRecorder()
			ctx := e.NewContext(req, rec)
			ctx.SetParamNames("campId")
			ctx.SetParamValues(campID)
			if err := handler.GetCurrentReport(ctx); err != nil {
				t.Errorf("request for %s failed: %v", campID, err)
			}
			if rec.Code != http.StatusOK {
				t.Errorf("request for %s returned %d", campID, rec.Code)
			}
		}()
	}
	wg.Wait()

	// Assert
	querier.mu.Lock()
	defer querier.mu.Unlock()
	if querier.queried["camp-a"] != 1 || querier.queried["camp-b"] != 1 {
		t.Fatalf("camp scopes were not isolated: %+v", querier.queried)
	}
}
