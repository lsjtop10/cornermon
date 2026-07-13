package web

import (
	"context"
	"log/slog"
	"time"

	"cornermon/backend/internal/errs"
	"github.com/google/uuid"
	"github.com/labstack/echo/v4"
)

// Logger는 Echo 요청에 대해 trace_id를 생성/전파하고, 성공 요청에 대해 slog JSON 로그를 1회 출력하는 미들웨어입니다.
func Logger() echo.MiddlewareFunc {
	return func(next echo.HandlerFunc) echo.HandlerFunc {
		return func(c echo.Context) error {
			start := time.Now()

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
			slog.InfoContext(ctx, "Request completed",
				slog.String("trace_id", traceID),
				slog.String("method", c.Request().Method),
				slog.String("path", c.Request().URL.Path),
				slog.Int("status", status),
				slog.Duration("duration", duration),
				slog.String("ip", c.RealIP()),
			)

			return nil
		}
	}
}
