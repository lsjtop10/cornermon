package http

import (
	"cornermon/backend/internal/interfaces/http/handler"
	"cornermon/backend/internal/interfaces/http/middleware"

	"github.com/labstack/echo/v4"
)

type Handlers struct {
	Auth *handler.AuthHandler
	// Add other handlers here (Camp, Corner, Track, Visit, Group, Badge, Event)
}

func RegisterRoutes(e *echo.Echo, h *Handlers, adminAuth middleware.AuthAdminUsecase, trackAuth middleware.AuthFacilitatorUsecase) {
	// Global Middlewares
	e.Use(middleware.Logger())
	e.HTTPErrorHandler = middleware.ErrorHandler()

	v1 := e.Group("/api/v1")

	// Public Auth Routes
	auth := v1.Group("/auth")
	auth.POST("/admin/login", h.Auth.AdminLogin)
	auth.POST("/track/login", h.Auth.TrackLogin)
	// TODO: Device Request, etc.

	// Admin Routes
	admin := v1.Group("")
	admin.Use(middleware.AdminAuthMiddleware(adminAuth))
	admin.POST("/auth/admin/refresh", h.Auth.AdminRefresh)
	admin.POST("/auth/admin/logout", h.Auth.AdminLogout)
	
	// Track Routes
	track := v1.Group("")
	track.Use(middleware.TrackAuthMiddleware(trackAuth))
	// Add track endpoints
}
