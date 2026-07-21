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

func TestVisitHTTPErrorShouldMapExpectedDomainErrors(t *testing.T) {
	tests := []struct {
		name       string
		err        error
		wantStatus int
		wantCode   string
	}{
		{name: "revoked session", err: domain.ErrSessionRevoked, wantStatus: http.StatusUnauthorized, wantCode: "SESSION_REVOKED"},
		{name: "wrapped busy track", err: fmt.Errorf("start visit: %w", domain.ErrTrackBusy), wantStatus: http.StatusConflict, wantCode: "TRACK_BUSY"},
		{name: "unassigned badge", err: domain.ErrBadgeNotAssigned, wantStatus: http.StatusNotFound, wantCode: "BADGE_NOT_ASSIGNED"},
		{name: "inactive camp", err: domain.ErrCampInvalidTransition, wantStatus: http.StatusConflict, wantCode: "CAMP_NOT_ACTIVE"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// arrange
			e := echo.New()
			req := httptest.NewRequest(http.MethodPost, "/tracks/track-1/visits/start", nil)
			rec := httptest.NewRecorder()
			ctx := e.NewContext(req, rec)

			// act
			ErrorHandler()(visitHTTPError(tt.err), ctx)

			// assert
			if rec.Code != tt.wantStatus || !strings.Contains(rec.Body.String(), tt.wantCode) {
				t.Fatalf("expected %d %s, got status=%d body=%s", tt.wantStatus, tt.wantCode, rec.Code, rec.Body.String())
			}
		})
	}
}
