package crypto

import (
	"context"
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"encoding/base64"
	"fmt"
	"io"
)

type TrackPINProtector struct{ gcm cipher.AEAD }

func NewTrackPINProtector(key []byte) (*TrackPINProtector, error) {
	block, err := aes.NewCipher(key)
	if err != nil {
		return nil, err
	}
	gcm, err := cipher.NewGCM(block)
	if err != nil {
		return nil, err
	}
	return &TrackPINProtector{gcm: gcm}, nil
}

func (p *TrackPINProtector) Encrypt(_ context.Context, pin string) (string, error) {
	nonce := make([]byte, p.gcm.NonceSize())
	if _, err := io.ReadFull(rand.Reader, nonce); err != nil {
		return "", err
	}
	return base64.StdEncoding.EncodeToString(append(nonce, p.gcm.Seal(nil, nonce, []byte(pin), nil)...)), nil
}

func (p *TrackPINProtector) Decrypt(_ context.Context, encoded string) (string, error) {
	raw, err := base64.StdEncoding.DecodeString(encoded)
	if err != nil {
		return "", err
	}
	if len(raw) < p.gcm.NonceSize() {
		return "", fmt.Errorf("ciphertext too short")
	}
	plain, err := p.gcm.Open(nil, raw[:p.gcm.NonceSize()], raw[p.gcm.NonceSize():], nil)
	if err != nil {
		return "", err
	}
	return string(plain), nil
}
