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
	t.Run("ShouldReturnPlain404WhenDemoHandlerIsNil", func(t *testing.T) {
		// Arrange - 운영 배포와 동일한 상태(DEMO_CAMP_NAME 미설정 → Handlers.Demo == nil).
		e := echo.New()
		RegisterRoutes(e, &Handlers{Auth: &AuthHandler{}, Device: &DeviceHandler{}}, adminAuthForMessageRoutes{}, trackAuthForMessageRoutes{})

		// Act
		req := httptest.NewRequest(http.MethodPost, "/api/v1/demo/device-registrations", strings.NewReader(`{}`))
		req.Header.Set(echo.HeaderContentType, echo.MIMEApplicationJSON)
		rec := httptest.NewRecorder()
		e.ServeHTTP(rec, req)

		// Assert - 도메인 에러를 4xx로 매핑한 결과도, 인증 미들웨어를 거쳐 나온 401도 아닌,
		// 라우트 자체가 없어서 나오는 순수 404여야 한다.
		if rec.Code != http.StatusNotFound {
			t.Fatalf("expected status 404 when Demo handler is nil, got %d: %s", rec.Code, rec.Body.String())
		}
		if !strings.Contains(rec.Body.String(), string(CodeNotFound)) {
			t.Fatalf("expected body to contain %s, got %s", CodeNotFound, rec.Body.String())
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

// echo v4는 Group.Use()를 호출한 그룹마다 자기 prefix에 404 폴백을 자동 등록하고, 그
// 폴백에도 그룹 미들웨어를 그대로 씌운다. admin/track/message 그룹이 v1과 같은 prefix를
// 공유해서 이 자동 등록들이 서로 덮어쓰며, 고치기 전에는 진짜 존재하지 않는 경로조차
// AdminAuthMiddleware를 타고 401을 반환했다 — 이 테스트는 그 회귀를 막는다.
func TestUndefinedRouteShouldReturnPlain404RegardlessOfHowManyAuthGroupsShareThePrefix(t *testing.T) {
	// Arrange - message 그룹까지 포함해 v1과 prefix를 공유하는 서브그룹을 최대한 채운다.
	e := echo.New()
	RegisterRoutes(e, &Handlers{
		Auth:    &AuthHandler{},
		Device:  &DeviceHandler{},
		Message: NewMessageHandler(&messageUsecaseForHandler{}, nil, nil),
	}, adminAuthForMessageRoutes{}, trackAuthForMessageRoutes{})

	// Act
	req := httptest.NewRequest(http.MethodGet, "/api/v1/totally-bogus-path-xyz", nil)
	rec := httptest.NewRecorder()
	e.ServeHTTP(rec, req)

	// Assert
	if rec.Code != http.StatusNotFound {
		t.Fatalf("expected status 404 for a route that was never registered, got %d: %s", rec.Code, rec.Body.String())
	}
}

// 위 404 수정이 실제 인증이 필요한 라우트의 인증 요구까지 없애버리지 않았는지 확인한다.
func TestRealProtectedRoutesShouldStillRequireAuthAfter404Fix(t *testing.T) {
	e := echo.New()
	RegisterRoutes(e, &Handlers{
		Auth:    &AuthHandler{},
		Device:  &DeviceHandler{},
		Message: NewMessageHandler(&messageUsecaseForHandler{}, nil, nil),
	}, adminAuthForMessageRoutes{}, trackAuthForMessageRoutes{})

	for _, tc := range []struct {
		name   string
		method string
		path   string
	}{
		{name: "admin route", method: http.MethodGet, path: "/api/v1/auth/track/sessions"},
		{name: "track route", method: http.MethodPost, path: "/api/v1/auth/track/logout"},
	} {
		t.Run(tc.name, func(t *testing.T) {
			// Act - 토큰 없이 호출
			req := httptest.NewRequest(tc.method, tc.path, nil)
			rec := httptest.NewRecorder()
			e.ServeHTTP(rec, req)

			// Assert - 여전히 401이어야 한다 (404로 바뀌면 안 됨 = 라우트는 실제로 존재)
			if rec.Code != http.StatusUnauthorized {
				t.Fatalf("expected status 401 for %s without token, got %d: %s", tc.path, rec.Code, rec.Body.String())
			}
		})
	}
}
