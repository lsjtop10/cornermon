package handler

import (
	"net/http"

	"cornermon/backend/internal/interfaces/http/dto"
	"github.com/labstack/echo/v4"
)

type ReportHandler struct {
}

func NewReportHandler() *ReportHandler {
	return &ReportHandler{}
}

// @Summary      라이브 서머리 (대시보드 상단)
// @Description  전체 진행 상황(완주율 등)의 핵심 요약 정보를 반환한다.
// @Tags         D. Report
// @Security     AdminAuth
// @Produce      json
// @Success      200 {object} dto.CampSummaryStats
// @Router       /reports/live-summary [get]
func (h *ReportHandler) LiveSummary(c echo.Context) error {
	return c.JSON(http.StatusOK, dto.CampSummaryStats{})
}

// @Summary      현재 리포트 전체 조회
// @Description  현재 활성화된 캠프의 상세 통계(CampReport)를 반환한다.
// @Tags         D. Report
// @Security     AdminAuth
// @Produce      json
// @Success      200 {object} dto.CampReport
// @Router       /reports/current [get]
func (h *ReportHandler) GetCurrentReport(c echo.Context) error {
	return c.JSON(http.StatusOK, dto.CampReport{})
}

// @Summary      과거 리포트 생성 및 저장
// @Description  캠프가 종료될 때 최종 리포트를 생성하여 저장소에 보관한다.
// @Tags         D. Report
// @Security     AdminAuth
// @Produce      json
// @Success      201 {object} dto.CampReport
// @Router       /reports/generate [post]
func (h *ReportHandler) GenerateReport(c echo.Context) error {
	return c.JSON(http.StatusCreated, dto.CampReport{})
}

// @Summary      현재 리포트 데이터 내보내기
// @Description  현재 캠프 리포트를 CSV(또는 지정된 포맷)로 다운로드한다.
// @Tags         D. Report
// @Security     AdminAuth
// @Produce      text/csv
// @Success      200 "CSV 데이터"
// @Router       /reports/current/export [get]
func (h *ReportHandler) ExportCurrentReport(c echo.Context) error {
	return c.String(http.StatusOK, "csv_data")
}
