package usecase

import (
	"context"
	"time"
)

const cornerSoftDeleteRetention = 7 * 24 * time.Hour

// CornerCleanupService removes expired soft-deleted corners. Active corners
// are deliberately never candidates: a corner with no tracks can be newly
// created and cannot be distinguished safely from a legacy zombie corner.
type CornerCleanupService struct {
	corners CornerCleanupRepository
	nowFn   func() time.Time
}

func NewCornerCleanupService(corners CornerCleanupRepository) *CornerCleanupService {
	return &CornerCleanupService{
		corners: corners,
		nowFn:   func() time.Time { return time.Now().UTC() },
	}
}

func (s *CornerCleanupService) PurgeExpired(ctx context.Context) (int64, error) {
	return s.corners.PurgeDeletedBefore(ctx, s.nowFn().Add(-cornerSoftDeleteRetention))
}
