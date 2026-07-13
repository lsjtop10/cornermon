package postgres

import (
	"context"
	"encoding/json"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/errs"
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
		return errs.Wrap(ctx, err)
	}

	err = r.queries(ctx).SaveAuditLog(ctx, db.SaveAuditLogParams{
		ID:         string(log.ID),
		Actor:      log.Actor,
		Action:     log.Action,
		Target:     log.Target,
		Success:    log.Success,
		OccurredAt: pgtype.Timestamptz{Time: log.OccurredAt, Valid: !log.OccurredAt.IsZero()},
		Metadata:   metaJSON,
	})
	if err != nil {
		return errs.Wrap(ctx, err)
	}
	return nil
}

func (r *pgAuditLogRepository) List(ctx context.Context, limit, offset int) ([]*domain.AuditLog, error) {
	rows, err := r.queries(ctx).ListAuditLogs(ctx, db.ListAuditLogsParams{
		Limit:  int32(limit),
		Offset: int32(offset),
	})
	if err != nil {
		return nil, errs.Wrap(ctx, err)
	}

	logs := make([]*domain.AuditLog, len(rows))
	for i, row := range rows {
		var metadata map[string]any
		if len(row.Metadata) > 0 {
			if err := json.Unmarshal(row.Metadata, &metadata); err != nil {
				return nil, errs.Wrap(ctx, err)
			}
		}
		logs[i] = &domain.AuditLog{
			ID:         domain.AuditLogID(row.ID),
			Actor:      row.Actor,
			Action:     row.Action,
			Target:     row.Target,
			Success:    row.Success,
			OccurredAt: row.OccurredAt.Time,
			Metadata:   metadata,
		}
	}
	return logs, nil
}
