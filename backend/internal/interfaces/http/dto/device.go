package dto

import (
	"time"
	"cornermon/backend/internal/domain"
)

type DeviceRegistrationDTO struct {
	ID                string     `json:"id"`
	CampID            string     `json:"campId"`
	DeviceName        string     `json:"deviceName"`
	Status            string     `json:"status"`
	FailedPinAttempts int        `json:"failedPinAttempts"`
	LockedUntil       *time.Time `json:"lockedUntil,omitempty"`
}

func ToDeviceRegistrationDTO(d *domain.DeviceRegistration) DeviceRegistrationDTO {
	var lockedUntil *time.Time
	if t, ok := d.LockedUntil.Value(); ok {
		lockedUntil = &t
	}
	return DeviceRegistrationDTO{
		ID:                string(d.ID),
		CampID:            string(d.CampID),
		DeviceName:        d.DeviceName,
		Status:            string(d.Status),
		FailedPinAttempts: d.FailedPinAttempts,
		LockedUntil:       lockedUntil,
	}
}

type DeviceRegistrationRequest struct {
	RegistrationCode string `json:"registrationCode"`
	DeviceName       string `json:"deviceName"`
}

type DeviceRegistrationResponse struct {
	DeviceRegistration DeviceRegistrationDTO `json:"deviceRegistration"`
	DeviceToken        string                `json:"deviceToken"`
}

type DeviceRegistrationsResponse struct {
	DeviceRegistrations []DeviceRegistrationDTO `json:"deviceRegistrations"`
}
