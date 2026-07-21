package web

import (
	"fmt"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"cornermon/backend/internal/domain"

	"github.com/labstack/echo/v4"
)

func TestTrackHTTPErrorShouldMapExpectedDomainErrors(t *testing.T) {
	tests := []struct {
		name       string
		err        error
		wantStatus int
		wantCode   string
	}{
		{name: "missing track", err: domain.ErrTrackNotActive, wantStatus: http.StatusNotFound, wantCode: "TRACK_NOT_FOUND"},
		{name: "wrapped target corner missing", err: fmt.Errorf("replace: %w", domain.ErrCornerNotFound), wantStatus: http.StatusNotFound, wantCode: "CORNER_NOT_FOUND"},
		{name: "cross camp replacement", err: domain.ErrTrackCampMismatch, wantStatus: http.StatusConflict, wantCode: "TRACK_CONFLICT"},
		{name: "ended camp", err: domain.ErrCampInvalidTransition, wantStatus: http.StatusConflict, wantCode: "CAMP_NOT_AVAILABLE"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// arrange
			e := echo.New()
			rec := httptest.NewRecorder()
			ctx := e.NewContext(httptest.NewRequest(http.MethodPut, "/tracks/track-1/replace", nil), rec)

			// act
			ErrorHandler()(trackHTTPError(tt.err), ctx)

			// assert
			if rec.Code != tt.wantStatus || !strings.Contains(rec.Body.String(), tt.wantCode) {
				t.Fatalf("expected %d %s, got status=%d body=%s", tt.wantStatus, tt.wantCode, rec.Code, rec.Body.String())
			}
		})
	}
}
