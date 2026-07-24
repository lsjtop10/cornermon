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
func (s adminManagementUsecaseStub) GetAdmin(context.Context, domain.AdminID) (*domain.Admin, error) {
	if s.err != nil {
		return nil, s.err
	}
	return domain.NewAdminFromProps(domain.AdminProps{ID: "actor", Username: "actor", Role: domain.AdminRoleCornerOperator}), nil
}
func (s adminManagementUsecaseStub) ListAdmins(context.Context, domain.AdminID) ([]*domain.Admin, error) {
	if s.err != nil {
		return nil, s.err
	}
	return []*domain.Admin{
		domain.NewAdminFromProps(domain.AdminProps{ID: "actor", Username: "actor", Role: domain.AdminRoleSystemAdmin}),
	}, nil
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
			e.HTTPErrorHandler = ErrorHandler()
			req := httptest.NewRequest(http.MethodPost, "/admins", strings.NewReader(`{"username":"new","password":"password","role":"CORNER_OPERATOR"}`))
			req.Header.Set(echo.HeaderContentType, echo.MIMEApplicationJSON)
			rec := httptest.NewRecorder()
			c := e.NewContext(req, rec)
			c.Set("adminSession", domain.NewAdminSessionFromProps(domain.AdminSessionProps{AdminID: "actor"}))
			handler := NewAdminManagementHandler(adminManagementUsecaseStub{err: tc.err})

			// Act
			err := handler.CreateAdmin(c)
			if err != nil {
				e.HTTPErrorHandler(err, c)
			}

			// Assert
			if rec.Code != tc.want {
				t.Fatalf("expected status %d, got status=%d err=%v", tc.want, rec.Code, err)
			}
		})
	}
}

func TestAdminManagementHandlerGetMyAdminShouldReturnSelf(t *testing.T) {
	// Arrange
	e := echo.New()
	req := httptest.NewRequest(http.MethodGet, "/admins/me", nil)
	rec := httptest.NewRecorder()
	c := e.NewContext(req, rec)
	c.Set("adminSession", domain.NewAdminSessionFromProps(domain.AdminSessionProps{AdminID: "actor"}))
	handler := NewAdminManagementHandler(adminManagementUsecaseStub{})

	// Act
	err := handler.GetMyAdmin(c)

	// Assert
	if err != nil || rec.Code != http.StatusOK {
		t.Fatalf("expected 200, got status=%d err=%v", rec.Code, err)
	}
}

func TestAdminManagementHandlerListAdminsShouldReturnForbiddenForCornerOperator(t *testing.T) {
	// Arrange
	e := echo.New()
	e.HTTPErrorHandler = ErrorHandler()
	req := httptest.NewRequest(http.MethodGet, "/admins", nil)
	rec := httptest.NewRecorder()
	c := e.NewContext(req, rec)
	c.Set("adminSession", domain.NewAdminSessionFromProps(domain.AdminSessionProps{AdminID: "actor"}))
	handler := NewAdminManagementHandler(adminManagementUsecaseStub{err: domain.ErrAdminForbidden})

	// Act
	err := handler.ListAdmins(c)
	if err != nil {
		e.HTTPErrorHandler(err, c)
	}

	// Assert
	if rec.Code != http.StatusForbidden {
		t.Fatalf("expected 403, got status=%d err=%v", rec.Code, err)
	}
}
