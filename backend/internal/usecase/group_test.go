package usecase

import (
	"context"
	"testing"
	"time"

	"cornermon/backend/internal/domain"
)

func TestGroupService_AssignBadge(t *testing.T) {
	t.Run("ShouldAssignBadgeSuccessfullyWhenBadgeIsUnassigned", func(t *testing.T) {
		// Arrange
		now := time.Now()
		camps := NewMockCampRepository()
		camp := domain.NewCampFromProps(domain.CampProps{ID: "camp-1", Status: domain.CampActive})
		camps.Save(context.Background(), camp)

		corners := NewMockCornerRepository()
		corner1 := domain.NewCornerFromProps(domain.CornerProps{ID: "corner-1", CampID: "camp-1"})
		corner2 := domain.NewCornerFromProps(domain.CornerProps{ID: "corner-2", CampID: "camp-1"})
		corners.Save(context.Background(), corner1)
		corners.Save(context.Background(), corner2)

		badges := NewMockBadgeRepository()
		badge := domain.NewBadgeFromProps(domain.BadgeProps{ID: "badge-1",
			ShortID:         "B1",
			QRPayload:       "qr-1",
			Status:          domain.BadgeUnassigned,
			AssignedGroupID: domain.None[domain.GroupID](),
		})
		badges.Save(context.Background(), badge)

		groups := NewMockGroupRepository()
		visits := NewMockVisitRepository()
		auditLogs := &MockAuditLogRepository{}
		tx := &MockTxManager{}

		s := NewGroupService(camps, corners, NewMockTrackRepository(), groups, badges, visits, auditLogs, tx)
		s.nowFn = func() time.Time { return now }
		s.uuidFn = func() string { return "group-uuid" }

		// Act
		group, err := s.AssignBadge(context.Background(), "badge-1", "1조")

		// Assert
		if err != nil {
			t.Fatalf("expected no error, got %v", err)
		}
		if group == nil {
			t.Fatal("expected group, got nil")
		}
		if group.ID() != "group-uuid" {
			t.Errorf("expected group ID 'group-uuid', got '%s'", group.ID())
		}
		if len(group.Itinerary()) != 2 {
			t.Errorf("expected itinerary size 2, got %d", len(group.Itinerary()))
		}

		updatedBadge, _ := badges.Get(context.Background(), "badge-1")
		if updatedBadge.Status() != domain.BadgeAssigned {
			t.Errorf("expected badge to be Assigned")
		}
	})

	t.Run("ShouldAssignBadgeWhenOnlyPendingCampExists", func(t *testing.T) {
		// Arrange
		camps := NewMockCampRepository()
		camp := domain.NewCampFromProps(domain.CampProps{ID: "camp-1", Status: domain.CampPending})
		camps.Save(context.Background(), camp)

		corners := NewMockCornerRepository()
		corners.Save(context.Background(), domain.NewCornerFromProps(domain.CornerProps{ID: "corner-1", CampID: "camp-1"}))
		badges := NewMockBadgeRepository()
		badge := domain.NewBadgeFromProps(domain.BadgeProps{ID: "badge-1",
			QRPayload: "qr-1",
			Status:    domain.BadgeUnassigned,
		})
		badges.Save(context.Background(), badge)

		groups := NewMockGroupRepository()
		visits := NewMockVisitRepository()
		auditLogs := &MockAuditLogRepository{}
		tx := &MockTxManager{}

		s := NewGroupService(camps, corners, NewMockTrackRepository(), groups, badges, visits, auditLogs, tx)
		s.uuidFn = func() string { return "group-uuid" }

		// Act
		group, err := s.AssignBadge(context.Background(), "badge-1", "1조")

		// Assert
		if err != nil {
			t.Fatalf("expected no error, got %v", err)
		}
		if group == nil || group.CampID() != "camp-1" {
			t.Fatalf("expected group assigned to pending camp, got %+v", group)
		}
	})

	t.Run("ShouldReturnCampNotFoundWhenNoPendingOrActiveCampExists", func(t *testing.T) {
		// Arrange
		camps := NewMockCampRepository()
		_ = camps.Save(context.Background(), domain.NewCampFromProps(domain.CampProps{ID: "camp-1", Status: domain.CampEnded}))
		badges := NewMockBadgeRepository()
		_ = badges.Save(context.Background(), domain.NewBadgeFromProps(domain.BadgeProps{ID: "badge-1", QRPayload: "qr-1", Status: domain.BadgeUnassigned}))
		service := NewGroupService(camps, NewMockCornerRepository(), NewMockTrackRepository(), NewMockGroupRepository(), badges, NewMockVisitRepository(), &MockAuditLogRepository{}, &MockTxManager{})

		// Act
		_, err := service.AssignBadge(context.Background(), "badge-1", "1조")

		// Assert
		if err != domain.ErrCampNotFound {
			t.Fatalf("expected ErrCampNotFound, got %v", err)
		}
	})

	t.Run("ShouldAssignBadgeWhenQRPayloadMatches", func(t *testing.T) {
		// Arrange
		camps := NewMockCampRepository()
		_ = camps.Save(context.Background(), domain.NewCampFromProps(domain.CampProps{ID: "camp-1", Status: domain.CampActive}))
		badges := NewMockBadgeRepository()
		_ = badges.Save(context.Background(), domain.NewBadgeFromProps(domain.BadgeProps{ID: "badge-1", QRPayload: "qr-1", Status: domain.BadgeUnassigned}))
		service := NewGroupService(camps, NewMockCornerRepository(), NewMockTrackRepository(), NewMockGroupRepository(), badges, NewMockVisitRepository(), &MockAuditLogRepository{}, &MockTxManager{})
		service.uuidFn = func() string { return "group-uuid" }

		// Act
		group, err := service.ScanAssignBadge(context.Background(), "qr-1", "1조")

		// Assert
		if err != nil {
			t.Fatalf("expected no error, got %v", err)
		}
		if group == nil || group.BadgeID() != "badge-1" {
			t.Fatalf("expected badge assignment from QR payload, got %+v", group)
		}
	})
}

