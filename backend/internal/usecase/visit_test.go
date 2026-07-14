package usecase

import (
	"context"
	"testing"
	"time"

	"cornermon/backend/internal/domain"
)

func TestVisitService_StartVisitByQR(t *testing.T) {
	t.Run("ShouldStartVisitWhenQRScanIsValid", func(t *testing.T) {
		// Arrange
		now := time.Now()
		camps := NewMockCampRepository()
		camp := &domain.Camp{ID: "camp-1", Status: domain.CampActive}
		camps.Save(context.Background(), camp)

		corners := NewMockCornerRepository()
		corner := &domain.Corner{ID: "corner-1", CampID: "camp-1"}
		corners.Save(context.Background(), corner)

		tracks := NewMockTrackRepository()
		track := &domain.Track{
			ID:             "track-1",
			CornerID:       "corner-1",
			Status:         domain.TrackActive,
			CurrentVisitID: domain.None[domain.VisitID](),
		}
		tracks.Save(context.Background(), track)

		badges := NewMockBadgeRepository()
		badge := &domain.Badge{
			ID:              "badge-1",
			QRPayload:       "qr-payload-1",
			Status:          domain.BadgeAssigned,
			AssignedGroupID: domain.Some[domain.GroupID]("group-1"),
		}
		badges.Save(context.Background(), badge)

		groups := NewMockGroupRepository()
		group := &domain.Group{
			ID:      "group-1",
			CampID:  "camp-1",
			BadgeID: "badge-1",
			Itinerary: []domain.CornerProgress{
				{CornerID: "corner-1", Status: domain.VisitNotVisited},
			},
		}
		groups.Save(context.Background(), group)

		sessions := NewMockFacilitatorSessionRepository()
		sessionToken := "session-token-1"
		tokenHash := hashSHA256(sessionToken)
		session := &domain.FacilitatorSession{
			ID:        "session-1",
			TrackID:   "track-1",
			TokenHash: tokenHash,
			CreatedAt: now,
		}
		sessions.Save(context.Background(), session)

		visits := NewMockVisitRepository()
		auditLogs := &MockAuditLogRepository{}
		broadcaster := &MockBroadcaster{}
		tx := &MockTxManager{}

		s := NewVisitService(camps, corners, tracks, visits, groups, badges, sessions, auditLogs, broadcaster, tx)
		s.nowFn = func() time.Time { return now }
		s.uuidFn = func() string { return "visit-1" }

		// Act
		visit, err := s.StartVisitByQR(context.Background(), sessionToken, "qr-payload-1")

		// Assert
		if err != nil {
			t.Fatalf("expected no error, got %v", err)
		}
		if visit == nil {
			t.Fatal("expected visit, got nil")
		}
		if visit.ID != "visit-1" {
			t.Errorf("expected visit ID to be 'visit-1', got '%s'", visit.ID)
		}
		if visit.Status != domain.VisitStatusInProgress {
			t.Errorf("expected visit status to be InProgress, got %s", visit.Status)
		}

		// Verify side effects
		updatedTrack, _ := tracks.Get(context.Background(), "track-1")
		currVisitVal, ok := updatedTrack.CurrentVisitID.Value()
		if !ok || currVisitVal != "visit-1" {
			t.Errorf("expected track to have current visit 'visit-1'")
		}

		updatedGroup, _ := groups.Get(context.Background(), "group-1")
		if updatedGroup.Itinerary[0].Status != domain.VisitInProgress {
			t.Errorf("expected group itinerary status to be InProgress")
		}

		if len(broadcaster.Broadcasts) != 4 ||
			broadcaster.Broadcasts[0].CampID != "camp-1" ||
			broadcaster.Broadcasts[0].Event != EventCornersUpdated ||
			broadcaster.Broadcasts[1].Event != EventGroupsUpdated ||
			broadcaster.Broadcasts[2].Event != EventTracksUpdated ||
			broadcaster.Broadcasts[3].Event != EventTrackUpdated ||
			broadcaster.Broadcasts[3].Scope != TrackScope("track-1") {
			t.Errorf("expected corners, groups, tracks, track alerts, got %v", broadcaster.Broadcasts)
		}

		if len(auditLogs.Logs) != 1 || !auditLogs.Logs[0].Success {
			t.Errorf("expected successful audit log to be recorded")
		}
	})

	t.Run("ShouldFailStartVisitWhenSessionIsRevoked", func(t *testing.T) {
		// Arrange
		now := time.Now()
		camps := NewMockCampRepository()
		corners := NewMockCornerRepository()
		tracks := NewMockTrackRepository()
		badges := NewMockBadgeRepository()
		groups := NewMockGroupRepository()
		sessions := NewMockFacilitatorSessionRepository()
		sessionToken := "session-token-2"
		tokenHash := hashSHA256(sessionToken)
		session := &domain.FacilitatorSession{
			ID:        "session-2",
			TrackID:   "track-1",
			TokenHash: tokenHash,
			CreatedAt: now,
			RevokedAt: domain.Some(now.Add(-time.Hour)),
		}
		sessions.Save(context.Background(), session)

		visits := NewMockVisitRepository()
		auditLogs := &MockAuditLogRepository{}
		broadcaster := &MockBroadcaster{}
		tx := &MockTxManager{}

		s := NewVisitService(camps, corners, tracks, visits, groups, badges, sessions, auditLogs, broadcaster, tx)

		// Act
		_, err := s.StartVisitByQR(context.Background(), sessionToken, "qr-payload-1")

		// Assert
		if err != domain.ErrSessionRevoked {
			t.Errorf("expected ErrSessionRevoked, got %v", err)
		}
	})

	t.Run("ShouldFailStartVisitWhenTrackIsBusy", func(t *testing.T) {
		// Arrange
		now := time.Now()
		camps := NewMockCampRepository()
		camp := &domain.Camp{ID: "camp-1", Status: domain.CampActive}
		camps.Save(context.Background(), camp)

		corners := NewMockCornerRepository()
		tracks := NewMockTrackRepository()
		track := &domain.Track{
			ID:             "track-1",
			CornerID:       "corner-1",
			Status:         domain.TrackActive,
			CurrentVisitID: domain.Some[domain.VisitID]("visit-0"),
		}
		tracks.Save(context.Background(), track)

		badges := NewMockBadgeRepository()
		badge := &domain.Badge{
			ID:              "badge-1",
			QRPayload:       "qr-payload-1",
			Status:          domain.BadgeAssigned,
			AssignedGroupID: domain.Some[domain.GroupID]("group-1"),
		}
		badges.Save(context.Background(), badge)

		groups := NewMockGroupRepository()
		group := &domain.Group{
			ID:      "group-1",
			CampID:  "camp-1",
			BadgeID: "badge-1",
			Itinerary: []domain.CornerProgress{
				{CornerID: "corner-1", Status: domain.VisitNotVisited},
			},
		}
		groups.Save(context.Background(), group)

		sessions := NewMockFacilitatorSessionRepository()
		sessionToken := "session-token-3"
		tokenHash := hashSHA256(sessionToken)
		session := &domain.FacilitatorSession{
			ID:        "session-3",
			TrackID:   "track-1",
			TokenHash: tokenHash,
			CreatedAt: now,
		}
		sessions.Save(context.Background(), session)

		visits := NewMockVisitRepository()
		auditLogs := &MockAuditLogRepository{}
		broadcaster := &MockBroadcaster{}
		tx := &MockTxManager{}

		s := NewVisitService(camps, corners, tracks, visits, groups, badges, sessions, auditLogs, broadcaster, tx)

		// Act
		_, err := s.StartVisitByQR(context.Background(), sessionToken, "qr-payload-1")

		// Assert
		if err != domain.ErrTrackBusy {
			t.Errorf("expected ErrTrackBusy, got %v", err)
		}
	})
}

