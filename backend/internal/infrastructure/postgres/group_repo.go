package postgres

import (
	"context"
	"encoding/json"

	"cornermon/backend/internal/domain"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type pgGroupRepository struct {
	pool *pgxpool.Pool
}

func NewGroupRepository(pool *pgxpool.Pool) *pgGroupRepository {
	return &pgGroupRepository{pool: pool}
}

func (r *pgGroupRepository) conn(ctx context.Context) DBTx {
	if tx := ExtractTx(ctx); tx != nil {
		return tx
	}
	return r.pool
}

func (r *pgGroupRepository) Get(ctx context.Context, id domain.GroupID) (*domain.Group, error) {
	query := `SELECT id, camp_id, name, badge_id, itinerary FROM groups WHERE id = $1`
	return r.get(ctx, query, id)
}

func (r *pgGroupRepository) GetByBadge(ctx context.Context, campID domain.CampID, badgeID domain.BadgeID) (*domain.Group, error) {
	query := `SELECT id, camp_id, name, badge_id, itinerary FROM groups WHERE camp_id = $1 AND badge_id = $2`
	return r.get(ctx, query, campID, badgeID)
}

func (r *pgGroupRepository) ListByCamp(ctx context.Context, campID domain.CampID) ([]*domain.Group, error) {
	query := `SELECT id, camp_id, name, badge_id, itinerary FROM groups WHERE camp_id = $1`
	rows, err := r.conn(ctx).Query(ctx, query, campID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var groups []*domain.Group
	for rows.Next() {
		var g domain.Group
		var itineraryJSON []byte

		if err := rows.Scan(&g.ID, &g.CampID, &g.Name, &g.BadgeID, &itineraryJSON); err != nil {
			return nil, err
		}

		if len(itineraryJSON) > 0 {
			if err := json.Unmarshal(itineraryJSON, &g.Itinerary); err != nil {
				return nil, err
			}
		}

		groups = append(groups, &g)
	}
	return groups, rows.Err()
}

func (r *pgGroupRepository) get(ctx context.Context, query string, args ...interface{}) (*domain.Group, error) {
	var g domain.Group
	var itineraryJSON []byte

	err := r.conn(ctx).QueryRow(ctx, query, args...).Scan(
		&g.ID, &g.CampID, &g.Name, &g.BadgeID, &itineraryJSON,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}

	if len(itineraryJSON) > 0 {
		if err := json.Unmarshal(itineraryJSON, &g.Itinerary); err != nil {
			return nil, err
		}
	}

	return &g, nil
}

func (r *pgGroupRepository) Save(ctx context.Context, group *domain.Group) error {
	itineraryJSON, err := json.Marshal(group.Itinerary)
	if err != nil {
		return err
	}

	query := `
		INSERT INTO groups (id, camp_id, name, badge_id, itinerary)
		VALUES ($1, $2, $3, $4, $5)
		ON CONFLICT (id) DO UPDATE SET
			name = EXCLUDED.name,
			badge_id = EXCLUDED.badge_id,
			itinerary = EXCLUDED.itinerary
	`
	_, err = r.conn(ctx).Exec(ctx, query,
		group.ID, group.CampID, group.Name, group.BadgeID, itineraryJSON,
	)
	return err
}
