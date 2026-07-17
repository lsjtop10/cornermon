
package usecase

import (
	"context"
	"testing"

	"cornermon/backend/internal/domain"
)

func TestCornerServiceCommandRegression(t *testing.T) {
	ctx := context.Background()
	camps := NewMockCampRepository()
	_ = camps.Save(ctx, domain.NewCampFromProps(domain.CampProps{ID: "camp-1", Status: domain.CampPending}))
	corners := NewMockCornerRepository()
	service := NewCornerService(camps, corners, &MockAuditLogRepository{}, &MockBroadcaster{}, &MockTxManager{})
	service.uuidFn = func() string { return "corner-1" }

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
		t.Fatalf("corner should be deleted: corner=%+v err=%v", deleted, err)
	}
}
