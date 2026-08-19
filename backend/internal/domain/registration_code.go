package domain

import (
	"crypto/rand"
	"encoding/base32"
	"fmt"
)

// crockfordAlphabet은 가독성을 위해 혼동되기 쉬운 I/L/O/U를 제외한 Crockford Base32 문자셋입니다.
const crockfordAlphabet = "0123456789ABCDEFGHJKMNPQRSTVWXYZ"

var registrationCodeEncoding = base32.NewEncoding(crockfordAlphabet).WithPadding(base32.NoPadding)

// registrationCodeRandomBytes는 40비트(8자 Crockford Base32)로 인코딩하기 위해 사용하는
// 난수 바이트 길이입니다.
const registrationCodeRandomBytes = 5

// GenerateRegistrationCode는 crypto/rand로 40비트를 뽑아 Crockford Base32 8자 등록 코드를
// 생성합니다. campId를 입력으로 받지 않습니다 — campId는 GET /camps 응답에 그대로 노출되는
// 비밀 아닌 값이라, 과거처럼 이를 해싱해 코드를 만들면 campId를 아는 사람이 등록 코드를
// 역산할 수 있게 됩니다(이슈 #217). crypto/rand 실패는 OS 엔트로피 소스 고갈 등 프로세스
// 자체가 불안정한 상황이므로 즉시 panic으로 드러냅니다.
func GenerateRegistrationCode() string {
	buf := make([]byte, registrationCodeRandomBytes)
	if _, err := rand.Read(buf); err != nil {
		panic(fmt.Sprintf("domain: failed to generate registration code: %v", err))
	}
	return registrationCodeEncoding.EncodeToString(buf)
}
