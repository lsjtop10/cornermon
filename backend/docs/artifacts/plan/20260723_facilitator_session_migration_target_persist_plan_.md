# 진행자 세션 트랙 마이그레이션 타겟 영속화 (Issue #199)

## 배경 / 원인 분석

관리자가 트랙을 교체(`TrackService.ReplaceTrack`, `internal/usecase/track.go:304`)하면
기존 트랙에 로그인 중인 활성 세션들에 `sess.SetMigrationTarget(newTrackID)`를 호출해 새 트랙 ID를
기록하고 `sessions.Save(ctx, sess)`로 저장한다. 진행자 클라이언트는 `track_replaced` SSE를 받으면
`POST /tracks/{id}/migrate-session`를 호출하고, 이 핸들러는 `FacilitatorAuthService.MigrateSession`에서
DB에서 다시 읽어온 옛 세션의 `MigrationTargetTrackID()`가 설정되어 있는지로 마이그레이션 가능 여부를
판단한다(`internal/usecase/auth_facilitator.go:219`).

문제는 `facilitator_sessions` 테이블(`db/migrations/20260723100000_init_schema.up.sql:146`)에
`migration_target_track_id` 컬럼이 없다는 것이다. 그 결과:

- `pgFacilitatorSessionRepository.Save`(`internal/infrastructure/postgres/facilitator_session_repo.go:95`)가
  이 필드를 DB에 쓰지 않는다 — `SaveFacilitatorSessionParams`/`SaveFacilitatorSession` 쿼리
  자체에 컬럼이 없다.
- `mapFacilitatorSession`(같은 파일 30번째 줄)도 이 필드를 복원하지 않는다.

즉 `ReplaceTrack` 트랜잭션 내에서는 메모리상 도메인 객체에 값이 설정되지만, 커밋 직후 DB에는
반영되지 않고, 다음에 세션을 다시 읽는 순간(`MigrateSession` 호출 시) 항상 `None`으로 복원된다.
그래서 진행자는 "no migration target for this session" 에러를 받고 기존 트랙 로그인 상태가
그대로 유지된다. `track_test.go:222`의 `TestReplaceTrackShoudMigrateSessionAndBroadcastAfterSuccess`는
in-memory mock repository(`MockFacilitatorSessionRepository`)를 사용하므로 도메인 객체를 그대로
보관해 이 버그를 잡지 못했다.

## 유즈케이스

| 우선순위 | 유즈케이스 | 설명 | 용도 |
|---|---|---|---|
| **P0** | UC-1: 마이그레이션 타겟 영속화 | 트랙 교체 시 세션에 기록된 `migrationTargetTrackID`가 DB에 저장되고, 재조회 시 복원된다 | **프로덕션 핵심 버그 수정** |
| **P0** | UC-2: 마이그레이션 세션 발급 | `POST /tracks/{id}/migrate-session` 호출 시 DB에서 다시 읽은 세션 기준으로 정상적으로 새 트랙 세션이 발급된다 | **프로덕션 핵심 로직** |

## 설계

### 1. DB 마이그레이션 (신규)

`db/migrations/20260723110000_add_facilitator_session_migration_target.up.sql`:

```sql
ALTER TABLE facilitator_sessions
    ADD COLUMN migration_target_track_id VARCHAR(50) REFERENCES tracks(id) ON DELETE SET NULL;
COMMENT ON COLUMN facilitator_sessions.migration_target_track_id IS '트랙 교체로 인해 마이그레이션해야 할 대상 트랙 ID (없으면 마이그레이션 불필요)';
```

`down.sql`:

```sql
ALTER TABLE facilitator_sessions DROP COLUMN IF EXISTS migration_target_track_id;
```

`ON DELETE SET NULL`: 트랙 row가 실제로 삭제되는 경우(현재는 `Track.Delete()`로 상태만
바꾸는 소프트 삭제라 발생하지 않지만, FK 안전장치로 둠)에도 세션 조회 자체가 깨지지 않게 한다.

### 2. sqlc 쿼리 (`db/query.sql`) 갱신

```sql
-- name: SaveFacilitatorSession :exec
INSERT INTO facilitator_sessions (id, track_id, token_hash, created_at, revoked_at, migration_target_track_id)
VALUES ($1, $2, $3, $4, $5, $6)
ON CONFLICT (id) DO UPDATE SET
    revoked_at = EXCLUDED.revoked_at,
    migration_target_track_id = EXCLUDED.migration_target_track_id;
```

`GetFacilitatorSession*`/`ListActiveFacilitatorSessions*`는 `SELECT *`라 컬럼 추가만으로
자동 반영됨. 이후 `sqlc generate` 실행해 `internal/infrastructure/postgres/db` 하위 생성물 갱신.

### 3. 리포지토리 매핑 (`internal/infrastructure/postgres/facilitator_session_repo.go`)

