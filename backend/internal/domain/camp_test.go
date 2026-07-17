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
		name          string
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

func TestUpdateSettingsShoudPatchOnlySpecifiedFieldsWhenValid(t *testing.T) {
	// Arrange
	start := time.Date(2026, 7, 13, 9, 0, 0, 0, time.UTC)
	end := start.Add(8 * time.Hour)
	activated := start.Add(time.Hour)
	camp := &domain.Camp{
		Name: "Original", StartAt: start, EndAt: end, Status: domain.CampActive,
		ActivatedAt: domain.Some(activated), BottleneckMinSamples: 3, BottleneckRatioPct: 20,
	}

	// Act
	err := camp.UpdateSettings(domain.CampSettingsPatch{Name: domain.Some("  Updated  "), BottleneckRatioPct: domain.Some(35)})

	// Assert
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if camp.Name != "Updated" || camp.BottleneckRatioPct != 35 || camp.StartAt != start || camp.EndAt != end || camp.BottleneckMinSamples != 3 {
		t.Fatalf("unexpected patched camp: %+v", camp)
	}
	gotActivated, ok := camp.ActivatedAt.Value()
	if !ok || gotActivated != activated || camp.EndedAt.IsSet() {
		t.Fatalf("actual lifecycle timestamps changed: %+v", camp)
	}
}

func TestUpdateSettingsShoudRejectInvalidPatchWithoutMutation(t *testing.T) {
	start := time.Date(2026, 7, 13, 9, 0, 0, 0, time.UTC)
	tests := []struct {
		name  string
		patch domain.CampSettingsPatch
	}{
		{name: "blank name", patch: domain.CampSettingsPatch{Name: domain.Some("  ")}},
		{name: "invalid period", patch: domain.CampSettingsPatch{StartAt: domain.Some(start.Add(2 * time.Hour)), EndAt: domain.Some(start)}},
		{name: "non-positive samples", patch: domain.CampSettingsPatch{BottleneckMinSamples: domain.Some(0)}},
		{name: "ratio below range", patch: domain.CampSettingsPatch{BottleneckRatioPct: domain.Some(-1)}},
		{name: "ratio above range", patch: domain.CampSettingsPatch{BottleneckRatioPct: domain.Some(101)}},
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			// Arrange
			camp := &domain.Camp{Name: "Original", StartAt: start, EndAt: start.Add(time.Hour), Status: domain.CampPending, BottleneckMinSamples: 3, BottleneckRatioPct: 20}
			before := *camp

			// Act
			err := camp.UpdateSettings(tc.patch)

			// Assert
			if err != domain.ErrCampInvalidSettings {
				t.Fatalf("expected ErrCampInvalidSettings, got %v", err)
			}
			if *camp != before {
				t.Fatalf("invalid patch mutated camp: before=%+v after=%+v", before, *camp)
			}
		})
	}
}

func TestNewCampShoudCreatePendingCampWhenValid(t *testing.T) {
	// Arrange
	start := time.Date(2026, 7, 20, 9, 0, 0, 0, time.UTC)
	end := start.Add(2 * time.Hour)

	// Act
	camp, err := domain.NewCamp("camp-1", "  2026 여름 코너학습  ", start, end)

	// Assert
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if camp.ID != "camp-1" || camp.Name != "2026 여름 코너학습" || camp.StartAt != start || camp.EndAt != end {
		t.Fatalf("unexpected camp: %+v", camp)
	}
	if camp.Status != domain.CampPending || camp.BottleneckMinSamples != 3 || camp.BottleneckRatioPct != 20 {
		t.Fatalf("unexpected defaults: %+v", camp)
	}
	if camp.RegistrationCode != domain.GenerateRegistrationCode("camp-1") {
		t.Fatalf("expected deterministic registration code, got %q", camp.RegistrationCode)
	}
}

func TestNewCampShoudRejectInvalidInputWithoutCreatingCamp(t *testing.T) {
	start := time.Date(2026, 7, 20, 9, 0, 0, 0, time.UTC)
	tests := []struct {
		name     string
		campName string
		startAt  time.Time
		endAt    time.Time
	}{
		{name: "blank name", campName: "  ", startAt: start, endAt: start.Add(time.Hour)},
		{name: "missing startAt", campName: "Camp", startAt: time.Time{}, endAt: start.Add(time.Hour)},
		{name: "missing endAt", campName: "Camp", startAt: start, endAt: time.Time{}},
		{name: "startAt not before endAt", campName: "Camp", startAt: start.Add(time.Hour), endAt: start},
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			// Act
			camp, err := domain.NewCamp("camp-1", tc.campName, tc.startAt, tc.endAt)

			// Assert
			if err != domain.ErrCampInvalidSettings {
				t.Fatalf("expected ErrCampInvalidSettings, got %v", err)
			}
			if camp != nil {
				t.Fatalf("expected nil camp on error, got %+v", camp)
			}
		})
	}
}

func TestUpdateSettingsShoudReturnConflictErrorWhenCampEnded(t *testing.T) {
	// Arrange
	camp := &domain.Camp{Status: domain.CampEnded}

	// Act
	err := camp.UpdateSettings(domain.CampSettingsPatch{Name: domain.Some("Updated")})

	// Assert
	if err != domain.ErrCampSettingsLocked {
		t.Fatalf("expected ErrCampSettingsLocked, got %v", err)
	}
}
