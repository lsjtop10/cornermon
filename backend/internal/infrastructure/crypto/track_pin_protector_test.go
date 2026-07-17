//go:build ignore

package crypto

import (
	"context"
	"testing"
)

func TestTrackPINProtector(t *testing.T) {
	// Arrange
	protector, err := NewTrackPINProtector(make([]byte, 32))
	if err != nil {
		t.Fatalf("unexpected protector error: %v", err)
	}

	// Act
	ciphertext, err := protector.Encrypt(context.Background(), "482910")
	if err != nil {
		t.Fatalf("unexpected encryption error: %v", err)
	}
	plaintext, err := protector.Decrypt(context.Background(), ciphertext)

	// Assert
	if err != nil || plaintext != "482910" {
		t.Fatalf("unexpected decryption result: %q, %v", plaintext, err)
	}
	if ciphertext == "482910" {
		t.Fatal("PIN was not encrypted")
	}
}
