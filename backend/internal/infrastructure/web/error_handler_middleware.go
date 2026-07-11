package web

import (
	"errors"
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

		var he *echo.HTTPError
		if errors.As(err, &he) {
			code := he.Code
			var msg string
			if m, ok := he.Message.(string); ok {
				msg = m
			} else {
				msg = err.Error()
			}
			_ = c.JSON(code, ErrorResponse{Code: "HTTP_ERROR", Message: msg})
			return
		}

		code, errCode := mapDomainError(err)

		var details map[string]interface{}
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

		_ = c.JSON(code, ErrorResponse{
			Code:    errCode,
			Message: err.Error(),
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
	default:
		return http.StatusInternalServerError, "INTERNAL_ERROR"
	}
}
