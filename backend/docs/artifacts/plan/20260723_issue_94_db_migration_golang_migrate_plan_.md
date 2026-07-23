# GitHub Issue #94 — 데이터베이스 마이그레이션 도구 도입 (golang-migrate) 구현 계획

> 이슈: https://github.com/lsjtop10/cornermon/issues/94

## 배경 / 문제 정의

현재 DB 스키마는 `backend/db/schema.sql` 단일 파일로 관리되고, `backend/db/Dockerfile`이 이 파일을
`/docker-entrypoint-initdb.d/init.sql`로 복사해 컨테이너 최초 기동(빈 볼륨) 시 1회만 적용한다.
점진적 스키마 변경(`ALTER TABLE`), 롤백, 버전 추적 수단이 없다.

### 코드베이스 조사 결과

- `backend/db/migrations/`이 이미 존재하지만 `20260721_add_corner_deleted_at.sql` 파일 하나뿐이고,
  golang-migrate가 요구하는 순번 접두사(`NNNNNN_name.up/down.sql`) 규칙을 따르지 않는 임시 파일이다.
- `backend/sqlc.yaml`은 여전히 `schema: "db/schema.sql"` 단일 파일을 가리킨다.
- `.github/` 워크플로우 자체가 저장소에 없어 CI/CD 마이그레이션 파이프라인을 얹을 대상이 없다.
- **사용자 확인: 현재 운영 DB가 존재하지 않는 개발 단계**이므로, 베이스라인 마이그레이션을
  "이미 적용된 것으로 마킹"할 필요 없이 그냥 처음부터 다시 적용하면 된다. 데이터 유실 리스크 없음.
- 사용자와의 논의 결과, 데이터 백필처럼 도메인 로직이 필요한 작업은 이번 이슈 범위에 포함하지
  않는다 — goose의 Go 마이그레이션 기능은 마이그레이션 파일이 앱과 같은 바이너리로 컴파일되어
  도메인 모델(`internal/domain`)이 나중에 바뀌면 옛 마이그레이션의 컴파일이 깨질 수 있다는 문제가
  있어 채택하지 않는다. **golang-migrate(순수 SQL, 도메인 결합 없음)를 채택**하고, 데이터 백필이
  필요해지면 `cmd/cleanup-corners`와 동일한 패턴으로 `cmd/` 아래 별도 원샷 배치 커맨드로 분리한다.
- CI/CD 파이프라인 구축은 `.github/` 자체가 없어 스코프가 커지므로 **이번 이슈에서 제외**하고
  별도 이슈로 분리 제안한다. 이번 범위는 "도구 도입 + 로컬/기동 시 자동 적용"까지로 좁힌다.

## 1. 유즈케이스 우선 정의

| 우선순위 | 유즈케이스 | 설명 | 용도 |
| --- | --- | --- | --- |
| **P0** | UC-1: 서버 기동 시 미적용 마이그레이션 자동 실행 | `cmd/server/main.go`가 DB 연결 직후, 리포지토리 생성 이전에 `db/migrations`의 미적용 파일을 순서대로 적용 | **프로덕션/로컬 공통 핵심 경로** |
| **P0** | UC-2: `schema.sql` → 버전별 마이그레이션 파일 전환 | 기존 스키마 전체를 `20260723100000_init_schema.up/down.sql`로 이관, 기존 임시 마이그레이션 흡수 | **베이스라인 확립** |
| P1 | UC-3: sqlc가 마이그레이션 디렉토리에서 스키마 추론 | `sqlc.yaml`의 `schema` 경로를 `db/migrations`로 변경 후 `sqlc generate` 결과가 기존과 동일 | 코드 생성 정합성 |
| P1 | UC-4: 로컬 개발 편의 CLI | `make migrate-up`/`migrate-down`, `go run ./cmd/migrate-tool force <v>`로 로컬에서 수동 조작 | 개발 편의(선택적 수동 개입용) |
| P2 (범위 외) | UC-5: CI/CD 마이그레이션 파이프라인 | `.github/` 부재로 이번 이슈에서 제외, 별도 이슈로 분리 제안 | 후속 작업 |

## 2. 객체 중심 설계

### 신규: 마이그레이션 소스 임베드 (`backend/db/migrations.go`, package `db`)

```go
package db

import "embed"

//go:embed migrations/*.sql
var MigrationsFS embed.FS
```

### 신규: 마이그레이션 실행 헬퍼 (`backend/db/migrate.go`, package `db`)

```go
package db

// 책임: embed된 SQL 마이그레이션을 iofs 소스로 읽어 pgx5 드라이버로 DB에 적용.
// migrate.ErrNoChange(적용할 변경 없음)는 에러로 취급하지 않는다.
func NewMigrate(databaseURL string) (*migrate.Migrate, error)
func RunMigrations(ctx context.Context, databaseURL string) error
```

