package db

import (
	"context"
	"errors"
	"net/url"

	"github.com/golang-migrate/migrate/v4"
	_ "github.com/golang-migrate/migrate/v4/database/pgx/v5"
	"github.com/golang-migrate/migrate/v4/source/iofs"
)

// NewMigrate builds a *migrate.Migrate wired to the embedded MigrationsFS and databaseURL.
// databaseURL is expected to be a postgres:// connection string; the scheme is rewritten
// to pgx5:// internally to select the golang-migrate pgx/v5 driver. Callers own the
// returned instance and must call Close() when done.
func NewMigrate(databaseURL string) (*migrate.Migrate, error) {
	sourceDriver, err := iofs.New(MigrationsFS, "migrations")
	if err != nil {
		return nil, err
	}

	u, err := url.Parse(databaseURL)
	if err != nil {
		return nil, err
	}
	u.Scheme = "pgx5"

	return migrate.NewWithSourceInstance("iofs", sourceDriver, u.String())
}

// RunMigrations applies all pending migrations embedded in MigrationsFS to databaseURL.
func RunMigrations(ctx context.Context, databaseURL string) error {
	if err := ctx.Err(); err != nil {
		return err
	}

	m, err := NewMigrate(databaseURL)
	if err != nil {
		return err
	}
	defer m.Close()

	if err := m.Up(); err != nil && !errors.Is(err, migrate.ErrNoChange) {
		return err
	}
	return nil
}
