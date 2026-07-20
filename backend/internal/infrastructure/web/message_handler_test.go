package web

import (
	"context"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/usecase"

	"github.com/labstack/echo/v4"
)

type messageUsecaseForHandler struct {
	markRead   bool
	after      domain.Optional[time.Time]
	viewerRole domain.SenderRole
}

func (m *messageUsecaseForHandler) SendDirect(context.Context, domain.TrackID, string, domain.SenderRole) (*domain.Message, error) {
	return nil, nil
}

func (m *messageUsecaseForHandler) ListDirectMessages(_ context.Context, _ domain.TrackID, viewerRole domain.SenderRole, after domain.Optional[time.Time], markRead bool) ([]*domain.Message, error) {
	m.after = after
	m.markRead = markRead
	m.viewerRole = viewerRole
	return []*domain.Message{}, nil
}

func (m *messageUsecaseForHandler) GetUnreadCount(context.Context, domain.TrackID, domain.SenderRole) (int, error) {
	return 0, nil
}

type announcementCommandUsecaseForHandler struct{}

func (a *announcementCommandUsecaseForHandler) SendAnnouncement(context.Context, domain.CampID, string, domain.AdminID) (*domain.Announcement, error) {
	return nil, nil
}

func (a *announcementCommandUsecaseForHandler) MarkNoticeRead(context.Context, string, domain.AnnouncementID) error {
	return nil
}

type announcementQueryUsecaseForHandler struct {
	notices []*domain.Announcement
	views   []usecase.BroadcastNoticeView
}

func (a *announcementQueryUsecaseForHandler) ListNoticesByCamp(context.Context, domain.CampID) ([]*domain.Announcement, error) {
	return a.notices, nil
}

func (a *announcementQueryUsecaseForHandler) ListNoticesForTrack(context.Context, domain.CampID, domain.TrackID) ([]usecase.BroadcastNoticeView, error) {
	return a.views, nil
}

func (a *announcementQueryUsecaseForHandler) GetAnnouncementReceipts(context.Context, domain.AnnouncementID) ([]usecase.BroadcastReceiptDTO, error) {
	return nil, nil
}

func TestListBroadcastsShoudReturnNoticesWhenAdminSessionPresent(t *testing.T) {
	// Arrange
	query := &announcementQueryUsecaseForHandler{notices: []*domain.Announcement{domain.NewAnnouncementFromProps(domain.AnnouncementProps{ID: "notice-1", CampID: "camp-1", Content: "hello"})}}
	e := echo.New()
	req := httptest.NewRequest(http.MethodGet, "/camps/camp-1/messages/broadcast", nil)
	rec := httptest.NewRecorder()
	c := e.NewContext(req, rec)
	c.SetParamNames("campId")
	c.SetParamValues("camp-1")
	c.Set("adminSession", domain.NewAdminSessionFromProps(domain.AdminSessionProps{AdminID: "admin-1"}))

	// Act
	err := NewMessageHandler(&messageUsecaseForHandler{}, &announcementCommandUsecaseForHandler{}, query).ListBroadcasts(c)

	// Assert
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if rec.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d", rec.Code)
	}
	if !strings.Contains(rec.Body.String(), `"isRead":false`) || strings.Contains(rec.Body.String(), `"readAt"`) {
		t.Fatalf("expected admin response without track receipt state, got %s", rec.Body.String())
	}
}

func TestListBroadcastsShoudReturnNoticesWhenFacilitatorSessionPresent(t *testing.T) {
	// Arrange
	readAt := time.Date(2026, 7, 20, 1, 2, 3, 0, time.UTC)
	query := &announcementQueryUsecaseForHandler{views: []usecase.BroadcastNoticeView{{Announcement: domain.NewAnnouncementFromProps(domain.AnnouncementProps{ID: "notice-1", CampID: "camp-1", Content: "hello"}), ReadAt: domain.Some(readAt)}}}
	e := echo.New()
	req := httptest.NewRequest(http.MethodGet, "/camps/camp-1/messages/broadcast", nil)
	rec := httptest.NewRecorder()
	c := e.NewContext(req, rec)
	c.SetParamNames("campId")
	c.SetParamValues("camp-1")
	c.Set("facilitatorSession", domain.NewFacilitatorSessionFromProps(domain.FacilitatorSessionProps{TrackID: "track-1"}))

	// Act
	err := NewMessageHandler(&messageUsecaseForHandler{}, &announcementCommandUsecaseForHandler{}, query).ListBroadcasts(c)

	// Assert
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if rec.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d", rec.Code)
	}
	if !strings.Contains(rec.Body.String(), `"isRead":true`) || !strings.Contains(rec.Body.String(), readAt.Format(time.RFC3339)) {
		t.Fatalf("expected read receipt state, got %s", rec.Body.String())
	}
}

