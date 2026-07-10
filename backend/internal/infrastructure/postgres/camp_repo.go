package postgres

import (
	"context"
	"time"

	"cornermon/backend/internal/domain"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type pgCampRepository struct {
	pool *pgxpool.Pool
}

func NewCampRepository(pool *pgxpool.Pool) *pgCampRepository {
	return &pgCampRepository{pool: pool}
}

// conn은 트랜잭션이 있으면 트랜잭션을, 없으면 풀을 반환합니다.
func (r *pgCampRepository) conn(ctx context.Context) DBTx {
	if tx := ExtractTx(ctx); tx != nil {
		return tx
	}
	return r.pool
}



func (r *pgCampRepository) Get(ctx context.Context, id domain.CampID) (*domain.Camp, error) {
	query := `SELECT id, name, start_at, end_at, activated_at, ended_at, status, bottleneck_min_samples, bottleneck_ratio_pct FROM camps WHERE id = $1`
	var camp domain.Camp
	var activatedAt *time.Time
	var endedAt *time.Time

	err := r.conn(ctx).QueryRow(ctx, query, id).Scan(
		&camp.ID, &camp.Name, &camp.StartAt, &camp.EndAt, &activatedAt, &endedAt, &camp.Status, &camp.BottleneckMinSamples, &camp.BottleneckRatioPct,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil // or specific domain error
		}
		return nil, err
	}

	if activatedAt != nil {
		camp.ActivatedAt = domain.Some(*activatedAt)
	} else {
		camp.ActivatedAt = domain.None[time.Time]()
	}

	if endedAt != nil {
		camp.EndedAt = domain.Some(*endedAt)
	} else {
		camp.EndedAt = domain.None[time.Time]()
	}

	return &camp, nil
}

func (r *pgCampRepository) Save(ctx context.Context, camp *domain.Camp) error {
	var activatedAt *time.Time
	if val, ok := camp.ActivatedAt.Value(); ok {
		activatedAt = &val
	}

	var endedAt *time.Time
	if val, ok := camp.EndedAt.Value(); ok {
		endedAt = &val
	}

	query := `
		INSERT INTO camps (id, name, start_at, end_at, activated_at, ended_at, status, bottleneck_min_samples, bottleneck_ratio_pct)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
		ON CONFLICT (id) DO UPDATE SET
			name = EXCLUDED.name,
			start_at = EXCLUDED.start_at,
			end_at = EXCLUDED.end_at,
			activated_at = EXCLUDED.activated_at,
			ended_at = EXCLUDED.ended_at,
			status = EXCLUDED.status,
			bottleneck_min_samples = EXCLUDED.bottleneck_min_samples,
			bottleneck_ratio_pct = EXCLUDED.bottleneck_ratio_pct
	`
	_, err := r.conn(ctx).Exec(ctx, query,
		camp.ID, camp.Name, camp.StartAt, camp.EndAt, activatedAt, endedAt, camp.Status, camp.BottleneckMinSamples, camp.BottleneckRatioPct,
	)
	return err
}
