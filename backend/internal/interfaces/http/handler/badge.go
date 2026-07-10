package handler

import (
	"net/http"

	"cornermon/backend/internal/interfaces/http/dto"
	"github.com/labstack/echo/v4"
)

type BadgeHandler struct {
}

func NewBadgeHandler() *BadgeHandler {
	return &BadgeHandler{}
}

// @Summary      전체 배지 목록 조회
// @Description  시스템에 존재하는 전체 배지 목록을 조회한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Produce      json
// @Success      200 {array} dto.Badge
// @Router       /badges [get]
func (h *BadgeHandler) ListBadges(c echo.Context) error {
	return c.JSON(http.StatusOK, []dto.Badge{})
}

type BulkGenerateBadgesRequest struct {
	Count int `json:"count"`
}

// @Summary      초기 배지 일괄 생성
// @Description  특정 개수만큼 QR 배지를 대량으로 일괄 발급한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Accept       json
// @Produce      json
// @Param        request body BulkGenerateBadgesRequest true "생성할 개수"
// @Success      201 {array} dto.Badge
// @Router       /badges/bulk-generate [post]
func (h *BadgeHandler) BulkGenerateBadges(c echo.Context) error {
	return c.JSON(http.StatusCreated, []dto.Badge{})
}

// @Summary      QR 배지 인쇄용 목록 내보내기
// @Description  인쇄소에 넘길 수 있도록 배지의 payload와 숏 코드를 CSV 형식으로 다운로드한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Produce      text/csv
// @Success      200 "CSV 데이터"
// @Router       /badges/export [get]
func (h *BadgeHandler) ExportBadges(c echo.Context) error {
	return c.String(http.StatusOK, "csv")
}

type AssignBadgeRequest struct {
	GroupID string `json:"groupId"`
}

// @Summary      배지를 특정 조에 배정 (수동)
// @Description  수동으로 특정 배지를 조회하여 조에 할당한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Accept       json
// @Produce      json
// @Param        id path string true "배지 ID"
// @Param        request body AssignBadgeRequest true "배정할 조 ID"
// @Success      200 {object} dto.Badge
// @Router       /badges/{id}/register [post]
func (h *BadgeHandler) AssignBadge(c echo.Context) error {
	return c.JSON(http.StatusOK, dto.Badge{})
}

type ScanAssignBadgeRequest struct {
	QRPayload string `json:"qrPayload"`
	GroupID   string `json:"groupId"`
}

// @Summary      배지를 특정 조에 배정 (스캔 기반)
// @Description  QR 코드를 스캔하여 배지를 특정 조에 등록(매핑)한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Accept       json
// @Produce      json
// @Param        request body ScanAssignBadgeRequest true "매핑 정보"
// @Success      200 {object} dto.Badge
// @Router       /badges/scan-register [post]
func (h *BadgeHandler) ScanAssignBadge(c echo.Context) error {
	return c.JSON(http.StatusOK, dto.Badge{})
}
