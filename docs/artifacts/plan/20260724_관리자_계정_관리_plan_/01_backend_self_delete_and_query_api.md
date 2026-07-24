# 01. 백엔드 — 운영 관리자 본인 탈퇴 + 관리자 조회 API

## 1. 유즈케이스

| 우선순위 | 유즈케이스 | 설명 | 용도 |
|---|---|---|---|
| **P0** | UC-1: 운영 관리자 본인 탈퇴 | `CORNER_OPERATOR`가 `DELETE /admins/{id}`로 자기 자신을 삭제할 수 있다. `SYSTEM_ADMIN`의 본인 삭제는 계속 금지(기존 정책 유지). | **프로덕션 핵심 로직** |
| **P0** | UC-2: 관리자 본인 정보 조회 | `GET /admins/me` — 세션의 관리자 본인 id/username/role을 반환한다. 프론트가 자기 자신을 대상으로 한 API(비밀번호 변경, 탈퇴)를 호출하려면 실제 id가 필요하다. | **프로덕션 핵심 로직** |
| **P0** | UC-3: 관리자 목록 조회 | `GET /admins` — `SYSTEM_ADMIN`만 호출 가능, 전체 관리자 목록(id/username/role)을 반환한다. 관리자 관리 화면의 목록/삭제 대상 선택에 사용. | **프로덕션 핵심 로직** |

기존에 이미 구현되어 변경하지 않는 것: `CreateAdmin`(POST /admins), `ChangeAdminPassword`(PATCH
/admins/{id}/password), `DeleteAdmin`의 SYSTEM_ADMIN→타 관리자 삭제 경로, 마지막 SYSTEM_ADMIN
보호(`ErrAdminLastSystemAdmin`).

## 2. 아키텍처 원칙 검증

- Domain은 역할 판별 predicate만 추가(순수 Go, 외부 의존성 없음).
- 새 포트를 만들지 않고 기존 `AdminRepository`(`internal/usecase/port.go`)에 `List` 메서드만 확장한다.
- `AdminManagementHandler`/`AdminManagementUsecase` 기존 구조를 그대로 확장한다(새 핸들러 struct
  생성하지 않음).
- 읽기 전용 조회(UC-2, UC-3)는 비즈니스 규칙이 거의 없는 단순 조회이지만, UC-3에는 "SYSTEM_ADMIN만"이라는
  인가 판단이 있으므로 `DEVELOPER_GUIDE.md` CQRS 가이드의 "인가 정책이 개입하면 유즈케이스 레이어 유지"
  원칙에 따라 기존 `AdminAuthService`(이미 있는 서비스) 메서드로 구현한다 — 신규 Read-only Port를
  따로 만들지 않는다.

## 3. 계층별 설계

### 3.1 Domain (`internal/domain/admin.go`)

```go
// 책임: 역할 predicate 추가 (기존 IsSystemAdmin과 대칭)
func (a *Admin) IsCornerOperator() bool { return a.role == AdminRoleCornerOperator }
```

도메인 에러/상태 전이는 추가하지 않는다. "본인 탈퇴 가능 여부"는 role 두 가지 predicate의 조합으로
usecase가 판단한다(기존에도 `IsSystemAdmin()`을 usecase에서 조합해 정책을 만드는 방식과 동일).

### 3.2 Usecase (`internal/usecase/auth_admin.go`)

```go
// 책임: 본인 탈퇴(CORNER_OPERATOR) 또는 SYSTEM_ADMIN의 타 관리자 삭제 허용.
// SYSTEM_ADMIN의 본인 삭제는 기존과 동일하게 금지.
func (s *AdminAuthService) DeleteAdmin(
    ctx context.Context,
    actorAdminID domain.AdminID,
    targetAdminID domain.AdminID,
) error

// 책임: 세션 소유자 본인 조회. 별도 역할 인가 불필요(누구나 자기 자신은 조회 가능).
func (s *AdminAuthService) GetAdmin(
    ctx context.Context,
    actorAdminID domain.AdminID,
) (*domain.Admin, error)

// 책임: 전체 관리자 목록 조회. SYSTEM_ADMIN 전용(authorizeSystemAdmin 재사용).
func (s *AdminAuthService) ListAdmins(
    ctx context.Context,
    actorAdminID domain.AdminID,
) ([]*domain.Admin, error)
```

`DeleteAdmin`의 인가 분기 의사코드(상세 구현은 개발자 재량):

