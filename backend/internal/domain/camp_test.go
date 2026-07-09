package domain_test

import (
	"errors"
	"testing"
	"time"

	"cornermon/backend/internal/domain"
)

func TestCamp_Activate(t *testing.T) {
	now := time.Date(2026, 7, 9, 15, 0, 0, 0, time.UTC)

	tests := []struct {
		name        string
		initialStatus domain.CampStatus
		expectedErr   error
		expectActive  bool
	}{
		{
			name:          "Activate from PENDING succeeds",
			initialStatus: domain.CampPending,
			expectedErr:   nil,
			expectActive:  true,
		},
		{
			name:          "Activate from ACTIVE fails",
			initialStatus: domain.CampActive,
			expectedErr:   domain.ErrCampInvalidTransition,
			expectActive:  true,
		},
		{
			name:          "Activate from ENDED fails",
			initialStatus: domain.CampEnded,
			expectedErr:   domain.ErrCampInvalidTransition,
			expectActive:  false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			camp := &domain.Camp{
				ID:     domain.CampID("camp-1"),
				Status: tt.initialStatus,
			}

			err := camp.Activate(now)

			if !errors.Is(err, tt.expectedErr) {
				t.Errorf("expected error %v, got %v", tt.expectedErr, err)
			}

			if err == nil {
				activatedAt, ok := camp.ActivatedAt.Value()
				if !ok {
					t.Error("expected ActivatedAt to be set")
				}
				if !activatedAt.Equal(now) {
					t.Errorf("expected ActivatedAt to be %v, got %v", now, activatedAt)
				}
			}

			if camp.IsActive() != tt.expectActive {
				t.Errorf("expected IsActive() to be %v, got %v", tt.expectActive, camp.IsActive())
			}
		})
	}
}

func TestCamp_End(t *testing.T) {
	now := time.Date(2026, 7, 9, 16, 0, 0, 0, time.UTC)

	tests := []struct {
		name          string
		initialStatus domain.CampStatus
		expectedErr   error
		expectEvent   bool
	}{
		{
			name:          "End from PENDING fails with zero-value event",
			initialStatus: domain.CampPending,
			expectedErr:   domain.ErrCampInvalidTransition,
			expectEvent:   false,
		},
		{
			name:          "End from ACTIVE succeeds",
			initialStatus: domain.CampActive,
			expectedErr:   nil,
			expectEvent:   true,
		},
		{
			name:          "End from ENDED fails with zero-value event",
			initialStatus: domain.CampEnded,
			expectedErr:   domain.ErrCampInvalidTransition,
			expectEvent:   false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			camp := &domain.Camp{
				ID:     domain.CampID("camp-1"),
				Status: tt.initialStatus,
			}

			event, err := camp.End(now)

			if !errors.Is(err, tt.expectedErr) {
				t.Errorf("expected error %v, got %v", tt.expectedErr, err)
			}

			if tt.expectEvent {
				if event.CampID != camp.ID {
					t.Errorf("expected event CampID to be %q, got %q", camp.ID, event.CampID)
				}
				if !event.OccurredAt.Equal(now) {
					t.Errorf("expected event OccurredAt to be %v, got %v", now, event.OccurredAt)
				}
				endedAt, ok := camp.EndedAt.Value()
				if !ok {
					t.Error("expected EndedAt to be set")
				}
				if !endedAt.Equal(now) {
					t.Errorf("expected EndedAt to be %v, got %v", now, endedAt)
				}
			} else {
				if event != (domain.CampEndedEvent{}) {
					t.Errorf("expected zero-value event, got %v", event)
				}
				if camp.EndedAt.IsSet() {
					t.Error("expected EndedAt not to be set")
				}
			}
		})
	}
}
