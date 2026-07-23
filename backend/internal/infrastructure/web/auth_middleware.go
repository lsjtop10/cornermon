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
				return echo.NewHTTPError(http.StatusUnauthorized, ErrorResponse{Code: CodeUnauthorized, Message: "missing token"})
			}

			session, err := adminAuth.ValidateAccessToken(c.Request().Context(), token)
			if err != nil {
				return echo.NewHTTPError(http.StatusUnauthorized, ErrorResponse{Code: CodeUnauthorized, Message: err.Error()}).SetInternal(err)
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
				return echo.NewHTTPError(http.StatusUnauthorized, ErrorResponse{Code: CodeUnauthorized, Message: "missing token"})
			}

			session, err := trackAuth.ValidateSession(c.Request().Context(), token)
			if err != nil {
				return echo.NewHTTPError(http.StatusUnauthorized, ErrorResponse{Code: CodeUnauthorized, Message: err.Error()}).SetInternal(err)
			}

			c.Set("facilitatorSession", session)
			return next(c)
		}
	}
}

// RequireNoPendingMigration은 트랙 교체로 인해 마이그레이션 대상이 지정된 세션이
// migrate-session/logout 이외의 트랙 스코프 엔드포인트를 계속 사용하지 못하도록 막는다.
// 세션을 직접 조회하지 않고, 앞서 실행된 TrackAuthMiddleware/MessageAuthMiddleware가
// 컨텍스트에 심어둔 facilitatorSession을 그대로 읽어서 판단하므로, 라우트 그룹 등록 시
// 이 미들웨어가 그 뒤에 오도록 순서를 지켜야 한다.
func RequireNoPendingMigration() echo.MiddlewareFunc {
	return func(next echo.HandlerFunc) echo.HandlerFunc {
		return func(c echo.Context) error {
			if session, ok := c.Get("facilitatorSession").(*domain.FacilitatorSession); ok {
				if session.MigrationTargetTrackID().IsSet() {
					return echo.NewHTTPError(http.StatusConflict, ErrorResponse{Code: CodeSessionMigrationRequired, Message: "session must migrate to the new track first"})
				}
			}
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
				return echo.NewHTTPError(http.StatusUnauthorized, ErrorResponse{Code: CodeUnauthorized, Message: "missing token"})
			}

			if session, err := adminAuth.ValidateAccessToken(c.Request().Context(), token); err == nil && session != nil {
				c.Set("adminSession", session)
				return next(c)
			}
			if session, err := trackAuth.ValidateSession(c.Request().Context(), token); err == nil && session != nil {
				c.Set("facilitatorSession", session)
				return next(c)
			}

			return echo.NewHTTPError(http.StatusUnauthorized, ErrorResponse{Code: CodeUnauthorized, Message: "invalid token"})
		}
	}
}

func extractToken(authHeader string) string {
	if strings.HasPrefix(authHeader, "Bearer ") {
		return strings.TrimPrefix(authHeader, "Bearer ")
	}
	return ""
}
