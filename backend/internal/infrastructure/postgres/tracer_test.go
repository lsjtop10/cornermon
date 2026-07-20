package postgres

import (
	"context"
	"testing"

	"github.com/jackc/pgx/v5"
)

func TestSlogQueryTracer_ShouldStoreDataInContext_WhenTraceQueryStartCalled(t *testing.T) {
	// Arrange
	tracer := &SlogQueryTracer{}
	ctx := context.Background()
	startData := pgx.TraceQueryStartData{
		SQL:  "SELECT 1",
		Args: []any{1, "test"},
	}

	// Act
	newCtx := tracer.TraceQueryStart(ctx, nil, startData)

	// Assert
	qd, ok := newCtx.Value(queryDataKey).(queryData)
	if !ok {
		t.Errorf("Expected queryData to be stored in context")
	}
	if qd.sql != "SELECT 1" {
		t.Errorf("Expected SQL 'SELECT 1', got %s", qd.sql)
	}
	if len(qd.args) != 2 {
		t.Errorf("Expected 2 args, got %d", len(qd.args))
	}
}