```
actor := admins.Get(actorAdminID)  // nil이면 ErrAdminNotFound
isSelf := actorAdminID == targetAdminID
switch {
case isSelf && actor.IsCornerOperator():
    // 허용 — 별도 SYSTEM_ADMIN 권한 불필요
case isSelf: // actor는 SYSTEM_ADMIN
    return ErrAdminSelfDeleteForbidden  // 기존 동작 유지
default:
    if !actor.IsSystemAdmin() { return ErrAdminForbidden }
}
target := isSelf ? actor : admins.Get(targetAdminID)  // nil이면 ErrAdminNotFound
// 이하 기존 로직 그대로: target이 SYSTEM_ADMIN이면 CountByRole로 마지막 1인 보호,
// tx 안에서 Delete, 커밋 후 recordAuditLog(ActionAdminDelete, metadata: {"self": isSelf})
```

**주의**: 현재 코드는 `authorizeSystemAdmin(ctx, actorAdminID)`을 함수 진입부에서 즉시 호출해 actor를
가져온다. 이 헬퍼를 그대로 쓰면 CORNER_OPERATOR가 진입 시점에 곧바로 `ErrAdminForbidden`으로 막히므로,
본인 탈퇴 분기를 먼저 판별할 수 있도록 actor 조회와 SYSTEM_ADMIN 인가 체크를 분리해야 한다
(`authorizeSystemAdmin` 헬퍼는 `isSelf`가 아닐 때만 사용).

`GetAdmin`/`ListAdmins`는 기존 `recordAuditLog` 패턴을 따르지 않는다 — 코드베이스 관례상 단순 조회
(`ListSessions`, `ListCamps` 등)는 감사 로그를 남기지 않는다.

### 3.3 Infrastructure — Postgres (`internal/infrastructure/postgres/admin_repo.go`)

```go
// 책임: 전체 관리자 목록 조회(생성 시각 컬럼이 없으므로 username 오름차순 정렬).
func (r *pgAdminRepository) List(ctx context.Context) ([]*domain.Admin, error)
```

`db/query.sql`에 추가:

```sql
-- name: ListAdmins :many
SELECT * FROM admins ORDER BY username;
```

추가 후 `sqlc generate` 실행 → `internal/infrastructure/postgres/db` 재생성 산출물 갱신.
스키마 변경 없음(마이그레이션 불필요) — `admins` 테이블은 이미 존재.

### 3.4 Port (`internal/usecase/port.go`)

```go
type AdminRepository interface {
    Get(ctx context.Context, id domain.AdminID) (*domain.Admin, error)
    GetByUsername(ctx context.Context, username string) (*domain.Admin, error)
    Save(ctx context.Context, admin *domain.Admin) error
    Delete(ctx context.Context, id domain.AdminID) error
    Count(ctx context.Context) (int, error)
    CountByRole(ctx context.Context, role domain.AdminRole) (int, error)
    List(ctx context.Context) ([]*domain.Admin, error) // 신규
}
```

### 3.5 Web (`internal/infrastructure/web/admin_management_handler.go`)

```go
type AdminManagementUsecase interface {
    CreateAdmin(...) (*domain.Admin, error)          // 기존
    ChangeAdminPassword(...) error                    // 기존
    DeleteAdmin(...) error                             // 기존 (내부 정책만 변경)
    GetAdmin(ctx context.Context, actorAdminID domain.AdminID) (*domain.Admin, error)       // 신규
    ListAdmins(ctx context.Context, actorAdminID domain.AdminID) ([]*domain.Admin, error)    // 신규
}

// @Summary 내 관리자 정보 조회
// @Router  /admins/me [get]
func (h *AdminManagementHandler) GetMyAdmin(c echo.Context) error

// @Summary 관리자 목록 조회 (SYSTEM_ADMIN 전용)
// @Router  /admins [get]
func (h *AdminManagementHandler) ListAdmins(c echo.Context) error
```

응답 DTO는 기존 `AdminResponse`를 재사용(`GetMyAdmin`은 단일, `ListAdmins`는 `[]AdminResponse`) —
필드가 이미 `id/username/role`로 API 계약과 1:1 대응한다. 에러 매핑은 기존 로컬 헬퍼
`adminManagementError(err)`를 그대로 재사용한다(이 핸들러는 중앙 `mapDomainError`가 아니라 자체
스위치문으로 `ErrAdmin*`를 처리하는 기존 관례 — `error_handler_middleware.go`에는 `ErrAdmin*` 매핑이
없음을 확인함).

`DeleteAdmin` 핸들러의 swag 설명 주석 갱신 필요:
> "SYSTEM_ADMIN은 다른 관리자를 삭제할 수 있습니다. CORNER_OPERATOR는 본인 계정만 탈퇴할 수 있습니다.
> SYSTEM_ADMIN은 자기 자신을 삭제할 수 없습니다(마지막 시스템 관리자 보호)."

