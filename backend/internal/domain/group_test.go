//go:build ignore

package domain_test

import (
	"errors"
	"testing"

	"cornermon/backend/internal/domain"
)

func TestGroup_IsFinishedAndStatus(t *testing.T) {
	t.Run("Empty itinerary is not finished and status is IDLE_MOVING", func(t *testing.T) {
		g := domain.NewGroupFromProps(domain.GroupProps{ID:        domain.GroupID("group-1"),
			Itinerary: []domain.CornerProgress{},
		})

		if g.IsFinished() {
			t.Error("expected empty itinerary not to be finished")
		}
		if g.Status() != domain.GroupIdleMoving {
			t.Errorf("expected status to be IDLE_MOVING, got %v", g.Status())
		}
	})

	t.Run("Status and Finish progress progression", func(t *testing.T) {
		g := domain.NewGroupFromProps(domain.GroupProps{ID: domain.GroupID("group-1"),
			Itinerary: []domain.CornerProgress{
				{CornerID: domain.CornerID("corner-1"), Status: domain.VisitNotVisited},
				{CornerID: domain.CornerID("corner-2"), Status: domain.VisitNotVisited},
			},
		})

		// Initial: IDLE_MOVING
		if g.IsFinished() {
			t.Error("expected not finished")
		}
		if g.Status() != domain.GroupIdleMoving {
			t.Errorf("expected IDLE_MOVING, got %v", g.Status())
		}

		// Start corner-1: AT_CORNER
		err := g.MarkVisitStarted(domain.CornerID("corner-1"))
		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}
		if g.IsFinished() {
			t.Error("expected not finished")
		}
		if g.Status() != domain.GroupAtCorner {
			t.Errorf("expected AT_CORNER, got %v", g.Status())
		}

		// Complete corner-1: IDLE_MOVING (still has corner-2)
		err = g.MarkVisitCompleted(domain.CornerID("corner-1"))
		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}
		if g.IsFinished() {
			t.Error("expected not finished")
		}
		if g.Status() != domain.GroupIdleMoving {
			t.Errorf("expected IDLE_MOVING, got %v", g.Status())
		}

		// Start corner-2: AT_CORNER
		err = g.MarkVisitStarted(domain.CornerID("corner-2"))
		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}
		if g.Status() != domain.GroupAtCorner {
			t.Errorf("expected AT_CORNER, got %v", g.Status())
		}

		// Complete corner-2: FINISHED (all completed)
		err = g.MarkVisitCompleted(domain.CornerID("corner-2"))
		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}
		if !g.IsFinished() {
			t.Error("expected finished")
		}
		if g.Status() != domain.GroupFinished {
			t.Errorf("expected FINISHED, got %v", g.Status())
		}
	})
}

func TestGroup_MarkVisitStarted_Constraints(t *testing.T) {
	t.Run("Cannot start if another corner is in progress (ErrGroupBusy)", func(t *testing.T) {
		g := domain.NewGroupFromProps(domain.GroupProps{ID: domain.GroupID("group-1"),
			Itinerary: []domain.CornerProgress{
				{CornerID: domain.CornerID("corner-1"), Status: domain.VisitInProgress},
				{CornerID: domain.CornerID("corner-2"), Status: domain.VisitNotVisited},
			},
		})

		err := g.MarkVisitStarted(domain.CornerID("corner-2"))
		if !errors.Is(err, domain.ErrGroupBusy) {
			t.Errorf("expected %v, got %v", domain.ErrGroupBusy, err)
		}
	})

	t.Run("Cannot start if corner is already completed (ErrDuplicateVisit)", func(t *testing.T) {
		g := domain.NewGroupFromProps(domain.GroupProps{ID: domain.GroupID("group-1"),
			Itinerary: []domain.CornerProgress{
				{CornerID: domain.CornerID("corner-1"), Status: domain.VisitCompleted},
				{CornerID: domain.CornerID("corner-2"), Status: domain.VisitNotVisited},
			},
		})

		err := g.MarkVisitStarted(domain.CornerID("corner-1"))
		if !errors.Is(err, domain.ErrDuplicateVisit) {
			t.Errorf("expected %v, got %v", domain.ErrDuplicateVisit, err)
		}
	})

	t.Run("Cannot start if corner does not exist in itinerary", func(t *testing.T) {
		g := domain.NewGroupFromProps(domain.GroupProps{ID: domain.GroupID("group-1"),
			Itinerary: []domain.CornerProgress{
				{CornerID: domain.CornerID("corner-1"), Status: domain.VisitNotVisited},
			},
		})

		err := g.MarkVisitStarted(domain.CornerID("corner-unknown"))
		if !errors.Is(err, domain.ErrCornerNotInItinerary) {
			t.Errorf("expected error %v, got %v", domain.ErrCornerNotInItinerary, err)
		}
	})
}

func TestGroup_MarkVisitCompleted_Constraints(t *testing.T) {
	t.Run("Cannot complete if corner is not in progress", func(t *testing.T) {
		g := domain.NewGroupFromProps(domain.GroupProps{ID: domain.GroupID("group-1"),
			Itinerary: []domain.CornerProgress{
				{CornerID: domain.CornerID("corner-1"), Status: domain.VisitNotVisited},
			},
		})

		err := g.MarkVisitCompleted(domain.CornerID("corner-1"))
		if !errors.Is(err, domain.ErrVisitNotInProgress) {
			t.Errorf("expected error %v, got %v", domain.ErrVisitNotInProgress, err)
		}
	})

	t.Run("Cannot complete if corner does not exist in itinerary", func(t *testing.T) {
		g := domain.NewGroupFromProps(domain.GroupProps{ID: domain.GroupID("group-1"),
			Itinerary: []domain.CornerProgress{
				{CornerID: domain.CornerID("corner-1"), Status: domain.VisitInProgress},
			},
		})

		err := g.MarkVisitCompleted(domain.CornerID("corner-unknown"))
		if !errors.Is(err, domain.ErrCornerNotInItinerary) {
			t.Errorf("expected error %v, got %v", domain.ErrCornerNotInItinerary, err)
		}
	})
}