func TestListDirectMessagesShoudRejectRequestWhenSessionTrackDiffers(t *testing.T) {
	// Arrange
	e := echo.New()
	req := httptest.NewRequest(http.MethodGet, "/tracks/track-2/messages", nil)
	rec := httptest.NewRecorder()
	c := e.NewContext(req, rec)
	c.SetParamNames("trackId")
	c.SetParamValues("track-2")
	c.Set("facilitatorSession", domain.NewFacilitatorSessionFromProps(domain.FacilitatorSessionProps{TrackID: "track-1"}))

	// Act
	err := NewMessageHandler(&messageUsecaseForHandler{}, nil, nil).ListDirectMessages(c)

	// Assert
	if err != domain.ErrTrackScopeForbidden {
		t.Fatalf("expected ErrTrackScopeForbidden, got %v", err)
	}
}

func TestGetUnreadCountShoudRejectRequestWhenSessionTrackDiffers(t *testing.T) {
	// Arrange
	e := echo.New()
	req := httptest.NewRequest(http.MethodGet, "/tracks/track-2/messages/unread-count", nil)
	rec := httptest.NewRecorder()
	c := e.NewContext(req, rec)
	c.SetParamNames("trackId")
	c.SetParamValues("track-2")
	c.Set("facilitatorSession", domain.NewFacilitatorSessionFromProps(domain.FacilitatorSessionProps{TrackID: "track-1"}))

	// Act
	err := NewMessageHandler(&messageUsecaseForHandler{}, nil, nil).GetUnreadCount(c)

	// Assert
	if err != domain.ErrTrackScopeForbidden {
		t.Fatalf("expected ErrTrackScopeForbidden, got %v", err)
	}
}

func TestSendDirectShoudRejectRequestWhenSessionTrackDiffers(t *testing.T) {
	// Arrange
	e := echo.New()
	req := httptest.NewRequest(http.MethodPost, "/tracks/track-2/messages/from-track", strings.NewReader(`{"content":"hello"}`))
	req.Header.Set(echo.HeaderContentType, echo.MIMEApplicationJSON)
	rec := httptest.NewRecorder()
	c := e.NewContext(req, rec)
	c.SetParamNames("trackId")
	c.SetParamValues("track-2")
	c.Set("facilitatorSession", domain.NewFacilitatorSessionFromProps(domain.FacilitatorSessionProps{TrackID: "track-1"}))

	// Act
	err := NewMessageHandler(&messageUsecaseForHandler{}, nil, nil).SendDirect(c)

	// Assert
	if err != domain.ErrTrackScopeForbidden {
		t.Fatalf("expected ErrTrackScopeForbidden, got %v", err)
	}
}

func TestListDirectMessagesShoudNotMarkReadWhenBackgroundIsOmitted(t *testing.T) {
	// Arrange
	uc := &messageUsecaseForHandler{}
	e := echo.New()
	req := httptest.NewRequest(http.MethodGet, "/tracks/track-1/messages", nil)
	rec := httptest.NewRecorder()
	c := e.NewContext(req, rec)
	c.SetParamNames("trackId")
	c.SetParamValues("track-1")
	c.Set("facilitatorSession", domain.NewFacilitatorSessionFromProps(domain.FacilitatorSessionProps{TrackID: "track-1"}))

	// Act
	err := NewMessageHandler(uc, nil, nil).ListDirectMessages(c)

	// Assert
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if uc.markRead {
		t.Fatal("expected omitted background to leave messages unread")
	}
	if uc.after.IsSet() {
		t.Fatal("expected omitted after to be unset")
	}
}
