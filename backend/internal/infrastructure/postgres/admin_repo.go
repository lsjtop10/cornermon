package postgres

import (
	"context"

	"cornermon/backend/internal/domain"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type pgAdminRepository struct {
	pool *pgxpool.Pool
}

func NewAdminRepository(pool *pgxpool.Pool) *pgAdminRepository {
	return &pgAdminRepository{pool: pool}
}

func (r *pgAdminRepository) conn(ctx context.Context) DBTx {
	if tx := ExtractTx(ctx); tx != nil {
		return tx
	}
	return r.pool
}

func (r *pgAdminRepository) Get(ctx context.Context, id domain.AdminID) (*domain.Admin, error) {
	query := `SELECT id, username, password_hash FROM admins WHERE id = $1`
	return r.get(ctx, query, id)
}

func (r *pgAdminRepository) GetByUsername(ctx context.Context, username string) (*domain.Admin, error) {
	query := `SELECT id, username, password_hash FROM admins WHERE username = $1`
	return r.get(ctx, query, username)
}

func (r *pgAdminRepository) get(ctx context.Context, query string, args ...interface{}) (*domain.Admin, error) {
	var a domain.Admin
	err := r.conn(ctx).QueryRow(ctx, query, args...).Scan(
		&a.ID, &a.Username, &a.PasswordHash,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}
	return &a, nil
}
