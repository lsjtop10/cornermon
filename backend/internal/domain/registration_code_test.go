
package domain_test

import (
	"strings"
	"testing"

	"cornermon/backend/internal/domain"
)

func TestGenerateRegistrationCodeShoudReturnSameCodeWhenCalledTwiceWithSameCampID(t *testing.T) {
	// Arrange
	campID := domain.CampID("camp-1")

	// Act
	first := domain.GenerateRegistrationCode(campID)
	second := domain.GenerateRegistrationCode(campID)

	// Assert
	if first != second {
		t.Fatalf("expected deterministic code, got %q and %q", first, second)
	}
}

func TestGenerateRegistrationCodeShoudReturnDifferentCodeWhenCampIDDiffers(t *testing.T) {
	// Arrange
	campA := domain.CampID("camp-1")
	campB := domain.CampID("camp-2")

	// Act
	codeA := domain.GenerateRegistrationCode(campA)
	codeB := domain.GenerateRegistrationCode(campB)

	// Assert
	if codeA == codeB {
		t.Fatalf("expected different codes for different camp IDs, got %q for both", codeA)
	}
}

func TestGenerateRegistrationCodeShoudReturnEightCrockfordCharsWhenCalled(t *testing.T) {
	// Arrange
	campID := domain.CampID("camp-1")
	const crockfordAlphabet = "0123456789ABCDEFGHJKMNPQRSTVWXYZ"

	// Act
	code := domain.GenerateRegistrationCode(campID)

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
