package web

import (
	"bytes"
	"context"
	"errors"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"reflect"
	"slices"
	"sort"
	"strings"
	"testing"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/errs"
	"cornermon/backend/internal/usecase"

	"github.com/labstack/echo/v4"
)

type mockSubscriber struct {
	adminCh     chan usecase.SSEMessage
	trackCh     chan usecase.SSEMessage
	adminCampID domain.CampID
	trackCampID domain.CampID
	trackID     domain.TrackID
}

func (m *mockSubscriber) SubscribeAdmin(_ context.Context, campID domain.CampID) (<-chan usecase.SSEMessage, error) {
	m.adminCampID = campID
	return m.adminCh, nil
}

func (m *mockSubscriber) SubscribeTrack(_ context.Context, campID domain.CampID, trackID domain.TrackID) (<-chan usecase.SSEMessage, error) {
	m.trackCampID = campID
	m.trackID = trackID
	return m.trackCh, nil
}

func TestShouldFormatStructuredPayloadWhenFormattingSSEMessage(t *testing.T) {
	// Arrange
	message := usecase.SSEMessage{
		Event: usecase.EventTrackUpdated,
		Scope: usecase.TrackScope("track-1"),
	}

	// Act
	got, err := formatSSEMessage(message)

	// Assert
	if err != nil {
		t.Fatalf("formatSSEMessage() error = %v", err)
	}
	want := "event: track_updated\ndata: {\"event\":\"track_updated\",\"scope\":{\"kind\":\"track\",\"trackId\":\"track-1\"}}\n\n"
	if got != want {
		t.Fatalf("formatSSEMessage() = %q, want %q", got, want)
	}
}

func TestShouldOmitTrackIDWhenFormattingCampScope(t *testing.T) {
	// Arrange
	message := usecase.SSEMessage{Event: usecase.EventCampUpdated, Scope: usecase.CampScope()}

	// Act
	got, err := formatSSEMessage(message)

	// Assert
	if err != nil {
		t.Fatalf("formatSSEMessage() error = %v", err)
	}
	if strings.Contains(got, "trackId") {
		t.Fatalf("camp-scoped payload should omit trackId: %s", got)
	}
}

// failAfterNWriter는 처음 n번의 Write는 성공시키고, 그 이후 호출부터는 클라이언트 연결
// 끊김을 흉내 내어 에러를 반환하는 http.ResponseWriter다. streamEvents가 최초 "connected"
// 메시지는 정상 기록한 뒤, 실제 이벤트 write에서 실패하는 상황을 재현하기 위함이다.
type failAfterNWriter struct {
	header   http.Header
	n        int
	writeCnt int
}

func (w *failAfterNWriter) Header() http.Header { return w.header }
func (w *failAfterNWriter) WriteHeader(int)     {}
func (w *failAfterNWriter) Write(p []byte) (int, error) {
	w.writeCnt++
	if w.writeCnt > w.n {
		return 0, errors.New("write: connection reset by peer")
	}
	return len(p), nil
}

// Flush는 echo.Response가 http.Flusher를 요구하므로 필요한 no-op 구현이다.
func (w *failAfterNWriter) Flush() {}

func withCapturedLogger(t *testing.T) *bytes.Buffer {
	t.Helper()
	buf := &bytes.Buffer{}
	original := slog.Default()
	slog.SetDefault(slog.New(errs.NewSlogWrappedHandler(slog.NewJSONHandler(buf, &slog.HandlerOptions{Level: slog.LevelDebug}))))
	t.Cleanup(func() { slog.SetDefault(original) })
	return buf
}

func TestShouldLogConnectionIDAndCausationIDWhenSSEEventWriteFails(t *testing.T) {
	// Arrange
	buf := withCapturedLogger(t)
	writer := &failAfterNWriter{header: http.Header{}, n: 1} // 최초 "connected" write만 허용
	req := httptest.NewRequest(http.MethodGet, "/api/v1/events/track/track-1", nil)
	// connection_id(연결 자신)와 causation_id(알림을 유발한 원본 요청의 계보)가 서로 다른
	// 값이라는 것을 로그에서 구분해서 볼 수 있어야 한다.
	ctx := context.WithValue(req.Context(), errs.TraceIDKey, "trace-connection")
	req = req.WithContext(ctx)
	e := echo.New()
	c := e.NewContext(req, httptest.NewRecorder())
	c.Response().Writer = writer

	ch := make(chan usecase.SSEMessage, 1)
	ch <- usecase.SSEMessage{Event: usecase.EventTrackUpdated, Scope: usecase.TrackScope("track-1"), CausationID: "trace-cause"}
	h := NewEventHandler(nil, nil, nil)

	// Act
	err := h.streamEvents(c, ch)

	// Assert
	if err == nil {
		t.Fatal("expected write error to propagate")
	}
	logLine := buf.String()
	if !strings.Contains(logLine, `"connection_id":"trace-connection"`) {
		t.Errorf("expected write-failure log to contain connection_id, got: %s", logLine)
	}
	if !strings.Contains(logLine, `"causation_id":"trace-cause"`) {
		t.Errorf("expected write-failure log to contain causation_id, got: %s", logLine)
	}
	if !strings.Contains(logLine, "SSE event write failed") {
		t.Errorf("expected write-failure log message, got: %s", logLine)
	}
}

func TestShouldLogConnectionIDAndCausationIDWhenSSEEventDelivered(t *testing.T) {
	// Arrange
	buf := withCapturedLogger(t)
	writer := &failAfterNWriter{header: http.Header{}, n: 2} // "connected" + 이벤트 write 모두 허용
	req := httptest.NewRequest(http.MethodGet, "/api/v1/events/track/track-1", nil)
	ctx := context.WithValue(req.Context(), errs.TraceIDKey, "trace-connection")
	req = req.WithContext(ctx)
	e := echo.New()
	c := e.NewContext(req, httptest.NewRecorder())
	c.Response().Writer = writer

	ch := make(chan usecase.SSEMessage, 1)
	ch <- usecase.SSEMessage{Event: usecase.EventTrackUpdated, Scope: usecase.TrackScope("track-1"), CausationID: "trace-cause"}
	close(ch) // 두 번째 for-select 순회에서 채널 닫힘으로 streamEvents가 정상 반환하도록 함
	h := NewEventHandler(nil, nil, nil)

	// Act
	err := h.streamEvents(c, ch)

	// Assert
	if err != nil {
		t.Fatalf("expected no error, got %v", err)
	}
	logLine := buf.String()
	if !strings.Contains(logLine, "SSE event delivered") {
		t.Fatalf("expected delivered log, got: %s", logLine)
	}
	if !strings.Contains(logLine, `"connection_id":"trace-connection"`) {
		t.Errorf("expected delivered log to contain connection_id, got: %s", logLine)
	}
	if !strings.Contains(logLine, `"causation_id":"trace-cause"`) {
		t.Errorf("expected delivered log to contain causation_id, got: %s", logLine)
	}
}

func TestShouldKeepSwaggerEventEnumInSyncWhenNotificationEventsChange(t *testing.T) {
	// Arrange
	field, _ := reflect.TypeOf(SSENotification{}).FieldByName("Event")
	got := strings.Split(field.Tag.Get("enums"), ",")
	want := make([]string, 0, len(usecase.NotificationEvents()))
	for _, event := range usecase.NotificationEvents() {
		want = append(want, string(event))
	}

	// Act
	sort.Strings(got)
	sort.Strings(want)

	// Assert
	if !slices.Equal(got, want) {
		t.Fatalf("SSENotification Event enums = %v, want %v", got, want)
	}
}
