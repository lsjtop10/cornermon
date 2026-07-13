package usecase

import (
	"context"
	"testing"
	"time"

	"cornermon/backend/internal/domain"
)

func TestGroupService_RegisterBadge(t *testing.T) {
	t.Run("ShouldRegisterBadgeSuccessfullyWhenBadgeIsUnassigned", func(t *testing.T) {
		// Arrange
		now := time.Now()
		camps := NewMockCampRepository()
		camp := &domain.Camp{ID: "camp-1", Status: domain.CampActive}
		camps.Save(context.Background(), camp)

		corners := NewMockCornerRepository()
		corner1 := &domain.Corner{ID: "corner-1", CampID: "camp-1"}
		corner2 := &domain.Corner{ID: "corner-2", CampID: "camp-1"}
		corners.Save(context.Background(), corner1)
		corners.Save(context.Background(), corner2)

		badges := NewMockBadgeRepository()
		badge := &domain.Badge{
			ID:              "badge-1",
			ShortID:         "B1",
			QRPayload:       "qr-1",
			Status:          domain.BadgeUnassigned,
			AssignedGroupID: domain.None[domain.GroupID](),
		}
		badges.Save(context.Background(), badge)

		groups := NewMockGroupRepository()
		visits := NewMockVisitRepository()
		auditLogs := &MockAuditLogRepository{}
		tx := &MockTxManager{}

		s := NewGroupService(camps, corners, groups, badges, visits, auditLogs, tx)
		s.nowFn = func() time.Time { return now }
		s.uuidFn = func() string { return "group-uuid" }

		// Act
		group, err := s.RegisterBadge(context.Background(), "camp-1", "qr-1", "1조")

		// Assert
		if err != nil {
			t.Fatalf("expected no error, got %v", err)
		}
		if group == nil {
			t.Fatal("expected group, got nil")
		}
		if group.ID != "group-uuid" {
			t.Errorf("expected group ID 'group-uuid', got '%s'", group.ID)
		}
		if len(group.Itinerary) != 2 {
			t.Errorf("expected itinerary size 2, got %d", len(group.Itinerary))
		}

		updatedBadge, _ := badges.Get(context.Background(), "badge-1")
		if updatedBadge.Status != domain.BadgeAssigned {
			t.Errorf("expected badge to be Assigned")
		}
	})

	t.Run("ShouldFailRegisterBadgeWhenCampIsEnded", func(t *testing.T) {
		// Arrange
		camps := NewMockCampRepository()
		camp := &domain.Camp{ID: "camp-1", Status: domain.CampEnded}
		camps.Save(context.Background(), camp)

		badges := NewMockBadgeRepository()
		badge := &domain.Badge{
			ID:        "badge-1",
			QRPayload: "qr-1",
			Status:    domain.BadgeUnassigned,
		}
		badges.Save(context.Background(), badge)

		groups := NewMockGroupRepository()
		visits := NewMockVisitRepository()
		auditLogs := &MockAuditLogRepository{}
		tx := &MockTxManager{}

		s := NewGroupService(camps, nil, groups, badges, visits, auditLogs, tx)

		// Act
		_, err := s.RegisterBadge(context.Background(), "camp-1", "qr-1", "1조")

		// Assert
		if err != domain.ErrCampInvalidTransition {
			t.Errorf("expected ErrCampInvalidTransition, got %v", err)
		}
	})
}