`NewMigrate`는 `RunMigrations`와 `cmd/migrate-tool`이 공유하는 저수준 생성자로 분리했다
(구현 중 CLI가 `Up`/`Steps(-1)`/`Force`를 모두 써야 해서 `RunMigrations` 내부에 있던 로직을
끌어올림).

### 변경: `cmd/server/main.go`

```go
// pool.Ping(dbctx) 성공 직후, adminRepo 등 리포지토리 생성 이전에 삽입
if err := db.RunMigrations(dbctx, dbURL); err != nil {
    cancel()
    log.Fatalf("Unable to apply database migrations: %v\n", err)
}
```

기존 `log.Fatalf` fail-fast 컨벤션(예: pool 연결 실패 시 처리)을 그대로 따른다 — 마이그레이션
실패 시에도 서버가 절반만 기동된 상태로 트래픽을 받으면 안 된다.

### 신규: 로컬 편의 CLI (`backend/cmd/migrate-tool/main.go`)

```go
// 책임: os.Args[1](up|down|force)에 따라 db.NewMigrate로 얻은 *migrate.Migrate를 조작하는 얇은 CLI.
// cmd/cleanup-corners와 동일하게 "go run ./cmd/migrate-tool <subcommand>" 형태로 사용.
func main()
```

golang-migrate 공식 CLI 바이너리를 별도로 설치/래핑하지 않고, 이미 앱에 추가하는
`database/pgx/v5` 드라이버 의존성을 재사용하는 얇은 자체 커맨드로 대체한다 — 이 저장소의
`cmd/cleanup-corners` 관례와 일치하고 별도 빌드 태그 관리가 필요 없다.

## 3. 아키텍처 원칙 명시

### 3.1 계층 배치

- 마이그레이션 실행 로직은 `backend/db/`(sqlc 쿼리 소스와 동급 위치)와 `cmd/` 레벨에만 존재한다.
  `internal/domain`, `internal/usecase`는 전혀 건드리지 않는다.
- `cmd/server/main.go`는 여전히 의존성 조립(wiring)만 담당하는 원칙을 유지 — 마이그레이션 실행도
  "기동 절차의 한 단계"로만 호출하고, 로직 자체는 `db.RunMigrations`에 캡슐화한다.

### 3.2 기존 컨벤션 재사용

- 원샷 배치 커맨드는 새 개념이 아니라 이미 `cmd/cleanup-corners`로 확립된 패턴을 그대로 따른다.
- fail-fast 로깅(`log.Fatalf`)도 `main.go`의 기존 DB 연결 실패 처리와 동일한 스타일을 따른다.

### 3.3 의존성 규칙 검증

- [x] `internal/domain`, `internal/usecase`에 golang-migrate import 없음
- [x] `db.RunMigrations`의 첫 인자는 `context.Context`
- [x] `internal/infrastructure/postgres`(sqlc 리포지토리)는 마이그레이션 실행 로직을 모름 —
      완전히 별개 경로

## 4. 구현 단계

### Phase A: 베이스라인 마이그레이션 정비 — 완료 (커밋 `6ee50d0`)

| 순서 | 작업 | 파일 |
| --- | --- | --- |
| A-1 | 기존 `schema.sql` 전체 내용 + `20260721_add_corner_deleted_at.sql`(soft-delete 컬럼/인덱스)을 흡수해 `20260723100000_init_schema.up.sql` 작성 | `db/migrations/20260723100000_init_schema.up.sql` |
| A-2 | 전체 테이블을 참조 관계 역순으로 DROP하는 down 마이그레이션 작성 | `db/migrations/20260723100000_init_schema.down.sql` |
| A-3 | `schema.sql`, `20260721_add_corner_deleted_at.sql` 삭제 | `db/schema.sql`, `db/migrations/20260721_add_corner_deleted_at.sql` |

검증: 임시 postgres:18 컨테이너에서 up → down → up 왕복 적용 성공.

### Phase B: golang-migrate 의존성 및 임베드 소스 — 완료 (커밋 `9d124b2`)

| 순서 | 작업 | 파일 |
| --- | --- | --- |
| B-1 | `go get github.com/golang-migrate/migrate/v4` (iofs 소스 + pgx/v5 드라이버) | `go.mod`, `go.sum` |
| B-2 | `//go:embed migrations/*.sql`로 `MigrationsFS embed.FS` 노출 | `db/migrations.go` |
| B-3 | `RunMigrations(ctx, databaseURL string) error` 구현 | `db/migrate.go` |
| B-4 | **검증 완료**: `database/pgx/v5` 드라이버의 `Open()`은 URL scheme만 `postgres`로 바꿔 `sql.Open("pgx/v5", ...)`를 호출하므로, 기존 `postgres://...timezone=UTC` DSN의 scheme만 `pgx5`로 치환하면 그대로 재사용 가능함을 소스 확인(`database/pgx/v5/pgx.go:139-150`) | (구현 단계 확인) |

