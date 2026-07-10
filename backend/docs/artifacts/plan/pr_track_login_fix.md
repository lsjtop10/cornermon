# Fix: 진행자 트랙 PIN 로그인 요구사항 불일치 수정

## 변경 사항
OpenAPI 명세(`openapi.yaml`)의 `/auth/track/login` 설계에 맞춰 `FacilitatorAuthService.Login`의 동작을 수정했습니다.

- **문제점:** 기존 `Login` 유즈케이스가 `campID`, `trackID`를 인자로 요구하여, `pin`만 전송하는 클라이언트의 스펙과 맞지 않음. (또한 `TrackRepository`에 PIN으로 트랙을 찾는 기능이 부재)
- **수정안:**
  1. `FacilitatorAuthService.Login` 시그니처에서 `campID`, `trackID` 파라미터를 제거했습니다.
  2. 기기 신뢰 토큰(`deviceToken`)을 통해 승인된 `DeviceRegistration`을 조회하고, 여기 포함된 `CampID`를 추출합니다.
  3. `CampID`에 속한 활성 트랙(`ActiveTracks`) 목록을 조회(`s.tracks.ListActiveByCamp`)한 후, 반복문을 통해 전달된 `pin`과 `PINHash`를 bcrypt 대조하여 일치하는 트랙을 동적으로 찾도록 수정했습니다.
  4. 관련 테스트 코드(`auth_facilitator_test.go`)의 인자 전달을 수정하여 모든 테스트가 통과함을 확인했습니다.

## 연관 파일
- `backend/internal/usecase/auth_facilitator.go`
- `backend/internal/usecase/auth_facilitator_test.go`
