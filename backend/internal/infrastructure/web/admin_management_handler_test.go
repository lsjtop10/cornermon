//go:build ignore

package web

import (
	"context"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"cornermon/backend/internal/domain"

	"github.com/labstack/echo/v4"
)

type adminManagementUsecaseStub struct{ err error }

func (s adminManagementUsecaseStub) CreateAdmin(context.Context, domain.AdminID, string, string, domain.AdminRole) (*domain.Admin, error) {
	return nil, s.err
}
func (s adminManagementUsecaseStub) ChangeAdminPassword(context.Context, domain.AdminID, domain.AdminID, string) error {
	return s.err
}
func (s adminManagementUsecaseStub) DeleteAdmin(context.Context, domain.AdminID, domain.AdminID) error {
	return s.err
}

func TestAdminManagementHandlerShouldMapDomainErrorsToHTTPStatus(t *testing.T) {
	for _, tc := range []struct {
		name string
		err  error
		want int
	}{
		{name: "forbidden", err: domain.ErrAdminForbidden, want: http.StatusForbidden},
		{name: "not found", err: domain.ErrAdminNotFound, want: http.StatusNotFound},
		{name: "conflict", err: domain.ErrAdminUsernameTaken, want: http.StatusConflict},
		{name: "bad request", err: domain.ErrAdminInvalidRole, want: http.StatusBadRequest},
	} {
		t.Run(tc.name, func(t *testing.T) {
			// Arrange
			e := echo.New()
			req := httptest.NewRequest(http.MethodPost, "/admins", strings.NewReader(`{"username":"new","password":"password","role":"CORNER_OPERATOR"}`))
			req.Header.Set(echo.HeaderContentType, echo.MIMEApplicationJSON)
			rec := httptest.NewRecorder()
			c := e.NewContext(req, rec)
			c.Set("adminSession", domain.NewAdminSessionFromProps(domain.AdminSessionProps{AdminID: "actor"}))
			handler := NewAdminManagementHandler(adminManagementUsecaseStub{err: tc.err})

			// Act
			err := handler.CreateAdmin(c)

			// Assert
			if err != nil || rec.Code != tc.want {
				t.Fatalf("expected status %d, got status=%d err=%v", tc.want, rec.Code, err)
			}
		})
	}
}
