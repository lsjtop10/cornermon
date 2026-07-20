package errs_test

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"log/slog"
	"strings"
	"testing"

	"cornermon/backend/internal/errs"
)

func TestWrap(t *testing.T) {
	// arrange
	originalErr := errors.New("something went wrong")
	ctx := context.WithValue(context.Background(), errs.TraceIDKey, "test-trace-id-123")

	// act
	wrappedErr := errs.Wrap(ctx, originalErr)

	// assert
	if wrappedErr == nil {
		t.Fatal("expected wrapped error to be not nil")
	}

	var appErr *errs.AppError
	if !errors.As(wrappedErr, &appErr) {
		t.Fatal("expected wrapped error to be unwrappable to AppError")
	}

	if appErr.TraceID != "test-trace-id-123" {
		t.Errorf("expected TraceID to be 'test-trace-id-123', got '%s'", appErr.TraceID)
	}

	if !errors.Is(wrappedErr, originalErr) {
		t.Error("expected wrapped error to wrap originalErr")
	}

	stack := appErr.FormatStack()
	if len(stack) == 0 {
		t.Error("expected stack trace to contain frames")
	}

	// stack trace contains this test function file
	found := false
	for _, frame := range stack {
		if strings.Contains(frame, "error_test.go") {
			found = true
			break
		}
	}
	if !found {
		t.Error("expected stack trace to contain current test file")
	}
}

func TestSlogWrappedHandlerShouldStripRawErrorAttrButKeepStackTraceWhenAppErrorLogged(t *testing.T) {
	// arrange
	buf := &bytes.Buffer{}
	logger := slog.New(errs.NewSlogWrappedHandler(slog.NewJSONHandler(buf, nil)))
	ctx := context.WithValue(context.Background(), errs.TraceIDKey, "test-trace-id-123")
	wrappedErr := errs.Wrap(ctx, errors.New("db down"))

	// act
	logger.ErrorContext(ctx, "System error occurred",
		slog.String("error_msg", wrappedErr.Error()),
		slog.Any("error", wrappedErr),
	)

	// assert
	var parsed map[string]any
	if err := json.Unmarshal(bytes.TrimSpace(buf.Bytes()), &parsed); err != nil {
		t.Fatalf("expected valid JSON log line, got error: %v, line: %s", err, buf.String())
	}
	if _, exists := parsed["error"]; exists {
		t.Errorf("expected raw 'error' attribute to be stripped, got: %v", parsed["error"])
	}
	if parsed["error_msg"] != "db down" {
		t.Errorf("expected error_msg to be 'db down', got %v", parsed["error_msg"])
	}
	if _, exists := parsed["stack_trace"]; !exists {
		t.Error("expected stack_trace to still be attached for an AppError")
	}
	if parsed["trace_id"] != "test-trace-id-123" {
		t.Errorf("expected trace_id to be 'test-trace-id-123', got %v", parsed["trace_id"])
	}
}
