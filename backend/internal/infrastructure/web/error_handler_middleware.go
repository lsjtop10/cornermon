package web

import (
	"errors"
	"log/slog"
	"net/http"
	"time"

	"github.com/labstack/echo/v4"
)

func ErrorHandler() echo.HTTPErrorHandler {
	return func(err error, c echo.Context) {
		if c.Response().Committed {
			return
		}

		ctx := c.Request().Context()

		var code int
		var errCode string
		var details map[string]interface{}
		var message string = err.Error()

		var he *echo.HTTPError
		if errors.As(err, &he) {
			code = he.Code
			if er, ok := he.Message.(ErrorResponse); ok {
				errCode = er.Code
				message = er.Message
				details = er.Details
			} else if erPtr, ok := he.Message.(*ErrorResponse); ok {
				errCode = erPtr.Code
				message = erPtr.Message
				details = erPtr.Details
			} else if m, ok := he.Message.(string); ok {
				errCode = "HTTP_ERROR"
				message = m
			} else {
				errCode = "HTTP_ERROR"
			}
		} else {
			code = http.StatusInternalServerError
			errCode = "INTERNAL_SERVER_ERROR"
		}

		var durationMsAttr slog.Attr
		if requestStart, ok := c.Get(requestStartKey).(time.Time); ok {
			durationMsAttr = slog.Float64("duration_ms", durationMs(time.Since(requestStart)))
		} else {
			durationMsAttr = slog.Float64("duration_ms", 0)
		}

		commonAttrs := []any{
			slog.String("method", c.Request().Method),
			slog.String("path", c.Request().URL.Path),
			slog.Int("status", code),
			durationMsAttr,
			slog.String("ip", c.RealIP()),
			slog.String("user_agent", c.Request().UserAgent()),
			slog.String("error_msg", err.Error()),
			slog.Any("error", err), // errs.SlogWrappedHandler가 AppError/stack_trace 추출에만 사용, 최종 출력에서는 제거됨
		}

		if code >= 500 {
			slog.ErrorContext(ctx, "System error occurred", commonAttrs...)
		} else {
			slog.WarnContext(ctx, "Request warning", commonAttrs...)
		}

		_ = c.JSON(code, ErrorResponse{
			Code:    errCode,
			Message: message,
			Details: details,
		})
	}
}
