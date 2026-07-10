package postgres

import (
	"context"

	"cornermon/backend/internal/domain"
	"github.com/jackc/pgx/v5/pgxpool"
)

type pgMessageRepository struct {
	pool *pgxpool.Pool
}

func NewMessageRepository(pool *pgxpool.Pool) *pgMessageRepository {
	return &pgMessageRepository{pool: pool}
}

func (r *pgMessageRepository) conn(ctx context.Context) DBTx {
	if tx := ExtractTx(ctx); tx != nil {
		return tx
	}
	return r.pool
}

func (r *pgMessageRepository) Save(ctx context.Context, msg *domain.Message) error {
	var trackID *string
	if val, ok := msg.TrackID.Value(); ok {
		s := string(val)
		trackID = &s
	}

	query := `
		INSERT INTO messages (id, channel_type, track_id, sender_role, content, sent_at)
		VALUES ($1, $2, $3, $4, $5, $6)
	`
	_, err := r.conn(ctx).Exec(ctx, query,
		msg.ID, msg.ChannelType, trackID, msg.SenderRole, msg.Content, msg.SentAt,
	)
	return err
}

func (r *pgMessageRepository) ListBroadcastsByCamp(ctx context.Context, campID domain.CampID) ([]*domain.Message, error) {
	// BROADCAST 메시지는 camp와 어떻게 연결될까? 
	// TrackID가 없는 경우 전체 camp에 대한 broadcast인지?
	// 여기서는 현재 도메인 상 camp_id 필드가 없으므로, 모든 broadcast를 반환하거나 조인을 해야 할 수 있습니다.
	// 임시 쿼리 작성. (추후 DB 스키마에 맞게 조정 필요)
	query := `
		SELECT m.id, m.channel_type, m.track_id, m.sender_role, m.content, m.sent_at 
		FROM messages m
		WHERE m.channel_type = 'BROADCAST'
	`
	return r.list(ctx, query)
}

func (r *pgMessageRepository) ListDirectByTrack(ctx context.Context, trackID domain.TrackID) ([]*domain.Message, error) {
	query := `
		SELECT id, channel_type, track_id, sender_role, content, sent_at 
		FROM messages 
		WHERE track_id = $1 AND channel_type = 'DIRECT'
	`
	return r.list(ctx, query, trackID)
}

func (r *pgMessageRepository) list(ctx context.Context, query string, args ...interface{}) ([]*domain.Message, error) {
	rows, err := r.conn(ctx).Query(ctx, query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var messages []*domain.Message
	for rows.Next() {
		var m domain.Message
		var trackID *string

		if err := rows.Scan(&m.ID, &m.ChannelType, &trackID, &m.SenderRole, &m.Content, &m.SentAt); err != nil {
			return nil, err
		}

		if trackID != nil {
			m.TrackID = domain.Some(domain.TrackID(*trackID))
		} else {
			m.TrackID = domain.None[domain.TrackID]()
		}

		messages = append(messages, &m)
	}
	return messages, rows.Err()
}
