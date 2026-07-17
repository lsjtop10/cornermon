# 기기 등록 코드(campId 해시, Crockford Base32) 사전 생성 및 등록 플로우 개선

이슈: [#108](https://github.com/lsjtop10/cornermon/issues/108) (백엔드) / 선행 이슈 [#107](https://github.com/lsjtop10/cornermon/issues/107)(설계 논의), [#109](https://github.com/lsjtop10/cornermon/issues/109)(프론트, 미착수)

## 배경 / 근본 원인

`POST /device-registrations`는 현재 `campId` 원문을 그대로 요청 바디로 받는다
(`backend/internal/infrastructure/web/device_handler.go:52-56`). 하지만 진행자 앱에는 campId를
사전에 안내받을 채널이 없고(#107), UI는 "관리자에게 받은 등록 코드"라는, API 계약에 존재하지
않는 개념을 전제로 한다.

#107 논의에서 다음과 같이 결정되었다:
- 등록 코드는 **campId 원문이 아닌, campId를 해싱한 코드**로 발급한다.
- 해시는 Camp 생성 시점에 **사전 계산**해 컬럼으로 저장한다(요청마다 재계산 금지, O(1) 조회).
- 문자셋은 **Crockford Base32**(`0123456789ABCDEFGHJKMNPQRSTVWXYZ`, I/L/O/U 제외).
- 승인 방식은 현행 유지(B-1, PENDING → 관리자 수동 승인).
- `DeviceRegistrationRequest`에 기종(device model)과 관리자 화면 표시용 이름(진행자 입력)을
  추가한다.

**진행 순서 관련 결정 (사용자 확인 완료)**: `workflow/Collaborate.md`의 API 변경 절차는
프론트가 계약 변경 PR을 먼저 여는 것을 원칙으로 하지만, 이번 건은 계약 내용이 이미 #107에서
owner(레포 오너)가 확정했으므로 **백엔드가 먼저 구현하고 `api/swagger.yaml`을 갱신**한 뒤,
#109(프론트)가 이 계약을 참조해 진행하는 것으로 합의함.

## 유즈케이스

| 우선순위 | 유즈케이스 | 설명 | 용도 |
| --- | --- | --- | --- |
| **P0** | UC-1: 캠프 생성 시 등록 코드 결정적 생성 | `domain.NewCamp` 호출 시 campId를 SHA-256 해싱 → 앞 5바이트(40bit)를 Crockford Base32로 인코딩해 8자 코드 생성, `camps.registration_code`에 저장 | **프로덕션 핵심 로직** |
| **P0** | UC-2: 등록 코드로 기기 등록 요청 | 진행자가 `registrationCode`를 제출 → 서버가 O(1)로 campId를 역참조 → 기존 PENDING 등록 플로우 그대로 진행 | **프로덕션 핵심 로직** |
| **P0** | UC-3: 존재하지 않는/오타 등록 코드 처리 | 매칭되는 캠프가 없으면 404, 캠프가 ACTIVE가 아니면 400 (기존 정책 유지) | 안정성 |
| **P1** | UC-4: 기기 등록 시 기종/표시 이름 저장 | `deviceModel`, `displayName` 필드를 받아 `device_registrations`에 저장, 조회 응답에 노출 | 관리자 UX 지원 |
| **P1** | UC-5: 관리자가 캠프 등록 코드 조회 | 기존 `GET /camps`, `GET /camps/{id}`, `POST /camps` 응답(`CampResponse`)에 `registrationCode` 필드 포함 (신규 엔드포인트 불필요) | 관리자 UX 지원 |

## 설계

### Domain Layer

#### `backend/internal/domain/registration_code.go` (신규)

```go
package domain

// 책임: campId를 결정적으로 해싱해 Crockford Base32 등록 코드를 생성한다.
// 외부 의존성 없음 (crypto/sha256, encoding/base32는 표준 라이브러리).
func GenerateRegistrationCode(id CampID) string
```

- SHA-256(campId) → 앞 5바이트(40bit) → Crockford Base32(`0123456789ABCDEFGHJKMNPQRSTVWXYZ`)
  인코딩 → 8자 고정 길이, 패딩 없음(`base32.NoPadding`).
- `encoding/base32.NewEncoding(alphabet)`으로 커스텀 인코딩 테이블만 구성한다(표준 base32
  패키지는 Crockford의 모호 문자 디코딩 보정까지는 지원하지 않지만, 이 코드는 단방향 발급용이라
  인코딩만 필요 — 디코딩해서 campId를 복원하지 않고 DB 컬럼 매칭으로 역참조하므로 문제 없음).

#### `backend/internal/domain/camp.go` (기존 파일 확장)

```go
type Camp struct {
    ID               CampID
    RegistrationCode string // 신규: campId 해시 기반 등록 코드 (Crockford Base32, 8자)
    Name             string
    // ... 기존 필드
}

// 책임: 필수 입력값 검증 + 등록 코드 결정적 생성 후 PENDING 상태의 새 캠프 생성
func NewCamp(id CampID, name string, startAt, endAt time.Time) (*Camp, error)
```

- `NewCamp` 내부에서 `RegistrationCode: GenerateRegistrationCode(id)`를 채워서 반환.
- 기존 검증 규칙(이름/기간)은 변경 없음.

#### `backend/internal/domain/device_registration.go` (기존 파일 확장)

```go
type DeviceRegistration struct {
    ID                DeviceRegistrationID
    CampID            CampID
    DeviceName        string // 기존: 클라이언트 자동 생성값(OS/버전)
    DeviceModel       string // 신규: 기기 기종(device model/type)
    DisplayName       string // 신규: 관리자 화면 표시용 이름(진행자 입력)
    Status            DeviceRegistrationStatus
    // ... 기존 필드
}
```

- 상태 전이 메서드(`Approve`/`Reject`/`Revoke`/`RecordPinFailure`/...)는 변경 없음.

### Usecase Layer

#### `backend/internal/usecase/port.go` (기존 파일 확장)

```go
type CampRepository interface {
    Get(ctx context.Context, id domain.CampID) (*domain.Camp, error)
    GetByRegistrationCode(ctx context.Context, code string) (*domain.Camp, error) // 신규
    List(ctx context.Context) ([]*domain.Camp, error)
    Save(ctx context.Context, camp *domain.Camp) error
}
```

#### `backend/internal/usecase/device_trust.go` (기존 파일 확장)

```go
// RequestRegistration - UC-8
// 책임: 등록 코드로 campId 역참조 → 활성 캠프 검증 → PENDING 등록 생성
func (s *DeviceTrustService) RequestRegistration(
    ctx context.Context,
    registrationCode string,
    deviceName, deviceModel, displayName string,
) (string, *domain.DeviceRegistration, error)
```

- 기존 `campID domain.CampID` 파라미터를 `registrationCode string`으로 교체.
- 내부 흐름: `s.camps.GetByRegistrationCode(ctx, registrationCode)` → `nil`이면
  `domain.ErrCampNotFound` 반환(기존 sentinel 재사용, 신규 에러 타입 추가하지 않음) →
  `!camp.IsActive()`면 기존과 동일하게 `domain.ErrCampInvalidTransition` 반환.
- 이후 로직(토큰 생성, `domain.DeviceRegistration{...}` 조립, 저장, 감사로그, 브로드캐스트)은
  동일 — `DeviceModel`, `DisplayName` 필드만 채워서 저장.

### Infrastructure — Postgres

#### `backend/db/schema.sql` (기존 파일 확장, 별도 마이그레이션 디렉터리 없음 — 이 레포는 `schema.sql` 단일 파일을 `docker-entrypoint-initdb.d/init.sql`로 사용)

```sql
-- camps 테이블
ALTER: registration_code VARCHAR(20) NOT NULL UNIQUE  -- 컬럼 추가, bottleneck_ratio_pct 다음
COMMENT ON COLUMN camps.registration_code IS '기기 등록 코드 (campId 해시, Crockford Base32)';

-- device_registrations 테이블
device_model VARCHAR(255) NOT NULL   -- device_name 다음에 추가
display_name VARCHAR(255) NOT NULL   -- device_model 다음에 추가
COMMENT ON COLUMN device_registrations.device_model IS '기기 기종(모델명)';
COMMENT ON COLUMN device_registrations.display_name IS '관리자 화면 표시용 이름(진행자 입력)';
```

- 기존 로컬 DB 볼륨을 쓰는 개발자는 `make reset-postgres`로 재초기화해야 스키마가 반영된다
  (마이그레이션 툴 부재는 기존 컨벤션 — 다른 plan 문서에서도 동일하게 처리).

#### `backend/db/query.sql` (기존 파일 확장)

```sql
-- name: GetCampByRegistrationCode :one
SELECT * FROM camps WHERE registration_code = $1;

-- name: SaveCamp :exec  (registration_code 컬럼 추가)
INSERT INTO camps (id, registration_code, name, start_at, end_at, activated_at, ended_at, status, bottleneck_min_samples, bottleneck_ratio_pct)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
ON CONFLICT (id) DO UPDATE SET ...  -- registration_code는 불변이므로 UPDATE SET에는 포함하지 않음(캠프 재생성 없음 전제)

-- name: SaveDeviceRegistration :exec  (device_model, display_name 컬럼 추가)
INSERT INTO device_registrations (id, camp_id, device_name, device_model, display_name, status, token_hash, failed_pin_attempts, locked_until, approved_at, created_at)
VALUES (...)
ON CONFLICT (id) DO UPDATE SET ...  -- 기존과 동일하게 device_name류는 UPDATE SET 대상 아님
```

- `internal/infrastructure/postgres/db/{models,query.sql,querier}.go`는 생성물이므로 수동
  편집하지 않고 `sqlc generate`로만 갱신한다. (이 워크트리는 origin/main에서 새로 분기했으므로
  원본 작업 디렉터리의 무관한 미커밋 변경은 포함되어 있지 않음 — stash 격리 불필요.)

#### `backend/internal/infrastructure/postgres/camp_repo.go` (기존 파일 확장)

```go
// 책임: registration_code로 O(1) 캠프 조회 (신규 sqlc 쿼리 래핑)
func (r *pgCampRepository) GetByRegistrationCode(ctx context.Context, code string) (*domain.Camp, error)
```

- `Get`/`List`/`Save`의 매핑 로직에 `RegistrationCode` 필드 추가(패턴은 `Name` 필드와 동일 —
  Optional이 아닌 필수 컬럼).

#### `backend/internal/infrastructure/postgres/device_registration_repo.go` (기존 파일 확장)

- `mapDeviceRegistration`, `Save`의 params 조립에 `DeviceModel`, `DisplayName` 추가(패턴은
  `DeviceName`과 동일).

### Infrastructure — Web

#### `backend/internal/infrastructure/web/camp_handler.go` (기존 파일 확장)

```go
type CampResponse struct {
    ID               string `json:"id" format:"uuid"`
    RegistrationCode string `json:"registrationCode" example:"7ZQK3M2X"` // 신규
    Name             string `json:"name" example:"2026 여름 코너학습"`
    // ... 기존 필드
} // @name CampResponse
```

- `mapDomainCampToDTO`에 `RegistrationCode: camp.RegistrationCode` 추가.
- `CreateCampRequest`는 변경 없음(등록 코드는 서버가 생성, 클라이언트 입력 아님).

#### `backend/internal/infrastructure/web/device_handler.go` (기존 파일 확장)

```go
type DeviceRegistrationRequest struct {
    RegistrationCode string `json:"registrationCode"` // 기존 campId 필드를 대체
    DeviceName       string `json:"deviceName"`
    DeviceModel      string `json:"deviceModel" example:"iPad Pro 11 2022"`   // 신규
    DisplayName      string `json:"displayName" example:"1번 태블릿"`           // 신규
    Role             string `json:"role" enums:"ADMIN,FACILITATOR"`
} // @name DeviceRegistrationRequest

type DeviceRegistrationResponse struct {
    ID           string `json:"id" format:"uuid"`
    DeviceName   string `json:"deviceName"`
    DeviceModel  string `json:"deviceModel"`   // 신규
    DisplayName  string `json:"displayName"`   // 신규
    // ... 기존 필드
} // @name DeviceRegistrationResponse
```

- `RequestRegistration` 핸들러: `h.deviceTrust.RequestRegistration(ctx, req.RegistrationCode,
  req.DeviceName, req.DeviceModel, req.DisplayName)` 호출로 변경.
  - 에러 매핑 추가(기존 `GetMyRegistrationStatus`의 로컬 관례를 따름 — 이 핸들러들은
    `error_handler_middleware`를 거치지 않고 직접 `c.JSON` 처리):
    - `errors.Is(err, domain.ErrCampNotFound)` → 404 `CAMP_NOT_FOUND`
    - `errors.Is(err, domain.ErrCampInvalidTransition)` → 400 `INVALID_TRANSITION`
    - 그 외 → 기존과 동일 500
- `mapDeviceRegistration`, `ListRegistrations`의 인라인 응답 조립에 `DeviceModel`/`DisplayName`
  추가.

### API 계약 변경 (`workflow/Collaborate.md`)

- 이 레포는 별도 `api/openapi.yaml`이 없고 swaggo 주석이 소스이며 `api/swagger.yaml` /
  `swagger.json` / `docs.go`가 생성물이다(기존 plan 문서들과 동일 확인).
- **Breaking change**: `DeviceRegistrationRequest.campId` → `registrationCode`로 필드명 변경
  (프론트 #109가 아직 착수 전이므로 영향 없음). `deviceModel`/`displayName` 신규 필수 필드 추가.
- 구현 완료 후 `make swag`(`swag init -g internal/infrastructure/web/doc.go -d . -o ../api
  --parseDependency --parseInternal`) 실행해 `api/swagger.yaml`, `api/swagger.json`,
  `api/docs.go` 갱신 필수.

### 문서 갱신

- `docs/technical-design.md` §2.2-a-i: campId 노출 없이 해시 등록 코드로 기기 등록 흐름이
  이루어짐을 반영.
- `docs/domain-model.md` §2.4-b: "등록 코드(campId 해시, Crockford Base32)" 개념 추가.

## Phase

| 순서 | 작업 | 파일 |
| --- | --- | --- |
| A-1 | `GenerateRegistrationCode` 구현 + 단위 테스트(결정성 검증) | `backend/internal/domain/registration_code.go`, `registration_code_test.go` |
| A-2 | `Camp.RegistrationCode` 필드 + `NewCamp` 반영 + 테스트 보강 | `backend/internal/domain/camp.go`, `camp_test.go` |
| A-3 | `DeviceRegistration`에 `DeviceModel`/`DisplayName` 필드 추가 | `backend/internal/domain/device_registration.go` |
| B-1 | `schema.sql`/`query.sql` 컬럼·쿼리 추가 | `backend/db/schema.sql`, `backend/db/query.sql` |
| B-2 | `sqlc generate` 실행 → 생성물 갱신 확인 | `backend/internal/infrastructure/postgres/db/*` |
| C-1 | `CampRepository.GetByRegistrationCode` 포트 추가 + 구현 + 매핑 필드 추가 | `backend/internal/usecase/port.go`, `backend/internal/infrastructure/postgres/camp_repo.go` |
| C-2 | `DeviceRegistrationRepository` 매핑에 신규 필드 반영 | `backend/internal/infrastructure/postgres/device_registration_repo.go` |
| D-1 | `MockCampRepository`에 `GetByRegistrationCode` 추가 (기존 usecase 테스트 전체가 이 mock 공유 — 누락 시 컴파일 실패) | `backend/internal/usecase/mock_test.go` |
| D-2 | `DeviceTrustService.RequestRegistration` 시그니처 변경 + 등록 코드 역참조 로직 + 테스트 갱신 | `backend/internal/usecase/device_trust.go`, `device_trust_test.go` |
| E-1 | `CampResponse`에 `registrationCode` 추가 | `backend/internal/infrastructure/web/camp_handler.go`, `camp_handler_test.go`(있다면) |
| E-2 | `DeviceRegistrationRequest`/`Response` 필드 교체·추가, 에러 매핑, 핸들러 테스트 | `backend/internal/infrastructure/web/device_handler.go`, `device_handler_test.go`(있다면) |
| F-1 | `make swag` 재생성 | `api/swagger.yaml`, `api/swagger.json`, `api/docs.go` |
| F-2 | `docs/technical-design.md` §2.2-a-i, `docs/domain-model.md` §2.4-b 갱신 | `docs/technical-design.md`, `docs/domain-model.md` |
| G-1 | `gofmt -w . && go vet ./... && go test ./...` 전체 통과 확인 | 전체 |

## 검증 방법

- **자동화 테스트**:
  - `domain`: `GenerateRegistrationCode`가 동일 입력에 항상 동일 출력을 내는지(결정성), 8자
    Crockford Base32 알파벳 범위 내 문자만 포함하는지.
  - `usecase`: `RequestRegistration`이 (a) 유효한 코드+ACTIVE 캠프 → PENDING 등록 성공,
    (b) 존재하지 않는 코드 → `ErrCampNotFound`, (c) PENDING/ENDED 캠프의 코드 →
    `ErrCampInvalidTransition` 반환하는지.
  - `web`: `DeviceRegistrationRequest` 바인딩 및 에러 매핑(404/400) 핸들러 테스트.
- **수동 검증**: `make reset-postgres` → 서버 기동 → `POST /camps`로 캠프 생성 → 응답의
  `registrationCode` 확인 → 해당 코드로 `POST /device-registrations` 호출해 정상 등록되는지
  curl로 확인. 잘못된 코드로 404, PENDING 캠프 코드로 400이 오는지도 확인.

## 검증 체크리스트

### 아키텍처 검증
- [x] `domain` 패키지에서 `infrastructure` import 없음 (`registration_code.go`는 표준
      라이브러리만 사용)
- [x] `usecase`가 `CampRepository` 인터페이스에만 의존 (구체 구현 모름)
- [x] 신규 포트 남발 없이 기존 `CampRepository`를 확장 (신규 인터페이스 생성하지 않음)

### 유즈케이스 검증
- [x] UC-1: 캠프 생성 시 8자 Crockford Base32 등록 코드가 결정적으로 생성되어 저장됨
- [x] UC-2: `POST /device-registrations`가 등록 코드로 campId를 해석해 등록 요청을 처리함
- [x] UC-3: 존재하지 않는 코드 404, 비활성 캠프 코드 400
- [x] UC-4: 기기 등록 시 기종/표시 이름이 저장되고 조회 응답에 노출됨
- [x] UC-5: 관리자 API(`GET /camps`, `GET /camps/{id}`)로 캠프의 등록 코드 조회 가능

### 종료 조건 (이슈 #108 원문 대조)
- [x] Camp 생성 시 Crockford Base32 등록 코드가 결정적으로 생성되어 저장됨
- [x] `POST /device-registrations`가 등록 코드로 campId를 해석해 등록 요청을 처리함
- [x] 관리자 API로 캠프의 등록 코드를 조회 가능
- [x] `api/swagger.yaml` 반영 완료
- [x] 관련 설계 문서(§2.2-a-i, §2.4-b) 갱신

### 부수 확인
- [x] `gofmt -w . && go vet ./... && go test ./...` 통과
