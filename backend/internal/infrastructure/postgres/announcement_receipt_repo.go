package postgres

import (
	"context"
	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/errs"
	"cornermon/backend/internal/infrastructure/postgres/db"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/jackc/pgx/v5/pgxpool"
	"time"
)

type pgAnnouncementReceiptRepository struct{ pool *pgxpool.Pool }

func NewAnnouncementReceiptRepository(pool *pgxpool.Pool) *pgAnnouncementReceiptRepository {
	return &pgAnnouncementReceiptRepository{pool: pool}
}
func (r *pgAnnouncementReceiptRepository) queries(ctx context.Context) *db.Queries {
	if tx := ExtractTx(ctx); tx != nil {
		return db.New(tx)
	}
	return db.New(r.pool)
}
func mapAnnouncementReceipt(row db.BroadcastReceipt) *domain.AnnouncementReceipt {
	x := &domain.AnnouncementReceipt{NoticeID: domain.AnnouncementID(row.MessageID), TrackID: domain.TrackID(row.TrackID)}
	if row.ReadAt.Valid {
		x.ReadAt = domain.Some(row.ReadAt.Time)
	} else {
		x.ReadAt = domain.None[time.Time]()
	}
	return x
}
func (r *pgAnnouncementReceiptRepository) Save(ctx context.Context, x *domain.AnnouncementReceipt) error {
	var read pgtype.Timestamptz
	if v, ok := x.ReadAt.Value(); ok {
		read = pgtype.Timestamptz{Time: v, Valid: true}
	}
	if err := r.queries(ctx).SaveBroadcastReceipt(ctx, db.SaveBroadcastReceiptParams{MessageID: string(x.NoticeID), TrackID: string(x.TrackID), ReadAt: read}); err != nil {
		return errs.Wrap(ctx, err)
	}
	return nil
}
func (r *pgAnnouncementReceiptRepository) GetByMessageAndTrack(ctx context.Context, id domain.AnnouncementID, track domain.TrackID) (*domain.AnnouncementReceipt, error) {
	row, err := r.queries(ctx).GetBroadcastReceiptByMessageAndTrack(ctx, db.GetBroadcastReceiptByMessageAndTrackParams{MessageID: string(id), TrackID: string(track)})
	if err == pgx.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, errs.Wrap(ctx, err)
	}
	return mapAnnouncementReceipt(row), nil
}
func (r *pgAnnouncementReceiptRepository) ListByMessage(ctx context.Context, id domain.AnnouncementID) ([]*domain.AnnouncementReceipt, error) {
	rows, err := r.queries(ctx).ListBroadcastReceiptsByMessage(ctx, string(id))
	if err != nil {
		return nil, errs.Wrap(ctx, err)
	}
	out := make([]*domain.AnnouncementReceipt, len(rows))
	for i, row := range rows {
		out[i] = mapAnnouncementReceipt(row)
	}
	return out, nil
}
