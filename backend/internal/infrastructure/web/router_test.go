package web

import (
	"context"
	"errors"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/usecase"

	"github.com/labstack/echo/v4"
)

type adminAuthForMessageRoutes struct{}

func (adminAuthForMessageRoutes) ValidateAccessToken(_ context.Context, token string) (*domain.AdminSession, error) {
	if token == "admin-token" {
		return &domain.AdminSession{}, nil
	}
	return nil, errors.New("invalid admin token")
}

type trackAuthForMessageRoutes struct{}

func (trackAuthForMessageRoutes) ValidateSession(_ context.Context, token string) (*domain.FacilitatorSession, error) {
	if token == "track-token" {
		return domain.NewFacilitatorSessionFromProps(domain.FacilitatorSessionProps{TrackID: "track-1"}), nil
	}
	if token == "migrating-token" {
		session := domain.NewFacilitatorSessionFromProps(domain.FacilitatorSessionProps{TrackID: "track-1"})
		session.SetMigrationTarget("track-2")
		return session, nil
	}
	return nil, errors.New("invalid track token")
}

type facilitatorAuthForMigrationRoutes struct{}

func (facilitatorAuthForMigrationRoutes) Login(_ context.Context, _, _ string) (*usecase.TrackLoginResult, error) {
	return nil, errors.New("not implemented")
}

func (facilitatorAuthForMigrationRoutes) Logout(_ context.Context, _ domain.FacilitatorSessionID) error {
	return nil
}

func (facilitatorAuthForMigrationRoutes) MigrateSession(_ context.Context, _ string) (*usecase.TrackLoginResult, error) {
	return &usecase.TrackLoginResult{
		TrackToken: "new-track-token",
		Track:      domain.NewTrackFromProps(domain.TrackProps{ID: "track-2", CornerID: "corner-1", Status: domain.TrackActive}),
		Corner:     domain.NewCornerFromProps(domain.CornerProps{ID: "corner-1", CampID: "camp-1"}),
	}, nil
}

func (facilitatorAuthForMigrationRoutes) ListActiveSessions(_ context.Context, _ domain.CampID) ([]*domain.FacilitatorSession, error) {
	return nil, nil
}

func TestMessageRoutesShoudAuthenticateAdminAndTrackWithoutDuplicateRouteRegistration(t *testing.T) {
	// Arrange
	uc := &messageUsecaseForHandler{}
	e := echo.New()
	RegisterRoutes(e, &Handlers{Auth: &AuthHandler{}, Device: &DeviceHandler{}, Message: NewMessageHandler(uc, nil, nil)}, adminAuthForMessageRoutes{}, trackAuthForMessageRoutes{})

	for _, tc := range []struct {
		name     string
		token    string
		expected domain.SenderRole
	}{
		{name: "admin", token: "admin-token", expected: domain.RoleAdmin},
		{name: "track", token: "track-token", expected: domain.RoleTrack},
	} {
		t.Run(tc.name, func(t *testing.T) {
			// Act
			req := httptest.NewRequest(http.MethodGet, "/api/v1/tracks/track-1/messages", nil)
			req.Header.Set(echo.HeaderAuthorization, "Bearer "+tc.token)
			rec := httptest.NewRecorder()
			e.ServeHTTP(rec, req)

			// Assert
			if rec.Code != http.StatusOK {
				t.Fatalf("expected status 200, got %d: %s", rec.Code, rec.Body.String())
			}
			if uc.viewerRole != tc.expected {
				t.Fatalf("expected viewer role %s, got %s", tc.expected, uc.viewerRole)
			}
		})
	}
}

func TestSendDirectRouteShoudAuthenticateAdminAndTrackWithoutDuplicateRouteRegistration(t *testing.T) {
	// Arrange
	uc := &messageUsecaseForHandler{}
	e := echo.New()
	RegisterRoutes(e, &Handlers{Auth: &AuthHandler{}, Device: &DeviceHandler{}, Message: NewMessageHandler(uc, nil, nil)}, adminAuthForMessageRoutes{}, trackAuthForMessageRoutes{})

	for _, tc := range []struct {
		name     string
		token    string
		expected domain.SenderRole
	}{
		{name: "admin", token: "admin-token", expected: domain.RoleAdmin},
		{name: "track", token: "track-token", expected: domain.RoleTrack},
	} {
		t.Run(tc.name, func(t *testing.T) {
			// Act
			req := httptest.NewRequest(http.MethodPost, "/api/v1/tracks/track-1/messages", strings.NewReader(`{"content":"hello"}`))
			req.Header.Set(echo.HeaderContentType, echo.MIMEApplicationJSON)
			req.Header.Set(echo.HeaderAuthorization, "Bearer "+tc.token)
			rec := httptest.NewRecorder()
			e.ServeHTTP(rec, req)

			// Assert
			if rec.Code != http.StatusCreated {
				t.Fatalf("expected status 201, got %d: %s", rec.Code, rec.Body.String())
			}
			if uc.senderRole != tc.expected {
				t.Fatalf("expected sender role %s, got %s", tc.expected, uc.senderRole)
			}
		})
	}
}

