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
		Logs:       []*domain.AuditLog{domain.NewAuditLogFromProps(domain.AuditLogProps{ID: "audit-1", Actor: "admin-1", Action: "CAMP_SETTINGS_UPDATE", Success: true})},
		NextCursor: domain.Some(cursor),
	}}
	req := httptest.NewRequest(http.MethodGet, "/audit-logs?actor=admin&action=CAMP_SETTINGS_UPDATE&result=success&limit=25&before="+encodeAuditLogCursor(cursor), nil)
	rec := httptest.NewRecorder()

	// act
	err := NewAuditHandler(stub).ListAuditLogs(e.NewContext(req, rec))

	// assert
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if stub.query.Actor != "admin" || stub.query.Action != "CAMP_SETTINGS_UPDATE" || stub.query.Limit != 25 {
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

func TestListAuditLogsShoudForwardCampIDWhenProvided(t *testing.T) {
	// arrange
	e := echo.New()
	stub := &auditLogQuerierStub{page: &usecase.AuditLogPage{Logs: []*domain.AuditLog{}, NextCursor: domain.None[usecase.AuditLogCursor]()}}
	req := httptest.NewRequest(http.MethodGet, "/audit-logs?campId=camp-1", nil)
	rec := httptest.NewRecorder()

	// act
	err := NewAuditHandler(stub).ListAuditLogs(e.NewContext(req, rec))

	// assert
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	campID, ok := stub.query.CampID.Value()
	if !ok || campID != domain.CampID("camp-1") {
		t.Fatalf("campId was not forwarded: %+v", stub.query.CampID)
	}
}

func TestListAuditLogsShoudLeaveCampIDUnsetWhenNotProvided(t *testing.T) {
	// arrange
	e := echo.New()
	stub := &auditLogQuerierStub{page: &usecase.AuditLogPage{Logs: []*domain.AuditLog{}, NextCursor: domain.None[usecase.AuditLogCursor]()}}
	req := httptest.NewRequest(http.MethodGet, "/audit-logs", nil)
	rec := httptest.NewRecorder()

	// act
	err := NewAuditHandler(stub).ListAuditLogs(e.NewContext(req, rec))

	// assert
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if _, ok := stub.query.CampID.Value(); ok {
		t.Fatalf("expected CampID to be unset, got %+v", stub.query.CampID)
	}
}

func TestListAuditLogsShoudRejectInvalidParametersWhenMalformed(t *testing.T) {
	tests := []string{
		"/audit-logs?limit=0",
		"/audit-logs?limit=201",
		"/audit-logs?limit=invalid",
		"/audit-logs?result=unknown",
		"/audit-logs?before=not-base64",
		"/audit-logs?action=UNKNOWN_ACTION",
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

func TestListAuditLogsShoudIncludeSnapshotFieldsInResponseWhenSet(t *testing.T) {
	// arrange
	e := echo.New()
	stub := &auditLogQuerierStub{page: &usecase.AuditLogPage{
		Logs: []*domain.AuditLog{domain.NewAuditLogFromProps(domain.AuditLogProps{
			ID: "audit-1", Actor: "admin-1", ActorName: "김관리",
			Action: "CORNER_DELETE", Target: "corner-1", TargetName: "체험 코너",
			CampID: domain.Some(domain.CampID("camp-1")), Success: true,
		})},
		NextCursor: domain.None[usecase.AuditLogCursor](),
	}}
	req := httptest.NewRequest(http.MethodGet, "/audit-logs", nil)
	rec := httptest.NewRecorder()

	// act
	err := NewAuditHandler(stub).ListAuditLogs(e.NewContext(req, rec))

	// assert
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	var response AuditLogPageResponse
	if err := json.Unmarshal(rec.Body.Bytes(), &response); err != nil {
		t.Fatalf("decode response: %v", err)
	}
	if len(response.Logs) != 1 {
		t.Fatalf("expected 1 log, got %d", len(response.Logs))
	}
	got := response.Logs[0]
	if got.ActorName != "김관리" || got.TargetName != "체험 코너" || got.CampID == nil || *got.CampID != "camp-1" {
		t.Fatalf("unexpected snapshot fields: %+v", got)
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
