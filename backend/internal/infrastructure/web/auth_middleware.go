package web

import (
	"context"
	"net/http"
	"strings"

	"cornermon/backend/internal/domain"

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
				return echo.NewHTTPError(http.StatusUnauthorized, ErrorResponse{Code: "UNAUTHORIZED", Message: "missing token"})
			}

			session, err := adminAuth.ValidateAccessToken(c.Request().Context(), token)
			if err != nil {
				return echo.NewHTTPError(http.StatusUnauthorized, ErrorResponse{Code: "UNAUTHORIZED", Message: err.Error()}).SetInternal(err)
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
				return echo.NewHTTPError(http.StatusUnauthorized, ErrorResponse{Code: "UNAUTHORIZED", Message: "missing token"})
			}

			session, err := trackAuth.ValidateSession(c.Request().Context(), token)
			if err != nil {
				return echo.NewHTTPError(http.StatusUnauthorized, ErrorResponse{Code: "UNAUTHORIZED", Message: err.Error()}).SetInternal(err)
			}

			c.Set("facilitatorSession", session)
			return next(c)
		}
	}
}

// MessageAuthMiddleware accepts either an administrator or facilitator session
// for the shared direct-message GET routes. Echo has one handler slot per
// method/path, so these routes cannot be registered separately under the two
// auth groups.
func MessageAuthMiddleware(adminAuth AuthAdminUsecase, trackAuth AuthFacilitatorUsecase) echo.MiddlewareFunc {
	return func(next echo.HandlerFunc) echo.HandlerFunc {
		return func(c echo.Context) error {
			token := extractToken(c.Request().Header.Get("Authorization"))
			if token == "" {
				return echo.NewHTTPError(http.StatusUnauthorized, ErrorResponse{Code: "UNAUTHORIZED", Message: "missing token"})
			}

			if session, err := adminAuth.ValidateAccessToken(c.Request().Context(), token); err == nil && session != nil {
				c.Set("adminSession", session)
				return next(c)
			}
			if session, err := trackAuth.ValidateSession(c.Request().Context(), token); err == nil && session != nil {
				c.Set("facilitatorSession", session)
				return next(c)
			}

			return echo.NewHTTPError(http.StatusUnauthorized, ErrorResponse{Code: "UNAUTHORIZED", Message: "invalid token"})
		}
	}
}

func extractToken(authHeader string) string {
	if strings.HasPrefix(authHeader, "Bearer ") {
		return strings.TrimPrefix(authHeader, "Bearer ")
	}
	return ""
}
