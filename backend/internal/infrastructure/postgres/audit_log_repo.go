package postgres

import (
	"context"
	"encoding/json"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/infrastructure/postgres/db"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/jackc/pgx/v5/pgxpool"
)

type pgAuditLogRepository struct {
	pool *pgxpool.Pool
}

func NewAuditLogRepository(pool *pgxpool.Pool) *pgAuditLogRepository {
	return &pgAuditLogRepository{pool: pool}
}

func (r *pgAuditLogRepository) queries(ctx context.Context) *db.Queries {
	if tx := ExtractTx(ctx); tx != nil {
		return db.New(tx)
	}
	return db.New(r.pool)
}

func (r *pgAuditLogRepository) Save(ctx context.Context, log *domain.AuditLog) error {
	metaJSON, err := json.Marshal(log.Metadata)
	if err != nil {
		return err
	}

	return r.queries(ctx).SaveAuditLog(ctx, db.SaveAuditLogParams{
		ID:         string(log.ID),
		Actor:      log.Actor,
		Action:     log.Action,
		Target:     log.Target,
		Success:    log.Success,
		OccurredAt: pgtype.Timestamptz{Time: log.OccurredAt, Valid: !log.OccurredAt.IsZero()},
		Metadata:   metaJSON,
	})
}
