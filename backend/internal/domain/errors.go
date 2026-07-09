package domain

import "errors"

var (
	ErrCampInvalidTransition = errors.New("camp: invalid status transition")
	ErrGroupBusy             = errors.New("group: already in progress at another corner")
	ErrDuplicateVisit        = errors.New("group: corner already completed")
	ErrTrackNotActive        = errors.New("track: not active")
	ErrTrackBusy             = errors.New("track: visit already in progress")
	ErrTrackDeleteBlocked    = errors.New("track: cannot delete while visit in progress")
	ErrVisitAlreadyCompleted = errors.New("visit: already completed")
	ErrBadgeAlreadyAssigned  = errors.New("badge: already assigned")
	ErrBadgeNotAssigned      = errors.New("badge: not assigned")
	ErrDeviceNotApproved     = errors.New("device: not approved")
	ErrDeviceLocked          = errors.New("device: locked due to pin failures")
	ErrSessionRevoked        = errors.New("session: already revoked")
)
