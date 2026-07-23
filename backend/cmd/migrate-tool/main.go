package main

import (
	"errors"
	"log"
	"net/url"
	"os"
	"strconv"

	"cornermon/backend/db"

	"github.com/golang-migrate/migrate/v4"
	"github.com/joho/godotenv"
)

func main() {
	_ = godotenv.Load()

	if len(os.Args) < 2 {
		log.Fatalf("usage: migrate-tool <up|down|force> [version]")
	}

	m, err := db.NewMigrate(loadDatabaseURL())
	if err != nil {
		log.Fatalf("init migrate: %v", err)
	}
	defer m.Close()

	subcommand := os.Args[1]
	switch subcommand {
	case "up":
		err = m.Up()
	case "down":
		err = m.Steps(-1)
	case "force":
		if len(os.Args) < 3 {
			log.Fatalf("usage: migrate-tool force <version>")
		}
		version, convErr := strconv.Atoi(os.Args[2])
		if convErr != nil {
			log.Fatalf("invalid version %q: %v", os.Args[2], convErr)
		}
		err = m.Force(version)
	default:
		log.Fatalf("unknown subcommand %q (expected up|down|force)", subcommand)
	}

	if err != nil && !errors.Is(err, migrate.ErrNoChange) {
		log.Fatalf("migrate %s: %v", subcommand, err)
	}
	log.Printf("migrate %s: done", subcommand)
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
