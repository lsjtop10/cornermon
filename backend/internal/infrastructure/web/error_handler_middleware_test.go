package web_test

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"net/http"
	"net/http/httptest"
	"testing"

	"cornermon/backend/internal/errs"
	"cornermon/backend/internal/infrastructure/web"

	"github.com/labstack/echo/v4"
	"cornermon/backend/internal/usecase"
)

func TestErrorHandler_AppError(t *testing.T) {
	// arrange
	e := echo.New()
	req := httptest.NewRequest(http.MethodGet, "/api/v1/test", nil)
	rec := httptest.NewRecorder()
	c := e.NewContext(req, rec)

	// trace_id context 에뮬레이트
	traceID := "test-trace-id-abc"
	c.Set("trace_id", traceID)
	ctx := context.WithValue(req.Context(), "trace_id", traceID)
	c.SetRequest(req.WithContext(ctx))

	handler := web.ErrorHandler()
	dbErr := errors.New("db query timeout")
	wrappedErr := errs.Wrap(c.Request().Context(), dbErr)

	// act
	handler(wrappedErr, c)

	// assert
	if rec.Code != http.StatusInternalServerError {
		t.Errorf("expected status code %d, got %d", http.StatusInternalServerError, rec.Code)
	}
}

func TestErrorHandlerShouldLogErrorMsgUserAgentAndDurationMsWhenSystemErrorOccurs(t *testing.T) {
	// arrange: Logger + ErrorHandler를 실제 파이프라인처럼 연결해 request_start 공유를 함께 검증한다
	buf := withCapturedLogger(t)
	e := echo.New()
	e.Use(web.Logger())
	e.HTTPErrorHandler = web.ErrorHandler()
	dbErr := errors.New("db query timeout")
	e.GET("/api/v1/test", func(c echo.Context) error {
		return errs.Wrap(c.Request().Context(), dbErr)
	})
	req := httptest.NewRequest(http.MethodGet, "/api/v1/test", nil)
	req.Header.Set("User-Agent", "test-agent/1.0")
	rec := httptest.NewRecorder()

	// act
	e.ServeHTTP(rec, req)

	// assert
	if rec.Code != http.StatusInternalServerError {
		t.Fatalf("expected status code %d, got %d", http.StatusInternalServerError, rec.Code)
	}
	var parsed map[string]any
	if err := json.Unmarshal(bytes.TrimSpace(buf.Bytes()), &parsed); err != nil {
		t.Fatalf("expected valid JSON log line, got error: %v, line: %s", err, buf.String())
	}
	if parsed["error_msg"] != "db query timeout" {
		t.Errorf("expected error_msg to be 'db query timeout', got %v", parsed["error_msg"])
	}
	if parsed["user_agent"] != "test-agent/1.0" {
		t.Errorf("expected user_agent to be 'test-agent/1.0', got %v", parsed["user_agent"])
	}
	if v, ok := parsed["duration_ms"].(float64); !ok || v < 0 {
		t.Errorf("expected duration_ms to be a non-negative JSON number, got %v (%T)", parsed["duration_ms"], parsed["duration_ms"])
	}
	if _, exists := parsed["error"]; exists {
		t.Errorf("expected raw 'error' attribute to be stripped from output, but found: %v", parsed["error"])
	}
	if _, exists := parsed["stack_trace"]; !exists {
		t.Error("expected stack_trace to be present for a Wrap()-ed 5xx error")
	}
}

func TestErrorHandler_OperationError(t *testing.T) {
	// arrange
	buf := withCapturedLogger(t)
	e := echo.New()
	e.Use(web.Logger())
	e.HTTPErrorHandler = web.ErrorHandler()
	dbErr := errors.New("underlying domain error")
	opErr := &usecase.OperationError{
		Operation: "test.op",
		Stage:     "test.stage",
		Attributes: map[string]any{
			"test_attr": "attr_value",
		},
		Cause: dbErr,
	}

	// operationErr can be wrapped inside an echo.HTTPError
	e.GET("/api/v1/test_op", func(c echo.Context) error {
		return echo.NewHTTPError(http.StatusBadRequest, web.ErrorResponse{
			Code:    "BAD_REQUEST",
			Message: "Bad request",
		}).SetInternal(opErr)
	})

	req := httptest.NewRequest(http.MethodGet, "/api/v1/test_op", nil)
	rec := httptest.NewRecorder()

	// act
	e.ServeHTTP(rec, req)

	// assert
	if rec.Code != http.StatusBadRequest {
		t.Fatalf("expected status code %d, got %d", http.StatusBadRequest, rec.Code)
	}

	var parsed map[string]any
	if err := json.Unmarshal(bytes.TrimSpace(buf.Bytes()), &parsed); err != nil {
		t.Fatalf("expected valid JSON log line, got error: %v, line: %s", err, buf.String())
	}

	if parsed["operation"] != "test.op" {
		t.Errorf("expected operation 'test.op', got %v", parsed["operation"])
	}
	if parsed["stage"] != "test.stage" {
		t.Errorf("expected stage 'test.stage', got %v", parsed["stage"])
	}

	ctxAttr, ok := parsed["error_context"].(map[string]any)
	if !ok {
		t.Fatalf("expected error_context map, got %v", parsed["error_context"])
	}
	if ctxAttr["test_attr"] != "attr_value" {
		t.Errorf("expected test_attr 'attr_value', got %v", ctxAttr["test_attr"])
	}
}
