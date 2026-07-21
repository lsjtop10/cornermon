# 진행자 트랙 로그인 HTTP 오류 매핑 계획

## 유즈케이스

| 우선순위 | 유즈케이스 | 설명 | 용도 |
| --- | --- | --- | --- |
| P0 | UC-9: 진행자 트랙 PIN 로그인 | 예상 가능한 로그인 실패를 API 문맥에 맞는 4xx로 응답한다. | 프로덕션 핵심 로직 |

## 변경

- `AuthHandler.TrackLogin`은 `errors.Is`로 도메인 오류를 분기한다.
- `ErrDeviceNotApproved`/`ErrCampInvalidTransition`은 403, `ErrDeviceLocked`는 429, `ErrInvalidPin`은 400으로 응답한다.
- 그 외 오류만 기존처럼 중앙 `ErrorHandler`의 500 처리로 전달한다.
- 엔드포인트 Swagger 주석에 각 4xx `ErrorResponse.code`의 의미를 명시한다.

## 검증

- [x] 각 예상 오류가 해당 HTTP 상태와 안정적인 응답 code를 반환한다.
- [x] 래핑된 sentinel error도 `errors.Is`로 매핑된다.
- [x] `go test ./internal/infrastructure/web` 통과
- [x] Swagger 주석에 4xx 응답 code와 클라이언트 대응 의미가 기록된다.
