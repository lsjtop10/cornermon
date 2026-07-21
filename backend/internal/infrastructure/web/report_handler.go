package web

import (
	"errors"
	"net/http"
	"time"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/usecase"

	"github.com/labstack/echo/v4"
)

type ReportHandler struct {
	reportService *usecase.ReportService
	querier       usecase.ReportQuerier
}

type TimelineStatsResponse struct{} // @name TimelineStatsResponse

type OperationalStatsResponse struct{} // @name OperationalStatsResponse

type TrackStatsResponse struct {
	TrackID             string  `json:"trackId" format:"uuid"`
	TrackNo             int     `json:"trackNo"`
	HandledVisitCount   int     `json:"handledVisitCount"`
	AvgDeviationSeconds int     `json:"avgDeviationSeconds"`
	ManualVisitRatio    float32 `json:"manualVisitRatio"`
} // @name TrackStatsResponse

type CornerStatsResponse struct {
	CornerID            string                   `json:"cornerId" format:"uuid"`
	CornerName          string                   `json:"cornerName"`
	CompletedVisitCount int                      `json:"completedVisitCount"`
	OverDeviationRatio  float32                  `json:"overDeviationRatio"`
	UnvisitedGroups     []UnvisitedGroupResponse `json:"unvisitedGroups"`
} // @name CornerStatsResponse

type UnvisitedGroupResponse struct {
	GroupID   string `json:"groupId" format:"uuid"`
	GroupName string `json:"groupName"`
} // @name UnvisitedGroupResponse

type GroupStatsResponse struct {
	GroupID              string `json:"groupId" format:"uuid"`
	GroupName            string `json:"groupName"`
	CompletedCount       int    `json:"completedCount"`
	TotalDurationSeconds int    `json:"totalDurationSeconds"`
} // @name GroupStatsResponse

type CampSummaryStatsResponse struct {
	TotalGroups            int                         `json:"totalGroups"`
	FinishedGroupCount     int                         `json:"finishedGroupCount"`
	CompletionRate         float32                     `json:"completionRate"`
	TotalVisits            int                         `json:"totalVisits"`
	VisitCompletionRate    float32                     `json:"visitCompletionRate"`
	ProgramDurationSeconds int                         `json:"programDurationSeconds"`
	AvgDeviationSeconds    float32                     `json:"avgDeviationSeconds"`
	ManualVisitRatio       float32                     `json:"manualVisitRatio"`
	RuleOverrideCount      int                         `json:"ruleOverrideCount"`
	TrackOperationCount    int                         `json:"trackOperationCount"`
	ExceptionApprovalCount int                         `json:"exceptionApprovalCount"`
	BottleneckRanking      []BottleneckRankingResponse `json:"bottleneckRanking"`
} // @name CampSummaryStatsResponse

type BottleneckRankingResponse struct {
	CornerID            string  `json:"cornerId" format:"uuid"`
	CornerName          string  `json:"cornerName"`
	AvgDeviationSeconds float32 `json:"avgDeviationSeconds"`
} // @name BottleneckRankingResponse

type CampReportResponse struct {
	CampID           string                   `json:"campId" format:"uuid"`
	GeneratedAt      time.Time                `json:"generatedAt" format:"date-time"`
	Summary          CampSummaryStatsResponse `json:"summary"`
	CornerStats      []CornerStatsResponse    `json:"cornerStats"`
	TrackStats       []TrackStatsResponse     `json:"trackStats"`
	GroupStats       []GroupStatsResponse     `json:"groupStats"`
	Timeline         TimelineStatsResponse    `json:"timeline"`
	OperationalStats OperationalStatsResponse `json:"operationalStats"`
} // @name CampReportResponse

func NewReportHandler(
	reportService *usecase.ReportService,
	querier usecase.ReportQuerier,
	camps usecase.CampRepository,
) *ReportHandler {
	return &ReportHandler{
		reportService: reportService,
		querier:       querier,
	}
}

// mapSummary maps usecase.CampReport to CampSummaryStatsResponse.
func mapSummary(r *usecase.CampReport) CampSummaryStatsResponse {
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

	return CampSummaryStatsResponse{
		TotalGroups:         r.TotalGroups,
		FinishedGroupCount:  r.FinishedGroups,
		CompletionRate:      completionRate,
		TotalVisits:         r.TotalVisits,
		VisitCompletionRate: visitCompletionRate,
		ManualVisitRatio:    manualVisitRatio,
	}
}

