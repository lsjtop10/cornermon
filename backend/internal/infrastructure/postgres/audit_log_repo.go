package postgres

import (
	"context"
	"encoding/json"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/errs"
	"cornermon/backend/internal/infrastructure/postgres/db"
	"cornermon/backend/internal/usecase"
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
	metaJSON, err := json.Marshal(log.Metadata())
	if err != nil {
		return errs.Wrap(ctx, err)
	}

	params := db.SaveAuditLogParams{
		ID:         string(log.ID()),
		Actor:      log.Actor(),
		Action:     log.Action(),
		Target:     log.Target(),
		Success:    log.Success(),
		OccurredAt: pgtype.Timestamptz{Time: log.OccurredAt(), Valid: !log.OccurredAt().IsZero()},
		Metadata:   metaJSON,
		TargetName: pgtype.Text{String: log.TargetName(), Valid: log.TargetName() != ""},
		ActorName:  pgtype.Text{String: log.ActorName(), Valid: log.ActorName() != ""},
	}
	if campID, ok := log.CampID().Value(); ok {
		params.CampID = pgtype.Text{String: string(campID), Valid: true}
	}

	err = r.queries(ctx).SaveAuditLog(ctx, params)
	if err != nil {
		return errs.Wrap(ctx, err)
	}
	return nil
}

func (r *pgAuditLogRepository) List(ctx context.Context, query usecase.AuditLogQuery) (*usecase.AuditLogPage, error) {
	params := db.ListAuditLogsParams{PageLimit: int32(query.Limit + 1)}
	if query.Actor != "" {
		params.Actor = pgtype.Text{String: query.Actor, Valid: true}
	}
	if query.Action != "" {
		params.Action = pgtype.Text{String: query.Action, Valid: true}
	}
	if query.Success != nil {
		params.Success = pgtype.Bool{Bool: *query.Success, Valid: true}
	}
	if campID, ok := query.CampID.Value(); ok {
		params.CampID = pgtype.Text{String: string(campID), Valid: true}
	}
	if cursor, ok := query.Before.Value(); ok {
		params.BeforeOccurredAt = pgtype.Timestamptz{Time: cursor.OccurredAt, Valid: true}
		params.BeforeID = pgtype.Text{String: string(cursor.ID), Valid: true}
	}

	rows, err := r.queries(ctx).ListAuditLogs(ctx, params)
	if err != nil {
		return nil, errs.Wrap(ctx, err)
	}
	hasMore := len(rows) > query.Limit
	if hasMore {
		rows = rows[:query.Limit]
	}

	logs := make([]*domain.AuditLog, len(rows))
	for i, row := range rows {
		log, err := mapAuditLog(row)
		if err != nil {
			return nil, errs.Wrap(ctx, err)
		}
		logs[i] = log
	}
	page := &usecase.AuditLogPage{Logs: logs, NextCursor: domain.None[usecase.AuditLogCursor]()}
	if hasMore && len(logs) > 0 {
		last := logs[len(logs)-1]
		page.NextCursor = domain.Some(usecase.AuditLogCursor{OccurredAt: last.OccurredAt(), ID: last.ID()})
	}
	return page, nil
}

func mapAuditLog(row db.AuditLog) (*domain.AuditLog, error) {
	var metadata map[string]any
	if len(row.Metadata) > 0 {
		if err := json.Unmarshal(row.Metadata, &metadata); err != nil {
			return nil, err
		}
	}
	props := domain.AuditLogProps{
		ID:         domain.AuditLogID(row.ID),
		Actor:      row.Actor,
		Action:     row.Action,
		Target:     row.Target,
		Success:    row.Success,
		OccurredAt: row.OccurredAt.Time,
		Metadata:   metadata,
		CampID:     domain.None[domain.CampID](),
	}
	if row.TargetName.Valid {
		props.TargetName = row.TargetName.String
	}
	if row.ActorName.Valid {
		props.ActorName = row.ActorName.String
	}
	if row.CampID.Valid {
		props.CampID = domain.Some(domain.CampID(row.CampID.String))
	}
	return domain.NewAuditLogFromProps(props), nil
}
