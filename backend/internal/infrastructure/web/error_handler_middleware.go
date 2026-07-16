package web

import (
	"errors"
	"log/slog"
	"math"
	"net/http"
	"time"

	"cornermon/backend/internal/domain"

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
			errCode = "HTTP_ERROR"
			if m, ok := he.Message.(string); ok {
				message = m
			}
		} else {
			code, errCode = mapDomainError(err)

			var lockedErr *domain.DeviceLockedError
			var invalidPinErr *domain.InvalidPinError

			if errors.As(err, &lockedErr) {
				now := time.Now()
				sec := int(math.Ceil(lockedErr.LockedUntil.Sub(now).Seconds()))
				if sec < 1 {
					sec = 1
				}
				details = map[string]interface{}{
					"retryAfterSeconds": sec,
				}
			} else if errors.As(err, &invalidPinErr) {
				if lockedUntil, ok := invalidPinErr.LockedUntil.Value(); ok {
					now := time.Now()
					sec := int(math.Ceil(lockedUntil.Sub(now).Seconds()))
					if sec < 1 {
						sec = 1
					}
					details = map[string]interface{}{
						"retryAfterSeconds": sec,
					}
				}
			}
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

func mapDomainError(err error) (int, string) {
	switch {
	case errors.Is(err, domain.ErrCampInvalidTransition):
		return http.StatusBadRequest, "INVALID_TRANSITION"
	case errors.Is(err, domain.ErrGroupBusy):
		return http.StatusConflict, "GROUP_BUSY"
	case errors.Is(err, domain.ErrDuplicateVisit):
		return http.StatusConflict, "DUPLICATE_VISIT"
	case errors.Is(err, domain.ErrTrackNotActive):
		return http.StatusForbidden, "TRACK_NOT_ACTIVE"
	case errors.Is(err, domain.ErrTrackScopeForbidden):
		return http.StatusForbidden, "TRACK_SCOPE_FORBIDDEN"
	case errors.Is(err, domain.ErrTrackNotFound):
		return http.StatusNotFound, "TRACK_NOT_FOUND"
	case errors.Is(err, domain.ErrTrackBusy):
		return http.StatusConflict, "TRACK_BUSY"
	case errors.Is(err, domain.ErrTrackDeleteBlocked):
		return http.StatusConflict, "TRACK_DELETE_BLOCKED"
	case errors.Is(err, domain.ErrVisitAlreadyCompleted):
		return http.StatusConflict, "VISIT_ALREADY_COMPLETED"
	case errors.Is(err, domain.ErrBadgeAlreadyAssigned):
		return http.StatusConflict, "BADGE_ALREADY_ASSIGNED"
	case errors.Is(err, domain.ErrBadgeNotAssigned):
		return http.StatusBadRequest, "BADGE_NOT_ASSIGNED"
	case errors.Is(err, domain.ErrDeviceNotApproved):
		return http.StatusForbidden, "DEVICE_NOT_APPROVED"
	case errors.Is(err, domain.ErrDeviceLocked):
		return http.StatusTooManyRequests, "PIN_LOCKED"
	case errors.Is(err, domain.ErrInvalidPin):
		return http.StatusBadRequest, "INVALID_PIN"
	case errors.Is(err, domain.ErrSessionRevoked):
		return http.StatusUnauthorized, "SESSION_REVOKED"
	case errors.Is(err, domain.ErrCornerNotInItinerary):
		return http.StatusBadRequest, "CORNER_NOT_IN_ITINERARY"
	case errors.Is(err, domain.ErrVisitNotInProgress):
		return http.StatusBadRequest, "VISIT_NOT_IN_PROGRESS"
	case errors.Is(err, domain.ErrTrackAlreadyDeleted):
		return http.StatusConflict, "TRACK_ALREADY_DELETED"
	case errors.Is(err, domain.ErrTrackNotBusy):
		return http.StatusBadRequest, "TRACK_NOT_BUSY"
	case errors.Is(err, domain.ErrVisitEndBeforeStart):
		return http.StatusBadRequest, "VISIT_END_BEFORE_START"
	case errors.Is(err, domain.ErrDeviceInvalidTransition):
		return http.StatusBadRequest, "INVALID_TRANSITION"
	case errors.Is(err, domain.ErrCornerNotFound):
		return http.StatusNotFound, "CORNER_NOT_FOUND"
	case errors.Is(err, domain.ErrCampNotFound):
		return http.StatusNotFound, "CAMP_NOT_FOUND"
	case errors.Is(err, domain.ErrCampInvalidSettings):
		return http.StatusBadRequest, "INVALID_CAMP_SETTINGS"
	case errors.Is(err, domain.ErrCampSettingsLocked):
		return http.StatusConflict, "CAMP_SETTINGS_LOCKED"
	case errors.Is(err, domain.ErrTrackCampMismatch):
		return http.StatusConflict, "TRACK_CAMP_MISMATCH"
	default:
		return http.StatusInternalServerError, "INTERNAL_ERROR"
	}
}