func TestSendDirectRouteShoudRejectRequestWithoutSession(t *testing.T) {
	// Arrange
	e := echo.New()
	RegisterRoutes(e, &Handlers{Auth: &AuthHandler{}, Device: &DeviceHandler{}, Message: NewMessageHandler(&messageUsecaseForHandler{}, nil, nil)}, adminAuthForMessageRoutes{}, trackAuthForMessageRoutes{})

	// Act
	req := httptest.NewRequest(http.MethodPost, "/api/v1/tracks/track-1/messages", strings.NewReader(`{"content":"hello"}`))
	req.Header.Set(echo.HeaderContentType, echo.MIMEApplicationJSON)
	rec := httptest.NewRecorder()
	e.ServeHTTP(rec, req)

	// Assert
	if rec.Code != http.StatusUnauthorized {
		t.Fatalf("expected status 401, got %d: %s", rec.Code, rec.Body.String())
	}
}

func TestSendDirectRouteShoudRejectSessionWithPendingMigration(t *testing.T) {
	// Arrange
	uc := &messageUsecaseForHandler{}
	e := echo.New()
	RegisterRoutes(e, &Handlers{Auth: &AuthHandler{}, Device: &DeviceHandler{}, Message: NewMessageHandler(uc, nil, nil)}, adminAuthForMessageRoutes{}, trackAuthForMessageRoutes{})

	// Act
	req := httptest.NewRequest(http.MethodPost, "/api/v1/tracks/track-1/messages", strings.NewReader(`{"content":"hello"}`))
	req.Header.Set(echo.HeaderContentType, echo.MIMEApplicationJSON)
	req.Header.Set(echo.HeaderAuthorization, "Bearer migrating-token")
	rec := httptest.NewRecorder()
	e.ServeHTTP(rec, req)

	// Assert
	if rec.Code != http.StatusConflict {
		t.Fatalf("expected status 409, got %d: %s", rec.Code, rec.Body.String())
	}
	if !strings.Contains(rec.Body.String(), string(CodeSessionMigrationRequired)) {
		t.Fatalf("expected body to contain %s, got %s", CodeSessionMigrationRequired, rec.Body.String())
	}
}

func TestMigrateSessionAndLogoutRoutesShoudBeExemptFromPendingMigrationGate(t *testing.T) {
	// Arrange
	e := echo.New()
	RegisterRoutes(e, &Handlers{Auth: NewAuthHandler(nil, facilitatorAuthForMigrationRoutes{}, nil), Device: &DeviceHandler{}}, adminAuthForMessageRoutes{}, trackAuthForMessageRoutes{})

	for _, tc := range []struct {
		name   string
		method string
		path   string
	}{
		{name: "migrate-session", method: http.MethodPost, path: "/api/v1/tracks/track-1/migrate-session"},
		{name: "logout", method: http.MethodPost, path: "/api/v1/auth/track/logout"},
	} {
		t.Run(tc.name, func(t *testing.T) {
			// Act
			req := httptest.NewRequest(tc.method, tc.path, nil)
			req.Header.Set(echo.HeaderAuthorization, "Bearer migrating-token")
			rec := httptest.NewRecorder()
			e.ServeHTTP(rec, req)

			// Assert
			if rec.Code == http.StatusConflict {
				t.Fatalf("expected route to be exempt from the migration gate, got 409: %s", rec.Body.String())
			}
		})
	}
}

func TestListBroadcastsRouteShoudAuthenticateBothAdminAndTrackSessions(t *testing.T) {
	// Arrange
	announcementCommandUC := &announcementCommandUsecaseForHandler{}
	announcementQueryUC := &announcementQueryUsecaseForHandler{notices: []*domain.Announcement{domain.NewAnnouncementFromProps(domain.AnnouncementProps{ID: "notice-1", CampID: "camp-1", Content: "hello"})}}
	e := echo.New()
	RegisterRoutes(e, &Handlers{Auth: &AuthHandler{}, Device: &DeviceHandler{}, Message: NewMessageHandler(&messageUsecaseForHandler{}, announcementCommandUC, announcementQueryUC)}, adminAuthForMessageRoutes{}, trackAuthForMessageRoutes{})

	for _, tc := range []struct {
		name  string
		token string
	}{
		{name: "admin", token: "admin-token"},
		{name: "track", token: "track-token"},
	} {
		t.Run(tc.name, func(t *testing.T) {
			// Act
			req := httptest.NewRequest(http.MethodGet, "/api/v1/camps/camp-1/messages/broadcast", nil)
			req.Header.Set(echo.HeaderAuthorization, "Bearer "+tc.token)
			rec := httptest.NewRecorder()
			e.ServeHTTP(rec, req)

			// Assert
			if rec.Code != http.StatusOK {
				t.Fatalf("expected status 200, got %d: %s", rec.Code, rec.Body.String())
			}
		})
	}
}