func TestListGroupsByTrackShoudReturnOnlyDerivedCampGroupsWhenTrackExists(t *testing.T) {
	// Arrange
	corners := NewMockCornerRepository()
	_ = corners.Save(context.Background(), domain.NewCornerFromProps(domain.CornerProps{ID: "corner-1", CampID: "camp-1"}))
	tracks := NewMockTrackRepository()
	_ = tracks.Save(context.Background(), domain.NewTrackFromProps(domain.TrackProps{ID: "track-1", CornerID: "corner-1", Status: domain.TrackActive}))
	groups := NewMockGroupRepository()
	_ = groups.Save(context.Background(), domain.NewGroupFromProps(domain.GroupProps{ID: "group-1", CampID: "camp-1"}))
	_ = groups.Save(context.Background(), domain.NewGroupFromProps(domain.GroupProps{ID: "group-other", CampID: "camp-2"}))
	service := NewGroupService(nil, corners, tracks, groups, nil, nil, nil, nil)

	// Act
	result, err := service.ListGroupsByTrack(context.Background(), "track-1")

	// Assert
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if len(result) != 1 || result[0].ID() != "group-1" {
		t.Fatalf("track camp scope leaked groups: %+v", result)
	}
}

func TestListGroupsByTrackShoudReturnNotFoundWhenRelationMissing(t *testing.T) {
	tests := []struct {
		name    string
		tracks  *MockTrackRepository
		corners *MockCornerRepository
		wantErr error
	}{
		{name: "track missing", tracks: NewMockTrackRepository(), corners: NewMockCornerRepository(), wantErr: domain.ErrTrackNotFound},
		{name: "corner missing", tracks: func() *MockTrackRepository {
			repo := NewMockTrackRepository()
			_ = repo.Save(context.Background(), domain.NewTrackFromProps(domain.TrackProps{ID: "track-1", CornerID: "missing", Status: domain.TrackActive}))
			return repo
		}(), corners: NewMockCornerRepository(), wantErr: domain.ErrCornerNotFound},
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			// Arrange
			service := NewGroupService(nil, tc.corners, tc.tracks, NewMockGroupRepository(), nil, nil, nil, nil)

			// Act
			_, err := service.ListGroupsByTrack(context.Background(), "track-1")

			// Assert
			if err != tc.wantErr {
				t.Fatalf("expected %v, got %v", tc.wantErr, err)
			}
		})
	}
}
