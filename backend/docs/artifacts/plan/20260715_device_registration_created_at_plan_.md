# DeviceRegistration 생성 시각 영속화 계획

## 목표

`DeviceRegistration`의 실제 등록 시각을 조회 시점이 아닌 영속 데이터로 보존한다.

## 현재 문제

- `db/schema.sql`의 `device_registrations` 테이블에 `created_at` 컬럼이 없다.
- `internal/infrastructure/web/device_handler.go`의 `RequestRegistration`, `ListRegistrations`, `mapDeviceRegistration`이 응답 DTO의 `CreatedAt`을 전부 `time.Now()`(핸들러 실행 시각, 즉 조회 시각)로 채우고 있어 실제 등록 시각과 무관하고, 조회할 때마다 값이 달라진다.
- `domain.DeviceRegistration`, `db.DeviceRegistration`(sqlc), repository 매핑 어디에도 생성 시각 필드가 없다.

## 유즈케이스

| 우선순위 | 유즈케이스 | 설명 | 용도 |
|---|---|---|---|
| **P0** | UC-8 기기 등록 요청 시 생성 시각 저장 | `RequestRegistration` 호출 시점의 `nowFn()` 값을 `CreatedAt`에 기록 | **프로덕션 핵심 로직** |
| **P0** | 기기 목록/잠금 조회 응답에 실제 생성 시각 반환 | `ListRegistrations`, `ListLockedDevices` 응답의 `createdAt`이 DB에 저장된 값을 그대로 노출 | **프로덕션 핵심 로직** |
| P1 | 기존 행 백필 | 컬럼 추가 시 기존 `device_registrations` 행에 안전한 기본값(`approved_at`이 있으면 그 값, 없으면 마이그레이션 시각) 채움 | 데이터 정합성 |

## 객체 변경

### domain.DeviceRegistration (`internal/domain/device_registration.go`)

```go
type DeviceRegistration struct {
    ID                DeviceRegistrationID
    CampID            CampID
    DeviceName        string
    Status            DeviceRegistrationStatus
    TokenHash         string
    FailedPinAttempts int
    LockedUntil       Optional[time.Time]
    ApprovedAt        Optional[time.Time]
    CreatedAt         time.Time // (신규) 등록 요청이 생성된 시각
}
```
- 상태 전이 메서드(`Approve`, `Reject`, `Revoke`, `RecordPinFailure` 등)는 변경 없음 — `CreatedAt`은 생성 시 1회 설정 후 불변.

### DB 스키마 (`backend/db/schema.sql`)

마이그레이션 디렉토리가 없고 `schema.sql` 단일 파일로 관리되는 구조이므로, `CREATE TABLE device_registrations` 선언에 `created_at` 컬럼을 `facilitator_sessions.created_at`과 동일한 패턴(`TIMESTAMP WITH TIME ZONE NOT NULL`)으로 바로 추가한다. 이미 배포된 DB가 있다면 별도로 `ALTER TABLE ... ADD COLUMN` + 백필 SQL을 운영 스크립트로 준비한다.

```sql
CREATE TABLE device_registrations (
    ...
    approved_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL
);
COMMENT ON COLUMN device_registrations.created_at IS '기기 등록 요청이 생성된 시각';
```

운영 DB 백필용 (배포 시 1회 실행):
```sql
ALTER TABLE device_registrations ADD COLUMN created_at TIMESTAMP WITH TIME ZONE;
UPDATE device_registrations SET created_at = COALESCE(approved_at, now()) WHERE created_at IS NULL;
ALTER TABLE device_registrations ALTER COLUMN created_at SET NOT NULL;
```

### db/query.sql

- `GetDeviceRegistration`, `GetDeviceRegistrationByTokenHash`, `ListPendingDeviceRegistrationsByCamp`, `ListDeviceRegistrationsByCampAndStatus`: `SELECT *`이므로 변경 불필요 (컬럼 추가만으로 자동 반영).
- `SaveDeviceRegistration`: `created_at` 컬럼을 INSERT 목록에 추가하되, `ON CONFLICT DO UPDATE`에는 포함하지 않음(불변 필드 보호).

