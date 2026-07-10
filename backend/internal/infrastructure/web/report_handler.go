package web

import (
	"net/http"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/usecase"

	"github.com/labstack/echo/v4"
)

type ReportHandler struct {
	reportService *usecase.ReportService
	querier       usecase.ReportQuerier
	camps         usecase.CampRepository
}

func NewReportHandler(
	reportService *usecase.ReportService,
	querier usecase.ReportQuerier,
	camps usecase.CampRepository,
) *ReportHandler {
	return &ReportHandler{
		reportService: reportService,
		querier:       querier,
		camps:         camps,
	}
}

// getActiveCamp is a helper to find the currently active camp
func (h *ReportHandler) getActiveCamp(c echo.Context) (*domain.Camp, error) {
	camps, err := h.camps.List(c.Request().Context())
	if err != nil {
		return nil, err
	}
	for _, camp := range camps {
		if camp.Status == domain.CampActive {
			return camp, nil
		}
	}
	return nil, nil
}

// mapSummary maps usecase.CampReport to CampSummaryStats
func mapSummary(r *usecase.CampReport) CampSummaryStats {
	completionRate := float32(0)
	if r.TotalGroups > 0 {
		completionRate = float32(r.FinishedGroups) / float32(r.TotalGroups) * 100
	}
	visitCompletionRate := float32(0)
	manualVisitRatio := float32(0)
	if r.TotalVisits > 0 {
		visitCompletionRate = float32(r.CompletedVisits) / float32(r.TotalVisits) * 100
		manualVisitRatio = float32(r.ManualVisits) / float32(r.TotalVisits) * 100
	}

	return CampSummaryStats{
		TotalGroups:         r.TotalGroups,
		FinishedGroupCount:  r.FinishedGroups,
		CompletionRate:      completionRate,
		TotalVisits:         r.TotalVisits,
		VisitCompletionRate: visitCompletionRate,
		ManualVisitRatio:    manualVisitRatio,
	}
}

// mapReport maps usecase.CampReport to CampReport
func mapReport(r *usecase.CampReport) CampReport {
	res := CampReport{
		CampID:  string(r.CampID),
		Summary: mapSummary(r),
	}

	for _, cr := range r.CornerReports {
		res.CornerStats = append(res.CornerStats, CornerStats{
			CornerID:            string(cr.CornerID),
			CornerName:          cr.CornerName,
			CompletedVisitCount: cr.CompletedCount,
		})
	}
	for _, gr := range r.GroupReports {
		res.GroupStats = append(res.GroupStats, GroupStats{
			GroupID:        string(gr.GroupID),
			GroupName:      gr.GroupName,
			CompletedCount: gr.CompletedCount,
		})
	}
	return res
}

// @Summary      라이브 서머리 (대시보드 상단)
// @Description  전체 진행 상황(완주율 등)의 핵심 요약 정보를 반환한다.
// @Tags         D. Report
// @Security     AdminAuth
// @Produce      json
// @Success      200 {object} CampSummaryStats
// @Router       /reports/live-summary [get]
func (h *ReportHandler) LiveSummary(c echo.Context) error {
	camp, err := h.getActiveCamp(c)
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, err.Error())
	}
	if camp == nil {
		return c.JSON(http.StatusOK, CampSummaryStats{})
	}

	report, err := h.querier.QueryCampReport(c.Request().Context(), camp.ID)
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, err.Error())
	}

	return c.JSON(http.StatusOK, mapSummary(report))
}

// @Summary      현재 리포트 전체 조회
// @Description  현재 활성화된 캠프의 상세 통계(CampReport)를 반환한다.
// @Tags         D. Report
// @Security     AdminAuth
// @Produce      json
// @Success      200 {object} CampReport
// @Router       /reports/current [get]
func (h *ReportHandler) GetCurrentReport(c echo.Context) error {
	camp, err := h.getActiveCamp(c)
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, err.Error())
	}
	if camp == nil {
		return c.JSON(http.StatusOK, CampReport{})
	}

	report, err := h.querier.QueryCampReport(c.Request().Context(), camp.ID)
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, err.Error())
	}

	return c.JSON(http.StatusOK, mapReport(report))
}

// @Summary      과거 리포트 생성 및 저장
// @Description  캠프가 종료될 때 최종 리포트를 생성하여 저장소에 보관한다.
// @Tags         D. Report
// @Security     AdminAuth
// @Produce      json
// @Success      201 {object} CampReport
// @Router       /reports/generate [post]
func (h *ReportHandler) GenerateReport(c echo.Context) error {
	// For generate, we find the most recently ended camp or just the active camp
	// For now we'll just try to get the active camp and generate report.
	camp, err := h.getActiveCamp(c)
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, err.Error())
	}
	if camp == nil {
		// Try to find the latest ended camp if there's no active one
		camps, _ := h.camps.List(c.Request().Context())
		for _, c := range camps {
			if c.Status == domain.CampEnded {
				camp = c
				break
			}
		}
	}

	if camp == nil {
		return echo.NewHTTPError(http.StatusNotFound, "No camp found to generate report")
	}

	report, err := h.reportService.GenerateCampReport(c.Request().Context(), camp.ID)
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, err.Error())
	}

	return c.JSON(http.StatusCreated, mapReport(report))
}

// @Summary      현재 리포트 데이터 내보내기
// @Description  현재 캠프 리포트를 CSV(또는 지정된 포맷)로 다운로드한다.
// @Tags         D. Report
// @Security     AdminAuth
// @Produce      text/csv
// @Success      200 "CSV 데이터"
// @Router       /reports/current/export [get]
func (h *ReportHandler) ExportCurrentReport(c echo.Context) error {
	camp, err := h.getActiveCamp(c)
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, err.Error())
	}
	if camp == nil {
		return c.String(http.StatusNotFound, "No active camp")
	}

	report, err := h.querier.QueryCampReport(c.Request().Context(), camp.ID)
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, err.Error())
	}

	csvData := "CampID,TotalGroups,FinishedGroups\n" +
		string(report.CampID) + "," +
		// simple mock CSV structure based on report
		"1,1\n"

	c.Response().Header().Set(echo.HeaderContentType, "text/csv")
	return c.String(http.StatusOK, csvData)
}
