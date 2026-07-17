
package web

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/usecase"
	"github.com/labstack/echo/v4"
)

type auditLogQuerierStub struct {
	query usecase.AuditLogQuery
	page  *usecase.AuditLogPage
}

func (s *auditLogQuerierStub) List(_ context.Context, query usecase.AuditLogQuery) (*usecase.AuditLogPage, error) {
	s.query = query
	return s.page, nil
}

func TestListAuditLogsShoudApplyFiltersAndCursorWhenValid(t *testing.T) {
	// arrange
	e := echo.New()
	cursor := usecase.AuditLogCursor{OccurredAt: time.Date(2026, 7, 13, 10, 0, 0, 0, time.UTC), ID: "audit-2"}
	stub := &auditLogQuerierStub{page: &usecase.AuditLogPage{
		Logs: []*domain.AuditLog{domain.NewAuditLogFromProps(domain.AuditLogProps{ID: "audit-1", Actor: "admin-1", Action: "UPDATE_CAMP", Success: true})},
		NextCursor: domain.Some(cursor),
	}}
	req := httptest.NewRequest(http.MethodGet, "/audit-logs?actor=admin&action=UPDATE_CAMP&result=success&limit=25&before="+encodeAuditLogCursor(cursor), nil)
	rec := httptest.NewRecorder()

	// act
	err := NewAuditHandler(stub).ListAuditLogs(e.NewContext(req, rec))

	// assert
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if stub.query.Actor != "admin" || stub.query.Action != "UPDATE_CAMP" || stub.query.Limit != 25 {
		t.Fatalf("unexpected query: %+v", stub.query)
	}
	if stub.query.Success == nil || !*stub.query.Success {
		t.Fatalf("success filter was not forwarded: %+v", stub.query.Success)
	}
	before, ok := stub.query.Before.Value()
	if !ok || before != cursor {
		t.Fatalf("cursor was not forwarded: %+v", before)
	}
	var response AuditLogPageResponse
	if err := json.Unmarshal(rec.Body.Bytes(), &response); err != nil {
		t.Fatalf("decode response: %v", err)
	}
	if len(response.Logs) != 1 || response.NextCursor == "" {
		t.Fatalf("unexpected page response: %+v", response)
	}
}

func TestListAuditLogsShoudRejectInvalidParametersWhenMalformed(t *testing.T) {
	tests := []string{
		"/audit-logs?limit=0",
		"/audit-logs?limit=201",
		"/audit-logs?limit=invalid",
		"/audit-logs?result=unknown",
		"/audit-logs?before=not-base64",
	}
	for _, target := range tests {
		t.Run(target, func(t *testing.T) {
			// arrange
			e := echo.New()
			req := httptest.NewRequest(http.MethodGet, target, nil)
			rec := httptest.NewRecorder()

			// act
			err := NewAuditHandler(nil).ListAuditLogs(e.NewContext(req, rec))

			// assert
			httpErr, ok := err.(*echo.HTTPError)
			if !ok || httpErr.Code != http.StatusBadRequest {
				t.Fatalf("expected 400 HTTP error, got %v", err)
			}
		})
	}
}

func TestAuditLogCursorShoudPreserveTieBreakerWhenRoundTripped(t *testing.T) {
	// arrange
	want := usecase.AuditLogCursor{OccurredAt: time.Date(2026, 7, 13, 10, 0, 0, 123, time.UTC), ID: "audit-tie-breaker"}

	// act
	encoded := encodeAuditLogCursor(want)
	got, err := decodeAuditLogCursor(encoded)

	// assert
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if got != want {
		t.Fatalf("cursor mismatch: got %+v, want %+v", got, want)
	}
}
