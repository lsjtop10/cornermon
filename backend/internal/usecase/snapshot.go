package usecase

import (
	"context"

	"cornermon/backend/internal/domain"
)

type CampSnapshot struct {
	CampID  domain.CampID    `json:"campId"`
	Camp    *domain.Camp     `json:"camp"`
	Corners []CornerSnapshot `json:"corners"`
	Groups  []*domain.Group  `json:"groups"`
}

type CornerSnapshot struct {
	Corner *domain.Corner  `json:"corner"`
	Tracks []*domain.Track `json:"tracks"`
}

type SnapshotService struct {
	camps   CampRepository
	corners CornerRepository
	tracks  TrackRepository
	groups  GroupRepository
}

func NewSnapshotService(
	camps CampRepository,
	corners CornerRepository,
	tracks TrackRepository,
	groups GroupRepository,
) *SnapshotService {
	return &SnapshotService{
		camps:   camps,
		corners: corners,
		tracks:  tracks,
		groups:  groups,
	}
}

// GetSnapshot - UC-25
func (s *SnapshotService) GetSnapshot(
	ctx context.Context,
	campID domain.CampID,
) (*CampSnapshot, error) {

	camp, err := s.camps.Get(ctx, campID)
	if err != nil {
		return nil, withErrorContext("snapshot.get", "repository.get_camp", err, map[string]any{"camp_id": string(campID)})
	}
	if camp == nil {
		return nil, withErrorContext("snapshot.get", "validate_camp", domain.ErrCampInvalidTransition, map[string]any{"camp_id": string(campID), "camp_found": false})
	}

	corners, err := s.corners.ListByCamp(ctx, campID)
	if err != nil {
		return nil, withErrorContext("snapshot.get", "repository.list_corners", err, map[string]any{"camp_id": string(campID)})
	}

	groups, err := s.groups.ListByCamp(ctx, campID)
	if err != nil {
		return nil, withErrorContext("snapshot.get", "repository.list_groups", err, map[string]any{"camp_id": string(campID)})
	}

	var cornerSnapshots []CornerSnapshot
	for _, c := range corners {
		allTracks, err := s.tracks.ListByCorner(ctx, c.ID())
		if err != nil {
			return nil, withErrorContext("snapshot.get", "repository.list_tracks", err, map[string]any{"corner_id": string(c.ID())})
		}

		var activeTracks []*domain.Track
		for _, t := range allTracks {
			if t.Status() == domain.TrackActive {
				activeTracks = append(activeTracks, t)
			}
		}

		cornerSnapshots = append(cornerSnapshots, CornerSnapshot{
			Corner: c,
			Tracks: activeTracks,
		})
	}

	return &CampSnapshot{
		CampID:  campID,
		Camp:    camp,
		Corners: cornerSnapshots,
		Groups:  groups,
	}, nil
}
