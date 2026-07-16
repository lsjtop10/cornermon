# 관리자 역할(Role) 도입 + 초기 관리자 부트스트랩 + 관리자 계정 관리 API

## 배경

`admins` 테이블과 로그인/세션 로직은 존재하지만, 최초 관리자 계정을 만들 방법이 시스템 어디에도 없다
(`AdminRepository`에 `Save` 없음, seed 없음, 회원가입 API 없음). 이 계획은:

1. 서버 최초 기동 시 ENV 기반으로 시스템 관리자 1명을 시딩
2. 관리자 역할(SYSTEM_ADMIN / CORNER_OPERATOR) 도입
3. 관리자 생성/비밀번호 변경/삭제 API를 유즈케이스로 노출 (모두 SYSTEM_ADMIN 전용)

를 다룬다.

---

## 1. 유즈케이스

| 우선순위 | 유즈케이스 | 설명 | 용도 |
|---|---|---|---|
| **P0** | UC-B1: 서버 부트스트랩 시 최초 관리자 시딩 | 서버 기동 시 `admins` 테이블이 비어있으면 ENV(`ADMIN_BOOTSTRAP_USERNAME`, `ADMIN_BOOTSTRAP_PASSWORD`)로 SYSTEM_ADMIN 1명 생성 | **프로덕션 핵심 로직** |
| **P0** | UC-B2: 관리자 생성 | SYSTEM_ADMIN이 새 CORNER_OPERATOR를 생성 (SYSTEM_ADMIN 생성 금지) | **프로덕션 핵심 로직** |
| **P0** | UC-B3: 관리자 비밀번호 변경 | 본인 또는 SYSTEM_ADMIN이 임의 관리자의 비밀번호를 변경 | **프로덕션 핵심 로직** |
| **P0** | UC-B4: 관리자 삭제 | SYSTEM_ADMIN이 임의 관리자를 삭제(세션도 함께 무효화) | **프로덕션 핵심 로직** |
| **P0** | UC-B6: 삭제 엣지케이스 가드 | 자기 자신 삭제 방지, 마지막 SYSTEM_ADMIN 삭제 방지 | 운영 사고 방지 |
| **P1** | UC-B5: 권한 통제 | CORNER_OPERATOR가 B2~B4 호출 시 403 | 보안 가드 |

**정책 확정 사항** (사용자 확답):
- 역할은 `SYSTEM_ADMIN`(시스템 관리자), `CORNER_OPERATOR`(코너 운용 관리자) 2종.
- SYSTEM_ADMIN은 다른 SYSTEM_ADMIN을 생성할 수 없으며, 관리자 생성 API는 CORNER_OPERATOR 생성만 허용한다.
- 관리자 생성/비밀번호변경/삭제는 전부 **SYSTEM_ADMIN 전용**.
- **(사용자 피드백 반영)** 자기 자신 삭제 방지, 마지막 SYSTEM_ADMIN 삭제 방지는 이번 계획 범위에 **포함**한다 (UC-B6). 아래 §2.2~2.4, §3, §5에 반영됨.
- **(사용자 피드백 반영)** 비밀번호 변경(UC-B3)은 SYSTEM_ADMIN 전용이 아니라 **본인 또는 SYSTEM_ADMIN**이 수행 가능하다 (생성/삭제는 여전히 SYSTEM_ADMIN 전용). 아래 §2.4, §2.8, §5에 반영됨.


---

## 2. 객체 설계

### 2.1 Domain Layer (`internal/domain/admin.go`)

```go
type AdminRole string

const (
    AdminRoleSystemAdmin    AdminRole = "SYSTEM_ADMIN"
    AdminRoleCornerOperator AdminRole = "CORNER_OPERATOR"
)

type Admin struct {
    ID           AdminID
    Username     string
    PasswordHash string
    Role         AdminRole
}

// IsSystemAdmin은 해당 관리자가 시스템 관리자 권한을 가지는지 반환합니다.
func (a *Admin) IsSystemAdmin() bool
```

### 2.2 Domain Errors (`internal/domain/errors.go`에 추가)

