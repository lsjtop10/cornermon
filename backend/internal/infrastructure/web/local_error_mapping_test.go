package web

import (
	"errors"
	"fmt"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"cornermon/backend/internal/domain"

	"github.com/labstack/echo/v4"
)

func TestLocalErrorMappersShouldPreserveExpectedAndUnexpectedErrorBoundaries(t *testing.T) {
	tests := []struct {
		name       string
		mapError   func(error) error
		err        error
		wantStatus int
		wantCode   string
	}{
		{name: "camp wrapped not found", mapError: campHTTPError, err: fmt.Errorf("load: %w", domain.ErrCampNotFound), wantStatus: http.StatusNotFound, wantCode: "CAMP_NOT_FOUND"},
		{name: "message revoked", mapError: messageHTTPError, err: domain.ErrSessionRevoked, wantStatus: http.StatusUnauthorized, wantCode: "SESSION_REVOKED"},
		{name: "report state", mapError: reportHTTPError, err: domain.ErrCampInvalidTransition, wantStatus: http.StatusConflict, wantCode: "CAMP_NOT_ENDED"},
		{name: "unexpected error remains internal", mapError: messageHTTPError, err: errors.New("database unavailable"), wantStatus: http.StatusInternalServerError, wantCode: "INTERNAL_SERVER_ERROR"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// arrange
			e := echo.New()
			rec := httptest.NewRecorder()
			ctx := e.NewContext(httptest.NewRequest(http.MethodGet, "/test", nil), rec)

			// act
			ErrorHandler()(tt.mapError(tt.err), ctx)

			// assert
			if rec.Code != tt.wantStatus || !strings.Contains(rec.Body.String(), tt.wantCode) {
				t.Fatalf("expected %d %s, got status=%d body=%s", tt.wantStatus, tt.wantCode, rec.Code, rec.Body.String())
			}
		})
	}
}
