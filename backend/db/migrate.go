package db

import (
	"context"
	"errors"
	"net/url"

	"github.com/golang-migrate/migrate/v4"
	_ "github.com/golang-migrate/migrate/v4/database/pgx/v5"
	"github.com/golang-migrate/migrate/v4/source/iofs"
)

// RunMigrations applies all pending migrations embedded in MigrationsFS to databaseURL.
// databaseURL is expected to be a postgres:// connection string; the scheme is rewritten
// to pgx5:// internally to select the golang-migrate pgx/v5 driver.
func RunMigrations(ctx context.Context, databaseURL string) error {
	if err := ctx.Err(); err != nil {
		return err
	}

	sourceDriver, err := iofs.New(MigrationsFS, "migrations")
	if err != nil {
		return err
	}

	u, err := url.Parse(databaseURL)
	if err != nil {
		return err
	}
	u.Scheme = "pgx5"

	m, err := migrate.NewWithSourceInstance("iofs", sourceDriver, u.String())
	if err != nil {
		return err
	}
	defer m.Close()

	if err := m.Up(); err != nil && !errors.Is(err, migrate.ErrNoChange) {
		return err
	}
	return nil
}
