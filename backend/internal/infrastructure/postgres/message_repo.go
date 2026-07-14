package postgres

import (
	"context"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/errs"
	"cornermon/backend/internal/infrastructure/postgres/db"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/jackc/pgx/v5/pgxpool"
)

type pgMessageRepository struct {
	pool *pgxpool.Pool
}

func NewMessageRepository(pool *pgxpool.Pool) *pgMessageRepository {
	return &pgMessageRepository{pool: pool}
}

func (r *pgMessageRepository) queries(ctx context.Context) *db.Queries {
	if tx := ExtractTx(ctx); tx != nil {
		return db.New(tx)
	}
	return db.New(r.pool)
}

func mapMessage(row db.Message) *domain.Message {
	m := &domain.Message{
		ID:          domain.MessageID(row.ID),
		ChannelType: domain.MessageDirect,
		TrackID:     domain.TrackID(row.TrackID),
		SenderRole:  domain.SenderRole(row.SenderRole),
		Content:     row.Content,
		SentAt:      row.SentAt.Time,
	}

	return m
}

func (r *pgMessageRepository) Save(ctx context.Context, msg *domain.Message) error {
	params := db.SaveMessageParams{
		ID:         string(msg.ID),
		TrackID:    string(msg.TrackID),
		SenderRole: string(msg.SenderRole),
		Content:    msg.Content,
		SentAt:     pgtype.Timestamptz{Time: msg.SentAt, Valid: !msg.SentAt.IsZero()},
	}

	err := r.queries(ctx).SaveMessage(ctx, params)
	if err != nil {
		return errs.Wrap(ctx, err)
	}
	return nil
}

func (r *pgMessageRepository) ListMessageByTrack(ctx context.Context, trackID domain.TrackID) ([]*domain.Message, error) {
	rows, err := r.queries(ctx).ListMessagesByTrack(ctx, string(trackID))
	if err != nil {
		return nil, errs.Wrap(ctx, err)
	}
	messages := make([]*domain.Message, len(rows))
	for i, row := range rows {
		messages[i] = mapMessage(row)
	}
	return messages, nil
}
