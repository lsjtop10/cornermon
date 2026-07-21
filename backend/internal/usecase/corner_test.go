package usecase

import (
	"context"
	"testing"
	"time"

	"cornermon/backend/internal/domain"
)

func TestCornerServiceCommandRegression(t *testing.T) {
	ctx := context.Background()
	camps := NewMockCampRepository()
	_ = camps.Save(ctx, domain.NewCampFromProps(domain.CampProps{ID: "camp-1", Status: domain.CampPending}))
	corners := NewMockCornerRepository()
	auditLogs := &MockAuditLogRepository{}
	broadcaster := &MockBroadcaster{}
	service := NewCornerService(camps, corners, NewMockTrackRepository(), auditLogs, broadcaster, &MockTxManager{})
	service.uuidFn = func() string { return "corner-1" }
	deletedAt := time.Date(2026, time.July, 21, 9, 0, 0, 0, time.UTC)
	service.nowFn = func() time.Time { return deletedAt }

	created, err := service.AddLearningCorner(ctx, "camp-1", "처음 이름")
	if err != nil || created.ID() != "corner-1" {
		t.Fatalf("create failed: corner=%+v err=%v", created, err)
	}

	updated, err := service.ModifyCornerSpecification(ctx, created.ID(), "수정 이름")
	if err != nil || updated.Name() != "수정 이름" {
		t.Fatalf("update failed: corner=%+v err=%v", updated, err)
	}

	if err := service.RemoveCornerFromCamp(ctx, created.ID()); err != nil {
		t.Fatalf("delete failed: %v", err)
	}
	deleted, err := corners.Get(ctx, created.ID())
	if err != nil || deleted != nil {
		t.Fatalf("soft-deleted corner should be hidden: corner=%+v err=%v", deleted, err)
	}
	if got := corners.DeletedAt[created.ID()]; !got.Equal(deletedAt) {
		t.Fatalf("expected deleted_at=%s, got %s", deletedAt, got)
	}
	if len(auditLogs.Logs) != 3 || auditLogs.Logs[2].Action() != string(ActionCornerDelete) || !auditLogs.Logs[2].Success() {
		t.Fatalf("expected successful corner deletion audit log, got %+v", auditLogs.Logs)
	}
	if len(broadcaster.Broadcasts) != 3 || broadcaster.Broadcasts[2].Event != EventCornersUpdated {
		t.Fatalf("expected corners_updated after deletion, got %+v", broadcaster.Broadcasts)
	}

	if err := service.RemoveCornerFromCamp(ctx, created.ID()); err != nil {
		t.Fatalf("repeat delete should be idempotent: %v", err)
	}
	if len(auditLogs.Logs) != 3 || len(broadcaster.Broadcasts) != 3 {
		t.Fatalf("repeat delete must not emit new side effects")
	}
}

func TestShouldPurgeCornersAfterSevenDaysWhenCleanupRuns(t *testing.T) {
	// Arrange
	ctx := context.Background()
	corners := NewMockCornerRepository()
	corners.PurgedCount = 2
	service := NewCornerCleanupService(corners)
	now := time.Date(2026, time.July, 21, 9, 0, 0, 0, time.UTC)
	service.nowFn = func() time.Time { return now }

	// Act
	count, err := service.PurgeExpired(ctx)

	// Assert
	wantBefore := now.Add(-7 * 24 * time.Hour)
	if err != nil || count != 2 || !corners.PurgeBefore.Equal(wantBefore) {
		t.Fatalf("expected count=2 and cutoff=%s, got count=%d cutoff=%s err=%v", wantBefore, count, corners.PurgeBefore, err)
	}
}

func TestGetCornerByTrackShouldReturnCornerWhenTrackAndCornerExist(t *testing.T) {
	// Arrange
	ctx := context.Background()
	corners := NewMockCornerRepository()
	_ = corners.Save(ctx, domain.NewCornerFromProps(domain.CornerProps{ID: "corner-1", CampID: "camp-1", Name: "코너 1"}))
	tracks := NewMockTrackRepository()
	_ = tracks.Save(ctx, domain.NewTrackFromProps(domain.TrackProps{ID: "track-1", CornerID: "corner-1"}))
	service := NewCornerService(NewMockCampRepository(), corners, tracks, &MockAuditLogRepository{}, &MockBroadcaster{}, &MockTxManager{})

	// Act
	corner, err := service.GetCornerByTrack(ctx, "track-1")

	// Assert
	if err != nil || corner == nil || corner.ID() != "corner-1" {
		t.Fatalf("expected corner-1, got corner=%+v err=%v", corner, err)
	}
}

func TestGetCornerByTrackShouldReturnTrackNotFoundWhenTrackMissing(t *testing.T) {
	// Arrange
	ctx := context.Background()
	service := NewCornerService(NewMockCampRepository(), NewMockCornerRepository(), NewMockTrackRepository(), &MockAuditLogRepository{}, &MockBroadcaster{}, &MockTxManager{})

	// Act
	corner, err := service.GetCornerByTrack(ctx, "missing-track")

	// Assert
	if err != domain.ErrTrackNotFound || corner != nil {
		t.Fatalf("expected ErrTrackNotFound, got corner=%+v err=%v", corner, err)
	}
}

func TestGetCornerByTrackShouldReturnCornerNotFoundWhenCornerMissing(t *testing.T) {
	// Arrange
	ctx := context.Background()
	tracks := NewMockTrackRepository()
	_ = tracks.Save(ctx, domain.NewTrackFromProps(domain.TrackProps{ID: "track-1", CornerID: "missing-corner"}))
	service := NewCornerService(NewMockCampRepository(), NewMockCornerRepository(), tracks, &MockAuditLogRepository{}, &MockBroadcaster{}, &MockTxManager{})

	// Act
	corner, err := service.GetCornerByTrack(ctx, "track-1")

	// Assert
	if err != domain.ErrCornerNotFound || corner != nil {
		t.Fatalf("expected ErrCornerNotFound, got corner=%+v err=%v", corner, err)
	}
}
