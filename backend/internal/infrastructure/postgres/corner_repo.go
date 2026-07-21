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

type pgCornerRepository struct {
	pool *pgxpool.Pool
}

func NewCornerRepository(pool *pgxpool.Pool) *pgCornerRepository {
	return &pgCornerRepository{pool: pool}
}

func (r *pgCornerRepository) queries(ctx context.Context) *db.Queries {
	if tx := ExtractTx(ctx); tx != nil {
		return db.New(tx)
	}
	return db.New(r.pool)
}

func mapCorner(row db.Corner) *domain.Corner {
	return domain.NewCornerFromProps(domain.CornerProps{
		ID:            domain.CornerID(row.ID),
		CampID:        domain.CampID(row.CampID),
		Name:          row.Name,
		TargetMinutes: int(row.TargetMinutes),
		IsMandatory:   row.IsMandatory,
	})
}

func (r *pgCornerRepository) Get(ctx context.Context, id domain.CornerID) (*domain.Corner, error) {
	row, err := r.queries(ctx).GetCorner(ctx, string(id))
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, errs.Wrap(ctx, err)
	}
	return mapCorner(row), nil
}

func (r *pgCornerRepository) ListByCamp(ctx context.Context, campID domain.CampID) ([]*domain.Corner, error) {
	rows, err := r.queries(ctx).ListCornersByCamp(ctx, string(campID))
	if err != nil {
		return nil, errs.Wrap(ctx, err)
	}

	corners := make([]*domain.Corner, len(rows))
	for i, row := range rows {
		corners[i] = mapCorner(row)
	}
	return corners, nil
}

func (r *pgCornerRepository) Save(ctx context.Context, corner *domain.Corner) error {
	err := r.queries(ctx).SaveCorner(ctx, db.SaveCornerParams{
		ID:            string(corner.ID()),
		CampID:        string(corner.CampID()),
		Name:          corner.Name(),
		TargetMinutes: int32(corner.TargetMinutes()),
		IsMandatory:   corner.IsMandatory(),
	})
	if err != nil {
		return errs.Wrap(ctx, err)
	}
	return nil
}

func (r *pgCornerRepository) SoftDelete(ctx context.Context, id domain.CornerID, deletedAt time.Time) error {
	err := r.queries(ctx).SoftDeleteCorner(ctx, db.SoftDeleteCornerParams{ID: string(id), DeletedAt: pgtype.Timestamptz{Time: deletedAt, Valid: true}})
	if err != nil {
		return errs.Wrap(ctx, err)
	}
	return nil
}

func (r *pgCornerRepository) PurgeDeletedBefore(ctx context.Context, deletedBefore time.Time) (int64, error) {
	count, err := r.queries(ctx).PurgeDeletedCorners(ctx, pgtype.Timestamptz{Time: deletedBefore, Valid: true})
	if err != nil {
		return 0, errs.Wrap(ctx, err)
	}
	return count, nil
}