```sql
-- name: SaveDeviceRegistration :exec
INSERT INTO device_registrations (id, camp_id, device_name, status, token_hash, failed_pin_attempts, locked_until, approved_at, created_at)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
ON CONFLICT (id) DO UPDATE SET
    status = EXCLUDED.status,
    failed_pin_attempts = EXCLUDED.failed_pin_attempts,
    locked_until = EXCLUDED.locked_until,
    approved_at = EXCLUDED.approved_at;
```

### Repository (`internal/infrastructure/postgres/device_registration_repo.go`)

- `mapDeviceRegistration`: `d.CreatedAt = row.CreatedAt.Time` 추가 (`NOT NULL` 컬럼이므로 sqlc가 `pgtype.Timestamptz`를 생성해도 `Valid`는 항상 true — 실제 생성 타입은 `sqlc generate` 후 확인).
- `Save`: `params.CreatedAt = pgtype.Timestamptz{Time: reg.CreatedAt, Valid: true}` 추가.

### Usecase (`internal/usecase/device_trust.go`)

```go
// RequestRegistration - UC-8
reg := &domain.DeviceRegistration{
    ...
    CreatedAt: s.nowFn(),
}
```
- `ApproveDevice`/`RejectDevice`/`RevokeDevice`/`ResetPinFailures`는 `Get`으로 기존 엔티티를 로드하므로 `CreatedAt`이 자동 보존됨 — 코드 변경 불필요.

### HTTP 핸들러 (`internal/infrastructure/web/device_handler.go`)

- `RequestRegistration`: `CreatedAt: time.Now()` → `CreatedAt: reg.CreatedAt`.
- `ListRegistrations`: `CreatedAt: time.Now()` → `CreatedAt: d.CreatedAt`.
- `mapDeviceRegistration` (핸들러 내부 헬퍼): `CreatedAt: time.Now().UTC()` → `CreatedAt: device.CreatedAt`.

## 검증 계획

1. **단위 테스트 (usecase)**: `RequestRegistration` 호출 시 저장되는 `DeviceRegistration.CreatedAt`이 주입된 `nowFn()` 값과 일치하는지 검증 (기존 fake clock 테스트 패턴 재사용).
2. **레포지토리 테스트**: `Save` 후 `Get`으로 재조회했을 때 `CreatedAt`이 왕복 보존되는지 검증.
3. **핸들러 테스트**: `RequestRegistration`/`ListRegistrations`/`ListLockedDevices` 응답의 `createdAt`이 usecase가 반환한 값과 동일한지 검증 (`time.Now()` 하드코딩 제거 확인).
4. **수동 확인**: `go run ./cmd/server/main.go`로 기동 후 기기 등록 요청 → 목록을 두 번 이상 연속 조회했을 때 `createdAt` 값이 변하지 않는지 확인 (현재는 매 조회마다 값이 바뀌는 버그가 재현됨).

## 검증 체크리스트

- [ ] `domain` 패키지에 외부 의존성 추가 없음 (`time` 표준 라이브러리만 사용, 기존과 동일)
- [ ] `device_registrations.created_at`은 `NOT NULL`, 운영 배포 시 백필 스크립트 준비
- [ ] `SaveDeviceRegistration`의 `ON CONFLICT DO UPDATE`가 `created_at`을 갱신하지 않음 (불변성 보장)
- [ ] 모든 응답 DTO(`RequestRegistration`, `ListRegistrations`, `ListLockedDevices`)가 실제 `CreatedAt` 값을 사용, `time.Now()` 잔존 코드 없음
- [ ] `sqlc generate` 재실행 후 `internal/infrastructure/postgres/db` 산출물 커밋
- [ ] 기존 테스트(`go test ./...`) 통과 + 신규 테스트 추가
