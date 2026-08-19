package web_test

import (
	"bytes"
	"encoding/json"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"cornermon/backend/internal/errs"
	"cornermon/backend/internal/infrastructure/web"

	"github.com/google/uuid"
	"github.com/labstack/echo/v4"
)

// withCapturedLogger는 slog 기본 로거를 버퍼를 향하는 JSON 핸들러(운영 설정과 동일하게
// errs.SlogWrappedHandler로 감쌈)로 교체하고, 테스트 종료 시 원복하는 cleanup 함수를 등록한다.
func withCapturedLogger(t *testing.T) *bytes.Buffer {
	t.Helper()
	buf := &bytes.Buffer{}
	original := slog.Default()
	slog.SetDefault(slog.New(errs.NewSlogWrappedHandler(slog.NewJSONHandler(buf, nil))))
	t.Cleanup(func() { slog.SetDefault(original) })
	return buf
}

func TestLoggerShouldLogTraceIDExactlyOnceWhenRequestSucceeds(t *testing.T) {
	// arrange
	buf := withCapturedLogger(t)
	e := echo.New()
	req := httptest.NewRequest(http.MethodGet, "/api/v1/camps", nil)
	req.Header.Set("User-Agent", "test-agent/1.0")
	rec := httptest.NewRecorder()
	c := e.NewContext(req, rec)
	next := func(c echo.Context) error { return c.NoContent(http.StatusOK) }

	// act
	err := web.Logger()(next)(c)

	// assert
	if err != nil {
		t.Fatalf("expected no error, got %v", err)
	}
	logLine := buf.String()
	if count := strings.Count(logLine, `"trace_id"`); count != 1 {
		t.Errorf("expected trace_id to appear exactly once, got %d in: %s", count, logLine)
	}
}

func TestLoggerShouldGenerateUuidV7TraceIDWhenHeaderIsAbsent(t *testing.T) {
	// arrange — 헤더가 없어 미들웨어가 자체 생성하는 경로(#131): 프론트가 이미 매
	// 요청 X-Trace-ID를 보내므로 실제로는 프론트 없는 클라이언트(curl 등)에서만 탄다.
	e := echo.New()
	req := httptest.NewRequest(http.MethodGet, "/api/v1/camps", nil)
	rec := httptest.NewRecorder()
	c := e.NewContext(req, rec)
	next := func(c echo.Context) error { return c.NoContent(http.StatusOK) }

	// act
	if err := web.Logger()(next)(c); err != nil {
		t.Fatalf("expected no error, got %v", err)
	}

	// assert — 문자열 정렬이 생성 시각 순서에 가깝도록 v4(완전 랜덤)가 아닌 v7이어야 한다.
	traceID := rec.Header().Get("X-Trace-ID")
	parsed, err := uuid.Parse(traceID)
	if err != nil {
		t.Fatalf("expected X-Trace-ID to be a valid UUID, got %q: %v", traceID, err)
	}
	if parsed.Version() != 7 {
		t.Errorf("expected UUID version 7, got version %d (%q)", parsed.Version(), traceID)
	}
}

func TestLoggerShouldReuseClientProvidedTraceIDWhenHeaderIsPresent(t *testing.T) {
	// arrange — 프론트의 TraceIdInterceptor가 이미 v7로 선생성해 보내는 일반적인
	// 경로(#131): 클라이언트가 보낸 값은 형식과 무관하게 그대로 재사용해야 한다.
	e := echo.New()
	req := httptest.NewRequest(http.MethodGet, "/api/v1/camps", nil)
	req.Header.Set("X-Trace-ID", "client-provided-id")
	rec := httptest.NewRecorder()
	c := e.NewContext(req, rec)
	next := func(c echo.Context) error { return c.NoContent(http.StatusOK) }

	// act
	if err := web.Logger()(next)(c); err != nil {
		t.Fatalf("expected no error, got %v", err)
	}

	// assert
	if got := rec.Header().Get("X-Trace-ID"); got != "client-provided-id" {
		t.Errorf("expected X-Trace-ID to be echoed back unchanged, got %q", got)
	}
}

func TestLoggerShouldIncludeUserAgentAndDurationMsWhenRequestSucceeds(t *testing.T) {
	// arrange
	buf := withCapturedLogger(t)
	e := echo.New()
	req := httptest.NewRequest(http.MethodGet, "/api/v1/camps", nil)
	req.Header.Set("User-Agent", "test-agent/1.0")
	rec := httptest.NewRecorder()
	c := e.NewContext(req, rec)
	next := func(c echo.Context) error { return c.NoContent(http.StatusOK) }

	// act
	if err := web.Logger()(next)(c); err != nil {
		t.Fatalf("expected no error, got %v", err)
	}

	// assert
	var parsed map[string]any
	if err := json.Unmarshal(buf.Bytes(), &parsed); err != nil {
		t.Fatalf("expected valid JSON log line, got error: %v, line: %s", err, buf.String())
	}
	if parsed["user_agent"] != "test-agent/1.0" {
		t.Errorf("expected user_agent to be 'test-agent/1.0', got %v", parsed["user_agent"])
	}
	if _, ok := parsed["duration_ms"].(float64); !ok {
		t.Errorf("expected duration_ms to be a JSON number, got %v (%T)", parsed["duration_ms"], parsed["duration_ms"])
	}
}
