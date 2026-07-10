package middleware

import (
	"context"
	"net/http"
	"strings"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/interfaces/http/dto"

	"github.com/labstack/echo/v4"
)

type AuthAdminUsecase interface {
	ValidateAccessToken(ctx context.Context, accessToken string) (*domain.AdminSession, error)
}

type AuthFacilitatorUsecase interface {
	ValidateSession(ctx context.Context, plainToken string) (*domain.FacilitatorSession, error)
}

func AdminAuthMiddleware(adminAuth AuthAdminUsecase) echo.MiddlewareFunc {
	return func(next echo.HandlerFunc) echo.HandlerFunc {
		return func(c echo.Context) error {
			token := extractToken(c.Request().Header.Get("Authorization"))
			if token == "" {
				return c.JSON(http.StatusUnauthorized, dto.ErrorResponse{Code: "UNAUTHORIZED", Message: "missing token"})
			}
			
			session, err := adminAuth.ValidateAccessToken(c.Request().Context(), token)
			if err != nil {
				return c.JSON(http.StatusUnauthorized, dto.ErrorResponse{Code: "UNAUTHORIZED", Message: err.Error()})
			}
			
			c.Set("adminSession", session)
			return next(c)
		}
	}
}

func TrackAuthMiddleware(trackAuth AuthFacilitatorUsecase) echo.MiddlewareFunc {
	return func(next echo.HandlerFunc) echo.HandlerFunc {
		return func(c echo.Context) error {
			token := extractToken(c.Request().Header.Get("Authorization"))
			if token == "" {
				return c.JSON(http.StatusUnauthorized, dto.ErrorResponse{Code: "UNAUTHORIZED", Message: "missing token"})
			}
			
			session, err := trackAuth.ValidateSession(c.Request().Context(), token)
			if err != nil {
				return c.JSON(http.StatusUnauthorized, dto.ErrorResponse{Code: "UNAUTHORIZED", Message: err.Error()})
			}
			
			c.Set("facilitatorSession", session)
			return next(c)
		}
	}
}

func extractToken(authHeader string) string {
	if strings.HasPrefix(authHeader, "Bearer ") {
		return strings.TrimPrefix(authHeader, "Bearer ")
	}
	return ""
}
