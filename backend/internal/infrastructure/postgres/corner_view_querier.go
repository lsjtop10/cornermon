package postgres

import (
	"context"
	"encoding/json"
	"fmt"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/errs"
	"cornermon/backend/internal/infrastructure/postgres/db"
	"cornermon/backend/internal/usecase"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type pgCornerViewQuerier struct {
	pool *pgxpool.Pool
}

func NewCornerViewQuerier(pool *pgxpool.Pool) *pgCornerViewQuerier {
	return &pgCornerViewQuerier{pool: pool}
}

func (r *pgCornerViewQuerier) queries(ctx context.Context) *db.Queries {
	if tx := ExtractTx(ctx); tx != nil {
		return db.New(tx)
	}
	return db.New(r.pool)
}

func mapCornerView(id, name string, targetMinutes int32, avgDurationSeconds float64, sampleCount int64, activeTracksValue any) (usecase.CornerView, error) {
	view := usecase.CornerView{
		ID:                 domain.CornerID(id),
		Name:               name,
		TargetMinutes:      int(targetMinutes),
		AvgDurationSeconds: int(avgDurationSeconds),
		SampleCount:        int(sampleCount),
	}
	activeTracksJSON, ok := activeTracksValue.([]byte)
	if !ok {
		return usecase.CornerView{}, fmt.Errorf("unexpected active_tracks type %T", activeTracksValue)
	}
	if err := json.Unmarshal(activeTracksJSON, &view.ActiveTracks); err != nil {
		return usecase.CornerView{}, err
	}
	return view, nil
}

func (r *pgCornerViewQuerier) ListCornerViewsByCamp(ctx context.Context, campID domain.CampID) ([]usecase.CornerView, error) {
	rows, err := r.queries(ctx).ListCornerViewsByCamp(ctx, string(campID))
	if err != nil {
		return nil, errs.Wrap(ctx, err)
	}
	views := make([]usecase.CornerView, len(rows))
	for i, row := range rows {
		view, err := mapCornerView(row.ID, row.Name, row.TargetMinutes, row.AvgDurationSeconds, row.SampleCount, row.ActiveTracks)
		if err != nil {
			return nil, errs.Wrap(ctx, err)
		}
		views[i] = view
	}
	return views, nil
}

func (r *pgCornerViewQuerier) GetCornerView(ctx context.Context, id domain.CornerID) (*usecase.CornerView, error) {
	row, err := r.queries(ctx).GetCornerView(ctx, string(id))
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, errs.Wrap(ctx, err)
	}
	view, err := mapCornerView(row.ID, row.Name, row.TargetMinutes, row.AvgDurationSeconds, row.SampleCount, row.ActiveTracks)
	if err != nil {
		return nil, errs.Wrap(ctx, err)
	}
	return &view, nil
}
