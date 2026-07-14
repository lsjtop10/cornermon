package main

import (
	"context"
	"log"
	"log/slog"
	"os"

	"cornermon/backend/internal/errs"
	"cornermon/backend/internal/infrastructure/postgres"
	"cornermon/backend/internal/infrastructure/sse"
	"cornermon/backend/internal/infrastructure/web"
	"cornermon/backend/internal/usecase"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/joho/godotenv"
	"github.com/labstack/echo/v4"
	"net/url"
)

func main() {
	// Initialize structured logging (slog JSON format + AppError handler)
	jsonHandler := slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{
		Level: slog.LevelInfo,
	})
	logger := slog.New(errs.NewSlogWrappedHandler(jsonHandler))
	slog.SetDefault(logger)

	slog.Info("Cornermon Backend Starting...")

	// Load .env if exists
	_ = godotenv.Load()

	ctx := context.Background()
	dbURL := os.Getenv("DATABASE_URL")
	dbPass := os.Getenv("DATABASE_PASSWORD")

	if dbURL == "" {
		// Fallback for development if not provided
		dbURL = "postgres://postgres:postgres@localhost:5432/cornermon?sslmode=disable&timezone=UTC"
	} else {
		u, err := url.Parse(dbURL)
		if err == nil {
			// Set separate password if provided
			if dbPass != "" {
				username := "postgres"
				if u.User != nil {
					username = u.User.Username()
				}
				u.User = url.UserPassword(username, dbPass)
			}
			// Force session timezone to UTC
			q := u.Query()
			q.Set("timezone", "UTC")
			u.RawQuery = q.Encode()
			dbURL = u.String()
		}
	}

	// Initialize Database Pool
	pool, err := pgxpool.New(ctx, dbURL)
	if err != nil {
		log.Fatalf("Unable to connect to database: %v\n", err)
	}
	defer pool.Close()

	// Initialize Repositories
	adminRepo := postgres.NewAdminRepository(pool)
	adminSessionRepo := postgres.NewAdminSessionRepository(pool)
	auditLogRepo := postgres.NewAuditLogRepository(pool)
	badgeRepo := postgres.NewBadgeRepository(pool)
	broadcastReceiptRepo := postgres.NewBroadcastReceiptRepository(pool)
	campRepo := postgres.NewCampRepository(pool)
	cornerRepo := postgres.NewCornerRepository(pool)
	deviceRepo := postgres.NewDeviceRegistrationRepository(pool)
	facilitatorSessionRepo := postgres.NewFacilitatorSessionRepository(pool)
	groupRepo := postgres.NewGroupRepository(pool)
	messageRepo := postgres.NewMessageRepository(pool)
	trackRepo := postgres.NewTrackRepository(pool)
	visitRepo := postgres.NewVisitRepository(pool)
	reportQuerier := postgres.NewReportQuerier(pool)
	txManager := postgres.NewTxManager(pool)

	// Initialize Infrastructure Services
	broadcaster := sse.NewBroadcaster()

	// Initialize Usecases
	authAdminService := usecase.NewAdminAuthService(adminRepo, adminSessionRepo, facilitatorSessionRepo, trackRepo, cornerRepo, broadcaster, auditLogRepo, txManager)

	deviceTrustService := usecase.NewDeviceTrustService(campRepo, deviceRepo, auditLogRepo, broadcaster, txManager)
	cornerService := usecase.NewCornerService(campRepo, cornerRepo, auditLogRepo, broadcaster, txManager)
	groupService := usecase.NewGroupService(campRepo, cornerRepo, trackRepo, groupRepo, badgeRepo, visitRepo, auditLogRepo, txManager)
	badgeService := usecase.NewBadgeService(badgeRepo, groupRepo, auditLogRepo, txManager)
	visitService := usecase.NewVisitService(campRepo, cornerRepo, trackRepo, visitRepo, groupRepo, badgeRepo, facilitatorSessionRepo, auditLogRepo, broadcaster, txManager)
	trackService := usecase.NewTrackService(campRepo, cornerRepo, trackRepo, facilitatorSessionRepo, auditLogRepo, broadcaster, txManager)
	reportService := usecase.NewReportService(campRepo, reportQuerier)
	authFacilitatorService := usecase.NewFacilitatorAuthService(campRepo, cornerRepo, trackRepo, deviceRepo, facilitatorSessionRepo, auditLogRepo, broadcaster, txManager)
	messageService := usecase.NewMessageService(campRepo, cornerRepo, trackRepo, messageRepo, broadcastReceiptRepo, facilitatorSessionRepo, auditLogRepo, broadcaster, txManager)
	campService := usecase.NewCampService(campRepo, trackRepo, facilitatorSessionRepo, auditLogRepo, broadcaster, txManager)

	// Initialize Handlers
	authHandler := web.NewAuthHandler(authAdminService, authFacilitatorService, deviceTrustService)
	deviceHandler := web.NewDeviceHandler(deviceTrustService)
	campHandler := web.NewCampHandler(campService)
	cornerHandler := web.NewCornerHandler(cornerService)
	trackHandler := web.NewTrackHandler(trackService)
	groupHandler := web.NewGroupHandler(groupService)
	badgeHandler := web.NewBadgeHandler(badgeService, groupService, campRepo)
	visitHandler := web.NewVisitHandler(visitService)

	eventHandler := web.NewEventHandler(broadcaster, trackRepo, cornerRepo)

	messageHandler := web.NewMessageHandler(messageService)
	reportHandler := web.NewReportHandler(reportService, reportQuerier, campRepo)
	auditHandler := web.NewAuditHandler(auditLogRepo)

	handlers := &web.Handlers{
		Auth:    authHandler,
		Device:  deviceHandler,
		Camp:    campHandler,
		Corner:  cornerHandler,
		Track:   trackHandler,
		Group:   groupHandler,
		Badge:   badgeHandler,
		Visit:   visitHandler,
		Event:   eventHandler,
		Message: messageHandler,
		Report:  reportHandler,
		Audit:   auditHandler,
	}

	e := echo.New()

	// Serve the auto-generated Swagger UI spec directly
	e.File("/openapi.yaml", "docs/swagger.yaml")
	e.File("/openapi.json", "docs/swagger.json")

	// Register Routes
	web.RegisterRoutes(e, handlers, authAdminService, authFacilitatorService)

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	log.Fatal(e.Start(":" + port))
}
