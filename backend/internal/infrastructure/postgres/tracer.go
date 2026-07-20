package postgres

import (
	"context"
	"fmt"
	"log/slog"
	"time"

	"github.com/jackc/pgx/v5"
)

// SlogQueryTracer intercepts pgx queries to log their execution time, errors, and parameters.
type SlogQueryTracer struct {
	SlowQueryThreshold time.Duration
	LogParameterValues bool // If true, logs actual parameter values. If false, hides them.
}

type ctxKey string

const queryDataKey ctxKey = "query_data_key"

type queryData struct {
	startTime time.Time
	sql       string
	args      []any
}

// TraceQueryStart is called at the beginning of a query execution.
func (t *SlogQueryTracer) TraceQueryStart(ctx context.Context, _ *pgx.Conn, data pgx.TraceQueryStartData) context.Context {
	return context.WithValue(ctx, queryDataKey, queryData{
		startTime: time.Now(),
		sql:       data.SQL,
		args:      data.Args,
	})
}

// TraceQueryEnd is called at the end of a query execution.
func (t *SlogQueryTracer) TraceQueryEnd(ctx context.Context, _ *pgx.Conn, data pgx.TraceQueryEndData) {
	qd, ok := ctx.Value(queryDataKey).(queryData)
	if !ok {
		return
	}

	duration := time.Since(qd.startTime)

	var argsToLog any
	if t.LogParameterValues {
		argsToLog = qd.args
	} else if len(qd.args) > 0 {
		argsToLog = fmt.Sprintf("[%d parameters hidden]", len(qd.args))
	} else {
		argsToLog = "[]"
	}

	if data.Err != nil {
		slog.Error("Database query error",
			"sql", qd.sql,
			"args", argsToLog,
			"duration", duration,
			"error", data.Err,
		)
		return
	}

	if t.SlowQueryThreshold > 0 && duration > t.SlowQueryThreshold {
		slog.Warn("Slow query detected",
			"sql", qd.sql,
			"args", argsToLog,
			"duration", duration,
		)
		return
	}

	slog.Debug("Database query",
		"sql", qd.sql,
		"args", argsToLog,
		"duration", duration,
	)
}
