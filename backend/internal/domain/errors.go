package domain

import (
	"errors"
	"time"
)

var (
	ErrCampInvalidTransition   = errors.New("camp: invalid status transition")
	ErrGroupBusy               = errors.New("group: already in progress at another corner")
	ErrDuplicateVisit          = errors.New("group: corner already completed")
	ErrTrackNotActive          = errors.New("track: not active")
	ErrTrackBusy               = errors.New("track: visit already in progress")
	ErrTrackDeleteBlocked      = errors.New("track: cannot delete while visit in progress")
	ErrVisitAlreadyCompleted   = errors.New("visit: already completed")
	ErrBadgeAlreadyAssigned    = errors.New("badge: already assigned")
	ErrBadgeNotAssigned        = errors.New("badge: not assigned")
	ErrDeviceNotApproved       = errors.New("device: not approved")
	ErrDeviceLocked            = errors.New("device: locked due to pin failures")
	ErrSessionRevoked          = errors.New("session: already revoked")
	ErrCornerNotInItinerary    = errors.New("group: corner not found in itinerary")
	ErrVisitNotInProgress      = errors.New("group: visit not in progress for this corner")
	ErrTrackAlreadyDeleted     = errors.New("track: already deleted")
	ErrTrackNotBusy            = errors.New("track: no visit in progress")
	ErrVisitEndBeforeStart     = errors.New("visit: endedAt cannot be before startedAt")
	ErrDeviceInvalidTransition = errors.New("device: invalid status transition")
	ErrCornerNotFound          = errors.New("corner: not found")
	ErrCampNotFound            = errors.New("camp: not found")
	ErrCampInvalidSettings     = errors.New("camp: invalid settings")
	ErrTrackCampMismatch       = errors.New("track: target corner belongs to another camp")
)

type DeviceLockedError struct {
	LockedUntil time.Time
}

func (e *DeviceLockedError) Error() string {
	return ErrDeviceLocked.Error()
}

func (e *DeviceLockedError) Is(target error) bool {
	return target == ErrDeviceLocked
}

var ErrInvalidPin = errors.New("auth: invalid pin")

type InvalidPinError struct {
	LockedUntil Optional[time.Time]
}

func (e *InvalidPinError) Error() string {
	return ErrInvalidPin.Error()
}

func (e *InvalidPinError) Is(target error) bool {
	return target == ErrInvalidPin
}
