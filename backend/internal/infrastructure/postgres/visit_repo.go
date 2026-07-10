package postgres

import (
	"context"
	"time"

	"cornermon/backend/internal/domain"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type pgVisitRepository struct {
	pool *pgxpool.Pool
}

func NewVisitRepository(pool *pgxpool.Pool) *pgVisitRepository {
	return &pgVisitRepository{pool: pool}
}

func (r *pgVisitRepository) conn(ctx context.Context) DBTx {
	if tx := ExtractTx(ctx); tx != nil {
		return tx
	}
	return r.pool
}

func (r *pgVisitRepository) Get(ctx context.Context, id domain.VisitID) (*domain.Visit, error) {
	query := `SELECT id, group_id, corner_id, track_id, status, input_method, started_at, ended_at FROM visits WHERE id = $1`
	var v domain.Visit
	var endedAt *time.Time
	err := r.conn(ctx).QueryRow(ctx, query, id).Scan(
		&v.ID, &v.GroupID, &v.CornerID, &v.TrackID, &v.Status, &v.InputMethod, &v.StartedAt, &endedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}
	if endedAt != nil {
		v.EndedAt = domain.Some(*endedAt)
	} else {
		v.EndedAt = domain.None[time.Time]()
	}
	return &v, nil
}

func (r *pgVisitRepository) GetInProgressByTrack(ctx context.Context, trackID domain.TrackID) (*domain.Visit, error) {
	query := `SELECT id, group_id, corner_id, track_id, status, input_method, started_at, ended_at FROM visits WHERE track_id = $1 AND status = 'IN_PROGRESS'`
	return r.get(ctx, query, trackID)
}

func (r *pgVisitRepository) GetCompletedByGroupAndCorner(ctx context.Context, groupID domain.GroupID, cornerID domain.CornerID) (*domain.Visit, error) {
	query := `SELECT id, group_id, corner_id, track_id, status, input_method, started_at, ended_at FROM visits WHERE group_id = $1 AND corner_id = $2 AND status = 'COMPLETED' ORDER BY ended_at DESC LIMIT 1`
	return r.get(ctx, query, groupID, cornerID)
}

func (r *pgVisitRepository) get(ctx context.Context, query string, args ...interface{}) (*domain.Visit, error) {
	var v domain.Visit
	var endedAt *time.Time
	err := r.conn(ctx).QueryRow(ctx, query, args...).Scan(
		&v.ID, &v.GroupID, &v.CornerID, &v.TrackID, &v.Status, &v.InputMethod, &v.StartedAt, &endedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}
	if endedAt != nil {
		v.EndedAt = domain.Some(*endedAt)
	} else {
		v.EndedAt = domain.None[time.Time]()
	}
	return &v, nil
}

func (r *pgVisitRepository) Save(ctx context.Context, visit *domain.Visit) error {
	var endedAt *time.Time
	if val, ok := visit.EndedAt.Value(); ok {
		endedAt = &val
	}

	query := `
		INSERT INTO visits (id, group_id, corner_id, track_id, status, input_method, started_at, ended_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
		ON CONFLICT (id) DO UPDATE SET
			status = EXCLUDED.status,
			ended_at = EXCLUDED.ended_at
	`
	_, err := r.conn(ctx).Exec(ctx, query,
		visit.ID, visit.GroupID, visit.CornerID, visit.TrackID, visit.Status, visit.InputMethod, visit.StartedAt, endedAt,
	)
	return err
}
