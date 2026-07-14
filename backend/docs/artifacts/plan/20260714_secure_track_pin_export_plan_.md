# 트랙 PIN 보관 및 JSON 내보내기 구현 계획

## 결정 및 전제

- 관리자 PIN 내보내기는 내부 앱 운영 편의를 위해 허용한다. 다만 일반 트랙 조회 응답에는 PIN을 포함하지 않는다.
- 로그인 검증용 bcrypt `pin_hash`는 유지하고, 재내보내기 전용으로 암호화한 PIN을 별도 저장한다. DB 평문 저장은 하지 않는다.
- 기기 등록은 이미 `camp_id`에 귀속되어 있으므로, 다른 캠프의 승인 토큰은 로그인 과정에서 해당 트랙의 캠프와 일치하지 않아야 한다.
- 기존 `tracks` 행의 PIN 평문은 복구할 수 없다. 마이그레이션은 암호문을 nullable로 추가하고, PIN을 재발급하기 전에는 내보내기를 거부한다. 자동 재발급으로 기존 세션을 의도치 않게 끊지 않는다.

## 유스케이스

| 우선순위 | 유스케이스 | 설명 | 용도 |
| --- | --- | --- | --- |
| **P0** | UC-TrackPinExport | 관리자에게 단건·전체 ACTIVE 트랙의 복호화된 PIN을 JSON으로 제공한다. | **프로덕션 핵심 로직** |
| **P0** | UC-TrackPinRotate | PIN 재발급 시 bcrypt 해시와 암호문을 함께 갱신한다. | **프로덕션 핵심 로직** |
| P1 | UC-CampScopedDeviceTrust | 승인된 기기가 로그인 대상 트랙과 동일한 캠프에 속하는지 검증한다. | 보안 경계 검증 |

```go
// /home/lsjtop10/projects/cornermon/backend/internal/usecase/track.go
func (s *TrackService) ExportTrackPINs(
    ctx context.Context,
    campID domain.CampID,
) ([]TrackPIN, error)

func (s *TrackService) ExportTrackPIN(
    ctx context.Context,
    trackID domain.TrackID,
) (TrackPIN, error)
```

## 설계

### Domain / Usecase

- `/home/lsjtop10/projects/cornermon/backend/internal/domain/track.go`의 `PINCiphertext`는 암호화 방식에 독립적인 불투명 저장값이다. AES-GCM 구현은 domain에 유입하지 않는다.
- `/home/lsjtop10/projects/cornermon/backend/internal/usecase/port.go`의 `TrackPINProtector`를 통해 `/home/lsjtop10/projects/cornermon/backend/internal/usecase/track.go`가 생성·재발급 때 hash와 암호문을 같은 트랜잭션에서 저장하고 export 때만 복호화한다.
- export 성공/실패는 PIN 원문을 metadata에 넣지 않고 감사 로그로 남긴다.

### Infrastructure / DB

- `/home/lsjtop10/projects/cornermon/backend/db/schema.sql`, `query.sql`, sqlc 산출물에 `tracks.pin_ciphertext`와 저장 쿼리를 반영한다.
- `/home/lsjtop10/projects/cornermon/backend/internal/infrastructure/postgres/`에 `TrackPINStore` 구현을 둔다.
- `/home/lsjtop10/projects/cornermon/backend/internal/config`이 없으므로, 초기에는 서버 시작 시 환경 변수 `TRACK_PIN_ENCRYPTION_KEY`(base64 인코딩 32바이트 AES-256 키)를 필수 검증하고 wiring한다. 키나 PIN은 로그에 남기지 않는다.

### Web API / OpenAPI

- `/home/lsjtop10/projects/cornermon/backend/internal/infrastructure/web/track_handler.go`에서 `TrackResponse`의 `pin`을 제거한다.
- `TrackPinResponse`는 트랙 식별·표시 필드와 `pin`만 포함한다. 생성·교체·재발급 응답 및 두 export 응답에만 사용한다.
- `GET /tracks/{id}/export`는 `{ "track": TrackPinResponse }`, `GET /tracks/export`는 `{ "tracks": []TrackPinResponse }` JSON을 반환한다. 전체 export는 명시 `campId` query parameter의 ACTIVE 트랙만 대상으로 한다.
- `Cache-Control: no-store`를 export 응답에 설정하고, swagger 주석부터 수정한 뒤 `/home/lsjtop10/projects/cornermon/api/swagger.yaml`, `swagger.json`, `docs.go`를 재생성한다.

