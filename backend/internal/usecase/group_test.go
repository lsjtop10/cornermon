package usecase

import (
	"context"
	"errors"
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
		admins := NewMockAdminRepository()
		admins.Admins["admin-1"] = domain.NewAdminFromProps(domain.AdminProps{ID: "admin-1", Username: "김관리"})

		s := NewGroupService(camps, corners, NewMockTrackRepository(), groups, badges, visits, admins, auditLogs, tx)
		s.nowFn = func() time.Time { return now }
		s.uuidFn = func() string { return "group-uuid" }

		// Act
		group, err := s.AssignBadge(context.Background(), "badge-1", "1조", "admin-1")

		// Assert
		if err != nil {
			t.Fatalf("expected no error, got %v", err)
		}
		if len(auditLogs.Logs) != 1 {
			t.Fatalf("expected 1 audit log, got %d", len(auditLogs.Logs))
		}
		if auditLogs.Logs[0].Actor() != "admin-1" {
			t.Errorf("expected Actor to remain raw admin ID 'admin-1', got %q", auditLogs.Logs[0].Actor())
		}
		if auditLogs.Logs[0].ActorName() != "김관리" {
			t.Errorf("expected ActorName '김관리', got %q", auditLogs.Logs[0].ActorName())
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

		s := NewGroupService(camps, corners, NewMockTrackRepository(), groups, badges, visits, NewMockAdminRepository(), auditLogs, tx)
		s.uuidFn = func() string { return "group-uuid" }

		// Act
		group, err := s.AssignBadge(context.Background(), "badge-1", "1조", "admin-1")

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
		service := NewGroupService(camps, NewMockCornerRepository(), NewMockTrackRepository(), NewMockGroupRepository(), badges, NewMockVisitRepository(), NewMockAdminRepository(), &MockAuditLogRepository{}, &MockTxManager{})

		// Act
		_, err := service.AssignBadge(context.Background(), "badge-1", "1조", "admin-1")

		// Assert
		if !errors.Is(err, domain.ErrCampNotFound) {
			t.Fatalf("expected ErrCampNotFound, got %v", err)
		}
	})

	t.Run("ShouldAssignBadgeWhenQRPayloadMatches", func(t *testing.T) {
		// Arrange
		camps := NewMockCampRepository()
		_ = camps.Save(context.Background(), domain.NewCampFromProps(domain.CampProps{ID: "camp-1", Status: domain.CampActive}))
		badges := NewMockBadgeRepository()
		_ = badges.Save(context.Background(), domain.NewBadgeFromProps(domain.BadgeProps{ID: "badge-1", QRPayload: "qr-1", Status: domain.BadgeUnassigned}))
		service := NewGroupService(camps, NewMockCornerRepository(), NewMockTrackRepository(), NewMockGroupRepository(), badges, NewMockVisitRepository(), NewMockAdminRepository(), &MockAuditLogRepository{}, &MockTxManager{})
		service.uuidFn = func() string { return "group-uuid" }

		// Act
		group, err := service.ScanAssignBadge(context.Background(), "qr-1", "1조", "admin-1")

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
	service := NewGroupService(nil, corners, tracks, groups, nil, nil, nil, nil, nil)

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

func TestGroupServiceShouldExcludeDeletedCornersWhenListingGroups(t *testing.T) {
	// Arrange
	ctx := context.Background()
	corners := NewMockCornerRepository()
	_ = corners.Save(ctx, domain.NewCornerFromProps(domain.CornerProps{ID: "corner-current", CampID: "camp-1"}))
	groups := NewMockGroupRepository()
	stored := domain.NewGroupFromProps(domain.GroupProps{
		ID:     "group-1",
		CampID: "camp-1",
		Itinerary: []domain.CornerProgress{
			domain.NewCornerProgressValFromProps(domain.CornerProgressProps{CornerID: "corner-current", Status: domain.VisitNotVisited}),
			domain.NewCornerProgressValFromProps(domain.CornerProgressProps{CornerID: "corner-deleted", Status: domain.VisitCompleted}),
		},
	})
	_ = groups.Save(ctx, stored)
	service := NewGroupService(nil, corners, nil, groups, nil, nil, nil, nil, nil)

	// Act
	result, err := service.ListGroups(ctx, "camp-1")

	// Assert
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if len(result) != 1 || len(result[0].Itinerary()) != 1 {
		t.Fatalf("expected one current itinerary corner, got %+v", result)
	}
	if result[0].Itinerary()[0].CornerID() != "corner-current" {
		t.Fatalf("unexpected itinerary: %+v", result[0].Itinerary())
	}
	if result[0].IsFinished() {
		t.Fatal("expected filtered itinerary status to be recalculated")
	}
	if len(stored.Itinerary()) != 2 {
		t.Fatal("expected read filtering not to mutate the stored group")
	}
}

func TestGroupServiceShouldExcludeDeletedCornersWhenRetrievingGroupSchedule(t *testing.T) {
	// Arrange
	ctx := context.Background()
	corners := NewMockCornerRepository()
	_ = corners.Save(ctx, domain.NewCornerFromProps(domain.CornerProps{ID: "corner-current", CampID: "camp-1"}))
	groups := NewMockGroupRepository()
	_ = groups.Save(ctx, domain.NewGroupFromProps(domain.GroupProps{
		ID:     "group-1",
		CampID: "camp-1",
		Itinerary: []domain.CornerProgress{
			domain.NewCornerProgressValFromProps(domain.CornerProgressProps{CornerID: "corner-current", Status: domain.VisitCompleted}),
			domain.NewCornerProgressValFromProps(domain.CornerProgressProps{CornerID: "corner-deleted", Status: domain.VisitNotVisited}),
		},
	}))
	service := NewGroupService(nil, corners, nil, groups, nil, nil, nil, nil, nil)

	// Act
	result, err := service.RetrieveGroupRotationSchedule(ctx, "group-1")

	// Assert
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if len(result.Itinerary()) != 1 || result.Itinerary()[0].CornerID() != "corner-current" {
		t.Fatalf("unexpected itinerary: %+v", result.Itinerary())
	}
	if !result.IsFinished() {
		t.Fatal("expected filtered itinerary completion to be recalculated")
	}
}

func TestGroupServiceShouldExcludeDeletedCornersWhenListingGroupsByTrack(t *testing.T) {
	// Arrange
	ctx := context.Background()
	corners := NewMockCornerRepository()
	_ = corners.Save(ctx, domain.NewCornerFromProps(domain.CornerProps{ID: "corner-current", CampID: "camp-1"}))
	tracks := NewMockTrackRepository()
	_ = tracks.Save(ctx, domain.NewTrackFromProps(domain.TrackProps{ID: "track-1", CornerID: "corner-current", Status: domain.TrackActive}))
	groups := NewMockGroupRepository()
	_ = groups.Save(ctx, domain.NewGroupFromProps(domain.GroupProps{
		ID:     "group-1",
		CampID: "camp-1",
		Itinerary: []domain.CornerProgress{
			domain.NewCornerProgressValFromProps(domain.CornerProgressProps{CornerID: "corner-deleted", Status: domain.VisitNotVisited}),
		},
	}))
	service := NewGroupService(nil, corners, tracks, groups, nil, nil, nil, nil, nil)

	// Act
	result, err := service.ListGroupsByTrack(ctx, "track-1")

	// Assert
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if len(result) != 1 || len(result[0].Itinerary()) != 0 {
		t.Fatalf("expected deleted corner to be excluded, got %+v", result)
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
			service := NewGroupService(nil, tc.corners, tc.tracks, NewMockGroupRepository(), nil, nil, nil, nil, nil)

			// Act
			_, err := service.ListGroupsByTrack(context.Background(), "track-1")

			// Assert
			if !errors.Is(err, tc.wantErr) {
				t.Fatalf("expected %v, got %v", tc.wantErr, err)
			}
		})
	}
}
