package web

import (
	"context"
	"net/http"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/usecase"

	"github.com/labstack/echo/v4"
)

type BadgeHandler struct {
	badgeUC *usecase.BadgeService
	groupUC *usecase.GroupService
	camps   usecase.CampRepository
}

type BadgeResponse struct {
	ID              string  `json:"id" format:"uuid"`
	ShortID         string  `json:"shortId" example:"B-0042"`
	QRPayload       string  `json:"qrPayload"`
	Status          string  `json:"status" enums:"UNASSIGNED,ASSIGNED"`
	AssignedGroupID *string `json:"assignedGroupId,omitempty" format:"uuid"`
}

// @name BadgeResponse

func NewBadgeHandler(
	badgeUC *usecase.BadgeService,
	groupUC *usecase.GroupService,
	camps usecase.CampRepository,
) *BadgeHandler {
	return &BadgeHandler{
		badgeUC: badgeUC,
		groupUC: groupUC,
		camps:   camps,
	}
}

// getActiveCamp is a helper to find the currently active camp
func (h *BadgeHandler) getActiveCamp(ctx context.Context) (*domain.Camp, error) {
	camps, err := h.camps.List(ctx)
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

func mapBadgeToDTO(b *domain.Badge) BadgeResponse {
	res := BadgeResponse{
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
// @Success      200 {array} BadgeResponse
// @Router       /badges [get]
func (h *BadgeHandler) ListBadges(c echo.Context) error {
	badges, err := h.badgeUC.ListBadges(c.Request().Context())
	if err != nil {
		return err
	}
	res := make([]BadgeResponse, len(badges))
	for i, b := range badges {
		res[i] = mapBadgeToDTO(b)
	}
	return c.JSON(http.StatusOK, res)
}

type BulkGenerateBadgesRequest struct {
	Count int `json:"count"`
}

// @name BulkGenerateBadgesRequest

// @Summary      초기 배지 일괄 생성
// @Description  특정 개수만큼 QR 배지를 대량으로 일괄 발급한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Accept       json
// @Produce      json
// @Param        request body BulkGenerateBadgesRequest true "생성할 개수"
// @Success      201 {array} BadgeResponse
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
	res := make([]BadgeResponse, len(badges))
	for i, b := range badges {
		res[i] = mapBadgeToDTO(b)
	}
	return c.JSON(http.StatusCreated, res)
}

type ExportBadgesResponse struct {
	Badges []BadgeResponse `json:"badges"`
}

// @name ExportBadgesResponse

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
	res := make([]BadgeResponse, len(badges))
	for i, b := range badges {
		res[i] = mapBadgeToDTO(b)
	}
	return c.JSON(http.StatusOK, ExportBadgesResponse{Badges: res})
}

type AssignBadgeRequest struct {
	GroupID string `json:"groupId"`
}

// @name AssignBadgeRequest

// @Summary      배지를 특정 조에 배정 (수동)
// @Description  수동으로 특정 배지를 조회하여 조에 할당한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Accept       json
// @Produce      json
// @Param        id path string true "배지 ID"
// @Param        request body AssignBadgeRequest true "배정할 조 ID"
// @Success      200 {object} BadgeResponse
// @Router       /badges/{id}/register [post]
func (h *BadgeHandler) AssignBadge(c echo.Context) error {
	id := domain.BadgeID(c.Param("id"))
	var req struct {
		GroupName string `json:"groupName"`
	}
	if err := c.Bind(&req); err != nil {
		return err
	}

	camp, err := h.getActiveCamp(c.Request().Context())
	if err != nil {
		return err
	}
	if camp == nil {
		return echo.NewHTTPError(http.StatusNotFound, "active camp not found")
	}

	// We need a badge's QRPayload to use GroupService.RegisterBadge, or we add RegisterBadgeByID to GroupService.
	// Since GroupService.RegisterBadge uses qrPayload, let's get the badge first.
	badges, err := h.badgeUC.ListBadges(c.Request().Context())
	if err != nil {
		return err
	}
	var qrPayload string
	for _, b := range badges {
		if b.ID == id {
			qrPayload = b.QRPayload
			break
		}
	}
	if qrPayload == "" {
		return echo.ErrNotFound
	}

	group, err := h.groupUC.RegisterBadge(c.Request().Context(), camp.ID, qrPayload, req.GroupName)
	if err != nil {
		return err
	}

	return c.JSON(http.StatusCreated, mapGroupToDTO(group))
}

type ScanAssignBadgeRequest struct {
	QRPayload string `json:"qrPayload"`
	GroupName string `json:"groupName"`
}

// @name ScanAssignBadgeRequest

// @Summary      배지를 특정 조에 배정 (스캔 기반)
// @Description  QR 코드를 스캔하여 배지를 특정 조에 등록(매핑)한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Accept       json
// @Produce      json
// @Param        request body ScanAssignBadgeRequest true "매핑 정보"
// @Success      201 {object} GroupResponse
// @Router       /badges/scan-register [post]
func (h *BadgeHandler) ScanAssignBadge(c echo.Context) error {
	var req ScanAssignBadgeRequest
	if err := c.Bind(&req); err != nil {
		return err
	}

	camp, err := h.getActiveCamp(c.Request().Context())
	if err != nil {
		return err
	}
	if camp == nil {
		return echo.NewHTTPError(http.StatusNotFound, "active camp not found")
	}

	group, err := h.groupUC.RegisterBadge(c.Request().Context(), camp.ID, req.QRPayload, req.GroupName)
	if err != nil {
		return err
	}

	return c.JSON(http.StatusCreated, mapGroupToDTO(group))
}
