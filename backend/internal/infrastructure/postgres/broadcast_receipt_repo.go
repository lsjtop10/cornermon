package postgres

import (
	"context"
	"time"

	"cornermon/backend/internal/domain"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type pgBroadcastReceiptRepository struct {
	pool *pgxpool.Pool
}

func NewBroadcastReceiptRepository(pool *pgxpool.Pool) *pgBroadcastReceiptRepository {
	return &pgBroadcastReceiptRepository{pool: pool}
}

func (r *pgBroadcastReceiptRepository) conn(ctx context.Context) DBTx {
	if tx := ExtractTx(ctx); tx != nil {
		return tx
	}
	return r.pool
}

func (r *pgBroadcastReceiptRepository) Save(ctx context.Context, receipt *domain.BroadcastReceipt) error {
	var readAt *time.Time
	if val, ok := receipt.ReadAt.Value(); ok {
		readAt = &val
	}

	query := `
		INSERT INTO broadcast_receipts (message_id, track_id, read_at)
		VALUES ($1, $2, $3)
		ON CONFLICT (message_id, track_id) DO UPDATE SET
			read_at = EXCLUDED.read_at
	`
	_, err := r.conn(ctx).Exec(ctx, query,
		receipt.MessageID, receipt.TrackID, readAt,
	)
	return err
}

func (r *pgBroadcastReceiptRepository) GetByMessageAndTrack(ctx context.Context, msgID domain.MessageID, trackID domain.TrackID) (*domain.BroadcastReceipt, error) {
	query := `SELECT message_id, track_id, read_at FROM broadcast_receipts WHERE message_id = $1 AND track_id = $2`
	var br domain.BroadcastReceipt
	var readAt *time.Time

	err := r.conn(ctx).QueryRow(ctx, query, msgID, trackID).Scan(
		&br.MessageID, &br.TrackID, &readAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}

	if readAt != nil {
		br.ReadAt = domain.Some(*readAt)
	} else {
		br.ReadAt = domain.None[time.Time]()
	}

	return &br, nil
}

func (r *pgBroadcastReceiptRepository) ListByMessage(ctx context.Context, msgID domain.MessageID) ([]*domain.BroadcastReceipt, error) {
	query := `SELECT message_id, track_id, read_at FROM broadcast_receipts WHERE message_id = $1`
	rows, err := r.conn(ctx).Query(ctx, query, msgID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var receipts []*domain.BroadcastReceipt
	for rows.Next() {
		var br domain.BroadcastReceipt
		var readAt *time.Time

		if err := rows.Scan(&br.MessageID, &br.TrackID, &readAt); err != nil {
			return nil, err
		}

		if readAt != nil {
			br.ReadAt = domain.Some(*readAt)
		} else {
			br.ReadAt = domain.None[time.Time]()
		}

		receipts = append(receipts, &br)
	}
	return receipts, rows.Err()
}
