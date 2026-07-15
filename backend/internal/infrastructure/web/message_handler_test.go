package web

import (
	"context"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"cornermon/backend/internal/domain"

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

func TestListDirectMessagesShoudRejectRequestWhenSessionTrackDiffers(t *testing.T) {
	// Arrange
	e := echo.New()
	req := httptest.NewRequest(http.MethodGet, "/tracks/track-2/messages", nil)
	rec := httptest.NewRecorder()
	c := e.NewContext(req, rec)
	c.SetParamNames("trackId")
	c.SetParamValues("track-2")
	c.Set("facilitatorSession", &domain.FacilitatorSession{TrackID: "track-1"})

	// Act
	err := NewMessageHandler(&messageUsecaseForHandler{}, nil).ListDirectMessages(c)

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
	c.Set("facilitatorSession", &domain.FacilitatorSession{TrackID: "track-1"})

	// Act
	err := NewMessageHandler(&messageUsecaseForHandler{}, nil).GetUnreadCount(c)

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
	c.Set("facilitatorSession", &domain.FacilitatorSession{TrackID: "track-1"})

	// Act
	err := NewMessageHandler(&messageUsecaseForHandler{}, nil).SendDirect(c)

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
	c.Set("facilitatorSession", &domain.FacilitatorSession{TrackID: "track-1"})

	// Act
	err := NewMessageHandler(uc, nil).ListDirectMessages(c)

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
