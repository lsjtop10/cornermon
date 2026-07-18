package postgres

import (
	"context"
	"time"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/errs"
	"cornermon/backend/internal/infrastructure/postgres/db"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/jackc/pgx/v5/pgxpool"
)

type pgFacilitatorSessionRepository struct {
	pool *pgxpool.Pool
}

func NewFacilitatorSessionRepository(pool *pgxpool.Pool) *pgFacilitatorSessionRepository {
	return &pgFacilitatorSessionRepository{pool: pool}
}

func (r *pgFacilitatorSessionRepository) queries(ctx context.Context) *db.Queries {
	if tx := ExtractTx(ctx); tx != nil {
		return db.New(tx)
	}
	return db.New(r.pool)
}

func mapFacilitatorSession(row db.FacilitatorSession) *domain.FacilitatorSession {
	s := domain.NewFacilitatorSessionFromProps(domain.FacilitatorSessionProps{
		ID:        domain.FacilitatorSessionID(row.ID),
		TrackID:   domain.TrackID(row.TrackID),
		TokenHash: row.TokenHash,
		CreatedAt: row.CreatedAt.Time,
	})

	if row.RevokedAt.Valid {
		s.SetRevokedAt(domain.Some(row.RevokedAt.Time))
	} else {
		s.SetRevokedAt(domain.None[time.Time]())
	}

	return s
}

func (r *pgFacilitatorSessionRepository) Get(ctx context.Context, id domain.FacilitatorSessionID) (*domain.FacilitatorSession, error) {
	row, err := r.queries(ctx).GetFacilitatorSession(ctx, string(id))
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, errs.Wrap(ctx, err)
	}
	return mapFacilitatorSession(row), nil
}

func (r *pgFacilitatorSessionRepository) GetByTokenHash(ctx context.Context, hash string) (*domain.FacilitatorSession, error) {
	row, err := r.queries(ctx).GetFacilitatorSessionByTokenHash(ctx, hash)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, errs.Wrap(ctx, err)
	}
	return mapFacilitatorSession(row), nil
}

func (r *pgFacilitatorSessionRepository) ListActiveByTrack(ctx context.Context, trackID domain.TrackID) ([]*domain.FacilitatorSession, error) {
	rows, err := r.queries(ctx).ListActiveFacilitatorSessionsByTrack(ctx, string(trackID))
	if err != nil {
		return nil, errs.Wrap(ctx, err)
	}

	sessions := make([]*domain.FacilitatorSession, len(rows))
	for i, row := range rows {
		sessions[i] = mapFacilitatorSession(row)
	}
	return sessions, nil
}

func (r *pgFacilitatorSessionRepository) ListActiveByCamp(ctx context.Context, campID domain.CampID) ([]*domain.FacilitatorSession, error) {
	rows, err := r.queries(ctx).ListActiveFacilitatorSessionsByCamp(ctx, string(campID))
	if err != nil {
		return nil, errs.Wrap(ctx, err)
	}

	sessions := make([]*domain.FacilitatorSession, len(rows))
	for i, row := range rows {
		sessions[i] = mapFacilitatorSession(row)
	}
	return sessions, nil
}

func (r *pgFacilitatorSessionRepository) Save(ctx context.Context, session *domain.FacilitatorSession) error {
	params := db.SaveFacilitatorSessionParams{
		ID:        string(session.ID()),
		TrackID:   string(session.TrackID()),
		TokenHash: session.TokenHash(),
		CreatedAt: pgtype.Timestamptz{Time: session.CreatedAt(), Valid: !session.CreatedAt().IsZero()},
	}

	if val, ok := session.RevokedAt().Value(); ok {
		params.RevokedAt = pgtype.Timestamptz{Time: val, Valid: true}
	}

	err := r.queries(ctx).SaveFacilitatorSession(ctx, params)
	if err != nil {
		return errs.Wrap(ctx, err)
	}
	return nil
}