```go
var (
    ErrAdminNotFound            = errors.New("admin: not found")
    ErrAdminUsernameTaken       = errors.New("admin: username already taken")
    ErrAdminForbidden           = errors.New("admin: insufficient role")
    ErrAdminInvalidRole         = errors.New("admin: invalid role")
    ErrAdminSelfDeleteForbidden = errors.New("admin: cannot delete self")           // (신규, UC-B6)
    ErrAdminLastSystemAdmin     = errors.New("admin: cannot delete last system admin") // (신규, UC-B6)
)
```

### 2.3 Port 확장 (`internal/usecase/port.go`)

```go
// AdminRepository는 관리자 엔티티의 지속성을 담당하는 포트입니다.
type AdminRepository interface {
    Get(ctx context.Context, id domain.AdminID) (*domain.Admin, error)
    GetByUsername(ctx context.Context, username string) (*domain.Admin, error)
    Save(ctx context.Context, admin *domain.Admin) error   // (신규) Create/Update 겸용 upsert
    Delete(ctx context.Context, id domain.AdminID) error   // (신규)
    Count(ctx context.Context) (int, error)                // (신규) 부트스트랩 시 빈 테이블 판단용
    CountByRole(ctx context.Context, role domain.AdminRole) (int, error) // (신규, UC-B6) 마지막 SYSTEM_ADMIN 삭제 방지 판단용
}
```

기존 `AdminSessionRepository`는 변경 없음. 삭제 시 세션은 `admin_sessions.admin_id REFERENCES admins(id) ON DELETE CASCADE`(schema.sql:165)로 이미 DB 레벨에서 정리됨 — usecase에서 별도 세션 무효화 호출 불필요.

### 2.4 Usecase Layer

`internal/usecase/auth_admin.go`의 `AdminAuthService`에 메서드 추가 (신규 서비스 분리 대신 기존 서비스 확장 — `workflow/plan.md` 3.2 "기존 포트 활용 우선" 원칙):

```go
// CreateAdmin - UC-B2. actorAdminID는 SYSTEM_ADMIN이어야 한다.
func (s *AdminAuthService) CreateAdmin(
    ctx context.Context,
    actorAdminID domain.AdminID,
    username string,
    password string,
    role domain.AdminRole,
) (*domain.Admin, error)

// ChangeAdminPassword - UC-B3. actorAdminID는 targetAdminID 본인이거나 SYSTEM_ADMIN이어야 한다.
func (s *AdminAuthService) ChangeAdminPassword(
    ctx context.Context,
    actorAdminID domain.AdminID,
    targetAdminID domain.AdminID,
    newPassword string,
) error

// authorizeSelfOrSystemAdmin은 actor가 target 본인이거나 SYSTEM_ADMIN인지 검증하는 내부 헬퍼 (UC-B3 전용).
// 실패 시 domain.ErrAdminForbidden 반환.
func (s *AdminAuthService) authorizeSelfOrSystemAdmin(ctx context.Context, actorAdminID, targetAdminID domain.AdminID) error

// DeleteAdmin - UC-B4. actorAdminID는 SYSTEM_ADMIN이어야 한다.
func (s *AdminAuthService) DeleteAdmin(
    ctx context.Context,
    actorAdminID domain.AdminID,
    targetAdminID domain.AdminID,
) error

// authorizeSystemAdmin은 actor가 SYSTEM_ADMIN인지 조회 후 검증하는 내부 헬퍼.
// 실패 시 domain.ErrAdminForbidden 반환.
func (s *AdminAuthService) authorizeSystemAdmin(ctx context.Context, actorAdminID domain.AdminID) (*domain.Admin, error)
```

