package main

import (
	"context"
	"encoding/base64"
	"fmt"
	"log"
	"log/slog"
	"os"
	"time"

	"cornermon/backend/internal/errs"
	trackcrypto "cornermon/backend/internal/infrastructure/crypto"
	"cornermon/backend/internal/infrastructure/postgres"
	"cornermon/backend/internal/infrastructure/sse"
	"cornermon/backend/internal/infrastructure/web"
	"cornermon/backend/internal/usecase"

	"net/url"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/joho/godotenv"
	"github.com/labstack/echo/v4"
)

func stringToLevel(logLevelString string) slog.Leveler {
	switch logLevelString {
	case "debug":
		return slog.LevelDebug
	case "info":
		return slog.LevelInfo
	}

	return slog.LevelInfo
}

func main() {
	// Load .env if exists
	_ = godotenv.Load()

	var logLevel slog.Leveler
	logLevelString := os.Getenv("LOGLEVEL")
	if logLevelString != "" {
		logLevel = stringToLevel(logLevelString)
	}

	// Initialize structured logging (slog JSON format + AppError handler)
	jsonHandler := slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{
		Level: logLevel,
	})
	logger := slog.New(errs.NewSlogWrappedHandler(jsonHandler))
	slog.SetDefault(logger)

	slog.Info("Cornermon Backend Starting...")

	trackPINEncryptionKey, err := loadTrackPINEncryptionKey()
	if err != nil {
		log.Fatalf("Invalid TRACK_PIN_ENCRYPTION_KEY: %v\n", err)
	}
	trackPINProtector, err := trackcrypto.NewTrackPINProtector(trackPINEncryptionKey)
	if err != nil {
		log.Fatalf("Unable to initialize track PIN encryption: %v\n", err)
	}

	backgroundCtx := context.Background()
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

	dbctx, cancel := context.WithTimeout(backgroundCtx, 1000*time.Millisecond)
	defer cancel()
	// Initialize Database Pool Config
	config, err := pgxpool.ParseConfig(dbURL)
	if err != nil {
		cancel()
		log.Fatalf("Unable to parse database config: %v\n", err)
	}

	isDev := os.Getenv("APP_ENV") == "development"

	config.ConnConfig.Tracer = &postgres.SlogQueryTracer{
		SlowQueryThreshold: 500 * time.Millisecond,
		LogParameterValues: isDev,
	}

	// Initialize Database Pool
	pool, err := pgxpool.NewWithConfig(dbctx, config)
	if err != nil {
		cancel()
		log.Fatalf("Unable to connect to database: %v\n", err)
	}

	err = pool.Ping(dbctx)
	if err != nil {
		cancel()
		log.Fatalf("Unable to connect to database: %v\n", err)
	}

	defer pool.Close()

	// Initialize Repositories
	adminRepo := postgres.NewAdminRepository(pool)
	adminCtx, cancel := context.WithTimeout(backgroundCtx, 5000*time.Millisecond)
	defer cancel()
	if err := usecase.BootstrapAdmin(adminCtx, adminRepo, os.Getenv("ADMIN_BOOTSTRAP_USERNAME"), os.Getenv("ADMIN_BOOTSTRAP_PASSWORD"), uuid.NewString); err != nil {
		cancel()
		log.Fatalf("Unable to bootstrap initial administrator: %v\n", err)
	}
	adminSessionRepo := postgres.NewAdminSessionRepository(pool)
	auditLogRepo := postgres.NewAuditLogRepository(pool)
	badgeRepo := postgres.NewBadgeRepository(pool)
	announcementReceiptRepo := postgres.NewAnnouncementReceiptRepository(pool)
	announcementRepo := postgres.NewAnnouncementRepository(pool)
	announcementQuerier := postgres.NewAnnouncementQuerier(pool)
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

	deviceTrustService := usecase.NewDeviceTrustService(campRepo, deviceRepo, adminRepo, auditLogRepo, broadcaster, txManager)
	cornerService := usecase.NewCornerService(campRepo, cornerRepo, trackRepo, groupRepo, adminRepo, auditLogRepo, broadcaster, txManager)
	cornerViewQuerier := postgres.NewCornerViewQuerier(pool)
	groupService := usecase.NewGroupService(campRepo, cornerRepo, trackRepo, groupRepo, badgeRepo, visitRepo, auditLogRepo, txManager)
	badgeService := usecase.NewBadgeService(badgeRepo, groupRepo, auditLogRepo, txManager)
	visitService := usecase.NewVisitService(campRepo, cornerRepo, trackRepo, visitRepo, groupRepo, badgeRepo, facilitatorSessionRepo, auditLogRepo, broadcaster, txManager)
	trackService := usecase.NewTrackService(campRepo, cornerRepo, trackRepo, facilitatorSessionRepo, auditLogRepo, broadcaster, txManager, trackPINProtector)
	reportService := usecase.NewReportService(campRepo, reportQuerier)
	authFacilitatorService := usecase.NewFacilitatorAuthService(campRepo, cornerRepo, trackRepo, deviceRepo, facilitatorSessionRepo, auditLogRepo, broadcaster, txManager)
	messageService := usecase.NewMessageService(cornerRepo, trackRepo, messageRepo, auditLogRepo, broadcaster, txManager)
	announcementService := usecase.NewAnnouncementService(announcementRepo, announcementReceiptRepo, campRepo, trackRepo, facilitatorSessionRepo, txManager, auditLogRepo, broadcaster)
	announcementQueryService := usecase.NewAnnouncementQueryService(announcementQuerier, trackRepo, cornerRepo)
	campService := usecase.NewCampService(campRepo, trackRepo, deviceRepo, visitRepo, groupRepo, facilitatorSessionRepo, adminRepo, auditLogRepo, broadcaster, txManager)

	// Initialize Handlers
	authHandler := web.NewAuthHandler(authAdminService, authFacilitatorService, deviceTrustService)
	deviceHandler := web.NewDeviceHandler(deviceTrustService)
	campHandler := web.NewCampHandler(campService)
	cornerHandler := web.NewCornerHandler(cornerService, cornerViewQuerier)
	trackHandler := web.NewTrackHandler(trackService)
	groupHandler := web.NewGroupHandler(groupService)
	badgeHandler := web.NewBadgeHandler(badgeService, groupService)
	visitHandler := web.NewVisitHandler(visitService)

	eventHandler := web.NewEventHandler(broadcaster, trackRepo, cornerRepo)

	messageHandler := web.NewMessageHandler(messageService, announcementService, announcementQueryService)
	reportHandler := web.NewReportHandler(reportService, reportQuerier, campRepo)
	auditHandler := web.NewAuditHandler(auditLogRepo)
	adminManagementHandler := web.NewAdminManagementHandler(authAdminService)
	healthHandler := web.NewHealthHandler(pool)

	handlers := &web.Handlers{
		Auth:            authHandler,
		Device:          deviceHandler,
		Camp:            campHandler,
		Corner:          cornerHandler,
		Track:           trackHandler,
		Group:           groupHandler,
		Badge:           badgeHandler,
		Visit:           visitHandler,
		Event:           eventHandler,
		Message:         messageHandler,
		Report:          reportHandler,
		Audit:           auditHandler,
		AdminManagement: adminManagementHandler,
		Health:          healthHandler,
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

func loadTrackPINEncryptionKey() ([]byte, error) {
	encodedKey := os.Getenv("TRACK_PIN_ENCRYPTION_KEY")
	if encodedKey == "" {
		return nil, fmt.Errorf("must be set")
	}

	key, err := base64.StdEncoding.DecodeString(encodedKey)
	if err != nil {
		return nil, fmt.Errorf("must be valid base64: %w", err)
	}
	if len(key) != 32 {
		return nil, fmt.Errorf("must decode to 32 bytes, got %d", len(key))
	}
	return key, nil
}
