package main

import (
	"context"
	"log"
	"net/url"
	"os"
	"time"

	"cornermon/backend/internal/infrastructure/postgres"
	"cornermon/backend/internal/usecase"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/joho/godotenv"
)

func main() {
	_ = godotenv.Load()
	databaseURL := loadDatabaseURL()

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	pool, err := pgxpool.New(ctx, databaseURL)
	if err != nil {
		log.Fatalf("connect database: %v", err)
	}
	defer pool.Close()

	count, err := usecase.NewCornerCleanupService(postgres.NewCornerRepository(pool)).PurgeExpired(ctx)
	if err != nil {
		log.Fatalf("purge soft-deleted corners: %v", err)
	}
	log.Printf("purged %d expired soft-deleted corners", count)
}

func loadDatabaseURL() string {
	databaseURL := os.Getenv("DATABASE_URL")
	if databaseURL == "" {
		return "postgres://postgres:postgres@localhost:5432/cornermon?sslmode=disable&timezone=UTC"
	}

	u, err := url.Parse(databaseURL)
	if err != nil {
		return databaseURL
	}
	if password := os.Getenv("DATABASE_PASSWORD"); password != "" {
		username := "postgres"
		if u.User != nil {
			username = u.User.Username()
		}
		u.User = url.UserPassword(username, password)
	}
	query := u.Query()
	query.Set("timezone", "UTC")
	u.RawQuery = query.Encode()
	return u.String()
}