기존 `RevokedAt` 처리와 동일한 패턴(뱃지 리포지토리의 `AssignedGroupID` 처리와도 동일한 패턴)을
따른다.

```go
func mapFacilitatorSession(row db.FacilitatorSession) *domain.FacilitatorSession {
    s := domain.NewFacilitatorSessionFromProps(...) // 기존과 동일

    // 기존 RevokedAt 처리 유지

    if row.MigrationTargetTrackID.Valid {
        s.SetMigrationTargetTrackID(domain.Some(domain.TrackID(row.MigrationTargetTrackID.String)))
    } else {
        s.SetMigrationTargetTrackID(domain.None[domain.TrackID]())
    }
    return s
}
```

`Save`에서 `params.MigrationTargetTrackID`를 `session.MigrationTargetTrackID().Value()` 기준으로
`pgtype.Text{String: string(val), Valid: true}` / zero-value로 채운다.

### 4. 도메인 (`internal/domain/facilitator_session.go`)

DB 복원 전용 raw setter를 `SetRevokedAt`과 동일한 컨벤션으로 추가한다(`SetMigrationTarget`은
비즈니스 전이 메서드로 그대로 유지 — 트랙 교체 시 항상 Some만 설정하면 되므로 시그니처 변경 없음):

```go
// SetMigrationTargetTrackID는 리포지토리가 DB row로부터 상태를 복원할 때만 사용합니다.
func (s *FacilitatorSession) SetMigrationTargetTrackID(t Optional[TrackID]) {
    s.migrationTargetTrackID = t
}
```

## 구현 단계

| 순서 | 작업 | 파일 |
|---|---|---|
| 1 | 마이그레이션 up/down 파일 작성 | `backend/db/migrations/20260723110000_*.{up,down}.sql` |
| 2 | `SaveFacilitatorSession` 쿼리 컬럼 추가 | `backend/db/query.sql` |
| 3 | `sqlc generate` 실행, 생성물 diff 확인 | `backend/internal/infrastructure/postgres/db/*` |
| 4 | `SetMigrationTargetTrackID` raw setter 추가 | `backend/internal/domain/facilitator_session.go` |
| 5 | `mapFacilitatorSession`/`Save` 갱신 | `backend/internal/infrastructure/postgres/facilitator_session_repo.go` |
| 6 | 로컬 postgres(docker-compose)로 마이그레이션 적용 확인 | - |
| 7 | 회귀 테스트: `go test ./...`, `gofmt`, `go vet` | - |

## 검증 체크리스트

- [x] `migration_target_track_id` 컬럼이 마이그레이션으로 추가되고 `down`이 안전하게 롤백된다.
      — 격리된 1회용 postgres:16-alpine 컨테이너(포트 5433)에 `migrate-tool up`/`down`/`up`을
      순서대로 실행해 컬럼 추가·제거·재추가가 모두 에러 없이 동작함을 확인.
- [x] `sqlc generate` 후 diff가 예상 범위(컬럼 추가로 인한 필드 추가)를 벗어나지 않는다.
      — `models.go`/`query.sql.go`에 `MigrationTargetTrackID` 필드/스캔 추가만 발생, 그 외 diff 없음.
- [x] `Save` → 재조회 시 `MigrationTargetTrackID()`가 왕복 보존된다.
      — 위 격리 DB에 대해 실제 `pgFacilitatorSessionRepository`를 사용하는 1회성 검증 스크립트로
      `SetMigrationTarget` → `Save` → `GetByTokenHash` 왕복 확인, `PASS: migration target
      round-tripped through postgres` 출력 확인 후 스크립트/컨테이너 제거.
- [x] 기존 `TestReplaceTrackShoudMigrateSessionAndBroadcastAfterSuccess`가 계속 통과한다.
- [x] `go test ./...`, `gofmt -w .`(diff 없음 확인), `go vet ./...` 통과.
- [x] `mapDomainError`, `api/openapi.yaml` 등 이번 변경으로 영향받는 계약이 없음을 확인(신규 도메인
      에러나 API 필드 변경 없음 — 내부 영속화 버그 수정이므로 API 스키마 변경 불필요).

## 자체 리뷰 결과

1. Plan의 모든 항목(마이그레이션, 쿼리, sqlc 생성물, 도메인 raw setter, 리포지토리 매핑) 빠짐없이 구현됨.
2. 위 검증 체크리스트 전 항목 통과.
3. 개발자 가이드라인 준수: 도메인 필드 private 유지, `SetMigrationTarget`(비즈니스 전이)과
   `SetMigrationTargetTrackID`(리포지토리 복원 전용) 역할 분리 — `SetRevokedAt`과 동일한 기존
   컨벤션을 그대로 따름. `mapXxx` 패턴, sqlc 사용, 마이그레이션 파일명 규칙(9.1) 모두 준수.
4. 신규 도메인 에러·하드코딩·보안 취약점 없음. FK는 `ON DELETE SET NULL`로 안전하게 처리.
