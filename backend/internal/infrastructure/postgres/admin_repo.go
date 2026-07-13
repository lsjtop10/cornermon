package postgres

import (
	"context"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/errs"
	"cornermon/backend/internal/infrastructure/postgres/db"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type pgAdminRepository struct {
	pool *pgxpool.Pool
}

func NewAdminRepository(pool *pgxpool.Pool) *pgAdminRepository {
	return &pgAdminRepository{pool: pool}
}

func (r *pgAdminRepository) queries(ctx context.Context) *db.Queries {
	if tx := ExtractTx(ctx); tx != nil {
		return db.New(tx)
	}
	return db.New(r.pool)
}

func mapAdmin(row db.Admin) *domain.Admin {
	return &domain.Admin{
		ID:           domain.AdminID(row.ID),
		Username:     row.Username,
		PasswordHash: row.PasswordHash,
	}
}

func (r *pgAdminRepository) Get(ctx context.Context, id domain.AdminID) (*domain.Admin, error) {
	row, err := r.queries(ctx).GetAdmin(ctx, string(id))
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, errs.Wrap(ctx, err)
	}
	return mapAdmin(row), nil
}

func (r *pgAdminRepository) GetByUsername(ctx context.Context, username string) (*domain.Admin, error) {
	row, err := r.queries(ctx).GetAdminByUsername(ctx, username)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, errs.Wrap(ctx, err)
	}
	return mapAdmin(row), nil
}
