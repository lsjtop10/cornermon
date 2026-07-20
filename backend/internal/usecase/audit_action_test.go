package usecase_test

import (
	"testing"

	"cornermon/backend/internal/usecase"
)

func TestAuditActionsShoudReturnUniqueValuesWhenListed(t *testing.T) {
	// arrange
	seen := make(map[usecase.AuditAction]bool)

	// act
	actions := usecase.AuditActions()

	// assert
	for _, action := range actions {
		if seen[action] {
			t.Fatalf("duplicate AuditAction found: %q", action)
		}
		seen[action] = true
		if action == "" {
			t.Fatal("AuditActions must not contain an empty value")
		}
	}
}

func TestIsValidAuditActionShoudReturnTrueWhenKnownAction(t *testing.T) {
	// arrange
	for _, action := range usecase.AuditActions() {
		// act
		got := usecase.IsValidAuditAction(string(action))

		// assert
		if !got {
			t.Fatalf("expected %q to be a valid audit action", action)
		}
	}
}

func TestIsValidAuditActionShoudReturnFalseWhenUnknownAction(t *testing.T) {
	// arrange
	unknown := "NOT_A_REAL_ACTION"

	// act
	got := usecase.IsValidAuditAction(unknown)

	// assert
	if got {
		t.Fatalf("expected %q to be invalid", unknown)
	}
}