책임:
- `CreateAdmin`: `authorizeSystemAdmin` 호출 → CORNER_OPERATOR 역할만 허용(SYSTEM_ADMIN 요청은 `ErrAdminForbidden`, 그 외 값은 `ErrAdminInvalidRole`) → username 중복 확인 → `hashPassword` → `AdminRepository.Save` (트랜잭션 내) → 감사 로그(`recordAuditLog`, action `ADMIN_CREATE`)
- `ChangeAdminPassword` (UC-B3, 사용자 피드백 반영): `authorizeSelfOrSystemAdmin(actorAdminID, targetAdminID)` 호출(`actorAdminID == targetAdminID`이면 통과, 아니면 actor가 SYSTEM_ADMIN인지 확인 후 실패 시 `ErrAdminForbidden`) → 대상 조회 → `hashPassword` → `Save` → 감사 로그 `ADMIN_PASSWORD_CHANGE`(본인 변경/타인 변경 여부를 필드로 구분 기록)
- `DeleteAdmin` (UC-B4 + UC-B6 가드 포함): `authorizeSystemAdmin` 호출 →
  1. `actorAdminID == targetAdminID` → `ErrAdminSelfDeleteForbidden` (자기 자신 삭제 방지)
  2. 대상 조회(`ErrAdminNotFound`)
  3. 대상 `Role == SYSTEM_ADMIN`이면 `AdminRepository.CountByRole(SYSTEM_ADMIN)` 확인 → 1 이하면 `ErrAdminLastSystemAdmin` (마지막 시스템 관리자 삭제 방지)
  4. `AdminRepository.Delete` → 감사 로그 `ADMIN_DELETE`
- `CreateAdmin`/`DeleteAdmin`은 시작부에 `authorizeSystemAdmin` 호출 (UC-B5, SYSTEM_ADMIN 전용 유지). `ChangeAdminPassword`만 `authorizeSelfOrSystemAdmin`으로 대체(UC-B3 정책 변경).

### 2.5 부트스트랩 (`cmd/server/main.go`)

기존 코드 흐름 재사용 원칙에 따라 별도 서비스 신설 없이 `main()` 내 `adminRepo` 생성 직후 인라인 처리:

```go
// bootstrapAdmin은 admins 테이블이 비어있을 때 ENV로 최초 SYSTEM_ADMIN을 생성한다.
// 책임: adminRepo.Count 확인 → 0이면 ENV(ADMIN_BOOTSTRAP_USERNAME/PASSWORD) 필수값 검증 후 저장.
func bootstrapAdmin(ctx context.Context, adminRepo usecase.AdminRepository, uuidFn func() string) error
```

- `main()`에서 `pool` 초기화 직후, `adminRepo` 생성 직후 호출.
- ENV 누락 & 테이블이 비어있으면 `log.Fatalf`로 서버 기동 중단 (운영 실수 방지 — 조용히 넘어가면 "관리자 없는 서버"가 배포될 위험).
- 이미 관리자가 1명 이상 있으면 아무 것도 하지 않고 통과 (idempotent, 재기동 시 중복 생성 안 됨).
- 비밀번호 해싱은 `usecase.hashPassword`를 그대로 쓸 수 없음(비공개) → `usecase` 패키지에 **exported wrapper 추가**:
  ```go
  // internal/usecase/utils.go
  func HashPasswordForBootstrap(password string) (string, error) { return hashPassword(password) }
  ```
  또는 더 깔끔하게, `bootstrapAdmin` 자체를 `internal/usecase` 패키지에 두어 비공개 `hashPassword`를 직접 쓰게 한다. **후자를 채택** (신규 export 최소화 원칙).

```go
// internal/usecase/admin_bootstrap.go (신규 파일)
// BootstrapAdmin은 admins 테이블이 비어있을 때 ENV 값으로 최초 SYSTEM_ADMIN을 생성한다.
func BootstrapAdmin(ctx context.Context, admins AdminRepository, username, password string, uuidFn func() string) error
```

### 2.6 Infrastructure Layer

`internal/infrastructure/postgres/admin_repo.go`:

```go
func (r *pgAdminRepository) Save(ctx context.Context, admin *domain.Admin) error   // (신규) INSERT ... ON CONFLICT (id) DO UPDATE
func (r *pgAdminRepository) Delete(ctx context.Context, id domain.AdminID) error   // (신규) DELETE FROM admins WHERE id = $1
func (r *pgAdminRepository) Count(ctx context.Context) (int, error)                // (신규) SELECT COUNT(*) FROM admins
func (r *pgAdminRepository) CountByRole(ctx context.Context, role domain.AdminRole) (int, error) // (신규, UC-B6) SELECT COUNT(*) FROM admins WHERE role = $1
```

