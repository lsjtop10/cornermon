package postgres

import (
	"context"

	"cornermon/backend/internal/domain"
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
		ChannelType: domain.MessageChannelType(row.ChannelType),
		SenderRole:  domain.SenderRole(row.SenderRole),
		Content:     row.Content,
		SentAt:      row.SentAt.Time,
	}

	if row.TrackID.Valid {
		m.TrackID = domain.Some(domain.TrackID(row.TrackID.String))
	} else {
		m.TrackID = domain.None[domain.TrackID]()
	}

	return m
}

func (r *pgMessageRepository) Save(ctx context.Context, msg *domain.Message) error {
	params := db.SaveMessageParams{
		ID:          string(msg.ID),
		ChannelType: string(msg.ChannelType),
		SenderRole:  string(msg.SenderRole),
		Content:     msg.Content,
		SentAt:      pgtype.Timestamptz{Time: msg.SentAt, Valid: !msg.SentAt.IsZero()},
	}

	if val, ok := msg.TrackID.Value(); ok {
		params.TrackID = pgtype.Text{String: string(val), Valid: true}
	}

	return r.queries(ctx).SaveMessage(ctx, params)
}

func (r *pgMessageRepository) ListBroadcastsByCamp(ctx context.Context, campID domain.CampID) ([]*domain.Message, error) {
	rows, err := r.queries(ctx).ListBroadcastMessagesByCamp(ctx)
	if err != nil {
		return nil, err
	}

	messages := make([]*domain.Message, len(rows))
	for i, row := range rows {
		messages[i] = mapMessage(row)
	}
	return messages, nil
}

func (r *pgMessageRepository) ListDirectByTrack(ctx context.Context, trackID domain.TrackID) ([]*domain.Message, error) {
	rows, err := r.queries(ctx).ListDirectMessagesByTrack(ctx, pgtype.Text{String: string(trackID), Valid: true})
	if err != nil {
		return nil, err
	}

	messages := make([]*domain.Message, len(rows))
	for i, row := range rows {
		messages[i] = mapMessage(row)
	}
	return messages, nil
}
