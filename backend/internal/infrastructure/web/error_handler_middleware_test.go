package web_test

import (
	"context"
	"errors"
	"net/http"
	"net/http/httptest"
	"testing"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/errs"
	"cornermon/backend/internal/infrastructure/web"
	"github.com/labstack/echo/v4"
)

func TestErrorHandler_DomainError(t *testing.T) {
	// arrange
	e := echo.New()
	req := httptest.NewRequest(http.MethodPost, "/api/v1/test", nil)
	rec := httptest.NewRecorder()
	c := e.NewContext(req, rec)

	handler := web.ErrorHandler()
	domainErr := domain.ErrCampInvalidTransition

	// act
	handler(domainErr, c)

	// assert
	if rec.Code != http.StatusBadRequest {
		t.Errorf("expected status code %d, got %d", http.StatusBadRequest, rec.Code)
	}
}

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

func TestErrorHandlerShoudReturnForbiddenWhenTrackScopeDiffers(t *testing.T) {
	// Arrange
	e := echo.New()
	req := httptest.NewRequest(http.MethodGet, "/api/v1/tracks/track-2/groups", nil)
	rec := httptest.NewRecorder()
	c := e.NewContext(req, rec)

	// Act
	web.ErrorHandler()(domain.ErrTrackScopeForbidden, c)

	// Assert
	if rec.Code != http.StatusForbidden {
		t.Fatalf("expected status %d, got %d", http.StatusForbidden, rec.Code)
	}
}