부수 발견: `go mod tidy` 과정에서 기존에 코드베이스 어디서도 쓰이지 않던
`github.com/stretchr/testify`가 함께 제거됨(이 작업과 무관한 기존 dead dependency 정리, 커밋
메시지에 명시).

### Phase C: 서버 기동 시 자동 적용 — 완료 (커밋 `e38ca11`)

| 순서 | 작업 | 파일 |
| --- | --- | --- |
| C-1 | `pool.Ping(dbctx)` 성공 직후, `adminRepo` 등 리포지토리 생성 이전에 `db.RunMigrations` 호출, 실패 시 `log.Fatalf` | `cmd/server/main.go` |

검증: 임시 postgres:18 컨테이너(빈 볼륨)에 실제로 `go run ./cmd/server/main.go` 기동 →
15개 테이블 생성, `schema_migrations.version=1, dirty=false` 확인. 재기동 시 `ErrNoChange`로
정상 통과하는 것도 확인.

### Phase D: sqlc / Dockerfile 정비 — 완료 (커밋 `f63c028`)

| 순서 | 작업 | 파일 |
| --- | --- | --- |
| D-1 | `sqlc.yaml`의 `schema: "db/schema.sql"` → `schema: "db/migrations"` | `sqlc.yaml` |
| D-2 | `COPY ./schema.sql /docker-entrypoint-initdb.d/init.sql` 제거 | `db/Dockerfile` |
| D-3 | `sqlc generate` 재실행 | `internal/infrastructure/postgres/db/*` |

검증: `sqlc generate` 실행 결과가 변경 전 생성물과 `diff -rq` 기준 완전히 동일(0 diff) —
sqlc가 up/down 쌍을 올바르게 처리함을 확인. `docker build`로 수정된 `db/Dockerfile` 빌드 성공.

### Phase E: 로컬 개발 편의 CLI + Makefile — 완료 (커밋 `471fa7b`)

| 순서 | 작업 | 파일 |
| --- | --- | --- |
| E-1 | `up`/`down`/`force` 서브커맨드 CLI | `cmd/migrate-tool/main.go` |
| E-2 | `migrate-up`/`migrate-down` 타겟 추가 | `Makefile` |

검증: 임시 컨테이너에서 `make migrate-up`(15개 테이블 생성) → `make migrate-down`(`schema_migrations`만
남기고 전부 제거) → `make migrate-up`(재생성) 왕복 확인.

### Phase F: 문서화 — 완료 (커밋 `e9f5c43`)

| 순서 | 작업 | 파일 |
| --- | --- | --- |
| F-1 | "9. DB 마이그레이션" 섹션 추가 | `docs/DEVELOPER_GUIDE.md` |

## 범위 외 (Out of Scope)

- CI/CD 마이그레이션 파이프라인 구축 — `.github/` 워크플로우 자체가 없어 별도 이슈로 분리 제안.
- 운영 DB 베이스라인 마킹(`migrate force`) — 현재 운영 DB가 존재하지 않아(사용자 확인) 불필요.
- 도메인 로직이 필요한 데이터 백필 마이그레이션 — 필요 시 `cmd/` 아래 별도 원샷 배치로 처리 (이번
  이슈에서 도구/컨벤션만 확립하고 실제 백필 커맨드는 만들지 않음).

## 5. 검증 체크리스트

### 5.1 아키텍처 검증

- [x] `internal/domain`, `internal/usecase`에 golang-migrate 관련 import 없음
- [x] `db.RunMigrations` 등 신규 함수의 첫 인자는 `context.Context`
- [x] `internal/infrastructure/postgres`(sqlc 리포지토리 계층) 변경 없음

### 5.2 유즈케이스 검증

- [x] UC-1: 빈 볼륨 컨테이너에서 서버 기동 시 마이그레이션이 자동 적용되고 정상 기동됨
- [x] UC-1: 서버를 재기동해도(이미 최신 상태) 에러 없이 통과(`ErrNoChange` 무시 확인)
- [x] UC-2: `db/migrations/20260723100000_init_schema.up.sql` 적용 결과가 기존 `schema.sql`과 동일한
      15개 테이블/인덱스를 생성함을 확인
- [x] UC-3: `sqlc generate` 후 `internal/infrastructure/postgres/db` 생성물 diff 없음
- [x] UC-4: `make migrate-up`/`make migrate-down` 왕복 동작 확인

### 5.3 자동화 테스트

- [x] `go test ./...` 전체 통과
- [x] `gofmt -l .` 출력 없음(포맷 클린), `go vet ./...` 클린

### 5.4 실환경 확인

- [x] 임시 postgres 컨테이너(빈 볼륨) → `go run ./cmd/server/main.go` 정상 기동 확인
      (기존 공유 dev DB 컨테이너 `cornermon-db`는 다른 세션에 영향 줄 수 있어 건드리지 않고,
      별도 임시 컨테이너로 검증함)
- [x] `make migrate-down` 후 `make migrate-up`으로 롤백/재적용 왕복 확인