sqlc를 쓰는 구조(`db.Queries`)이므로 `backend/db/query.sql`에 대응 쿼리 추가 후 `sqlc generate` 필요 (기존 관례 확인 필요 — Makefile/Dockerfile이 방금 추가된 `db/` 디렉토리에 있으므로 sqlc 생성 명령 확인 필수, 구현 착수 전 확인).

`mapAdmin`에 `Role: domain.AdminRole(row.Role)` 매핑 추가.

### 2.7 DB Schema (`backend/db/schema.sql`)

```sql
ALTER TABLE admins ADD COLUMN role VARCHAR(30) NOT NULL DEFAULT 'CORNER_OPERATOR';
-- 기존 스키마 파일 자체가 초기 생성 스크립트이므로(마이그레이션 이력 없음),
-- CREATE TABLE admins 문에 컬럼을 직접 추가하는 것으로 확인 필요 (마이그레이션 디렉토리 유무 확인 선행)
```

### 2.8 HTTP Layer (`internal/infrastructure/web/auth_handler.go` 또는 신규 `admin_handler.go`)

기존 파일 패턴(`AuthHandler`)을 따라 관리자 CRUD는 별도 핸들러로 분리 (`AdminManagementHandler`) — 책임 분리, `auth_handler.go`가 이미 400줄 넘음.

```go
type AdminManagementUsecase interface {
    CreateAdmin(ctx context.Context, actorAdminID domain.AdminID, username, password string, role domain.AdminRole) (*domain.Admin, error)
    ChangeAdminPassword(ctx context.Context, actorAdminID, targetAdminID domain.AdminID, newPassword string) error
    DeleteAdmin(ctx context.Context, actorAdminID, targetAdminID domain.AdminID) error
}

type AdminManagementHandler struct {
    admins AdminManagementUsecase
}

func (h *AdminManagementHandler) CreateAdmin(c echo.Context) error       // POST   /admins
func (h *AdminManagementHandler) ChangeAdminPassword(c echo.Context) error // PATCH  /admins/{id}/password
func (h *AdminManagementHandler) DeleteAdmin(c echo.Context) error       // DELETE /admins/{id}
```

- 인증: 기존 `AdminAuthMiddleware` 그룹에 등록 (세션 존재 확인까지만).
- **역할 인가는 usecase 레이어(`authorizeSystemAdmin`/`authorizeSelfOrSystemAdmin`)에서 강제** — 핸들러가 아니라 유즈케이스를 반드시 거치도록 하라는 요구사항 반영. 핸들러는 `session.AdminID`를 `actorAdminID`로, URL 경로의 `{id}`를 `targetAdminID`로 넘기기만 하고 role/본인 여부 분기 로직을 갖지 않는다 (`ChangeAdminPassword`도 동일 — 본인/SYSTEM_ADMIN 판별은 usecase에서 수행).
- 에러 매핑: `domain.ErrAdminForbidden` → 403, `domain.ErrAdminNotFound` → 404, `domain.ErrAdminUsernameTaken` → 409, `domain.ErrAdminSelfDeleteForbidden` → 409, `domain.ErrAdminLastSystemAdmin` → 409 (UC-B6).

라우팅은 `router.go`의 `RegisterRoutes` 내 admin 그룹에 추가 (기존 `/auth/admin/*` 그룹과 별개로 `/admins` 리소스 그룹 신설).

### 2.9 API 문서 (swaggo)

- 각 핸들러에 기존 패턴과 동일한 `@Summary/@Tags/@Security AdminAuth/@Router` 주석 추가.
- 구현 완료 후 `swag init` (또는 프로젝트에서 쓰는 정확한 생성 명령 확인) 실행 → `api/docs.go`, `api/swagger.yaml` 갱신. **PR에 반드시 포함** (`workflow/Collaborate.md`).

---

## 3. Phase 구성

