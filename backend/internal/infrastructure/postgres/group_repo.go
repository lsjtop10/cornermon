package postgres

import (
	"context"
	"encoding/json"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/errs"
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
	g := domain.NewGroupFromProps(domain.GroupProps{
		ID:      domain.GroupID(row.ID),
		CampID:  domain.CampID(row.CampID),
		Name:    row.Name,
		BadgeID: domain.BadgeID(row.BadgeID),
	})

	if len(row.Itinerary) > 0 {
		var itinerary []domain.CornerProgress
		if err := json.Unmarshal(row.Itinerary, &itinerary); err != nil {
			return nil, err
		}
		g.SetItinerary(itinerary)
	}

	return g, nil
}

func (r *pgGroupRepository) Get(ctx context.Context, id domain.GroupID) (*domain.Group, error) {
	row, err := r.queries(ctx).GetGroup(ctx, string(id))
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, errs.Wrap(ctx, err)
	}
	return mapGroup(row)
}

func (r *pgGroupRepository) GetForUpdate(ctx context.Context, id domain.GroupID) (*domain.Group, error) {
	row, err := r.queries(ctx).GetGroupForUpdate(ctx, string(id))
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, errs.Wrap(ctx, err)
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
		return nil, errs.Wrap(ctx, err)
	}
	return mapGroup(row)
}

func (r *pgGroupRepository) ListByCamp(ctx context.Context, campID domain.CampID) ([]*domain.Group, error) {
	rows, err := r.queries(ctx).ListGroupsByCamp(ctx, string(campID))
	if err != nil {
		return nil, errs.Wrap(ctx, err)
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

func (r *pgGroupRepository) ListByCampForUpdate(ctx context.Context, campID domain.CampID) ([]*domain.Group, error) {
	rows, err := r.queries(ctx).ListGroupsByCampForUpdate(ctx, string(campID))
	if err != nil {
		return nil, errs.Wrap(ctx, err)
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
	itineraryJSON, err := json.Marshal(group.Itinerary())
	if err != nil {
		return err
	}

	err = r.queries(ctx).SaveGroup(ctx, db.SaveGroupParams{
		ID:        string(group.ID()),
		CampID:    string(group.CampID()),
		Name:      group.Name(),
		BadgeID:   string(group.BadgeID()),
		Itinerary: itineraryJSON,
	})
	if err != nil {
		return errs.Wrap(ctx, err)
	}
	return nil
}

func (r *pgGroupRepository) SaveBulk(ctx context.Context, groups []*domain.Group) error {
	if tx := ExtractTx(ctx); tx != nil {
		for _, g := range groups {
			if err := r.Save(ctx, g); err != nil {
				return err
			}
		}
		return nil
	}

	tx, err := r.pool.BeginTx(ctx, pgx.TxOptions{})
	if err != nil {
		return errs.Wrap(ctx, err)
	}
	defer tx.Rollback(ctx)

	txCtx := context.WithValue(ctx, txKey, tx)
	for _, g := range groups {
		if err := r.Save(txCtx, g); err != nil {
			return err
		}
	}

	err = tx.Commit(ctx)
	if err != nil {
		return errs.Wrap(ctx, err)
	}
	return nil
}
