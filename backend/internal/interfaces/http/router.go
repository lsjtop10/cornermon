package http

import (
	"cornermon/backend/internal/interfaces/http/handler"
	"cornermon/backend/internal/interfaces/http/middleware"

	"github.com/labstack/echo/v4"
)

type Handlers struct {
	Auth   *handler.AuthHandler
	Device  *handler.DeviceHandler
	Missing *handler.MissingHandlers
	Visit   *handler.VisitHandler
	Event   *handler.EventHandler
	Message *handler.MessageHandler
	Report  *handler.ReportHandler
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

	v1.POST("/device-registrations", h.Device.RequestRegistration)

	// Admin Routes
	admin := v1.Group("")
	admin.Use(middleware.AdminAuthMiddleware(adminAuth))
	admin.POST("/auth/admin/refresh", h.Auth.AdminRefresh)
	admin.POST("/auth/admin/logout", h.Auth.AdminLogout)
	
	if h.Missing != nil {
		admin.POST("/camps", h.Missing.CreateCamp)
		admin.GET("/camps", h.Missing.ListCamps)
		admin.GET("/camps/:id", h.Missing.GetCamp)

		admin.POST("/corners", h.Missing.CreateCorner)
		admin.GET("/corners", h.Missing.ListCorners)
		admin.PUT("/corners/:id", h.Missing.UpdateCorner)
		admin.DELETE("/corners/:id", h.Missing.DeleteCorner)

		admin.GET("/camps/:id/tracks", h.Missing.ListTracks)

		admin.POST("/badges/bulk-generate", h.Missing.BulkGenerateBadges)
		admin.GET("/badges/export", h.Missing.ExportBadges)
		admin.GET("/badges", h.Missing.ListBadges)

		admin.GET("/groups", h.Missing.ListGroups)
		admin.GET("/groups/:id/schedule", h.Missing.GetGroupSchedule)
	}

	admin.GET("/device-registrations", h.Device.ListRegistrations)
	admin.POST("/device-registrations/:id/approve", h.Device.ApproveDevice)
	admin.POST("/device-registrations/:id/reject", h.Device.RejectDevice)
	admin.POST("/device-registrations/:id/revoke", h.Device.RevokeDevice)

	if h.Message != nil {
		admin.POST("/messages/broadcast", h.Message.SendBroadcast)
		admin.POST("/tracks/:trackId/messages", h.Message.SendDirect)
	}

	if h.Report != nil {
		admin.GET("/reports/current", h.Report.GetCurrentReport)
	}

	// Track Routes
	track := v1.Group("")
	track.Use(middleware.TrackAuthMiddleware(trackAuth))
	
	if h.Visit != nil {
		track.POST("/tracks/:trackId/visits/start", h.Visit.StartVisit)
		track.POST("/tracks/:trackId/visits/current/end", h.Visit.EndCurrentVisit)
	}

	if h.Event != nil {
		admin.GET("/events/admin", h.Event.AdminEvents)
		track.GET("/events/track/:trackId", h.Event.TrackEvents)
	}
}
