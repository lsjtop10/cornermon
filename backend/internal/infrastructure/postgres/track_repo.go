package postgres

import (
	"context"
	"time"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/infrastructure/postgres/db"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/jackc/pgx/v5/pgxpool"
)

type pgTrackRepository struct {
	pool *pgxpool.Pool
}

func NewTrackRepository(pool *pgxpool.Pool) *pgTrackRepository {
	return &pgTrackRepository{pool: pool}
}

func (r *pgTrackRepository) queries(ctx context.Context) *db.Queries {
	if tx := ExtractTx(ctx); tx != nil {
		return db.New(tx)
	}
	return db.New(r.pool)
}

func mapTrack(row db.Track) *domain.Track {
	t := &domain.Track{
		ID:       domain.TrackID(row.ID),
		CornerID: domain.CornerID(row.CornerID),
		TrackNo:  int(row.TrackNo),
		Status:   domain.TrackStatus(row.Status),
		PINHash:  row.PinHash,
	}

	if row.CurrentVisitID.Valid {
		t.CurrentVisitID = domain.Some(domain.VisitID(row.CurrentVisitID.String))
	} else {
		t.CurrentVisitID = domain.None[domain.VisitID]()
	}

	if row.DeletedAt.Valid {
		t.DeletedAt = domain.Some(row.DeletedAt.Time)
	} else {
		t.DeletedAt = domain.None[time.Time]()
	}

	return t
}

func (r *pgTrackRepository) Get(ctx context.Context, id domain.TrackID) (*domain.Track, error) {
	row, err := r.queries(ctx).GetTrack(ctx, string(id))
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}
	return mapTrack(row), nil
}

func (r *pgTrackRepository) ListByCorner(ctx context.Context, cornerID domain.CornerID) ([]*domain.Track, error) {
	rows, err := r.queries(ctx).ListTracksByCorner(ctx, string(cornerID))
	if err != nil {
		return nil, err
	}

	tracks := make([]*domain.Track, len(rows))
	for i, row := range rows {
		tracks[i] = mapTrack(row)
	}
	return tracks, nil
}

func (r *pgTrackRepository) ListActiveByCamp(ctx context.Context, campID domain.CampID) ([]*domain.Track, error) {
	rows, err := r.queries(ctx).ListActiveTracksByCamp(ctx, string(campID))
	if err != nil {
		return nil, err
	}

	tracks := make([]*domain.Track, len(rows))
	for i, row := range rows {
		tracks[i] = mapTrack(row)
	}
	return tracks, nil
}

func (r *pgTrackRepository) Save(ctx context.Context, track *domain.Track) error {
	params := db.SaveTrackParams{
		ID:       string(track.ID),
		CornerID: string(track.CornerID),
		TrackNo:  int32(track.TrackNo),
		Status:   string(track.Status),
		PinHash:  track.PINHash,
	}

	if val, ok := track.CurrentVisitID.Value(); ok {
		params.CurrentVisitID = pgtype.Text{String: string(val), Valid: true}
	}

	if val, ok := track.DeletedAt.Value(); ok {
		params.DeletedAt = pgtype.Timestamptz{Time: val, Valid: true}
	}

	return r.queries(ctx).SaveTrack(ctx, params)
}
