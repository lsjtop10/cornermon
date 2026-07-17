
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
