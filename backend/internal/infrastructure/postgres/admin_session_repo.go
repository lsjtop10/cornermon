package postgres

import (
	"context"
	"time"

	"cornermon/backend/internal/domain"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type pgAdminSessionRepository struct {
	pool *pgxpool.Pool
}

func NewAdminSessionRepository(pool *pgxpool.Pool) *pgAdminSessionRepository {
	return &pgAdminSessionRepository{pool: pool}
}

func (r *pgAdminSessionRepository) conn(ctx context.Context) DBTx {
	if tx := ExtractTx(ctx); tx != nil {
		return tx
	}
	return r.pool
}

func (r *pgAdminSessionRepository) Get(ctx context.Context, id domain.AdminSessionID) (*domain.AdminSession, error) {
	query := `SELECT id, admin_id, access_token_hash, refresh_token_hash, device_info, created_at, last_used_at, revoked_at FROM admin_sessions WHERE id = $1`
	return r.get(ctx, query, id)
}

func (r *pgAdminSessionRepository) GetByAccessTokenHash(ctx context.Context, hash string) (*domain.AdminSession, error) {
	query := `SELECT id, admin_id, access_token_hash, refresh_token_hash, device_info, created_at, last_used_at, revoked_at FROM admin_sessions WHERE access_token_hash = $1`
	return r.get(ctx, query, hash)
}

func (r *pgAdminSessionRepository) GetByRefreshTokenHash(ctx context.Context, hash string) (*domain.AdminSession, error) {
	query := `SELECT id, admin_id, access_token_hash, refresh_token_hash, device_info, created_at, last_used_at, revoked_at FROM admin_sessions WHERE refresh_token_hash = $1`
	return r.get(ctx, query, hash)
}

func (r *pgAdminSessionRepository) get(ctx context.Context, query string, args ...interface{}) (*domain.AdminSession, error) {
	var s domain.AdminSession
	var revokedAt *time.Time

	err := r.conn(ctx).QueryRow(ctx, query, args...).Scan(
		&s.ID, &s.AdminID, &s.AccessTokenHash, &s.RefreshTokenHash, &s.DeviceInfo, &s.CreatedAt, &s.LastUsedAt, &revokedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}

	if revokedAt != nil {
		s.RevokedAt = domain.Some(*revokedAt)
	} else {
		s.RevokedAt = domain.None[time.Time]()
	}

	return &s, nil
}

func (r *pgAdminSessionRepository) Save(ctx context.Context, session *domain.AdminSession) error {
	var revokedAt *time.Time
	if val, ok := session.RevokedAt.Value(); ok {
		revokedAt = &val
	}

	query := `
		INSERT INTO admin_sessions (id, admin_id, access_token_hash, refresh_token_hash, device_info, created_at, last_used_at, revoked_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
		ON CONFLICT (id) DO UPDATE SET
			last_used_at = EXCLUDED.last_used_at,
			revoked_at = EXCLUDED.revoked_at
	`
	_, err := r.conn(ctx).Exec(ctx, query,
		session.ID, session.AdminID, session.AccessTokenHash, session.RefreshTokenHash, session.DeviceInfo, session.CreatedAt, session.LastUsedAt, revokedAt,
	)
	return err
}
