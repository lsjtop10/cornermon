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

type pgVisitRepository struct {
	pool *pgxpool.Pool
}

func NewVisitRepository(pool *pgxpool.Pool) *pgVisitRepository {
	return &pgVisitRepository{pool: pool}
}

func (r *pgVisitRepository) queries(ctx context.Context) *db.Queries {
	if tx := ExtractTx(ctx); tx != nil {
		return db.New(tx)
	}
	return db.New(r.pool)
}

func mapVisit(row db.Visit) *domain.Visit {
	v := domain.NewVisitFromProps(domain.VisitProps{
		ID:          domain.VisitID(row.ID),
		GroupID:     domain.GroupID(row.GroupID),
		CornerID:    domain.CornerID(row.CornerID),
		TrackID:     domain.TrackID(row.TrackID),
		Status:      domain.VisitStatus(row.Status),
		InputMethod: domain.VisitInputMethod(row.InputMethod),
		StartedAt:   row.StartedAt.Time,
	})

	if row.EndedAt.Valid {
		v.SetEndedAt(domain.Some(row.EndedAt.Time))
	} else {
		v.SetEndedAt(domain.None[time.Time]())
	}

	return v
}

func (r *pgVisitRepository) Get(ctx context.Context, id domain.VisitID) (*domain.Visit, error) {
	row, err := r.queries(ctx).GetVisit(ctx, string(id))
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, errs.Wrap(ctx, err)
	}
	return mapVisit(row), nil
}

func (r *pgVisitRepository) GetInProgressByTrack(ctx context.Context, trackID domain.TrackID) (*domain.Visit, error) {
	row, err := r.queries(ctx).GetInProgressVisitByTrack(ctx, string(trackID))
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, errs.Wrap(ctx, err)
	}
	return mapVisit(row), nil
}

func (r *pgVisitRepository) GetCompletedByGroupAndCorner(ctx context.Context, groupID domain.GroupID, cornerID domain.CornerID) (*domain.Visit, error) {
	row, err := r.queries(ctx).GetCompletedVisitByGroupAndCorner(ctx, db.GetCompletedVisitByGroupAndCornerParams{
		GroupID:  string(groupID),
		CornerID: string(cornerID),
	})
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, errs.Wrap(ctx, err)
	}
	return mapVisit(row), nil
}

func (r *pgVisitRepository) Save(ctx context.Context, visit *domain.Visit) error {
	params := db.SaveVisitParams{
		ID:          string(visit.ID()),
		GroupID:     string(visit.GroupID()),
		CornerID:    string(visit.CornerID()),
		TrackID:     string(visit.TrackID()),
		Status:      string(visit.Status()),
		InputMethod: string(visit.InputMethod()),
		StartedAt:   pgtype.Timestamptz{Time: visit.StartedAt(), Valid: !visit.StartedAt().IsZero()},
	}

	if val, ok := visit.EndedAt().Value(); ok {
		params.EndedAt = pgtype.Timestamptz{Time: val, Valid: true}
	}

	err := r.queries(ctx).SaveVisit(ctx, params)
	if err != nil {
		return errs.Wrap(ctx, err)
	}
	return nil
}

func (r *pgVisitRepository) ListByGroup(ctx context.Context, groupID domain.GroupID) ([]*domain.Visit, error) {
	rows, err := r.queries(ctx).ListVisitsByGroup(ctx, string(groupID))
	if err != nil {
		return nil, errs.Wrap(ctx, err)
	}
	res := make([]*domain.Visit, len(rows))
	for i, row := range rows {
		res[i] = mapVisit(row)
	}
	return res, nil
}
