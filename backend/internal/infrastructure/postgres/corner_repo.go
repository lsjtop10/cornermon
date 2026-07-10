package postgres

import (
	"context"

	"cornermon/backend/internal/domain"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type pgCornerRepository struct {
	pool *pgxpool.Pool
}

func NewCornerRepository(pool *pgxpool.Pool) *pgCornerRepository {
	return &pgCornerRepository{pool: pool}
}

func (r *pgCornerRepository) conn(ctx context.Context) DBTx {
	if tx := ExtractTx(ctx); tx != nil {
		return tx
	}
	return r.pool
}



func (r *pgCornerRepository) Get(ctx context.Context, id domain.CornerID) (*domain.Corner, error) {
	query := `SELECT id, camp_id, name, target_minutes, is_mandatory FROM corners WHERE id = $1`
	var corner domain.Corner
	err := r.conn(ctx).QueryRow(ctx, query, id).Scan(
		&corner.ID, &corner.CampID, &corner.Name, &corner.TargetMinutes, &corner.IsMandatory,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}
	return &corner, nil
}

func (r *pgCornerRepository) ListByCamp(ctx context.Context, campID domain.CampID) ([]*domain.Corner, error) {
	query := `SELECT id, camp_id, name, target_minutes, is_mandatory FROM corners WHERE camp_id = $1`
	rows, err := r.conn(ctx).Query(ctx, query, campID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var corners []*domain.Corner
	for rows.Next() {
		var corner domain.Corner
		if err := rows.Scan(&corner.ID, &corner.CampID, &corner.Name, &corner.TargetMinutes, &corner.IsMandatory); err != nil {
			return nil, err
		}
		corners = append(corners, &corner)
	}
	return corners, rows.Err()
}

func (r *pgCornerRepository) Save(ctx context.Context, corner *domain.Corner) error {
	query := `
		INSERT INTO corners (id, camp_id, name, target_minutes, is_mandatory)
		VALUES ($1, $2, $3, $4, $5)
		ON CONFLICT (id) DO UPDATE SET
			name = EXCLUDED.name,
			target_minutes = EXCLUDED.target_minutes,
			is_mandatory = EXCLUDED.is_mandatory
	`
	_, err := r.conn(ctx).Exec(ctx, query,
		corner.ID, corner.CampID, corner.Name, corner.TargetMinutes, corner.IsMandatory,
	)
	return err
}
