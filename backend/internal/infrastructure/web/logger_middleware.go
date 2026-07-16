package web

import (
	"context"
	"log/slog"
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

			// Trace ID 추출 또는 생성
			traceID := c.Request().Header.Get("X-Trace-ID")
			if traceID == "" {
				traceID = uuid.New().String()
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

			// 정상 처리 완료 시 INFO 레벨로 단 1회 로깅
			// trace_id는 errs.SlogWrappedHandler가 ctx 기반으로 자동 1회 주입하므로 여기서는 찍지 않는다.
			slog.InfoContext(ctx, "Request completed",
				slog.String("method", c.Request().Method),
				slog.String("path", c.Request().URL.Path),
				slog.Int("status", status),
				slog.Float64("duration_ms", durationMs(duration)),
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
