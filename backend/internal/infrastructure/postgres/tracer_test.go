package postgres

import (
	"bytes"
	"context"
	"errors"
	"log/slog"
	"strings"
	"testing"

	"cornermon/backend/internal/errs"

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

// withCapturedLogger는 slog 기본 로거를 버퍼를 향하는 JSON 핸들러(운영 설정과 동일하게
// errs.SlogWrappedHandler로 감쌈)로 교체하고, 테스트 종료 시 원복하는 cleanup 함수를 등록한다.
func withCapturedLogger(t *testing.T) *bytes.Buffer {
	t.Helper()
	buf := &bytes.Buffer{}
	original := slog.Default()
	slog.SetDefault(slog.New(errs.NewSlogWrappedHandler(slog.NewJSONHandler(buf, &slog.HandlerOptions{Level: slog.LevelDebug}))))
	t.Cleanup(func() { slog.SetDefault(original) })
	return buf
}

func TestSlogQueryTracer_ShouldLogTraceID_WhenQueryErrors(t *testing.T) {
	// Arrange
	buf := withCapturedLogger(t)
	tracer := &SlogQueryTracer{}
	ctx := context.WithValue(context.Background(), errs.TraceIDKey, "trace-abc")
	ctx = tracer.TraceQueryStart(ctx, nil, pgx.TraceQueryStartData{SQL: "SELECT 1"})

	// Act
	tracer.TraceQueryEnd(ctx, nil, pgx.TraceQueryEndData{Err: errors.New("boom")})

	// Assert
	logLine := buf.String()
	if !strings.Contains(logLine, `"trace_id":"trace-abc"`) {
		t.Errorf("expected log to contain trace_id, got: %s", logLine)
	}
}

func TestSlogQueryTracer_ShouldLogTraceID_WhenSlowQueryDetected(t *testing.T) {
	// Arrange
	buf := withCapturedLogger(t)
	tracer := &SlogQueryTracer{SlowQueryThreshold: -1} // 항상 느린 쿼리로 판정되도록 음수 임계값 사용
	ctx := context.WithValue(context.Background(), errs.TraceIDKey, "trace-slow")
	ctx = tracer.TraceQueryStart(ctx, nil, pgx.TraceQueryStartData{SQL: "SELECT 1"})

	// Act
	tracer.TraceQueryEnd(ctx, nil, pgx.TraceQueryEndData{})

	// Assert
	logLine := buf.String()
	if !strings.Contains(logLine, `"trace_id":"trace-slow"`) {
		t.Errorf("expected log to contain trace_id, got: %s", logLine)
	}
}
