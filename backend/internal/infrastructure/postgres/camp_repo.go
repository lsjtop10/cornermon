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

type pgCampRepository struct {
	pool *pgxpool.Pool
}

func NewCampRepository(pool *pgxpool.Pool) *pgCampRepository {
	return &pgCampRepository{pool: pool}
}

func (r *pgCampRepository) queries(ctx context.Context) *db.Queries {
	if tx := ExtractTx(ctx); tx != nil {
		return db.New(tx)
	}
	return db.New(r.pool)
}

func (r *pgCampRepository) Get(ctx context.Context, id domain.CampID) (*domain.Camp, error) {
	row, err := r.queries(ctx).GetCamp(ctx, string(id))
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, errs.Wrap(ctx, err)
	}

	camp := &domain.Camp{
		ID:                   domain.CampID(row.ID),
		Name:                 row.Name,
		StartAt:              row.StartAt.Time,
		EndAt:                row.EndAt.Time,
		Status:               domain.CampStatus(row.Status),
		BottleneckMinSamples: int(row.BottleneckMinSamples),
		BottleneckRatioPct:   int(row.BottleneckRatioPct),
	}

	if row.ActivatedAt.Valid {
		camp.ActivatedAt = domain.Some(row.ActivatedAt.Time)
	} else {
		camp.ActivatedAt = domain.None[time.Time]()
	}

	if row.EndedAt.Valid {
		camp.EndedAt = domain.Some(row.EndedAt.Time)
	} else {
		camp.EndedAt = domain.None[time.Time]()
	}

	return camp, nil
}

func (r *pgCampRepository) Save(ctx context.Context, camp *domain.Camp) error {
	params := db.SaveCampParams{
		ID:                   string(camp.ID),
		Name:                 camp.Name,
		StartAt:              pgtype.Timestamptz{Time: camp.StartAt, Valid: !camp.StartAt.IsZero()},
		EndAt:                pgtype.Timestamptz{Time: camp.EndAt, Valid: !camp.EndAt.IsZero()},
		Status:               string(camp.Status),
		BottleneckMinSamples: int32(camp.BottleneckMinSamples),
		BottleneckRatioPct:   int32(camp.BottleneckRatioPct),
	}

	if val, ok := camp.ActivatedAt.Value(); ok {
		params.ActivatedAt = pgtype.Timestamptz{Time: val, Valid: true}
	}

	if val, ok := camp.EndedAt.Value(); ok {
		params.EndedAt = pgtype.Timestamptz{Time: val, Valid: true}
	}

	err := r.queries(ctx).SaveCamp(ctx, params)
	if err != nil {
		return errs.Wrap(ctx, err)
	}
	return nil
}

func (r *pgCampRepository) List(ctx context.Context) ([]*domain.Camp, error) {
	rows, err := r.queries(ctx).ListCamps(ctx)
	if err != nil {
		return nil, errs.Wrap(ctx, err)
	}

	camps := make([]*domain.Camp, len(rows))
	for i, row := range rows {
		camp := &domain.Camp{
			ID:                   domain.CampID(row.ID),
			Name:                 row.Name,
			StartAt:              row.StartAt.Time,
			EndAt:                row.EndAt.Time,
			Status:               domain.CampStatus(row.Status),
			BottleneckMinSamples: int(row.BottleneckMinSamples),
			BottleneckRatioPct:   int(row.BottleneckRatioPct),
		}

		if row.ActivatedAt.Valid {
			camp.ActivatedAt = domain.Some(row.ActivatedAt.Time)
		} else {
			camp.ActivatedAt = domain.None[time.Time]()
		}

		if row.EndedAt.Valid {
			camp.EndedAt = domain.Some(row.EndedAt.Time)
		} else {
			camp.EndedAt = domain.None[time.Time]()
		}

		camps[i] = camp
	}

	return camps, nil
}
