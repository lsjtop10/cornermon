package web

import (
	"net/http"
	"time"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/usecase"

	"github.com/labstack/echo/v4"
)

type CampHandler struct {
	svc *usecase.CampService
}

type CampResponse struct {
	ID                   string    `json:"id" format:"uuid"`
	RegistrationCode     string    `json:"registrationCode" example:"7ZQK3M2X"`
	Name                 string    `json:"name" example:"2026 여름 코너학습"`
	StartAt              time.Time `json:"startAt" format:"date-time"`
	EndAt                time.Time `json:"endAt" format:"date-time"`
	Status               string    `json:"status" enums:"PENDING,ACTIVE,ENDED"`
	BottleneckMinSamples int       `json:"bottleneckMinSamples" example:"3"`
	BottleneckRatioPct   int       `json:"bottleneckRatioPct" example:"20"`
} // @name CampResponse

type UpdateCampRequest struct {
	Name                 *string    `json:"name,omitempty"`
	StartAt              *time.Time `json:"startAt,omitempty" format:"date-time"`
	EndAt                *time.Time `json:"endAt,omitempty" format:"date-time"`
	BottleneckMinSamples *int       `json:"bottleneckMinSamples,omitempty"`
	BottleneckRatioPct   *int       `json:"bottleneckRatioPct,omitempty"`
} // @name UpdateCampRequest

// @Summary      캠프 정보 및 병목 기준 수정
// @Description  캠프 이름, 예정 기간, 병목 판정 기준 중 요청에 포함된 필드만 수정한다. 종료된 캠프는 수정할 수 없다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Accept       json
// @Produce      json
// @Param        id path string true "캠프 ID"
// @Param        request body UpdateCampRequest true "부분 수정할 캠프 설정"
// @Success      200 {object} CampResponse
// @Failure      400 {object} ErrorResponse
// @Failure      404 {object} ErrorResponse
// @Failure      409 {object} ErrorResponse
// @Router       /camps/{id} [patch]
func (h *CampHandler) UpdateCamp(c echo.Context) error {
	var req UpdateCampRequest
	if err := c.Bind(&req); err != nil {
		return echo.NewHTTPError(http.StatusBadRequest, "invalid request body")
	}

	patch := domain.CampSettingsPatch{}
	if req.Name != nil {
		patch.Name = domain.Some(*req.Name)
	}
	if req.StartAt != nil {
		patch.StartAt = domain.Some(*req.StartAt)
	}
	if req.EndAt != nil {
		patch.EndAt = domain.Some(*req.EndAt)
	}
	if req.BottleneckMinSamples != nil {
		patch.BottleneckMinSamples = domain.Some(*req.BottleneckMinSamples)
	}
	if req.BottleneckRatioPct != nil {
		patch.BottleneckRatioPct = domain.Some(*req.BottleneckRatioPct)
	}

	camp, err := h.svc.UpdateCampSettings(c.Request().Context(), domain.CampID(c.Param("id")), getAdminID(c), patch)
	if err != nil {
		return err
	}
	return c.JSON(http.StatusOK, mapDomainCampToDTO(camp))
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

func mapDomainCampToDTO(camp *domain.Camp) CampResponse {
	if camp == nil {
		return CampResponse{}
	}
	return CampResponse{
		ID:                   string(camp.ID),
		RegistrationCode:     camp.RegistrationCode,
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
// @Success      200 {array} CampResponse
// @Failure      401 {object} ErrorResponse
// @Router       /camps [get]
func (h *CampHandler) ListCamps(c echo.Context) error {
	camps, err := h.svc.ListCamps(c.Request().Context())
	if err != nil {
		return c.JSON(http.StatusInternalServerError, ErrorResponse{Code: "INTERNAL_ERROR", Message: err.Error()})
	}
	res := make([]CampResponse, len(camps))
	for i, cp := range camps {
		res[i] = mapDomainCampToDTO(cp)
	}
	return c.JSON(http.StatusOK, res)
}

type CreateCampRequest struct {
	Name    string    `json:"name"`
	StartAt time.Time `json:"startAt" format:"date-time"`
	EndAt   time.Time `json:"endAt" format:"date-time"`
} // @name CreateCampRequest

// @Summary      새 캠프 생성
// @Description  새로운 코너학습 캠프를 생성한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Accept       json
// @Produce      json
// @Param        request body CreateCampRequest true "캠프 생성 정보"
// @Success      201 {object} CampResponse
// @Failure      400 {object} ErrorResponse
// @Failure      401 {object} ErrorResponse
// @Router       /camps [post]
func (h *CampHandler) CreateCamp(c echo.Context) error {
	var req CreateCampRequest
	if err := c.Bind(&req); err != nil {
		return c.JSON(http.StatusBadRequest, ErrorResponse{Code: "BAD_REQUEST", Message: "Invalid request body"})
	}
	camp, err := h.svc.OpenNewCamp(c.Request().Context(), req.Name, req.StartAt, req.EndAt)
	if err != nil {
		if err == domain.ErrCampInvalidSettings {
			return c.JSON(http.StatusBadRequest, ErrorResponse{Code: "BAD_REQUEST", Message: err.Error()})
		}
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
// @Success      200 {object} CampResponse
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
// @Success      200 {object} CampResponse
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
// @Success      200 {object} CampResponse
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