func TestVisitService_CompleteVisit(t *testing.T) {
	t.Run("ShouldCompleteVisitWhenTrackIsBusy", func(t *testing.T) {
		// Arrange
		now := time.Now()
		camps := NewMockCampRepository()
		corners := NewMockCornerRepository()
		tracks := NewMockTrackRepository()
		track := &domain.Track{
			ID:             "track-1",
			CornerID:       "corner-1",
			Status:         domain.TrackActive,
			CurrentVisitID: domain.Some[domain.VisitID]("visit-1"),
		}
		tracks.Save(context.Background(), track)

		groups := NewMockGroupRepository()
		group := &domain.Group{
			ID:     "group-1",
			CampID: "camp-1",
			Itinerary: []domain.CornerProgress{
				{CornerID: "corner-1", Status: domain.VisitInProgress},
			},
		}
		groups.Save(context.Background(), group)

		visits := NewMockVisitRepository()
		visit := domain.NewVisit("visit-1", "group-1", "corner-1", "track-1", domain.VisitQRScan, now.Add(-10*time.Minute))
		visits.Save(context.Background(), visit)

		sessions := NewMockFacilitatorSessionRepository()
		sessionToken := "session-token-1"
		tokenHash := hashSHA256(sessionToken)
		session := &domain.FacilitatorSession{
			ID:        "session-1",
			TrackID:   "track-1",
			TokenHash: tokenHash,
			CreatedAt: now,
		}
		sessions.Save(context.Background(), session)

		auditLogs := &MockAuditLogRepository{}
		broadcaster := &MockBroadcaster{}
		tx := &MockTxManager{}

		s := NewVisitService(camps, corners, tracks, visits, groups, nil, sessions, auditLogs, broadcaster, tx)
		s.nowFn = func() time.Time { return now }
		s.uuidFn = func() string { return "audit-1" }

		// Act
		completedVisit, err := s.CompleteVisit(context.Background(), sessionToken)

		// Assert
		if err != nil {
			t.Fatalf("expected no error, got %v", err)
		}
		if completedVisit == nil {
			t.Fatal("expected visit, got nil")
		}
		if completedVisit.Status != domain.VisitStatusCompleted {
			t.Errorf("expected visit status Completed, got %s", completedVisit.Status)
		}

		updatedTrack, _ := tracks.Get(context.Background(), "track-1")
		if updatedTrack.CurrentVisitID.IsSet() {
			t.Errorf("expected track CurrentVisitID to be cleared")
		}

		updatedGroup, _ := groups.Get(context.Background(), "group-1")
		if updatedGroup.Itinerary[0].Status != domain.VisitCompleted {
			t.Errorf("expected group itinerary to be completed")
		}

		if len(broadcaster.Broadcasts) != 4 ||
			broadcaster.Broadcasts[0].CampID != "camp-1" ||
			broadcaster.Broadcasts[0].Event != EventCornersUpdated ||
			broadcaster.Broadcasts[1].Event != EventGroupsUpdated ||
			broadcaster.Broadcasts[2].Event != EventTracksUpdated ||
			broadcaster.Broadcasts[3].Event != EventTrackUpdated ||
			broadcaster.Broadcasts[3].Scope != TrackScope("track-1") {
			t.Errorf("expected corners, groups, tracks, track alerts, got %v", broadcaster.Broadcasts)
		}
	})

	t.Run("ShouldFailCompleteVisitWhenTrackIsIdle", func(t *testing.T) {
		// Arrange
		now := time.Now()
		camps := NewMockCampRepository()
		corners := NewMockCornerRepository()
		tracks := NewMockTrackRepository()
		track := &domain.Track{
			ID:             "track-1",
			CornerID:       "corner-1",
			Status:         domain.TrackActive,
			CurrentVisitID: domain.None[domain.VisitID](),
		}
		tracks.Save(context.Background(), track)

		sessions := NewMockFacilitatorSessionRepository()
		sessionToken := "session-token-1"
		tokenHash := hashSHA256(sessionToken)
		session := &domain.FacilitatorSession{
			ID:        "session-1",
			TrackID:   "track-1",
			TokenHash: tokenHash,
			CreatedAt: now,
		}
		sessions.Save(context.Background(), session)

		visits := NewMockVisitRepository()
		groups := NewMockGroupRepository()
		auditLogs := &MockAuditLogRepository{}
		broadcaster := &MockBroadcaster{}
		tx := &MockTxManager{}

		s := NewVisitService(camps, corners, tracks, visits, groups, nil, sessions, auditLogs, broadcaster, tx)

		// Act
		_, err := s.CompleteVisit(context.Background(), sessionToken)

		// Assert
		if err != domain.ErrTrackNotBusy {
			t.Errorf("expected ErrTrackNotBusy, got %v", err)
		}
	})
}
