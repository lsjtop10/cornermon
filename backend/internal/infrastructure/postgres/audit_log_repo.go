package postgres

import (
	"context"
	"encoding/json"

	"cornermon/backend/internal/domain"
	"github.com/jackc/pgx/v5/pgxpool"
)

type pgAuditLogRepository struct {
	pool *pgxpool.Pool
}

func NewAuditLogRepository(pool *pgxpool.Pool) *pgAuditLogRepository {
	return &pgAuditLogRepository{pool: pool}
}

func (r *pgAuditLogRepository) conn(ctx context.Context) DBTx {
	if tx := ExtractTx(ctx); tx != nil {
		return tx
	}
	return r.pool
}

func (r *pgAuditLogRepository) Save(ctx context.Context, log *domain.AuditLog) error {
	metaJSON, err := json.Marshal(log.Metadata)
	if err != nil {
		return err
	}

	query := `
		INSERT INTO audit_logs (id, actor, action, target, success, occurred_at, metadata)
		VALUES ($1, $2, $3, $4, $5, $6, $7)
	`
	_, err = r.conn(ctx).Exec(ctx, query,
		log.ID, log.Actor, log.Action, log.Target, log.Success, log.OccurredAt, metaJSON,
	)
	return err
}
