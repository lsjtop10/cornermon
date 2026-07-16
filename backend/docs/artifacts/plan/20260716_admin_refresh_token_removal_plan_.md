# 관리자 Refresh Token 제거 Plan

## 배경

관리자 인증은 opaque token(불투명 토큰) 방식이라 서버가 세션을 DB 해시 조회로 완전히 통제한다. Refresh 토큰을 두는 이유는 보통 JWT처럼 "발급 후 서버 통제력이 약해지는" 토큰에서 access 토큰 수명을 짧게 유지하기 위함인데, 지금 구조는 그 이점 없이 (refresh 토큰 미rotate, idle TTL만 연장) 세션 하이재킹 취약점만 추가로 안고 있다.

관리자 계정 수가 적고 로그인 UX 비용이 크지 않으므로, refresh 플로우를 완전히 제거하고 access 토큰 단일 구조 + TTL 연장으로 단순화한다.

## 유즈케이스

| 우선순위 | 유즈케이스 | 설명 | 용도 |
|---|---|---|---|
| **P0** | UC-11 로그인 (변경) | 관리자 ID/PW 로그인 시 access 토큰만 발급 (refresh 토큰 발급 제거) | **프로덕션 핵심 로직** |
| **P0** | UC-13 액세스 토큰 검증 (유지) | 기존 로직 그대로, TTL 상수만 연장 | **프로덕션 핵심 로직** |
| P1 | UC-12 리프레시 (삭제) | `AdminAuthService.RefreshToken`, `/auth/admin/refresh` 엔드포인트, `AdminRefreshAuth` 시큐리티 스킴 전체 삭제 | 제거 대상 |
| P1 | 만료 시 재로그인 | Access 토큰 만료 시 클라이언트는 재로그인만 수행 (refresh 재발급 없음) | 프론트 영향 있음 — 프론트 별도 대응 필요 (본 plan은 백엔드 한정) |

## 아키텍처 영향

- Domain / Usecase / Infrastructure 3계층 모두 수정. `domain`은 외부 의존성 없이 필드/메서드만 제거.
- 새 인터페이스 생성 없음 — 기존 `AdminAuthUsecase`, `AdminSessionRepository` 포트에서 불필요해진 메서드만 제거.
- **API 스키마 변경 있음** → `workflow/Collaborate.md` 절차에 따라 swagger 주석(`auth_handler.go`, `doc.go`) 갱신 필수 (본 레포는 별도 `api/openapi.yaml` 없이 `swag` 주석이 소스임을 확인함).

## 객체/메서드 변경 정의

### Domain — `backend/internal/domain/admin.go`

```go
type AdminSession struct {
    ID              AdminSessionID
    AdminID         AdminID
    AccessTokenHash string
    // RefreshTokenHash string  // 삭제
    DeviceInfo      string
    CreatedAt       time.Time
    LastUsedAt      time.Time
    RevokedAt       Optional[time.Time]
}

// TouchRefresh → TouchActivity(now)로 이름 변경 (역할: 슬라이딩 세션의 활동 시각 갱신, refresh 전용 의미 제거)
// IsRefreshExpired → IsExpired(now, idleTTL)로 이름 변경 (refresh 문맥 제거, access 세션의 idle 만료 판정으로 의미 전환)
// Revoke(now)는 유지 — 로그아웃/강제 종료에 계속 사용됨
```

### Usecase — `backend/internal/usecase/auth_admin.go`

```go
const AdminAccessTokenTTL = 12 * time.Hour // 30분 → 12시간으로 연장 (재로그인 부담 완화)
// AdminRefreshTokenIdleTTL 삭제

// Login - UC-11 (시그니처 변경: refresh 토큰 반환 제거)
func (s *AdminAuthService) Login(
    ctx context.Context,
    username string,
    password string,
    deviceInfo string,
) (string /* access token */, *domain.AdminSession, error)

// RefreshToken - UC-12 전체 삭제

// ValidateAccessToken - UC-13 (슬라이딩 세션: 검증 성공 시 LastUsedAt 갱신 후 저장)
func (s *AdminAuthService) ValidateAccessToken(
    ctx context.Context,
    accessToken string,
) (*domain.AdminSession, error)
// 책임: 세션 조회 + 만료/취소 확인 + LastUsedAt 갱신(TouchActivity) + 저장(활동 있으면 TTL 연장, 방치 시 12h 후 만료)
```

### Port — `backend/internal/usecase/port.go`

```go
type AdminSessionRepository interface {
    // GetByRefreshTokenHash(ctx, hash) 삭제
    // 나머지 메서드 유지
}
```

### Web — `backend/internal/infrastructure/web/auth_handler.go`

```go
type AdminAuthUsecase interface {
    Login(ctx context.Context, username, password, deviceInfo string) (string, *domain.AdminSession, error)
    // RefreshToken(...) 삭제
    RevokeSession(ctx context.Context, sessionID domain.AdminSessionID, actorAdminID domain.AdminID) error
    ListSessions(ctx context.Context, adminID domain.AdminID) ([]*domain.AdminSession, error)
    ForceTrackLogout(ctx context.Context, trackID domain.TrackID, actorAdminID domain.AdminID) error
}

type AdminLoginResponse struct {
    AccessToken      string `json:"accessToken"`
    // RefreshToken 필드 삭제
    ExpiresInSeconds int    `json:"expiresInSeconds"` // 1800 → 43200 (12h)
}

// AdminRefreshResponse 구조체 전체 삭제
// AdminRefresh 핸들러 전체 삭제 (swagger 주석 포함)
```

