package web

import (
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/labstack/echo/v4"
)

func TestReplaceTrackShoudReturnBadRequestWhenTargetCornerIsMissing(t *testing.T) {
	tests := []struct {
		name string
		body string
	}{
		{name: "empty object", body: `{}`},
		{name: "malformed JSON", body: `{`},
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			// Arrange
			e := echo.New()
			req := httptest.NewRequest(http.MethodPut, "/tracks/track-1/replace", strings.NewReader(tc.body))
			req.Header.Set(echo.HeaderContentType, echo.MIMEApplicationJSON)
			rec := httptest.NewRecorder()

			// Act
			err := NewTrackHandler(nil).ReplaceTrack(e.NewContext(req, rec))

			// Assert
			httpErr, ok := err.(*echo.HTTPError)
			if !ok || httpErr.Code != http.StatusBadRequest {
				t.Fatalf("expected 400 error, got %v", err)
			}
		})
	}
}
