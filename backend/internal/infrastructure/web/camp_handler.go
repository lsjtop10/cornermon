package web

import (
	"net/http"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/usecase"

	"github.com/labstack/echo/v4"
)

type CampHandler struct {
	svc *usecase.CampService
}

func NewCampHandler(svc *usecase.CampService) *CampHandler {
	return &CampHandler{svc: svc}
}

func getAdminID(c echo.Context) domain.AdminID {
	val := c.Get("adminId")
	if val != nil {
		if s, ok := val.(string); ok {
			return domain.AdminID(s)
		}
	}
	return domain.AdminID("admin")
}

func mapDomainCampToDTO(camp *domain.Camp) Camp {
	if camp == nil {
		return Camp{}
	}
	return Camp{
		ID:                   string(camp.ID),
		Name:                 camp.Name,
		StartAt:              camp.StartAt,
		EndAt:                camp.EndAt,
		Status:               string(camp.Status),
		BottleneckMinSamples: camp.BottleneckMinSamples,
		BottleneckRatioPct:   camp.BottleneckRatioPct,
	}
}

// @Summary      캠프 목록 조회
// @Description  전체 캠프 목록을 조회한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Produce      json
// @Success      200 {array} Camp
// @Failure      401 {object} ErrorResponse
// @Router       /camps [get]
func (h *CampHandler) ListCamps(c echo.Context) error {
	camps, err := h.svc.ListCamps(c.Request().Context())
	if err != nil {
		return c.JSON(http.StatusInternalServerError, ErrorResponse{Code: "INTERNAL_ERROR", Message: err.Error()})
	}
	res := make([]Camp, len(camps))
	for i, cp := range camps {
		res[i] = mapDomainCampToDTO(cp)
	}
	return c.JSON(http.StatusOK, res)
}

type CreateCampRequest struct {
	Name string `json:"name"`
}

// @Summary      새 캠프 생성
// @Description  새로운 코너학습 캠프를 생성한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Accept       json
// @Produce      json
// @Param        request body CreateCampRequest true "캠프 생성 정보"
// @Success      201 {object} Camp
// @Failure      400 {object} ErrorResponse
// @Failure      401 {object} ErrorResponse
// @Router       /camps [post]
func (h *CampHandler) CreateCamp(c echo.Context) error {
	var req CreateCampRequest
	if err := c.Bind(&req); err != nil {
		return c.JSON(http.StatusBadRequest, ErrorResponse{Code: "BAD_REQUEST", Message: "Invalid request body"})
	}
	camp, err := h.svc.OpenNewCamp(c.Request().Context(), req.Name)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, ErrorResponse{Code: "INTERNAL_ERROR", Message: err.Error()})
	}
	return c.JSON(http.StatusCreated, mapDomainCampToDTO(camp))
}

// @Summary      캠프 상세 조회
// @Description  특정 캠프 정보를 조회한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Produce      json
// @Param        id path string true "캠프 ID"
// @Success      200 {object} Camp
// @Failure      404 {object} ErrorResponse
// @Router       /camps/{id} [get]
func (h *CampHandler) GetCamp(c echo.Context) error {
	id := domain.CampID(c.Param("id"))
	camp, err := h.svc.GetCamp(c.Request().Context(), id)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, ErrorResponse{Code: "INTERNAL_ERROR", Message: err.Error()})
	}
	if camp == nil {
		return c.JSON(http.StatusNotFound, ErrorResponse{Code: "NOT_FOUND", Message: "Camp not found"})
	}
	return c.JSON(http.StatusOK, mapDomainCampToDTO(camp))
}

// @Summary      캠프 시작
// @Description  캠프를 ACTIVE 상태로 변경하고 운영을 시작한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Produce      json
// @Param        id path string true "캠프 ID"
// @Success      200 {object} Camp
// @Failure      400 {object} ErrorResponse
// @Failure      409 {object} ErrorResponse "이미 활성화됨 또는 필수 조건 미충족"
// @Router       /camps/{id}/start [post]
func (h *CampHandler) StartCamp(c echo.Context) error {
	id := domain.CampID(c.Param("id"))
	adminID := getAdminID(c)
	err := h.svc.ActivateCamp(c.Request().Context(), id, adminID)
	if err != nil {
		if err == domain.ErrCampInvalidTransition {
			return c.JSON(http.StatusConflict, ErrorResponse{Code: "CONFLICT", Message: err.Error()})
		}
		return c.JSON(http.StatusInternalServerError, ErrorResponse{Code: "INTERNAL_ERROR", Message: err.Error()})
	}
	camp, _ := h.svc.GetCamp(c.Request().Context(), id)
	return c.JSON(http.StatusOK, mapDomainCampToDTO(camp))
}

// @Summary      캠프 종료
// @Description  캠프를 ENDED 상태로 변경한다. 이후 데이터 수정이 불가하다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Produce      json
// @Param        id path string true "캠프 ID"
// @Success      200 {object} Camp
// @Failure      400 {object} ErrorResponse
// @Failure      409 {object} ErrorResponse
// @Router       /camps/{id}/end [post]
func (h *CampHandler) EndCamp(c echo.Context) error {
	id := domain.CampID(c.Param("id"))
	adminID := getAdminID(c)
	err := h.svc.EndCamp(c.Request().Context(), id, adminID)
	if err != nil {
		if err == domain.ErrCampInvalidTransition {
			return c.JSON(http.StatusConflict, ErrorResponse{Code: "CONFLICT", Message: err.Error()})
		}
		return c.JSON(http.StatusInternalServerError, ErrorResponse{Code: "INTERNAL_ERROR", Message: err.Error()})
	}
	camp, _ := h.svc.GetCamp(c.Request().Context(), id)
	return c.JSON(http.StatusOK, mapDomainCampToDTO(camp))
}