## 구현 단계

### Phase A: PIN 영속성 및 서비스 (예상 2시간)

| 순서 | 작업 | 파일 |
| --- | --- | --- |
| A-1 | 암호화 PIN 저장 포트와 서비스 결과 객체 추가 | `/home/lsjtop10/projects/cornermon/backend/internal/usecase/port.go` (기존 파일 확장), `track.go` (기존 파일 확장) |
| A-2 | AES-GCM PIN 암호화 구현과 환경 키 검증/wiring | `/home/lsjtop10/projects/cornermon/backend/internal/infrastructure/...` (신규/기존 파일 확장), `/home/lsjtop10/projects/cornermon/backend/cmd/server/main.go` (기존 파일 확장) |
| A-3 | schema/sqlc/리포지토리 저장 경로 확장 | `/home/lsjtop10/projects/cornermon/backend/db/*.sql` 및 `/home/lsjtop10/projects/cornermon/backend/internal/infrastructure/postgres/` (기존 파일 확장) |

### Phase B: API 계약 및 핸들러 (예상 1시간)

| 순서 | 작업 | 파일 |
| --- | --- | --- |
| B-1 | `TrackResponse`/`TrackPinResponse` 분리 및 생성·교체·재발급 응답 갱신 | `/home/lsjtop10/projects/cornermon/backend/internal/infrastructure/web/track_handler.go` (기존 파일 확장) |
| B-2 | JSON 단건·전체 내보내기, 캠프 범위 및 no-store 적용 | `/home/lsjtop10/projects/cornermon/backend/internal/infrastructure/web/track_handler.go` (기존 파일 확장) |
| B-3 | Swagger source annotation과 생성 산출물 동기화 | `/home/lsjtop10/projects/cornermon/api/swagger.yaml`, `swagger.json`, `docs.go` (생성 파일 갱신) |

### Phase C: 테스트 및 검증 (예상 1시간)

| 순서 | 작업 | 파일 |
| --- | --- | --- |
| C-1 | 생성·재발급·내보내기 복호화와 암호문 누락 거부 테스트 | `/home/lsjtop10/projects/cornermon/backend/internal/usecase/track_test.go` (기존 파일 확장) |
| C-2 | JSON DTO에서 일반 트랙 PIN 비노출, 단건/전체 export 계약과 no-store 테스트 | `/home/lsjtop10/projects/cornermon/backend/internal/infrastructure/web/` (신규 테스트) |
| C-3 | swagger 생성 및 전체·race 테스트, 자체 리뷰 | `/home/lsjtop10/projects/cornermon/backend/` |

## 검증 체크리스트

- [ ] `TrackResponse` JSON에 `pin`이 없다.
- [ ] PIN을 제공하는 모든 응답은 `TrackPinResponse`만 사용한다.
- [ ] `pin_hash`는 bcrypt 검증에 계속 사용되고 PIN 원문은 감사 로그·일반 DTO에 없다.
- [ ] 전체 export는 요청한 캠프의 ACTIVE 트랙만 반환하고, 단건 export는 해당 트랙만 반환한다.
- [ ] 암호문이 없는 기존 트랙 export는 PIN 재발급을 요구하는 안전한 오류를 반환한다.
- [ ] export 응답이 `application/json` 및 `Cache-Control: no-store`를 사용한다.
- [ ] 기기 인증은 등록의 `camp_id`와 로그인 트랙의 캠프가 일치할 때만 통과한다.
- [ ] `go test ./...`, `go test -race ./internal/usecase ./internal/infrastructure/web`, `go vet ./...`가 통과한다.

## 작업 현황

- [x] 기존 export stub, PIN hash-only 모델, QR 배지 JSON export 관례, 기기 등록의 캠프 귀속 확인
- [x] Phase A — AES-GCM protector, 환경 키 검증/wiring, schema/sqlc/repository 암호문 저장 구현
- [x] Phase B — `TrackResponse`/`TrackPinResponse` 분리, JSON 단건·전체 export, no-store 및 Swagger 산출물 동기화
- [ ] Phase C 및 자체 리뷰
