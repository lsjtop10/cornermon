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

type pgAdminSessionRepository struct {
	pool *pgxpool.Pool
}

func NewAdminSessionRepository(pool *pgxpool.Pool) *pgAdminSessionRepository {
	return &pgAdminSessionRepository{pool: pool}
}

func (r *pgAdminSessionRepository) queries(ctx context.Context) *db.Queries {
	if tx := ExtractTx(ctx); tx != nil {
		return db.New(tx)
	}
	return db.New(r.pool)
}

func mapAdminSession(row db.AdminSession) *domain.AdminSession {
	var revokedAt domain.Optional[time.Time]
	if row.RevokedAt.Valid {
		revokedAt = domain.Some(row.RevokedAt.Time)
	} else {
		revokedAt = domain.None[time.Time]()
	}

	s := domain.NewAdminSessionFromProps(domain.AdminSessionProps{
		ID:              domain.AdminSessionID(row.ID),
		AdminID:         domain.AdminID(row.AdminID),
		AccessTokenHash: row.AccessTokenHash,
		DeviceInfo:      row.DeviceInfo,
		CreatedAt:       row.CreatedAt.Time,
		LastUsedAt:      row.LastUsedAt.Time,
		RevokedAt:       revokedAt,
	})

	return s
}

func (r *pgAdminSessionRepository) Get(ctx context.Context, id domain.AdminSessionID) (*domain.AdminSession, error) {
	row, err := r.queries(ctx).GetAdminSession(ctx, string(id))
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, errs.Wrap(ctx, err)
	}
	return mapAdminSession(row), nil
}

func (r *pgAdminSessionRepository) GetByAccessTokenHash(ctx context.Context, hash string) (*domain.AdminSession, error) {
	row, err := r.queries(ctx).GetAdminSessionByAccessTokenHash(ctx, hash)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, errs.Wrap(ctx, err)
	}
	return mapAdminSession(row), nil
}

func (r *pgAdminSessionRepository) Save(ctx context.Context, session *domain.AdminSession) error {
	params := db.SaveAdminSessionParams{
		ID:              string(session.ID()),
		AdminID:         string(session.AdminID()),
		AccessTokenHash: session.AccessTokenHash(),
		DeviceInfo:      session.DeviceInfo(),
		CreatedAt:       pgtype.Timestamptz{Time: session.CreatedAt(), Valid: !session.CreatedAt().IsZero()},
		LastUsedAt:      pgtype.Timestamptz{Time: session.LastUsedAt(), Valid: !session.LastUsedAt().IsZero()},
	}

	if val, ok := session.RevokedAt().Value(); ok {
		params.RevokedAt = pgtype.Timestamptz{Time: val, Valid: true}
	}

	err := r.queries(ctx).SaveAdminSession(ctx, params)
	if err != nil {
		return errs.Wrap(ctx, err)
	}
	return nil
}

func (r *pgAdminSessionRepository) ListByAdmin(ctx context.Context, adminID domain.AdminID) ([]*domain.AdminSession, error) {
	rows, err := r.queries(ctx).ListAdminSessionsByAdmin(ctx, string(adminID))
	if err != nil {
		return nil, errs.Wrap(ctx, err)
	}

	sessions := make([]*domain.AdminSession, len(rows))
	for i, row := range rows {
		sessions[i] = mapAdminSession(row)
	}
	return sessions, nil
}
