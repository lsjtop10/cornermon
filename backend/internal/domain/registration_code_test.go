package domain_test

import (
	"strings"
	"testing"

	"cornermon/backend/internal/domain"
)

func TestGenerateRegistrationCodeShoudReturnDifferentCodeWhenCalledTwice(t *testing.T) {
	// Arrange (no campId input anymore — code is random, not derived from any value)

	// Act
	first := domain.GenerateRegistrationCode()
	second := domain.GenerateRegistrationCode()

	// Assert
	if first == second {
		t.Fatalf("expected two random calls to differ (40-bit space), got %q for both", first)
	}
}

func TestGenerateRegistrationCodeShoudReturnEightCrockfordCharsWhenCalled(t *testing.T) {
	// Arrange
	const crockfordAlphabet = "0123456789ABCDEFGHJKMNPQRSTVWXYZ"

	// Act
	code := domain.GenerateRegistrationCode()

	// Assert
	if len(code) != 8 {
		t.Fatalf("expected 8-character code, got %q (len=%d)", code, len(code))
	}
	for _, r := range code {
		if !strings.ContainsRune(crockfordAlphabet, r) {
			t.Fatalf("code %q contains character %q outside Crockford Base32 alphabet", code, r)
		}
	}
}
