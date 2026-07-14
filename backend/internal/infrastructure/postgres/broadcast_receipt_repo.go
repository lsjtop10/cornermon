package postgres

import (
	"context"
	"time"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/errs"
	"cornermon/backend/internal/infrastructure/postgres/db"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/jackc/pgx/v5/pgxpool"
)

type pgBroadcastReceiptRepository struct {
	pool *pgxpool.Pool
}

func NewBroadcastReceiptRepository(pool *pgxpool.Pool) *pgBroadcastReceiptRepository {
	return &pgBroadcastReceiptRepository{pool: pool}
}

func (r *pgBroadcastReceiptRepository) queries(ctx context.Context) *db.Queries {
	if tx := ExtractTx(ctx); tx != nil {
		return db.New(tx)
	}
	return db.New(r.pool)
}

func mapBroadcastReceipt(row db.BroadcastReceipt) *domain.BroadcastReceipt {
	br := &domain.BroadcastReceipt{
		MessageID: domain.MessageID(row.MessageID),
		TrackID:   domain.TrackID(row.TrackID),
	}

	if row.ReadAt.Valid {
		br.ReadAt = domain.Some(row.ReadAt.Time)
	} else {
		br.ReadAt = domain.None[time.Time]()
	}

	return br
}

func (r *pgBroadcastReceiptRepository) Save(ctx context.Context, receipt *domain.BroadcastReceipt) error {
	params := db.SaveBroadcastReceiptParams{
		MessageID: string(receipt.MessageID),
		TrackID:   string(receipt.TrackID),
	}

	if val, ok := receipt.ReadAt.Value(); ok {
		params.ReadAt = pgtype.Timestamptz{Time: val, Valid: true}
	}

	err := r.queries(ctx).SaveBroadcastReceipt(ctx, params)
	if err != nil {
		return errs.Wrap(ctx, err)
	}
	return nil
}

func (r *pgBroadcastReceiptRepository) GetByMessageAndTrack(ctx context.Context, msgID domain.MessageID, trackID domain.TrackID) (*domain.BroadcastReceipt, error) {
	row, err := r.queries(ctx).GetBroadcastReceiptByMessageAndTrack(ctx, db.GetBroadcastReceiptByMessageAndTrackParams{
		MessageID: string(msgID),
		TrackID:   string(trackID),
	})
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, errs.Wrap(ctx, err)
	}
	return mapBroadcastReceipt(row), nil
}

func (r *pgBroadcastReceiptRepository) ListByMessage(ctx context.Context, msgID domain.MessageID) ([]*domain.BroadcastReceipt, error) {
	rows, err := r.queries(ctx).ListBroadcastReceiptsByMessage(ctx, string(msgID))
	if err != nil {
		return nil, errs.Wrap(ctx, err)
	}

	receipts := make([]*domain.BroadcastReceipt, len(rows))
	for i, row := range rows {
		receipts[i] = mapBroadcastReceipt(row)
	}
	return receipts, nil
}