func TestListBroadcastsRouteShoudRejectRequestWithoutSession(t *testing.T) {
	// Arrange
	announcementCommandUC := &announcementCommandUsecaseForHandler{}
	announcementQueryUC := &announcementQueryUsecaseForHandler{}
	e := echo.New()
	RegisterRoutes(e, &Handlers{Auth: &AuthHandler{}, Device: &DeviceHandler{}, Message: NewMessageHandler(&messageUsecaseForHandler{}, announcementCommandUC, announcementQueryUC)}, adminAuthForMessageRoutes{}, trackAuthForMessageRoutes{})

	// Act
	req := httptest.NewRequest(http.MethodGet, "/api/v1/camps/camp-1/messages/broadcast", nil)
	rec := httptest.NewRecorder()
	e.ServeHTTP(rec, req)

	// Assert
	if rec.Code != http.StatusUnauthorized {
		t.Fatalf("expected status 401, got %d: %s", rec.Code, rec.Body.String())
	}
}

func TestDeviceRegistrationRoutesShouldBeScopedToCamp(t *testing.T) {
	// Arrange
	e := echo.New()
	RegisterRoutes(e, &Handlers{Auth: &AuthHandler{}, Device: &DeviceHandler{}}, adminAuthForMessageRoutes{}, trackAuthForMessageRoutes{})

	// Act
	routes := make(map[string]bool)
	for _, route := range e.Routes() {
		routes[route.Method+" "+route.Path] = true
	}

	// Assert
	if !routes[http.MethodGet+" /api/v1/camps/:campId/device-registrations"] {
		t.Fatal("expected camp-scoped device registration route to be registered")
	}
	if routes[http.MethodGet+" /api/v1/device-registrations"] {
		t.Fatal("expected legacy device registration route to be absent")
	}
}

func TestDemoDeviceRegistrationRouteShouldOnlyExistWhenDemoHandlerIsSet(t *testing.T) {
	t.Run("ShouldRespondIdenticallyToAnyUndefinedRouteWhenDemoHandlerIsNil", func(t *testing.T) {
		// Arrange - 운영 배포와 동일한 상태(DEMO_CAMP_NAME 미설정 → Handlers.Demo == nil).
		//
		// echo v4는 같은 prefix("/api/v1")를 공유하는 여러 Group(v1 자신 + admin/track/
		// message 서브그룹)이 있을 때, 그 prefix 아래의 미등록 경로 전부를 마지막에 등록된
		// 서브그룹의 미들웨어(여기서는 AdminAuthMiddleware)로 흘려보낸다 — 그래서 진짜
		// 존재하지 않는 라우트도 echo 표준 404가 아니라 401 "missing token"을 반환한다.
		// 이건 이번 변경과 무관한 기존 라우터 동작이며, 오히려 우리 목적엔 더 잘 맞는다 —
		// /demo/device-registrations를 두드려도 다른 아무 존재하지 않는 경로와 완전히
		// 동일한 응답이 나와서 "이 경로가 특별히 존재하는지"에 대한 신호가 전혀 없다.
		e := echo.New()
		RegisterRoutes(e, &Handlers{Auth: &AuthHandler{}, Device: &DeviceHandler{}}, adminAuthForMessageRoutes{}, trackAuthForMessageRoutes{})

		// Act
		demoReq := httptest.NewRequest(http.MethodPost, "/api/v1/demo/device-registrations", strings.NewReader(`{}`))
		demoReq.Header.Set(echo.HeaderContentType, echo.MIMEApplicationJSON)
		demoRec := httptest.NewRecorder()
		e.ServeHTTP(demoRec, demoReq)

		bogusReq := httptest.NewRequest(http.MethodPost, "/api/v1/totally-bogus-path-xyz", strings.NewReader(`{}`))
		bogusReq.Header.Set(echo.HeaderContentType, echo.MIMEApplicationJSON)
		bogusRec := httptest.NewRecorder()
		e.ServeHTTP(bogusRec, bogusReq)

		// Assert
		if demoRec.Code != bogusRec.Code || demoRec.Body.String() != bogusRec.Body.String() {
			t.Fatalf("expected /demo/device-registrations to respond identically to an undefined route, got demo=%d %q bogus=%d %q",
				demoRec.Code, demoRec.Body.String(), bogusRec.Code, bogusRec.Body.String())
		}
		for _, route := range e.Routes() {
			if route.Path == "/api/v1/demo/device-registrations" {
				t.Fatal("expected /demo/device-registrations route to be absent when Demo handler is nil")
			}
		}
	})

	t.Run("ShouldRegisterRouteWhenDemoHandlerIsSet", func(t *testing.T) {
		// Arrange - review 배포와 동일한 상태(DEMO_CAMP_NAME 설정 → Handlers.Demo != nil).
		e := echo.New()
		RegisterRoutes(e, &Handlers{Auth: &AuthHandler{}, Device: &DeviceHandler{}, Demo: NewDemoHandler(&listDeviceTrustStub{})}, adminAuthForMessageRoutes{}, trackAuthForMessageRoutes{})

		// Act
		found := false
		for _, route := range e.Routes() {
			if route.Method == http.MethodPost && route.Path == "/api/v1/demo/device-registrations" {
				found = true
			}
		}

		// Assert
		if !found {
			t.Fatal("expected /demo/device-registrations route to be registered when Demo handler is set")
		}
	})
}
