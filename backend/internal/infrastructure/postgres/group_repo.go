package postgres

import (
	"context"
	"encoding/json"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/infrastructure/postgres/db"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type pgGroupRepository struct {
	pool *pgxpool.Pool
}

func NewGroupRepository(pool *pgxpool.Pool) *pgGroupRepository {
	return &pgGroupRepository{pool: pool}
}

func (r *pgGroupRepository) queries(ctx context.Context) *db.Queries {
	if tx := ExtractTx(ctx); tx != nil {
		return db.New(tx)
	}
	return db.New(r.pool)
}

func mapGroup(row db.Group) (*domain.Group, error) {
	g := &domain.Group{
		ID:      domain.GroupID(row.ID),
		CampID:  domain.CampID(row.CampID),
		Name:    row.Name,
		BadgeID: domain.BadgeID(row.BadgeID),
	}

	if len(row.Itinerary) > 0 {
		if err := json.Unmarshal(row.Itinerary, &g.Itinerary); err != nil {
			return nil, err
		}
	}

	return g, nil
}

func (r *pgGroupRepository) Get(ctx context.Context, id domain.GroupID) (*domain.Group, error) {
	row, err := r.queries(ctx).GetGroup(ctx, string(id))
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}
	return mapGroup(row)
}

func (r *pgGroupRepository) GetByBadge(ctx context.Context, campID domain.CampID, badgeID domain.BadgeID) (*domain.Group, error) {
	row, err := r.queries(ctx).GetGroupByBadge(ctx, db.GetGroupByBadgeParams{
		CampID:  string(campID),
		BadgeID: string(badgeID),
	})
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}
	return mapGroup(row)
}

func (r *pgGroupRepository) ListByCamp(ctx context.Context, campID domain.CampID) ([]*domain.Group, error) {
	rows, err := r.queries(ctx).ListGroupsByCamp(ctx, string(campID))
	if err != nil {
		return nil, err
	}

	groups := make([]*domain.Group, len(rows))
	for i, row := range rows {
		g, err := mapGroup(row)
		if err != nil {
			return nil, err
		}
		groups[i] = g
	}
	return groups, nil
}

func (r *pgGroupRepository) Save(ctx context.Context, group *domain.Group) error {
	itineraryJSON, err := json.Marshal(group.Itinerary)
	if err != nil {
		return err
	}

	return r.queries(ctx).SaveGroup(ctx, db.SaveGroupParams{
		ID:        string(group.ID),
		CampID:    string(group.CampID),
		Name:      group.Name,
		BadgeID:   string(group.BadgeID),
		Itinerary: itineraryJSON,
	})
}
