package web

import (
	"context"
	"log/slog"
	"strings"
	"time"

	"cornermon/backend/internal/errs"
	"github.com/google/uuid"
	"github.com/labstack/echo/v4"
)

// requestStartKey는 요청 시작 시각을 echo.Context에 공유해, ErrorHandler가 동일한
// 시작 시각 기준으로 duration_ms를 계산할 수 있도록 하는 키입니다.
const requestStartKey = "request_start"

// Logger는 Echo 요청에 대해 trace_id를 생성/전파하고, 성공 요청에 대해 slog JSON 로그를 1회 출력하는 미들웨어입니다.
func Logger() echo.MiddlewareFunc {
	return func(next echo.HandlerFunc) echo.HandlerFunc {
		return func(c echo.Context) error {
			start := time.Now()
			c.Set(requestStartKey, start)

			// Trace ID 추출 또는 생성. 프론트가 항상 UUIDv7로 선생성해서 보내므로
			// (frontend/lib/shared/api/client/trace_id_interceptor.dart) 여기서 새로
			// 만드는 경우(#131) — 헤더가 아예 없는 요청 — 도 v7로 맞춘다: 문자열 정렬이
			// 생성 시각 순서에 가까워져 로그를 훑어볼 때 도움이 된다.
			traceID := c.Request().Header.Get("X-Trace-ID")
			if traceID == "" {
				if generated, err := uuid.NewV7(); err == nil {
					traceID = generated.String()
				} else {
					// crypto/rand 실패 등 극히 드문 경우에만 v4로 대체 — trace_id
					// 생성 실패로 요청 자체를 막지 않는다.
					traceID = uuid.New().String()
				}
			}

			// Context에 trace_id 바인딩
			ctx := context.WithValue(c.Request().Context(), errs.TraceIDKey, traceID)
			c.SetRequest(c.Request().WithContext(ctx))
			c.Set("trace_id", traceID)

			// 클라이언트 응답 헤더에도 Trace ID 반환
			c.Response().Header().Set("X-Trace-ID", traceID)

			// 다음 체인 실행
			err := next(c)
			if err != nil {
				// 에러 발생 시 Echo의 HTTPErrorHandler로 위임하여 1회에 한해 예외 및 감사 로깅을 수행하도록 함
				c.Error(err)
				return nil
			}

			status := c.Response().Status
			duration := time.Since(start)

			// SSE 핸들러(setSSEHeaders)는 next(c)가 클라이언트 접속 종료까지 블로킹되므로,
			// 이 duration은 응답 지연이 아니라 커넥션 유지 시간이다. duration_ms로 같이
			// 찍으면 "느린 요청" 필터/알림이 SSE 커넥션마다 오탐한다. Content-Type으로
			// 판별하는 이유: 경로 문자열(`/events/`)은 나중에 SSE 아닌 리소스가 같은
			// 이름으로 생겨도 걸릴 수 있지만, Content-Type은 실제 SSE 핸들러만 세팅하는
			// 응답의 실제 성격이라 안전하다.
			msg := "Request completed"
			durationField := slog.Float64("duration_ms", durationMs(duration))
			if strings.HasPrefix(c.Response().Header().Get(echo.HeaderContentType), "text/event-stream") {
				msg = "SSE connection closed"
				durationField = slog.Float64("connection_duration_ms", durationMs(duration))
			}

			// 정상 처리 완료 시 INFO 레벨로 단 1회 로깅
			// trace_id는 errs.SlogWrappedHandler가 ctx 기반으로 자동 1회 주입하므로 여기서는 찍지 않는다.
			slog.InfoContext(ctx, msg,
				slog.String("method", c.Request().Method),
				slog.String("path", c.Request().URL.Path),
				slog.Int("status", status),
				durationField,
				slog.String("ip", c.RealIP()),
				slog.String("user_agent", c.Request().UserAgent()),
			)

			return nil
		}
	}
}

// durationMs는 time.Duration을 소수점 밀리초 단위 float64로 변환합니다.
func durationMs(d time.Duration) float64 {
	return float64(d.Microseconds()) / 1000.0
}