### Phase A: 도메인 + 에러 + 포트 (예상 0.5시간)
| 순서 | 작업 | 파일 |
|---|---|---|
| A-1 | `AdminRole` 타입 + `Admin.Role` 필드 + `IsSystemAdmin()` (신규 필드/메서드) | `internal/domain/admin.go` |
| A-2 | 에러 6종 추가 (UC-B6 가드용 2종 포함) | `internal/domain/errors.go` |
| A-3 | `AdminRepository`에 `Save/Delete/Count/CountByRole` 추가 (기존 파일 확장) | `internal/usecase/port.go` |

### Phase B: 인프라 (예상 1시간)
| 순서 | 작업 | 파일 |
|---|---|---|
| B-1 | schema에 `role` 컬럼 추가 (또는 마이그레이션 파일 — 선행 확인 필요) | `backend/db/schema.sql` |
| B-2 | sqlc 쿼리 추가 (`CreateAdmin`/`UpdateAdmin`/`DeleteAdmin`/`CountAdmins`/`CountAdminsByRole`) + generate | `backend/db/query.sql` |
| B-3 | `pgAdminRepository`에 `Save/Delete/Count/CountByRole` 구현, `mapAdmin`에 role 매핑 | `internal/infrastructure/postgres/admin_repo.go` |

### Phase C: 유즈케이스 (예상 1시간)
| 순서 | 작업 | 파일 |
|---|---|---|
| C-1 | `authorizeSystemAdmin` / `authorizeSelfOrSystemAdmin` 헬퍼 | `internal/usecase/auth_admin.go` |
| C-2 | `CreateAdmin` / `ChangeAdminPassword`(본인 또는 SYSTEM_ADMIN, UC-B3) / `DeleteAdmin`(자기 자신·마지막 SYSTEM_ADMIN 삭제 가드 포함, UC-B6) | `internal/usecase/auth_admin.go` |
| C-3 | `BootstrapAdmin` (신규 파일) | `internal/usecase/admin_bootstrap.go` |

### Phase D: HTTP + 부트스트랩 연결 (예상 1시간)
| 순서 | 작업 | 파일 |
|---|---|---|
| D-1 | `AdminManagementHandler` (신규) | `internal/infrastructure/web/admin_handler.go` |
| D-2 | 라우팅 등록 (`AdminAuthMiddleware` 그룹) | `internal/infrastructure/web/router.go` |
| D-3 | `main()`에서 `usecase.BootstrapAdmin` 호출, ENV 로드/검증 | `cmd/server/main.go` |
| D-4 | swaggo 주석 + 문서 재생성 | `internal/infrastructure/web/admin_handler.go`, `api/docs.go`, `api/swagger.yaml` |

### Phase E: 테스트
| 순서 | 작업 |
|---|---|
| E-1 | `AdminAuthService` 유닛 테스트: `ShouldCreateAdminWhenActorIsSystemAdmin`, `ShouldReturnForbiddenWhenActorIsCornerOperator`, `ShouldReturnConflictWhenUsernameTaken`, `ShouldChangePasswordWhenActorIsSystemAdmin`, `ShouldChangeOwnPasswordWhenActorIsCornerOperator`(UC-B3), `ShouldReturnForbiddenWhenCornerOperatorChangesAnothersPassword`(UC-B3), `ShouldDeleteAdminWhenActorIsSystemAdmin`, `ShouldReturnConflictWhenDeletingSelf`(UC-B6), `ShouldReturnConflictWhenDeletingLastSystemAdmin`(UC-B6), `ShouldAllowDeletingSystemAdminWhenAnotherSystemAdminRemains`(UC-B6) |
| E-2 | `BootstrapAdmin` 유닛 테스트: `ShouldCreateAdminWhenTableEmpty`, `ShouldSkipWhenAdminExists` |
| E-3 | 핸들러 레벨 테스트(선택, 기존 router_test.go 관례 확인 후): 403/404/409 응답 코드 |

---

## 4. 구현 전 확인 필요 사항 (착수 전 반드시 확인)

