package web

import (
	"github.com/labstack/echo/v4"
)

type Handlers struct {
	Auth            *AuthHandler
	Device          *DeviceHandler
	Camp            *CampHandler
	Corner          *CornerHandler
	Track           *TrackHandler
	Group           *GroupHandler
	Badge           *BadgeHandler
	Visit           *VisitHandler
	Event           *EventHandler
	Message         *MessageHandler
	Report          *ReportHandler
	Audit           *AuditHandler
	AdminManagement *AdminManagementHandler
	Health          *HealthHandler
}

func RegisterRoutes(e *echo.Echo, h *Handlers, adminAuth AuthAdminUsecase, trackAuth AuthFacilitatorUsecase) {
	e.Use(Logger())
	e.HTTPErrorHandler = ErrorHandler()

	v1 := e.Group("/api/v1")

	if h.Health != nil {
		v1.GET("/health", h.Health.Check)
		v1.GET("/ready", h.Health.Ready)
	}

	// ── A. Auth & Device Trust ──
	auth := v1.Group("/auth")
	auth.POST("/admin/login", h.Auth.AdminLogin)
	auth.POST("/track/login", h.Auth.TrackLogin)

	v1.POST("/device-registrations", h.Device.RequestRegistration)
	v1.GET("/device-registrations/me", h.Device.GetMyRegistrationStatus)

	admin := v1.Group("")
	admin.Use(AdminAuthMiddleware(adminAuth))

	admin.POST("/auth/admin/logout", h.Auth.AdminLogout)
	admin.GET("/auth/admin/sessions", h.Auth.ListAdminSessions)
	admin.POST("/auth/admin/sessions/:id/revoke", h.Auth.RevokeAdminSession)
	if h.AdminManagement != nil {
		admin.POST("/admins", h.AdminManagement.CreateAdmin)
		admin.PATCH("/admins/:id/password", h.AdminManagement.ChangeAdminPassword)
		admin.DELETE("/admins/:id", h.AdminManagement.DeleteAdmin)
	}
	admin.POST("/auth/track/:trackId/force-logout", h.Auth.ForceTrackLogout)
	admin.POST("/auth/track/lockout/:deviceId/release", h.Auth.ReleaseLockout)
	admin.GET("/auth/track/sessions", h.Auth.ListActiveFacilitatorSessions)

	admin.GET("/camps/:campId/device-registrations", h.Device.ListRegistrations)
	admin.GET("/camps/:campId/device-registrations/locked", h.Device.ListLockedDevices)
	admin.POST("/camps/:campId/device-registrations/:id/approve", h.Device.ApproveDevice)
	admin.POST("/camps/:campId/device-registrations/:id/reject", h.Device.RejectDevice)
	admin.POST("/camps/:campId/device-registrations/:id/revoke", h.Device.RevokeDevice)

	// ── B. Resource Management ──
	if h.Camp != nil {
		admin.GET("/camps", h.Camp.ListCamps)
		admin.POST("/camps", h.Camp.CreateCamp)
		admin.GET("/camps/:id", h.Camp.GetCamp)
		admin.PATCH("/camps/:id", h.Camp.UpdateCamp)
		admin.POST("/camps/:id/start", h.Camp.StartCamp)
		admin.POST("/camps/:id/end", h.Camp.EndCamp)
	}

	if h.Corner != nil {
		admin.GET("/camps/:campId/corners", h.Corner.ListCorners)
		admin.POST("/corners", h.Corner.CreateCorner)
		admin.PUT("/corners/bulk-update", h.Corner.BulkUpdateCorners)
		admin.GET("/corners/:id", h.Corner.GetCorner)
		admin.DELETE("/corners/:id", h.Corner.DeleteCorner)
	}

	if h.Track != nil {
		admin.GET("/camps/:campId/tracks", h.Track.ListTracks)
		admin.POST("/tracks", h.Track.CreateTracks)
		admin.GET("/corners/:cornerId/tracks", h.Track.ListTracksByCorner)
		admin.GET("/tracks/:id", h.Track.GetTrack)
		admin.DELETE("/tracks/bulk-delete", h.Track.BulkDeleteTracks)
		admin.PUT("/tracks/:id/replace", h.Track.ReplaceTrack)
		admin.POST("/tracks/:id/regenerate-pin", h.Track.RegeneratePin)
		admin.GET("/tracks/export", h.Track.ExportTracks)
		admin.GET("/tracks/:id/export", h.Track.ExportTrackSingle)
	}

	if h.Badge != nil {
		admin.GET("/badges", h.Badge.ListBadges)
		admin.POST("/badges/bulk-generate", h.Badge.BulkGenerateBadges)
		admin.GET("/badges/export", h.Badge.ExportBadges)
		admin.POST("/badges/:id/register", h.Badge.AssignBadge)
		admin.POST("/badges/scan-register", h.Badge.ScanAssignBadge)
	}

	if h.Group != nil {
		admin.GET("/camps/:campId/groups", h.Group.ListGroups)
		admin.GET("/groups/:id", h.Group.GetGroup)
		admin.GET("/groups/:id/visits", h.Group.ListGroupVisits)
	}

	// ── D. Report & G. Audit ──
	if h.Report != nil {
		admin.GET("/camps/:campId/reports/live-summary", h.Report.LiveSummary)
		admin.GET("/camps/:campId/reports/current", h.Report.GetCurrentReport)
		admin.POST("/camps/:campId/reports/generate", h.Report.GenerateReport)
		admin.GET("/camps/:campId/reports/current/export", h.Report.ExportCurrentReport)
	}

	if h.Audit != nil {
		admin.GET("/audit-logs", h.Audit.ListAuditLogs)
	}

	// ── E. Message (Admin) ──
	if h.Message != nil {
		admin.POST("/camps/:campId/messages/broadcast", h.Message.SendBroadcast)
		admin.GET("/messages/broadcast/:id/receipts", h.Message.GetBroadcastReceipts)
		admin.POST("/tracks/:trackId/messages", h.Message.SendDirect)

		// Both administrator and facilitator sessions may access these paths.
		// They must be registered once because Echo routes by method and path
		// before group middleware is evaluated.
		message := v1.Group("")
		message.Use(MessageAuthMiddleware(adminAuth, trackAuth))
		message.GET("/camps/:campId/messages/broadcast", h.Message.ListBroadcasts)
		message.GET("/tracks/:trackId/messages", h.Message.ListDirectMessages)
		message.GET("/tracks/:trackId/messages/unread-count", h.Message.GetUnreadCount)
	}

	// ── F. Events (Admin) ──
	if h.Event != nil {
		admin.GET("/camps/:campId/events/admin", h.Event.AdminEvents)
	}

	// ── Track Auth Required Routes ──
	track := v1.Group("")
	track.Use(TrackAuthMiddleware(trackAuth))

	track.POST("/auth/track/logout", h.Auth.TrackLogout)
	track.POST("/tracks/:id/migrate-session", h.Auth.MigrateSession)
	if h.Group != nil {
		track.GET("/tracks/:trackId/groups", h.Group.ListGroupsByTrack)
	}

	// ── C. Visit ──
	if h.Visit != nil {
		track.POST("/tracks/:trackId/visits/start", h.Visit.StartVisit)
		track.POST("/tracks/:trackId/visits/current/end", h.Visit.EndCurrentVisit)
		track.GET("/tracks/:trackId/visits/current", h.Visit.GetCurrentVisit)
	}

	if h.Message != nil {
		track.POST("/messages/broadcast/:id/read", h.Message.ReadBroadcast)
		// Track can also send/get direct messages
		track.POST("/tracks/:trackId/messages/from-track", h.Message.SendDirect)
	}

	if h.Event != nil {
		track.GET("/events/track/:trackId", h.Event.TrackEvents)
	}
}
