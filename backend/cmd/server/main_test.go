
package main

import (
	"encoding/base64"
	"testing"
)

func TestLoadTrackPINEncryptionKey(t *testing.T) {
	t.Run("ShoudReturnKeyWhenEnvironmentValueIsBase64Encoded32Bytes", func(t *testing.T) {
		// Arrange
		expected := make([]byte, 32)
		for i := range expected {
			expected[i] = byte(i)
		}
		t.Setenv("TRACK_PIN_ENCRYPTION_KEY", base64.StdEncoding.EncodeToString(expected))

		// Act
		actual, err := loadTrackPINEncryptionKey()

		// Assert
		if err != nil {
			t.Fatalf("expected no error, got %v", err)
		}
		if string(actual) != string(expected) {
			t.Fatalf("expected decoded key to match")
		}
	})

	t.Run("ShoudFailWhenEnvironmentValueIsMissingOrInvalid", func(t *testing.T) {
		for _, key := range []string{"", "not-base64", base64.StdEncoding.EncodeToString(make([]byte, 31))} {
			t.Run(key, func(t *testing.T) {
				// Arrange
				t.Setenv("TRACK_PIN_ENCRYPTION_KEY", key)

				// Act
				_, err := loadTrackPINEncryptionKey()

				// Assert
				if err == nil {
					t.Fatal("expected validation error")
				}
			})
		}
	})
}
