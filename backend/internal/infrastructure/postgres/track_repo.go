package postgres

import (
	"context"
	"time"

	"cornermon/backend/internal/domain"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type pgTrackRepository struct {
	pool *pgxpool.Pool
}

func NewTrackRepository(pool *pgxpool.Pool) *pgTrackRepository {
	return &pgTrackRepository{pool: pool}
}

func (r *pgTrackRepository) conn(ctx context.Context) DBTx {
	if tx := ExtractTx(ctx); tx != nil {
		return tx
	}
	return r.pool
}



func (r *pgTrackRepository) Get(ctx context.Context, id domain.TrackID) (*domain.Track, error) {
	query := `SELECT id, corner_id, track_no, status, pin_hash, current_visit_id, deleted_at FROM tracks WHERE id = $1`
	var t domain.Track
	var currentVisitID *string
	var deletedAt *time.Time

	err := r.conn(ctx).QueryRow(ctx, query, id).Scan(
		&t.ID, &t.CornerID, &t.TrackNo, &t.Status, &t.PINHash, &currentVisitID, &deletedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}
	
	if currentVisitID != nil {
		t.CurrentVisitID = domain.Some(domain.VisitID(*currentVisitID))
	} else {
		t.CurrentVisitID = domain.None[domain.VisitID]()
	}

	if deletedAt != nil {
		t.DeletedAt = domain.Some(*deletedAt)
	} else {
		t.DeletedAt = domain.None[time.Time]()
	}

	return &t, nil
}

func (r *pgTrackRepository) ListByCorner(ctx context.Context, cornerID domain.CornerID) ([]*domain.Track, error) {
	query := `SELECT id, corner_id, track_no, status, pin_hash, current_visit_id, deleted_at FROM tracks WHERE corner_id = $1`
	return r.list(ctx, query, cornerID)
}

func (r *pgTrackRepository) ListActiveByCamp(ctx context.Context, campID domain.CampID) ([]*domain.Track, error) {
	query := `
		SELECT t.id, t.corner_id, t.track_no, t.status, t.pin_hash, t.current_visit_id, t.deleted_at 
		FROM tracks t
		JOIN corners c ON t.corner_id = c.id
		WHERE c.camp_id = $1 AND t.status = 'ACTIVE'
	`
	return r.list(ctx, query, campID)
}

func (r *pgTrackRepository) list(ctx context.Context, query string, args ...interface{}) ([]*domain.Track, error) {
	rows, err := r.conn(ctx).Query(ctx, query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var tracks []*domain.Track
	for rows.Next() {
		var t domain.Track
		var currentVisitID *string
		var deletedAt *time.Time

		if err := rows.Scan(&t.ID, &t.CornerID, &t.TrackNo, &t.Status, &t.PINHash, &currentVisitID, &deletedAt); err != nil {
			return nil, err
		}

		if currentVisitID != nil {
			t.CurrentVisitID = domain.Some(domain.VisitID(*currentVisitID))
		} else {
			t.CurrentVisitID = domain.None[domain.VisitID]()
		}

		if deletedAt != nil {
			t.DeletedAt = domain.Some(*deletedAt)
		} else {
			t.DeletedAt = domain.None[time.Time]()
		}

		tracks = append(tracks, &t)
	}
	return tracks, rows.Err()
}

func (r *pgTrackRepository) Save(ctx context.Context, track *domain.Track) error {
	var currentVisitID *string
	if val, ok := track.CurrentVisitID.Value(); ok {
		s := string(val)
		currentVisitID = &s
	}

	var deletedAt *time.Time
	if val, ok := track.DeletedAt.Value(); ok {
		deletedAt = &val
	}

	query := `
		INSERT INTO tracks (id, corner_id, track_no, status, pin_hash, current_visit_id, deleted_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7)
		ON CONFLICT (id) DO UPDATE SET
			status = EXCLUDED.status,
			pin_hash = EXCLUDED.pin_hash,
			current_visit_id = EXCLUDED.current_visit_id,
			deleted_at = EXCLUDED.deleted_at
	`
	_, err := r.conn(ctx).Exec(ctx, query,
		track.ID, track.CornerID, track.TrackNo, track.Status, track.PINHash, currentVisitID, deletedAt,
	)
	return err
}
