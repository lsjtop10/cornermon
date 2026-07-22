package usecase

import (
	"context"
	"errors"
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
	service := NewCornerService(camps, corners, NewMockTrackRepository(), NewMockGroupRepository(), auditLogs, broadcaster, &MockTxManager{})
	service.uuidFn = func() string { return "corner-1" }
	deletedAt := time.Date(2026, time.July, 21, 9, 0, 0, 0, time.UTC)
	service.nowFn = func() time.Time { return deletedAt }

	created, err := service.AddLearningCorner(ctx, "camp-1", "처음 이름", 15)
	if err != nil || created.ID() != "corner-1" || created.TargetMinutes() != 15 {
		t.Fatalf("create failed: corner=%+v err=%v", created, err)
	}

	updated, err := service.ModifyCornerSpecification(ctx, created.ID(), "수정 이름", 25)
	if err != nil || updated.Name() != "수정 이름" || updated.TargetMinutes() != 25 {
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

func TestAddLearningCornerShouldAppendNewCornerToExistingGroupItineraries(t *testing.T) {
	// Arrange
	ctx := context.Background()
	camps := NewMockCampRepository()
	_ = camps.Save(ctx, domain.NewCampFromProps(domain.CampProps{ID: "camp-1", Status: domain.CampActive}))
	groups := NewMockGroupRepository()
	_ = groups.Save(ctx, domain.NewGroupFromProps(domain.GroupProps{ID: "group-1", CampID: "camp-1",
		Itinerary: []domain.CornerProgress{
			domain.NewCornerProgressValFromProps(domain.CornerProgressProps{CornerID: "corner-1", Status: domain.VisitCompleted}),
		},
	}))
	_ = groups.Save(ctx, domain.NewGroupFromProps(domain.GroupProps{ID: "group-2", CampID: "camp-1"}))
	service := NewCornerService(camps, NewMockCornerRepository(), NewMockTrackRepository(), groups, &MockAuditLogRepository{}, &MockBroadcaster{}, &MockTxManager{})
	service.uuidFn = func() string { return "corner-2" }

	// Act
	created, err := service.AddLearningCorner(ctx, "camp-1", "새 코너", 10)

	// Assert
	if err != nil || created.ID() != "corner-2" {
		t.Fatalf("create failed: corner=%+v err=%v", created, err)
	}

	// N+1 회귀 방지: 조 조회는 캠프 단위 잠금 조회 1회뿐이어야 한다(검증용 Get 호출 전에 카운트 고정).
	if groups.ListByCampForUpdateCalls != 1 {
		t.Errorf("expected ListByCampForUpdate to be called exactly once, got %d", groups.ListByCampForUpdateCalls)
	}
	if groups.GetCalls != 0 || groups.GetForUpdateCalls != 0 {
		t.Errorf("expected no per-group Get/GetForUpdate calls during corner add, got Get=%d GetForUpdate=%d", groups.GetCalls, groups.GetForUpdateCalls)
	}
	if groups.SaveBulkCalls != 1 {
		t.Errorf("expected SaveBulk to be called exactly once, got %d", groups.SaveBulkCalls)
	}

	g1, _ := groups.Get(ctx, "group-1")
	if len(g1.Itinerary()) != 2 || g1.Itinerary()[1].CornerID() != "corner-2" || g1.Itinerary()[1].Status() != domain.VisitNotVisited {
		t.Fatalf("expected group-1 itinerary to gain corner-2 as NOT_VISITED, got %+v", g1.Itinerary())
	}
	g2, _ := groups.Get(ctx, "group-2")
	if len(g2.Itinerary()) != 1 || g2.Itinerary()[0].CornerID() != "corner-2" {
		t.Fatalf("expected group-2 itinerary to contain corner-2, got %+v", g2.Itinerary())
	}
}

func TestRemoveCornerFromCampShouldRemoveCornerFromExistingGroupItineraries(t *testing.T) {
	// Arrange
	ctx := context.Background()
	corners := NewMockCornerRepository()
	_ = corners.Save(ctx, domain.NewCornerFromProps(domain.CornerProps{ID: "corner-1", CampID: "camp-1", Name: "코너 1"}))
	groups := NewMockGroupRepository()
	_ = groups.Save(ctx, domain.NewGroupFromProps(domain.GroupProps{ID: "group-1", CampID: "camp-1",
		Itinerary: []domain.CornerProgress{
			domain.NewCornerProgressValFromProps(domain.CornerProgressProps{CornerID: "corner-1", Status: domain.VisitInProgress}),
			domain.NewCornerProgressValFromProps(domain.CornerProgressProps{CornerID: "corner-2", Status: domain.VisitNotVisited}),
		},
	}))
	service := NewCornerService(NewMockCampRepository(), corners, NewMockTrackRepository(), groups, &MockAuditLogRepository{}, &MockBroadcaster{}, &MockTxManager{})

	// Act
	err := service.RemoveCornerFromCamp(ctx, "corner-1")

	// Assert
	if err != nil {
		t.Fatalf("delete failed: %v", err)
	}
	g1, _ := groups.Get(ctx, "group-1")
	if len(g1.Itinerary()) != 1 || g1.Itinerary()[0].CornerID() != "corner-2" {
		t.Fatalf("expected corner-1 removed from itinerary, got %+v", g1.Itinerary())
	}

	// 삭제된 코너가 IN_PROGRESS 상태로 순회표에 남아있으면 그 조는 다른 코너에서
	// 영원히 MarkVisitStarted(ErrGroupBusy)에 막히므로, 유령 항목 제거가 이 락업을 푼다.
	if err := g1.MarkVisitStarted("corner-2"); err != nil {
		t.Fatalf("expected group to be able to start visiting corner-2 after ghost entry removal, got %v", err)
	}
}

func TestGetCornerByTrackShouldReturnCornerWhenTrackAndCornerExist(t *testing.T) {
	// Arrange
	ctx := context.Background()
	corners := NewMockCornerRepository()
	_ = corners.Save(ctx, domain.NewCornerFromProps(domain.CornerProps{ID: "corner-1", CampID: "camp-1", Name: "코너 1"}))
	tracks := NewMockTrackRepository()
	_ = tracks.Save(ctx, domain.NewTrackFromProps(domain.TrackProps{ID: "track-1", CornerID: "corner-1"}))
	service := NewCornerService(NewMockCampRepository(), corners, tracks, NewMockGroupRepository(), &MockAuditLogRepository{}, &MockBroadcaster{}, &MockTxManager{})

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
	service := NewCornerService(NewMockCampRepository(), NewMockCornerRepository(), NewMockTrackRepository(), NewMockGroupRepository(), &MockAuditLogRepository{}, &MockBroadcaster{}, &MockTxManager{})

	// Act
	corner, err := service.GetCornerByTrack(ctx, "missing-track")

	// Assert
	if !errors.Is(err, domain.ErrTrackNotFound) || corner != nil {
		t.Fatalf("expected ErrTrackNotFound, got corner=%+v err=%v", corner, err)
	}
}

func TestGetCornerByTrackShouldReturnCornerNotFoundWhenCornerMissing(t *testing.T) {
	// Arrange
	ctx := context.Background()
	tracks := NewMockTrackRepository()
	_ = tracks.Save(ctx, domain.NewTrackFromProps(domain.TrackProps{ID: "track-1", CornerID: "missing-corner"}))
	service := NewCornerService(NewMockCampRepository(), NewMockCornerRepository(), tracks, NewMockGroupRepository(), &MockAuditLogRepository{}, &MockBroadcaster{}, &MockTxManager{})

	// Act
	corner, err := service.GetCornerByTrack(ctx, "track-1")

	// Assert
	if !errors.Is(err, domain.ErrCornerNotFound) || corner != nil {
		t.Fatalf("expected ErrCornerNotFound, got corner=%+v err=%v", corner, err)
	}
}
