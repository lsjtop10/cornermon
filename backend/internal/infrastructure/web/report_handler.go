package web

import (
	"errors"
	"net/http"
	"sort"
	"time"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/usecase"

	"github.com/labstack/echo/v4"
)

type ReportHandler struct {
	reportService *usecase.ReportService
	querier       usecase.ReportQuerier
}

type TimelineStatsResponse struct {
	Buckets []TimelineBucketResponse `json:"buckets"`
} // @name TimelineStatsResponse

type TimelineBucketResponse struct {
	BucketStart         time.Time `json:"bucketStart" format:"date-time"`
	InProgressCount     int       `json:"inProgressCount"`
	CumulativeCompleted int       `json:"cumulativeCompleted"`
} // @name TimelineBucketResponse

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
	AvgDurationSeconds  *float32                 `json:"avgDurationSeconds,omitempty"`
	AvgDeviationSeconds *float32                 `json:"avgDeviationSeconds,omitempty"`
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

	bottleneckRanking := make([]BottleneckRankingResponse, 0, len(r.CornerReports))
	for _, cr := range r.CornerReports {
		bottleneckRanking = append(bottleneckRanking, BottleneckRankingResponse{
			CornerID:            string(cr.CornerID),
			CornerName:          cr.CornerName,
			AvgDeviationSeconds: float32(cr.AvgDeviationSec),
		})
	}
	// 컷오프 없이 전체 코너를 평균편차 내림차순으로 보여준다(analytics-model.md §1.1) — 실시간
	// 대시보드의 "병목" 이진 판정(표본/비율 임계치)과는 별개 지표다.
	sort.SliceStable(bottleneckRanking, func(i, j int) bool {
		return bottleneckRanking[i].AvgDeviationSeconds > bottleneckRanking[j].AvgDeviationSeconds
	})

	return CampSummaryStatsResponse{
		TotalGroups:            r.TotalGroups,
		FinishedGroupCount:     r.FinishedGroups,
		CompletionRate:         completionRate,
		TotalVisits:            r.TotalVisits,
		VisitCompletionRate:    visitCompletionRate,
		ProgramDurationSeconds: r.ProgramDurationSec,
		AvgDeviationSeconds:    float32(r.AvgDeviationSec),
		ManualVisitRatio:       manualVisitRatio,
		RuleOverrideCount:      r.RuleOverrideCount,
		TrackOperationCount:    r.TrackOperationCount,
		// ExceptionApprovalCount: 중복 방문 예외 승인 기능은 #171 이전에 전방위로 삭제되어
		// 집계할 원장 데이터가 없다(missing_features_report_20260711.md §3.1). 항상 0.
		ExceptionApprovalCount: 0,
		BottleneckRanking:      bottleneckRanking,
	}
}

// mapReport maps usecase.CampReport to CampReportResponse.
func mapReport(r *usecase.CampReport) CampReportResponse {
	res := CampReportResponse{
		CampID:  string(r.CampID),
		Summary: mapSummary(r),
	}

	for _, cr := range r.CornerReports {
		var avgDurationSeconds, avgDeviationSeconds *float32
		if cr.CompletedCount > 0 {
			avgDuration := float32(cr.AvgDurationSec)
			avgDeviation := float32(cr.AvgDeviationSec)
			avgDurationSeconds = &avgDuration
			avgDeviationSeconds = &avgDeviation
		}
		res.CornerStats = append(res.CornerStats, CornerStatsResponse{
			CornerID:            string(cr.CornerID),
			CornerName:          cr.CornerName,
			CompletedVisitCount: cr.CompletedCount,
			AvgDurationSeconds:  avgDurationSeconds,
			AvgDeviationSeconds: avgDeviationSeconds,
			OverDeviationRatio:  float32(cr.PositiveDeviationRatio),
		})
	}
	for _, gr := range r.GroupReports {
		res.GroupStats = append(res.GroupStats, GroupStatsResponse{
			GroupID:              string(gr.GroupID),
			GroupName:            gr.GroupName,
			CompletedCount:       gr.CompletedCount,
			TotalDurationSeconds: gr.TotalDurationSec,
		})
	}
	for _, tr := range r.TrackReports {
		manualVisitRatio := float32(0)
		if tr.CompletedCount > 0 {
			manualVisitRatio = float32(tr.ManualCount) / float32(tr.CompletedCount) * 100
		}
		res.TrackStats = append(res.TrackStats, TrackStatsResponse{
			TrackID:             string(tr.TrackID),
			TrackNo:             tr.TrackNo,
			HandledVisitCount:   tr.CompletedCount,
			AvgDeviationSeconds: int(tr.AvgDeviationSec),
			ManualVisitRatio:    manualVisitRatio,
		})
	}
	timelineBuckets := make([]TimelineBucketResponse, 0, len(r.Timeline))
	for _, b := range r.Timeline {
		timelineBuckets = append(timelineBuckets, TimelineBucketResponse{
			BucketStart:         b.BucketStart,
			InProgressCount:     b.InProgressCount,
			CumulativeCompleted: b.CumulativeCompleted,
		})
	}
	res.Timeline = TimelineStatsResponse{Buckets: timelineBuckets}
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
		return echo.NewHTTPError(http.StatusNotFound, ErrorResponse{Code: CodeCampNotFound, Message: "camp not found"}).SetInternal(err)
	case errors.Is(err, domain.ErrCampInvalidTransition):
		return echo.NewHTTPError(http.StatusConflict, ErrorResponse{Code: CodeCampNotEnded, Message: "camp must be ended before report generation"}).SetInternal(err)
	default:
		return err
	}
}