// mapReport maps usecase.CampReport to CampReportResponse.
func mapReport(r *usecase.CampReport) CampReportResponse {
	res := CampReportResponse{
		CampID:  string(r.CampID),
		Summary: mapSummary(r),
	}

	for _, cr := range r.CornerReports {
		res.CornerStats = append(res.CornerStats, CornerStatsResponse{
			CornerID:            string(cr.CornerID),
			CornerName:          cr.CornerName,
			CompletedVisitCount: cr.CompletedCount,
			OverDeviationRatio:  float32(cr.PositiveDeviationRatio),
		})
	}
	for _, gr := range r.GroupReports {
		res.GroupStats = append(res.GroupStats, GroupStatsResponse{
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
// @Param        campId path string true "캠프 ID"
// @Success      200 {object} CampSummaryStatsResponse
// @Failure      404 {object} ErrorResponse "CAMP_NOT_FOUND: 캠프가 없음"
// @Router       /camps/{campId}/reports/live-summary [get]
func (h *ReportHandler) LiveSummary(c echo.Context) error {
	campID := domain.CampID(c.Param("campId"))
	report, err := h.reportService.GetCampReport(c.Request().Context(), campID)
	if err != nil {
		return reportHTTPError(err)
	}

	return c.JSON(http.StatusOK, mapSummary(report))
}

// @Summary      현재 리포트 전체 조회
// @Description  현재 활성화된 캠프의 상세 통계(CampReport)를 반환한다.
// @Tags         D. Report
// @Security     AdminAuth
// @Produce      json
// @Param        campId path string true "캠프 ID"
// @Success      200 {object} CampReportResponse
// @Failure      404 {object} ErrorResponse "CAMP_NOT_FOUND: 캠프가 없음"
// @Router       /camps/{campId}/reports/current [get]
func (h *ReportHandler) GetCurrentReport(c echo.Context) error {
	campID := domain.CampID(c.Param("campId"))
	report, err := h.reportService.GetCampReport(c.Request().Context(), campID)
	if err != nil {
		return reportHTTPError(err)
	}

	return c.JSON(http.StatusOK, mapReport(report))
}

// @Summary      과거 리포트 생성 및 저장
// @Description  캠프가 종료될 때 최종 리포트를 생성하여 저장소에 보관한다.
// @Tags         D. Report
// @Security     AdminAuth
// @Produce      json
// @Param        campId path string true "캠프 ID"
// @Success      201 {object} CampReportResponse
// @Failure      404 {object} ErrorResponse "CAMP_NOT_FOUND: 캠프가 없음"
// @Failure      409 {object} ErrorResponse "CAMP_NOT_ENDED: 종료된 캠프에서만 최종 리포트를 생성할 수 있음"
// @Router       /camps/{campId}/reports/generate [post]
func (h *ReportHandler) GenerateReport(c echo.Context) error {
	campID := domain.CampID(c.Param("campId"))
	report, err := h.reportService.GenerateCampReport(c.Request().Context(), campID)
	if err != nil {
		return reportHTTPError(err)
	}

	return c.JSON(http.StatusCreated, mapReport(report))
}

// @Summary      현재 리포트 데이터 내보내기
// @Description  현재 캠프 리포트를 다운로드한다.
// @Tags         D. Report
// @Security     AdminAuth
// @Produce      json
// @Param        campId path string true "캠프 ID"
// @Success      200 {object} CampReportResponse
// @Failure      404 {object} ErrorResponse "CAMP_NOT_FOUND: 캠프가 없음"
// @Router       /camps/{campId}/reports/current/export [get]
func (h *ReportHandler) ExportCurrentReport(c echo.Context) error {
	campID := domain.CampID(c.Param("campId"))
	report, err := h.reportService.GetCampReport(c.Request().Context(), campID)
	if err != nil {
		return reportHTTPError(err)
	}

	// Just return JSON as per the updated spec
	return c.JSON(http.StatusOK, mapReport(report))
}

func reportHTTPError(err error) error {
	switch {
	case errors.Is(err, domain.ErrCampNotFound):
		return echo.NewHTTPError(http.StatusNotFound, ErrorResponse{Code: "CAMP_NOT_FOUND", Message: "camp not found"}).SetInternal(err)
	case errors.Is(err, domain.ErrCampInvalidTransition):
		return echo.NewHTTPError(http.StatusConflict, ErrorResponse{Code: "CAMP_NOT_ENDED", Message: "camp must be ended before report generation"}).SetInternal(err)
	default:
		return err
	}
}
