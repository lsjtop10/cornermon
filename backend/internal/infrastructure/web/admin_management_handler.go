package web

import (
	"context"
	"errors"
	"net/http"

	"cornermon/backend/internal/domain"

	"github.com/labstack/echo/v4"
)

type AdminManagementUsecase interface {
	CreateAdmin(ctx context.Context, actorAdminID domain.AdminID, username, password string, role domain.AdminRole) (*domain.Admin, error)
	ChangeAdminPassword(ctx context.Context, actorAdminID, targetAdminID domain.AdminID, newPassword string) error
	DeleteAdmin(ctx context.Context, actorAdminID, targetAdminID domain.AdminID) error
}

type AdminManagementHandler struct{ admins AdminManagementUsecase }

func NewAdminManagementHandler(admins AdminManagementUsecase) *AdminManagementHandler {
	return &AdminManagementHandler{admins: admins}
}

type CreateAdminRequest struct {
	Username string `json:"username"`
	Password string `json:"password"`
	Role     string `json:"role" enums:"CORNER_OPERATOR"`
} // @name CreateAdminRequest

type ChangeAdminPasswordRequest struct {
	Password string `json:"password"`
} // @name ChangeAdminPasswordRequest

type AdminResponse struct {
	ID       string `json:"id"`
	Username string `json:"username"`
	Role     string `json:"role" enums:"SYSTEM_ADMIN,CORNER_OPERATOR"`
} // @name AdminResponse

// @Summary      관리자 생성
// @Description  SYSTEM_ADMIN만 호출할 수 있습니다. 생성할 역할은 CORNER_OPERATOR로 고정되며, SYSTEM_ADMIN은 다른 SYSTEM_ADMIN을 생성할 수 없습니다. 동일한 username은 생성할 수 없습니다.
// @Tags         A. Auth & Device Trust
// @Security     AdminAuth
// @Accept       json
// @Produce      json
// @Param        request body CreateAdminRequest true "생성할 관리자"
// @Success      201 {object} AdminResponse
// @Failure      403,409 {object} ErrorResponse
// @Router       /admins [post]
func (h *AdminManagementHandler) CreateAdmin(c echo.Context) error {
	actor, ok := c.Get("adminSession").(*domain.AdminSession)
	if !ok {
		return echo.NewHTTPError(http.StatusUnauthorized, ErrorResponse{Code: CodeUnauthorized, Message: "unauthorized"})
	}
	var req CreateAdminRequest
	if err := c.Bind(&req); err != nil || req.Username == "" || req.Password == "" {
		return echo.NewHTTPError(http.StatusBadRequest, ErrorResponse{Code: CodeBadRequest, Message: "username and password are required"}).SetInternal(err)
	}
	admin, err := h.admins.CreateAdmin(c.Request().Context(), actor.AdminID(), req.Username, req.Password, domain.AdminRole(req.Role))
	if err != nil {
		return adminManagementError(err)
	}
	return c.JSON(http.StatusCreated, AdminResponse{ID: string(admin.ID()), Username: admin.Username(), Role: string(admin.Role())})
}

// @Summary      관리자 비밀번호 변경
// @Description  대상 관리자 본인 또는 SYSTEM_ADMIN만 호출할 수 있습니다. 비밀번호 변경은 기존 세션을 즉시 무효화하지 않으며, 현재 access token은 기존 TTL까지 유효합니다.
// @Tags         A. Auth & Device Trust
// @Security     AdminAuth
// @Accept       json
// @Param        id path string true "관리자 ID"
// @Param        request body ChangeAdminPasswordRequest true "새 비밀번호"
// @Success      204
// @Failure      403,404 {object} ErrorResponse
// @Router       /admins/{id}/password [patch]
func (h *AdminManagementHandler) ChangeAdminPassword(c echo.Context) error {
	actor, ok := c.Get("adminSession").(*domain.AdminSession)
	if !ok {
		return echo.NewHTTPError(http.StatusUnauthorized, ErrorResponse{Code: CodeUnauthorized, Message: "unauthorized"})
	}
	var req ChangeAdminPasswordRequest
	if err := c.Bind(&req); err != nil || req.Password == "" {
		return echo.NewHTTPError(http.StatusBadRequest, ErrorResponse{Code: CodeBadRequest, Message: "password is required"}).SetInternal(err)
	}
	if err := h.admins.ChangeAdminPassword(c.Request().Context(), actor.AdminID(), domain.AdminID(c.Param("id")), req.Password); err != nil {
		return adminManagementError(err)
	}
	return c.NoContent(http.StatusNoContent)
}

// @Summary      관리자 삭제
// @Description  SYSTEM_ADMIN만 호출할 수 있습니다. 자기 자신은 삭제할 수 없으므로 마지막 SYSTEM_ADMIN 삭제 요청은 성립하지 않습니다. 삭제 시 admin_sessions는 DB foreign key cascade로 함께 제거됩니다.
// @Tags         A. Auth & Device Trust
// @Security     AdminAuth
// @Param        id path string true "관리자 ID"
// @Success      204
// @Failure      403,404,409 {object} ErrorResponse
// @Router       /admins/{id} [delete]
func (h *AdminManagementHandler) DeleteAdmin(c echo.Context) error {
	actor, ok := c.Get("adminSession").(*domain.AdminSession)
	if !ok {
		return echo.NewHTTPError(http.StatusUnauthorized, ErrorResponse{Code: CodeUnauthorized, Message: "unauthorized"})
	}
	if err := h.admins.DeleteAdmin(c.Request().Context(), actor.AdminID(), domain.AdminID(c.Param("id"))); err != nil {
		return adminManagementError(err)
	}
	return c.NoContent(http.StatusNoContent)
}

func adminManagementError(err error) error {
	switch {
	case errors.Is(err, domain.ErrAdminForbidden):
		return echo.NewHTTPError(http.StatusForbidden, ErrorResponse{Code: CodeForbidden, Message: err.Error()}).SetInternal(err)
	case errors.Is(err, domain.ErrAdminNotFound):
		return echo.NewHTTPError(http.StatusNotFound, ErrorResponse{Code: CodeNotFound, Message: err.Error()}).SetInternal(err)
	case errors.Is(err, domain.ErrAdminUsernameTaken), errors.Is(err, domain.ErrAdminSelfDeleteForbidden), errors.Is(err, domain.ErrAdminLastSystemAdmin):
		return echo.NewHTTPError(http.StatusConflict, ErrorResponse{Code: CodeConflict, Message: err.Error()}).SetInternal(err)
	case errors.Is(err, domain.ErrAdminInvalidRole):
		return echo.NewHTTPError(http.StatusBadRequest, ErrorResponse{Code: CodeBadRequest, Message: err.Error()}).SetInternal(err)
	default:
		return echo.NewHTTPError(http.StatusInternalServerError, ErrorResponse{Code: CodeInternalServerError, Message: err.Error()}).SetInternal(err)
	}
}
