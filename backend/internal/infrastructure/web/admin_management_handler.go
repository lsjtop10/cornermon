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
	Role     string `json:"role" enums:"SYSTEM_ADMIN,CORNER_OPERATOR"`
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
		return c.JSON(http.StatusUnauthorized, ErrorResponse{Code: "UNAUTHORIZED", Message: "unauthorized"})
	}
	var req CreateAdminRequest
	if err := c.Bind(&req); err != nil || req.Username == "" || req.Password == "" {
		return c.JSON(http.StatusBadRequest, ErrorResponse{Code: "BAD_REQUEST", Message: "username and password are required"})
	}
	admin, err := h.admins.CreateAdmin(c.Request().Context(), actor.AdminID, req.Username, req.Password, domain.AdminRole(req.Role))
	if err != nil {
		return adminManagementError(c, err)
	}
	return c.JSON(http.StatusCreated, AdminResponse{ID: string(admin.ID), Username: admin.Username, Role: string(admin.Role)})
}

// @Summary      관리자 비밀번호 변경
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
		return c.JSON(http.StatusUnauthorized, ErrorResponse{Code: "UNAUTHORIZED", Message: "unauthorized"})
	}
	var req ChangeAdminPasswordRequest
	if err := c.Bind(&req); err != nil || req.Password == "" {
		return c.JSON(http.StatusBadRequest, ErrorResponse{Code: "BAD_REQUEST", Message: "password is required"})
	}
	if err := h.admins.ChangeAdminPassword(c.Request().Context(), actor.AdminID, domain.AdminID(c.Param("id")), req.Password); err != nil {
		return adminManagementError(c, err)
	}
	return c.NoContent(http.StatusNoContent)
}

// @Summary      관리자 삭제
// @Tags         A. Auth & Device Trust
// @Security     AdminAuth
// @Param        id path string true "관리자 ID"
// @Success      204
// @Failure      403,404,409 {object} ErrorResponse
// @Router       /admins/{id} [delete]
func (h *AdminManagementHandler) DeleteAdmin(c echo.Context) error {
	actor, ok := c.Get("adminSession").(*domain.AdminSession)
	if !ok {
		return c.JSON(http.StatusUnauthorized, ErrorResponse{Code: "UNAUTHORIZED", Message: "unauthorized"})
	}
	if err := h.admins.DeleteAdmin(c.Request().Context(), actor.AdminID, domain.AdminID(c.Param("id"))); err != nil {
		return adminManagementError(c, err)
	}
	return c.NoContent(http.StatusNoContent)
}

func adminManagementError(c echo.Context, err error) error {
	switch {
	case errors.Is(err, domain.ErrAdminForbidden):
		return c.JSON(http.StatusForbidden, ErrorResponse{Code: "FORBIDDEN", Message: err.Error()})
	case errors.Is(err, domain.ErrAdminNotFound):
		return c.JSON(http.StatusNotFound, ErrorResponse{Code: "NOT_FOUND", Message: err.Error()})
	case errors.Is(err, domain.ErrAdminUsernameTaken), errors.Is(err, domain.ErrAdminSelfDeleteForbidden), errors.Is(err, domain.ErrAdminLastSystemAdmin):
		return c.JSON(http.StatusConflict, ErrorResponse{Code: "CONFLICT", Message: err.Error()})
	case errors.Is(err, domain.ErrAdminInvalidRole):
		return c.JSON(http.StatusBadRequest, ErrorResponse{Code: "BAD_REQUEST", Message: err.Error()})
	default:
		return c.JSON(http.StatusInternalServerError, ErrorResponse{Code: "INTERNAL_SERVER_ERROR", Message: err.Error()})
	}
}