### 3.6 Router (`internal/infrastructure/web/router.go`)

```go
admin.GET("/admins/me", h.AdminManagement.GetMyAdmin)
admin.GET("/admins", h.AdminManagement.ListAdmins)
```
(`AdminAuthMiddleware` 그룹 안에 기존 `/admins` 라우트들과 나란히 추가 — 경로 충돌 없음: `POST/GET
/admins`, `GET /admins/me` vs `PATCH/DELETE /admins/:id`.)

## 4. 구현 단계

| 순서 | 작업 | 파일 | 예상 소요 |
|---|---|---|---|
| A-1 | `Admin.IsCornerOperator()` 추가 | `internal/domain/admin.go` (기존 파일 확장) | 10분 |
| B-1 | `DeleteAdmin` 인가 로직 분기 수정 | `internal/usecase/auth_admin.go` (기존 파일 확장) | 40분 |
| B-2 | `GetAdmin`, `ListAdmins` usecase 메서드 추가 | `internal/usecase/auth_admin.go` | 30분 |
| C-1 | `ListAdmins` sqlc 쿼리 추가 + `sqlc generate` | `backend/db/query.sql` (신규 쿼리) | 15분 |
| C-2 | `AdminRepository.List` 포트 확장 + pg 구현체 | `internal/usecase/port.go`, `internal/infrastructure/postgres/admin_repo.go` | 20분 |
| C-3 | `MockAdminRepository.List` 테스트 더블 추가 | `internal/usecase/mock_test.go` (기존 파일 확장) | 10분 |
| D-1 | `GetMyAdmin`/`ListAdmins` 핸들러 + swag 주석 | `internal/infrastructure/web/admin_management_handler.go` | 40분 |
| D-2 | 라우트 등록 | `internal/infrastructure/web/router.go` | 10분 |
| D-3 | `make swag` 실행 → `api/swagger.yaml`/`swagger.json`/`docs.go` 갱신 | (자동 생성, `workflow/Collaborate.md` 준수) | 5분 |
| E-1 | usecase 테스트: 본인 탈퇴 허용/SYSTEM_ADMIN 본인삭제 금지 유지/타인 삭제 여전히 SYSTEM_ADMIN 전용/GetAdmin/ListAdmins | `internal/usecase/admin_management_test.go` (기존 파일 확장) | 40분 |
| E-2 | 핸들러 테스트: 신규 두 엔드포인트 에러 매핑 | `internal/infrastructure/web/admin_management_handler_test.go` (기존 파일 확장) | 20분 |

## 5. 검증 체크리스트

### 5.1 아키텍처 검증
- [ ] `domain` 패키지에서 `infrastructure` import 없음
- [ ] `AdminManagementHandler`는 `AdminManagementUsecase` 인터페이스에만 의존
- [ ] 새 리포지토리 메서드는 최소 필요분(`List`)만 추가, 범용 `Update`류 추가하지 않음

### 5.2 유즈케이스 검증 (자동 테스트)
- [ ] `ShouldAllowCornerOperatorToDeleteSelf`
- [ ] `ShouldPreventSystemAdminFromDeletingSelf` (기존 테스트명 유지 또는 위 테스트로 흡수)
- [ ] `ShouldReturnForbiddenWhenCornerOperatorDeletesAnotherAdmin` (본인 탈퇴가 아닌 경로는 여전히 SYSTEM_ADMIN 전용임을 확인)
- [ ] `ShouldReturnSelfAdminWhenGetAdminCalled`
- [ ] `ShouldListAllAdminsWhenActorIsSystemAdmin`
- [ ] `ShouldReturnForbiddenWhenCornerOperatorListsAdmins`
- [ ] 핸들러 레벨: `GET /admins/me`, `GET /admins` 에러 매핑(403/401) 테스트
- [ ] `go test ./...` 전체 통과
- [ ] `gofmt -w . && go vet ./...` 클린

### 5.3 수동 검증
- [ ] 로컬 서버 기동 후 `curl`로 `GET /admins/me`, `GET /admins`, `DELETE /admins/{자기id}`(CORNER_OPERATOR
      세션) 실제 호출해 응답 확인
- [ ] 마지막 SYSTEM_ADMIN 보호가 여전히 동작하는지 확인(회귀 없음)

> 샌드박스에 이미 다른 워크트리가 쓰고 있을 수 있는 고정 이름 컨테이너(`cornermon-db`)가 있어
> 공유 상태를 건드리지 않기 위해 이번 세션에서는 **위 두 항목을 실행하지 않았다** — 자동 테스트
> (§5.2)만으로 검증된 상태다. 병합 전 사용자가 직접 서버를 띄워 확인 필요.
