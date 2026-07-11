package web

import (
	"net/http"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/usecase"

	"github.com/labstack/echo/v4"
)

type BadgeHandler struct {
	badgeUC *usecase.BadgeService
}

func NewBadgeHandler(badgeUC *usecase.BadgeService) *BadgeHandler {
	return &BadgeHandler{badgeUC: badgeUC}
}

func mapBadgeToDTO(b *domain.Badge) Badge {
	res := Badge{
		ID:        string(b.ID),
		ShortID:   b.ShortID,
		QRPayload: b.QRPayload,
		Status:    string(b.Status),
	}
	if gid, ok := b.AssignedGroupID.Value(); ok {
		s := string(gid)
		res.AssignedGroupID = &s
	}
	return res
}

// @Summary      전체 배지 목록 조회
// @Description  시스템에 존재하는 전체 배지 목록을 조회한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Produce      json
// @Success      200 {array} Badge
// @Router       /badges [get]
func (h *BadgeHandler) ListBadges(c echo.Context) error {
	badges, err := h.badgeUC.ListBadges(c.Request().Context())
	if err != nil {
		return err
	}
	res := make([]Badge, len(badges))
	for i, b := range badges {
		res[i] = mapBadgeToDTO(b)
	}
	return c.JSON(http.StatusOK, res)
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
// @Success      201 {array} Badge
// @Router       /badges/bulk-generate [post]
func (h *BadgeHandler) BulkGenerateBadges(c echo.Context) error {
	var req BulkGenerateBadgesRequest
	if err := c.Bind(&req); err != nil {
		return err
	}
	badges, err := h.badgeUC.IssueInitialBadges(c.Request().Context(), req.Count)
	if err != nil {
		return err
	}
	res := make([]Badge, len(badges))
	for i, b := range badges {
		res[i] = mapBadgeToDTO(b)
	}
	return c.JSON(http.StatusCreated, res)
}

type ExportBadgesResponse struct {
	Badges []Badge `json:"badges"`
}

// @Summary      QR 배지 인쇄용 목록 내보내기 (JSON)
// @Description  클라이언트가 직접 PDF 인쇄 및 레이아웃 구성을 할 수 있도록 미배정(UNASSIGNED) 배지 전체 목록을 JSON으로 다운로드한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Produce      json
// @Success      200 {object} ExportBadgesResponse "미배정 배지 목록"
// @Router       /badges/export [get]
func (h *BadgeHandler) ExportBadges(c echo.Context) error {
	badges, err := h.badgeUC.ExportBadges(c.Request().Context())
	if err != nil {
		return err
	}
	res := make([]Badge, len(badges))
	for i, b := range badges {
		res[i] = mapBadgeToDTO(b)
	}
	return c.JSON(http.StatusOK, ExportBadgesResponse{Badges: res})
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
// @Success      200 {object} Badge
// @Router       /badges/{id}/register [post]
func (h *BadgeHandler) AssignBadge(c echo.Context) error {
	return echo.NewHTTPError(http.StatusNotImplemented, "Not implemented yet")
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
// @Success      200 {object} Badge
// @Router       /badges/scan-register [post]
func (h *BadgeHandler) ScanAssignBadge(c echo.Context) error {
	return echo.NewHTTPError(http.StatusNotImplemented, "Not implemented yet")
}
