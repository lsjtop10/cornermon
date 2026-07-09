package domain_test

import (
	"errors"
	"testing"

	"cornermon/backend/internal/domain"
)

func TestBadge_AssignTo(t *testing.T) {
	t.Run("AssignTo on UNASSIGNED badge succeeds", func(t *testing.T) {
		badge := &domain.Badge{
			ID:     domain.BadgeID("badge-1"),
			Status: domain.BadgeUnassigned,
		}

		err := badge.AssignTo(domain.GroupID("group-1"))
		if err != nil {
			t.Fatalf("expected no error, got %v", err)
		}

		if badge.Status != domain.BadgeAssigned {
			t.Errorf("expected status to be ASSIGNED, got %v", badge.Status)
		}

		groupID, ok := badge.AssignedGroupID.Value()
		if !ok {
			t.Error("expected AssignedGroupID to be set")
		}
		if groupID != domain.GroupID("group-1") {
			t.Errorf("expected groupID to be 'group-1', got %q", groupID)
		}
	})

	t.Run("AssignTo on ASSIGNED badge fails with ErrBadgeAlreadyAssigned", func(t *testing.T) {
		badge := &domain.Badge{
			ID:              domain.BadgeID("badge-1"),
			Status:          domain.BadgeAssigned,
			AssignedGroupID: domain.Some(domain.GroupID("group-1")),
		}

		err := badge.AssignTo(domain.GroupID("group-2"))
		if !errors.Is(err, domain.ErrBadgeAlreadyAssigned) {
			t.Errorf("expected error %v, got %v", domain.ErrBadgeAlreadyAssigned, err)
		}

		// 값 변경 안됨 검증
		groupID, _ := badge.AssignedGroupID.Value()
		if groupID != domain.GroupID("group-1") {
			t.Errorf("expected groupID to remain 'group-1', got %q", groupID)
		}
	})
}

func TestBadge_Release(t *testing.T) {
	t.Run("Release on ASSIGNED badge succeeds", func(t *testing.T) {
		badge := &domain.Badge{
			ID:              domain.BadgeID("badge-1"),
			Status:          domain.BadgeAssigned,
			AssignedGroupID: domain.Some(domain.GroupID("group-1")),
		}

		err := badge.Release()
		if err != nil {
			t.Fatalf("expected no error, got %v", err)
		}

		if badge.Status != domain.BadgeUnassigned {
			t.Errorf("expected status to be UNASSIGNED, got %v", badge.Status)
		}

		if badge.AssignedGroupID.IsSet() {
			t.Error("expected AssignedGroupID to be unset (None)")
		}
	})

	t.Run("Release on UNASSIGNED badge fails with ErrBadgeNotAssigned", func(t *testing.T) {
		badge := &domain.Badge{
			ID:     domain.BadgeID("badge-1"),
			Status: domain.BadgeUnassigned,
		}

		err := badge.Release()
		if !errors.Is(err, domain.ErrBadgeNotAssigned) {
			t.Errorf("expected error %v, got %v", domain.ErrBadgeNotAssigned, err)
		}
	})
}
