package domain_test

import (
	"errors"
	"testing"

	"cornermon/backend/internal/domain"
)

func TestGroup_IsFinishedAndStatus(t *testing.T) {
	t.Run("Empty itinerary is not finished and status is IDLE_MOVING", func(t *testing.T) {
		g := domain.NewGroupFromProps(domain.GroupProps{ID: domain.GroupID("group-1"),
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
				domain.NewCornerProgressValFromProps(domain.CornerProgressProps{CornerID: domain.CornerID("corner-1"), Status: domain.VisitNotVisited}),
				domain.NewCornerProgressValFromProps(domain.CornerProgressProps{CornerID: domain.CornerID("corner-2"), Status: domain.VisitNotVisited}),
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
				domain.NewCornerProgressValFromProps(domain.CornerProgressProps{CornerID: domain.CornerID("corner-1"), Status: domain.VisitInProgress}),
				domain.NewCornerProgressValFromProps(domain.CornerProgressProps{CornerID: domain.CornerID("corner-2"), Status: domain.VisitNotVisited}),
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
				domain.NewCornerProgressValFromProps(domain.CornerProgressProps{CornerID: domain.CornerID("corner-1"), Status: domain.VisitCompleted}),
				domain.NewCornerProgressValFromProps(domain.CornerProgressProps{CornerID: domain.CornerID("corner-2"), Status: domain.VisitNotVisited}),
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
				domain.NewCornerProgressValFromProps(domain.CornerProgressProps{CornerID: domain.CornerID("corner-1"), Status: domain.VisitNotVisited}),
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
				domain.NewCornerProgressValFromProps(domain.CornerProgressProps{CornerID: domain.CornerID("corner-1"), Status: domain.VisitNotVisited}),
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
				domain.NewCornerProgressValFromProps(domain.CornerProgressProps{CornerID: domain.CornerID("corner-1"), Status: domain.VisitInProgress}),
			},
		})

		err := g.MarkVisitCompleted(domain.CornerID("corner-unknown"))
		if !errors.Is(err, domain.ErrCornerNotInItinerary) {
			t.Errorf("expected error %v, got %v", domain.ErrCornerNotInItinerary, err)
		}
	})
}

func TestGroup_AddCornerToItinerary(t *testing.T) {
	t.Run("Appends a NOT_VISITED entry for a new corner", func(t *testing.T) {
		// Arrange
		g := domain.NewGroupFromProps(domain.GroupProps{ID: domain.GroupID("group-1"),
			Itinerary: []domain.CornerProgress{
				domain.NewCornerProgressValFromProps(domain.CornerProgressProps{CornerID: domain.CornerID("corner-1"), Status: domain.VisitCompleted}),
			},
		})

		// Act
		g.AddCornerToItinerary(domain.CornerID("corner-2"))

		// Assert
		itinerary := g.Itinerary()
		if len(itinerary) != 2 {
			t.Fatalf("expected 2 itinerary entries, got %d", len(itinerary))
		}
		if itinerary[1].CornerID() != domain.CornerID("corner-2") || itinerary[1].Status() != domain.VisitNotVisited {
			t.Errorf("expected corner-2 NOT_VISITED, got %+v", itinerary[1])
		}
	})

	t.Run("Is idempotent when the corner already exists in the itinerary", func(t *testing.T) {
		// Arrange
		g := domain.NewGroupFromProps(domain.GroupProps{ID: domain.GroupID("group-1"),
			Itinerary: []domain.CornerProgress{
				domain.NewCornerProgressValFromProps(domain.CornerProgressProps{CornerID: domain.CornerID("corner-1"), Status: domain.VisitInProgress}),
			},
		})

		// Act
		g.AddCornerToItinerary(domain.CornerID("corner-1"))

		// Assert
		itinerary := g.Itinerary()
		if len(itinerary) != 1 {
			t.Fatalf("expected itinerary to stay at 1 entry, got %d", len(itinerary))
		}
		if itinerary[0].Status() != domain.VisitInProgress {
			t.Errorf("expected existing status to be preserved, got %v", itinerary[0].Status())
		}
	})
}

func TestGroup_RemoveCornerFromItinerary(t *testing.T) {
	t.Run("Removes the matching entry", func(t *testing.T) {
		// Arrange
		g := domain.NewGroupFromProps(domain.GroupProps{ID: domain.GroupID("group-1"),
			Itinerary: []domain.CornerProgress{
				domain.NewCornerProgressValFromProps(domain.CornerProgressProps{CornerID: domain.CornerID("corner-1"), Status: domain.VisitCompleted}),
				domain.NewCornerProgressValFromProps(domain.CornerProgressProps{CornerID: domain.CornerID("corner-2"), Status: domain.VisitNotVisited}),
			},
		})

		// Act
		g.RemoveCornerFromItinerary(domain.CornerID("corner-1"))

		// Assert
		itinerary := g.Itinerary()
		if len(itinerary) != 1 {
			t.Fatalf("expected 1 itinerary entry, got %d", len(itinerary))
		}
		if itinerary[0].CornerID() != domain.CornerID("corner-2") {
			t.Errorf("expected remaining entry to be corner-2, got %v", itinerary[0].CornerID())
		}
	})

	t.Run("Is idempotent when the corner is not in the itinerary", func(t *testing.T) {
		// Arrange
		g := domain.NewGroupFromProps(domain.GroupProps{ID: domain.GroupID("group-1"),
			Itinerary: []domain.CornerProgress{
				domain.NewCornerProgressValFromProps(domain.CornerProgressProps{CornerID: domain.CornerID("corner-1"), Status: domain.VisitNotVisited}),
			},
		})

		// Act
		g.RemoveCornerFromItinerary(domain.CornerID("corner-unknown"))

		// Assert
		if len(g.Itinerary()) != 1 {
			t.Errorf("expected itinerary to stay at 1 entry, got %d", len(g.Itinerary()))
		}
	})
}
