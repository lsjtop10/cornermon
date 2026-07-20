package postgres

import (
	"context"
	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/errs"
	"cornermon/backend/internal/infrastructure/postgres/db"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/jackc/pgx/v5/pgxpool"
)

type pgAnnouncementRepository struct{ pool *pgxpool.Pool }

func NewAnnouncementRepository(pool *pgxpool.Pool) *pgAnnouncementRepository {
	return &pgAnnouncementRepository{pool: pool}
}
func (r *pgAnnouncementRepository) queries(ctx context.Context) *db.Queries {
	if tx := ExtractTx(ctx); tx != nil {
		return db.New(tx)
	}
	return db.New(r.pool)
}

func (r *pgAnnouncementRepository) Save(ctx context.Context, a *domain.Announcement) error {
	err := r.queries(ctx).SaveAnnouncement(ctx, db.SaveAnnouncementParams{ID: string(a.ID()), CampID: string(a.CampID()), SenderRole: string(a.SenderRole()), Content: a.Content(), SentAt: pgtype.Timestamptz{Time: a.SentAt(), Valid: true}})
	if err != nil {
		return errs.Wrap(ctx, err)
	}
	return nil
}