### Router — `backend/internal/infrastructure/web/router.go`

- `admin.POST("/auth/admin/refresh", h.Auth.AdminRefresh)` 라인 삭제

### Swagger 문서 헤더 — `backend/internal/infrastructure/web/doc.go`

- `@securityDefinitions.apikey AdminRefreshAuth` 및 설명 라인 삭제
- `swag init` (또는 프로젝트의 codegen 커맨드) 재실행하여 생성 문서 갱신

### Postgres — `backend/internal/infrastructure/postgres/admin_session_repo.go`, `db/query.sql`, `db/schema.sql`

```sql
-- db/schema.sql
-- admin_sessions 테이블에서 refresh_token_hash 컬럼 삭제
```

- `GetAdminSessionByRefreshTokenHash` 쿼리 삭제
- 나머지 쿼리(`GetAdminSessionByID`, `GetAdminSessionByAccessTokenHash`, list, `CreateAdminSession`)에서 `refresh_token_hash` 컬럼 참조 제거
- `sqlc generate` 재실행하여 `internal/infrastructure/postgres/db/*.go` 갱신 (직접 손으로 수정하지 않음)
- **DB 마이그레이션 도구 없음(레포에 `db/migrations/` 부재, `db/schema.sql` 단일 소스)** → 실제 운영 DB에 반영할 `ALTER TABLE admin_sessions DROP COLUMN refresh_token_hash;` 실행 방법은 사용자 확인 필요 (로컬 개발 DB는 schema.sql 재적용으로 충분하나, 배포 환경 반영 절차는 이 plan 범위 밖)

### Tests

- `internal/domain/admin_test.go`: `RefreshTokenHash`, `IsRefreshExpired`, `TouchRefresh` 관련 테스트 삭제
- `internal/usecase/auth_admin_test.go`: `Login` 테스트에서 refresh 반환값 검증 제거, `TestAdminAuthService_RefreshToken` 전체 삭제
- `internal/usecase/mock_test.go`: `MockAdminSessionRepository.GetByRefreshTokenHash` 삭제

## 구현 단계

| Phase | 작업 | 파일 | 예상 소요 |
|---|---|---|---|
| A | Domain 계층 수정 (필드/메서드 삭제) | `internal/domain/admin.go`, `admin_test.go` | 15분 |
| B | Usecase 계층 수정 (Login 시그니처, RefreshToken 삭제, TTL 상수) | `internal/usecase/auth_admin.go`, `port.go`, `auth_admin_test.go`, `mock_test.go` | 30분 |
| C | Web 계층 수정 (핸들러/DTO/라우터/swagger) | `auth_handler.go`, `router.go`, `doc.go` | 30분 |
| D | DB 계층 수정 (schema, query, sqlc 재생성, repo) | `db/schema.sql`, `db/query.sql`, `admin_session_repo.go` | 30분 |
| E | 전체 빌드/테스트, swag 재생성 확인 | - | 15분 |

## 검증 체크리스트

### 아키텍처 검증
- [ ] `domain` 패키지에 외부 의존성 없음 (변경 없음, 필드만 제거)
- [ ] `usecase` 계층이 여전히 `AdminSessionRepository` 인터페이스에만 의존
- [ ] 새 인터페이스 생성 없음 (기존 포트 축소만 진행)

### 유즈케이스 검증
- [ ] UC-11: 로그인 시 access 토큰만 반환, refresh 토큰 없음
- [ ] UC-13: access 토큰이 TTL(12h) 내에서 유효, 만료 후 401
- [ ] `/auth/admin/refresh` 라우트 자체가 404 (삭제 확인)
- [ ] `go build ./...`, `go vet ./...` 통과
- [ ] `go test ./...` 통과 (수정된 테스트 포함)
- [ ] swagger 생성 문서에 `AdminRefreshAuth`/`AdminRefreshResponse` 미노출
- [ ] `sqlc generate` 후 `admin_sessions` 관련 생성 코드에 `refresh_token_hash` 미참조

### 확정된 결정 사항
- [x] 슬라이딩 세션 적용: `ValidateAccessToken` 성공 시 `LastUsedAt` 갱신 + 저장 (활동 있으면 연장, idle 12h 후 만료)
- [x] Access 토큰 TTL: 12시간 (idle 기준)
- [x] 대상 클라이언트: 모바일(Flutter)만 우선 고려. 웹(캠프 생성용)은 별도 검토 대상, 이 plan 범위 밖

### 미결 사항 (사용자 확인 필요)
- [ ] 운영 DB에 `refresh_token_hash` 컬럼 DROP을 어떻게 반영할지 (마이그레이션 도구 부재 — 로컬 개발은 schema.sql 재적용으로 충분)
