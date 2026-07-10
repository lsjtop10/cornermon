package handler

import (
	"net/http"

	"github.com/labstack/echo/v4"
)

type ReportHandler struct {
	// reportUC ReportUsecase
}

func NewReportHandler() *ReportHandler {
	return &ReportHandler{}
}

// @Summary      현재 캠프 리포트 조회
// @Description  현재 캠프의 진행 현황 리포트를 조회한다.
// @Tags         D. Report
// @Security     AdminAuth
// @Produce      json
// @Success      200 "리포트 반환"
// @Router       /api/v1/reports/current [get]
func (h *ReportHandler) GetCurrentReport(c echo.Context) error {
	return c.JSON(http.StatusOK, map[string]string{"status": "ok"})
}