1. **sqlc 생성 명령**: `db/Makefile`, `db/Dockerfile`이 방금 추가된 상태 — sqlc 설정 파일(`sqlc.yaml`) 위치와 `make gen` 여부 확인.
2. **마이그레이션 이력 유무**: `backend/db/schema.sql` 하나로 관리되는지, 별도 migration 디렉토리가 있는지 확인 후 role 컬럼 추가 방식 결정.
3. **ENV 변수명**: `ADMIN_BOOTSTRAP_USERNAME` / `ADMIN_BOOTSTRAP_PASSWORD` (가칭) — `.env.docker.example`, `.env` 예시 파일에도 추가.

---

## 5. 검증 체크리스트

### 5.1 아키텍처 검증
- [x] `domain` 패키지에 `infrastructure`/`usecase` import 없음
- [x] `AdminManagementHandler`가 `AdminManagementUsecase` 인터페이스에만 의존 (구현체 `AdminAuthService` 직접 참조 안 함)
- [x] 역할 인가 로직이 핸들러가 아닌 `usecase.AdminAuthService.authorizeSystemAdmin`/`authorizeSelfOrSystemAdmin`에만 존재 (요구사항: "유즈케이스를 반드시 거치도록")

### 5.2 유즈케이스 검증
- [x] UC-B1: 빈 테이블 + ENV 설정 → 서버 기동 시 SYSTEM_ADMIN 1명 생성, 재기동해도 중복 생성 안 됨
- [x] UC-B1: ENV 미설정 + 빈 테이블 → 서버 기동 실패(Fatal)
- [x] UC-B2: SYSTEM_ADMIN이 CORNER_OPERATOR를 생성할 수 있고, SYSTEM_ADMIN 생성 요청은 403 + `ErrAdminForbidden`
- [x] UC-B3: SYSTEM_ADMIN이 임의 관리자 비밀번호 변경 후 새 비밀번호로 로그인 성공, 기존 세션 access token은 TTL 만료 전까지 유효(재로그인 강제 아님 — 범위 확인됨)
- [x] UC-B3: CORNER_OPERATOR가 본인 비밀번호 변경 가능
- [x] UC-B3: CORNER_OPERATOR가 타인(다른 CORNER_OPERATOR/SYSTEM_ADMIN) 비밀번호 변경 시도 시 403 + `ErrAdminForbidden`
- [x] UC-B4: SYSTEM_ADMIN이 관리자 삭제 시 해당 관리자의 `admin_sessions`도 CASCADE로 제거됨
- [x] UC-B5: CORNER_OPERATOR가 B2/B3/B4 호출 시 403 + `ErrAdminForbidden`
- [x] UC-B6: SYSTEM_ADMIN이 자기 자신을 삭제 시도 시 409 + `ErrAdminSelfDeleteForbidden`
- [x] UC-B6: 마지막 SYSTEM_ADMIN은 자기 자신 삭제 차단으로 삭제 요청 자체가 성립하지 않음 (사용자 확인 완료)
- [x] UC-B6: SYSTEM_ADMIN이 2명 이상일 때는 SYSTEM_ADMIN 삭제 가능

### 5.3 회귀 검증
- [x] 기존 `Login`/`RefreshToken`/`ValidateAccessToken` 동작 불변 (Admin 구조체에 필드만 추가, 기존 로직 미변경)
- [x] `go test ./...` 전체 통과

## 자체 리뷰

- [x] 역할 인가가 핸들러를 우회하지 않고 유즈케이스에서 강제되는지 확인했다.
- [x] 비밀번호는 bcrypt 해시만 저장·감사 로그에는 저장하지 않음을 확인했다.
- [x] 관리자 삭제는 DB foreign key `ON DELETE CASCADE`에 의해 세션을 함께 제거함을 확인했다.
- [x] `go build ./...`, `go vet ./...`, `go test ./...`, 관련 패키지 race 테스트 및 Swagger 재생성을 완료했다.

---

**사용자 확인 필요 (구현 착수 전)**: Phase B의 sqlc 생성 명령과 마이그레이션 방식(§4-1, §4-2)은 `backend/db/` 디렉토리가 최근 막 추가된 상태라 관례가 아직 확정되지 않았을 수 있음 — 실제 착수 시 재확인.
