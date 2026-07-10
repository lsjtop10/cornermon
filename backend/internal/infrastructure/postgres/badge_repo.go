package postgres

import (
	"context"

	"cornermon/backend/internal/domain"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type pgBadgeRepository struct {
	pool *pgxpool.Pool
}

func NewBadgeRepository(pool *pgxpool.Pool) *pgBadgeRepository {
	return &pgBadgeRepository{pool: pool}
}

func (r *pgBadgeRepository) conn(ctx context.Context) DBTx {
	if tx := ExtractTx(ctx); tx != nil {
		return tx
	}
	return r.pool
}

func (r *pgBadgeRepository) Get(ctx context.Context, id domain.BadgeID) (*domain.Badge, error) {
	query := `SELECT id, short_id, qr_payload, status, assigned_group_id FROM badges WHERE id = $1`
	return r.get(ctx, query, id)
}

func (r *pgBadgeRepository) GetByQRPayload(ctx context.Context, payload string) (*domain.Badge, error) {
	query := `SELECT id, short_id, qr_payload, status, assigned_group_id FROM badges WHERE qr_payload = $1`
	return r.get(ctx, query, payload)
}

func (r *pgBadgeRepository) get(ctx context.Context, query string, args ...interface{}) (*domain.Badge, error) {
	var b domain.Badge
	var assignedGroupID *string

	err := r.conn(ctx).QueryRow(ctx, query, args...).Scan(
		&b.ID, &b.ShortID, &b.QRPayload, &b.Status, &assignedGroupID,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}

	if assignedGroupID != nil {
		b.AssignedGroupID = domain.Some(domain.GroupID(*assignedGroupID))
	} else {
		b.AssignedGroupID = domain.None[domain.GroupID]()
	}

	return &b, nil
}

func (r *pgBadgeRepository) Save(ctx context.Context, badge *domain.Badge) error {
	var assignedGroupID *string
	if val, ok := badge.AssignedGroupID.Value(); ok {
		s := string(val)
		assignedGroupID = &s
	}

	query := `
		INSERT INTO badges (id, short_id, qr_payload, status, assigned_group_id)
		VALUES ($1, $2, $3, $4, $5)
		ON CONFLICT (id) DO UPDATE SET
			status = EXCLUDED.status,
			assigned_group_id = EXCLUDED.assigned_group_id
	`
	_, err := r.conn(ctx).Exec(ctx, query,
		badge.ID, badge.ShortID, badge.QRPayload, badge.Status, assignedGroupID,
	)
	return err
}
