package postgres

import (
	"context"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/infrastructure/postgres/db"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/jackc/pgx/v5/pgxpool"
)

type pgBadgeRepository struct {
	pool *pgxpool.Pool
}

func NewBadgeRepository(pool *pgxpool.Pool) *pgBadgeRepository {
	return &pgBadgeRepository{pool: pool}
}

func (r *pgBadgeRepository) queries(ctx context.Context) *db.Queries {
	if tx := ExtractTx(ctx); tx != nil {
		return db.New(tx)
	}
	return db.New(r.pool)
}

func mapBadge(row db.Badge) *domain.Badge {
	b := &domain.Badge{
		ID:        domain.BadgeID(row.ID),
		ShortID:   row.ShortID,
		QRPayload: row.QrPayload,
		Status:    domain.BadgeStatus(row.Status),
	}

	if row.AssignedGroupID.Valid {
		b.AssignedGroupID = domain.Some(domain.GroupID(row.AssignedGroupID.String))
	} else {
		b.AssignedGroupID = domain.None[domain.GroupID]()
	}

	return b
}

func (r *pgBadgeRepository) Get(ctx context.Context, id domain.BadgeID) (*domain.Badge, error) {
	row, err := r.queries(ctx).GetBadge(ctx, string(id))
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}
	return mapBadge(row), nil
}

func (r *pgBadgeRepository) GetByQRPayload(ctx context.Context, payload string) (*domain.Badge, error) {
	row, err := r.queries(ctx).GetBadgeByQRPayload(ctx, payload)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}
	return mapBadge(row), nil
}

func (r *pgBadgeRepository) Save(ctx context.Context, badge *domain.Badge) error {
	params := db.SaveBadgeParams{
		ID:        string(badge.ID),
		ShortID:   badge.ShortID,
		QrPayload: badge.QRPayload,
		Status:    string(badge.Status),
	}

	if val, ok := badge.AssignedGroupID.Value(); ok {
		params.AssignedGroupID = pgtype.Text{String: string(val), Valid: true}
	}

	return r.queries(ctx).SaveBadge(ctx, params)
}
