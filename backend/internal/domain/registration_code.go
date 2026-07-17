package domain

import (
	"crypto/sha256"
	"encoding/base32"
)

// crockfordAlphabet은 가독성을 위해 혼동되기 쉬운 I/L/O/U를 제외한 Crockford Base32 문자셋입니다.
const crockfordAlphabet = "0123456789ABCDEFGHJKMNPQRSTVWXYZ"

var registrationCodeEncoding = base32.NewEncoding(crockfordAlphabet).WithPadding(base32.NoPadding)

// registrationCodeHashBytes는 40비트(8자 Crockford Base32)로 인코딩하기 위해 사용하는 해시 길이입니다.
const registrationCodeHashBytes = 5

// GenerateRegistrationCode는 campId를 SHA-256으로 해싱한 뒤 앞 5바이트(40비트)를
// Crockford Base32로 인코딩해 8자 등록 코드를 결정적으로 생성합니다.
// 같은 campId는 항상 같은 코드를 반환하므로, 매 요청마다 재계산하지 않고 Camp 생성 시점에
// 한 번 계산해 저장하는 용도로 쓰입니다.
func GenerateRegistrationCode(id CampID) string {
	sum := sha256.Sum256([]byte(id))
	return registrationCodeEncoding.EncodeToString(sum[:registrationCodeHashBytes])
}
