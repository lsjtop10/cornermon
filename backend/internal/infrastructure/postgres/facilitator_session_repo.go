package postgres

import (
	"context"
	"time"

	"cornermon/backend/internal/domain"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type pgFacilitatorSessionRepository struct {
	pool *pgxpool.Pool
}

func NewFacilitatorSessionRepository(pool *pgxpool.Pool) *pgFacilitatorSessionRepository {
	return &pgFacilitatorSessionRepository{pool: pool}
}

func (r *pgFacilitatorSessionRepository) conn(ctx context.Context) DBTx {
	if tx := ExtractTx(ctx); tx != nil {
		return tx
	}
	return r.pool
}

func (r *pgFacilitatorSessionRepository) GetByTokenHash(ctx context.Context, hash string) (*domain.FacilitatorSession, error) {
	query := `SELECT id, track_id, token_hash, created_at, revoked_at FROM facilitator_sessions WHERE token_hash = $1`
	var s domain.FacilitatorSession
	var revokedAt *time.Time

	err := r.conn(ctx).QueryRow(ctx, query, hash).Scan(
		&s.ID, &s.TrackID, &s.TokenHash, &s.CreatedAt, &revokedAt,
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

func (r *pgFacilitatorSessionRepository) ListActiveByTrack(ctx context.Context, trackID domain.TrackID) ([]*domain.FacilitatorSession, error) {
	query := `SELECT id, track_id, token_hash, created_at, revoked_at FROM facilitator_sessions WHERE track_id = $1 AND revoked_at IS NULL`
	return r.list(ctx, query, trackID)
}

func (r *pgFacilitatorSessionRepository) ListActiveByCamp(ctx context.Context, campID domain.CampID) ([]*domain.FacilitatorSession, error) {
	query := `
		SELECT f.id, f.track_id, f.token_hash, f.created_at, f.revoked_at 
		FROM facilitator_sessions f
		JOIN tracks t ON f.track_id = t.id
		JOIN corners c ON t.corner_id = c.id
		WHERE c.camp_id = $1 AND f.revoked_at IS NULL
	`
	return r.list(ctx, query, campID)
}

func (r *pgFacilitatorSessionRepository) list(ctx context.Context, query string, args ...interface{}) ([]*domain.FacilitatorSession, error) {
	rows, err := r.conn(ctx).Query(ctx, query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var sessions []*domain.FacilitatorSession
	for rows.Next() {
		var s domain.FacilitatorSession
		var revokedAt *time.Time

		if err := rows.Scan(&s.ID, &s.TrackID, &s.TokenHash, &s.CreatedAt, &revokedAt); err != nil {
			return nil, err
		}

		if revokedAt != nil {
			s.RevokedAt = domain.Some(*revokedAt)
		} else {
			s.RevokedAt = domain.None[time.Time]()
		}

		sessions = append(sessions, &s)
	}
	return sessions, rows.Err()
}

func (r *pgFacilitatorSessionRepository) Save(ctx context.Context, session *domain.FacilitatorSession) error {
	var revokedAt *time.Time
	if val, ok := session.RevokedAt.Value(); ok {
		revokedAt = &val
	}

	query := `
		INSERT INTO facilitator_sessions (id, track_id, token_hash, created_at, revoked_at)
		VALUES ($1, $2, $3, $4, $5)
		ON CONFLICT (id) DO UPDATE SET
			revoked_at = EXCLUDED.revoked_at
	`
	_, err := r.conn(ctx).Exec(ctx, query,
		session.ID, session.TrackID, session.TokenHash, session.CreatedAt, revokedAt,
	)
	return err
}
