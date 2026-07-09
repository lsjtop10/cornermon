package usecase

import (
	"crypto/rand"
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"math/big"

	"golang.org/x/crypto/bcrypt"
)

// hashSHA256은 입력 문자열의 SHA-256 해시값을 hex string으로 반환합니다.
func hashSHA256(s string) string {
	h := sha256.New()
	h.Write([]byte(s))
	return hex.EncodeToString(h.Sum(nil))
}

// generateOpaqueToken은 32바이트 무작위 토큰 평문(hex)과 그 SHA-256 해시값을 생성합니다.
func generateOpaqueToken() (string, string, error) {
	bytes := make([]byte, 32)
	if _, err := rand.Read(bytes); err != nil {
		return "", "", err
	}
	plain := hex.EncodeToString(bytes)
	hash := hashSHA256(plain)
	return plain, hash, nil
}

// generateTrackPIN은 6자리 숫자 PIN 평문과 bcrypt 해시값을 생성합니다.
func generateTrackPIN() (string, string, error) {
	var plain string
	for i := 0; i < 6; i++ {
		n, err := rand.Int(rand.Reader, big.NewInt(10))
		if err != nil {
			return "", "", err
		}
		plain += fmt.Sprintf("%d", n.Int64())
	}

	hashBytes, err := bcrypt.GenerateFromPassword([]byte(plain), bcrypt.DefaultCost)
	if err != nil {
		return "", "", err
	}

	return plain, string(hashBytes), nil
}

// hashPassword는 평문 비밀번호를 bcrypt로 해싱합니다.
func hashPassword(password string) (string, error) {
	hashBytes, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return "", err
	}
	return string(hashBytes), nil
}

// verifyPassword는 평문 비밀번호와 bcrypt 해시값을 비교 검증합니다.
func verifyPassword(hashedPassword, password string) error {
	return bcrypt.CompareHashAndPassword([]byte(hashedPassword), []byte(password))
}
