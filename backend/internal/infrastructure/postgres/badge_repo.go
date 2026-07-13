package postgres

import (
	"context"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/errs"
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
		return nil, errs.Wrap(ctx, err)
	}
	return mapBadge(row), nil
}

func (r *pgBadgeRepository) GetByQRPayload(ctx context.Context, payload string) (*domain.Badge, error) {
	row, err := r.queries(ctx).GetBadgeByQRPayload(ctx, payload)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, errs.Wrap(ctx, err)
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

	err := r.queries(ctx).SaveBadge(ctx, params)
	if err != nil {
		return errs.Wrap(ctx, err)
	}
	return nil
}

func (r *pgBadgeRepository) ListAll(ctx context.Context) ([]*domain.Badge, error) {
	rows, err := r.queries(ctx).ListAllBadges(ctx)
	if err != nil {
		return nil, errs.Wrap(ctx, err)
	}

	badges := make([]*domain.Badge, len(rows))
	for i, row := range rows {
		badges[i] = mapBadge(row)
	}
	return badges, nil
}

func (r *pgBadgeRepository) SaveBulk(ctx context.Context, badges []*domain.Badge) error {
	if tx := ExtractTx(ctx); tx != nil {
		for _, b := range badges {
			if err := r.Save(ctx, b); err != nil {
				return err
			}
		}
		return nil
	}

	tx, err := r.pool.BeginTx(ctx, pgx.TxOptions{})
	if err != nil {
		return errs.Wrap(ctx, err)
	}
	defer tx.Rollback(ctx)

	txCtx := context.WithValue(ctx, txKey, tx)
	for _, b := range badges {
		if err := r.Save(txCtx, b); err != nil {
			return err
		}
	}

	err = tx.Commit(ctx)
	if err != nil {
		return errs.Wrap(ctx, err)
	}
	return nil
}
