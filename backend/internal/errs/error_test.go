package errs_test

import (
	"context"
	"errors"
	"strings"
	"testing"

	"cornermon/backend/internal/errs"
)

func TestWrap(t *testing.T) {
	// arrange
	originalErr := errors.New("something went wrong")
	ctx := context.WithValue(context.Background(), "trace_id", "test-trace-id-123")

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
