# 감사 로그 설계 결함 수정 (Issues #151, #152, #153)

## 진행 현황 (2026-07-23)

- **Phase A (스키마 + 도메인) — 완료.** A-1~A-3 모두 구현. 추가로 §설계 6의 `campId` 조회
  필터(`AuditLogQuery.CampID`, `ListAuditLogs` WHERE절, 핸들러 `campId` 쿼리 파라미터 +
  응답 필드)도 스키마 작업과 함께 한 번에 처리했다 — sqlc 재생성을 두 번 하지 않기 위함.
  원래 Phase C-1/C-3 범위였던 이 부분은 아래 Phase C에서 제외하고 남은 항목만 진행하면 된다.
- **Phase B (UC-0 실제 행위자 표시값 기록) — 완료.** B-1~B-7 모두 구현. 10개 서비스
  전부(Camp/DeviceTrust/AdminAuth/Corner/Badge/Group/Track/FacilitatorAuth/Message/Visit)
  `actor`는 원시 ID를 유지하고 `actor_name`에 실제 username 또는 트랙 레이블을 기록한다.
  `usecase` 계층에 하드코딩된 `"admin"` 리터럴은 모두 제거됐다(`grep -rn '"admin"'
  internal/usecase/*.go`로 확인).
  - 부수적으로 `camp_handler.go`의 `getAdminID`가 한 번도 설정되지 않는 컨텍스트 키를 읽고
    있던 버그를 발견해 함께 수정했다(커밋 `08c5e1c`) — `adminSession`에서 `AdminID()`를
    꺼내도록 고쳤다. 이 버그 때문에 `CampService`의 `actorAdminID`는 항상 리터럴 `"admin"`을
    받고 있었다.
  - `BadgeService.AssignBadge`/`ScanAssignBadge`는 실제로는 어떤 핸들러에서도 호출되지 않는
    죽은 코드로 확인됐다(배지-조 배정은 `GroupService.AssignBadge`/`ScanAssignBadge`가
    실제 경로). 계획에 있던 대로 두 서비스 모두 동일하게 수정했다.
- **Phase C (UC-1 잔여분)**: `campId` 쿼리 필터는 Phase A에서 완료. C-2(각 recordAuditLog
  호출부에 실제 campID 전달)는 아직 미착수. **C-4(프론트엔드 자동 스코프)는 의도적으로
  보류** — 현재 어떤 서비스도 `campID`를 채우지 않으므로(C-2 미착수) 화면 진입 시 캠프로
  자동 스코프하면 모든 로그가 걸러져 빈 화면만 보이게 된다. C-2가 끝난 뒤에 붙여야 한다.
- **Phase D (UC-2 target 스냅샷)**: 백엔드(D-1, 각 서비스 호출부의 `targetName` 채움)는
  미착수. 프론트엔드 표시 로직(D-3)은 Phase E-2와 함께 먼저 구현 — `target_name`이 항상
  비어있는 현재는 원본 `target` ID로 자동 폴백되므로 안전하게 먼저 배포 가능.
- **Phase E (UC-3 metadata 팝업) — E-2 완료.** `AuditLogMetadataDialog` 구현 및 행 탭
  연결. §설계 8 가이드라인에 따른 metadata 콘텐츠 보강과 성공 경로 민감정보 필터링(E-1,
  백엔드 10개 서비스)은 아직 미착수 — 현재는 각 서비스가 이미 채워둔 metadata를 그대로
  노출할 뿐이다.
- **프론트엔드 actorName/targetName 표시 (Phase C-4 밖, D-3 일부)**: `audit_log_table.dart`가
  `actorName`/`targetName` 스냅샷을 우선 표시하고 없으면 원본 ID로 폴백하도록 수정. 스냅샷을
  보여줄 때는 원본 ID를 `Tooltip`으로 보조 노출. OpenAPI 생성 클라이언트(`lib/shared/api/gen`)는
  로컬에 Dart/Flutter가 설치돼 있지 않아 `docker run openapitools/openapi-generator-cli` +
  `cornermon-flutter` 이미지의 `dart run build_runner build`로 재생성했다(백엔드 `swagger.yaml`
  기준, actorName/targetName/campId 필드 및 campId 쿼리 파라미터 반영).
- 백엔드 `go build`/`go vet`/`go test ./...` 전부 통과(181개 서브테스트), `gofmt -l .` 클린.
- **실제 DB 검증**: 로컬 dev Postgres(`cornermon-db` 컨테이너)에 마이그레이션을 직접 적용해
  확인했다 — 신규 컬럼 3개(`camp_id`/`target_name`/`actor_name`) 및 인덱스 2개가 기대한
  대로 생성되고, 재실행해도 `IF NOT EXISTS`로 안전하게 스킵됨(멱등성 확인). 리포지토리
  계층(`pgAuditLogRepository.Save`/`List`)도 실제 DB에 round-trip 저장/조회해 `actor`가
  원시 ID로, `actor_name`/`target_name`/`campID`가 스냅샷 그대로 보존되는지, `campId` 쿼리
  필터가 다른 캠프 로그를 올바르게 제외하는지 확인했다(임시 검증 코드는 실행 후 삭제, 커밋
  없음). 다만 **HTTP 엔드투엔드 흐름**(관리자 로그인 → 실제 API 호출 → `audit_logs` 조회)은
  아직 수행하지 않았다 — 기존 dev DB의 admin 계정 비밀번호를 몰라 로그인 세션을 만들 수
  없었다. 검증 체크리스트의 "DB 조회로 확인" 항목은 리포지토리 레벨까지만 검증됐고, 실기기/
  API 레벨 검증은 리뷰어 또는 후속 QA에서 진행이 필요하다.
- **golang-migrate 도입(#94) 반영**: 이 작업 도중 `main`에 DB 마이그레이션 툴링이
  golang-migrate로 교체됐다(`db/schema.sql` 단일 파일 폐지, `db/migrations/`의
  timestamped up/down 쌍 + 서버 기동 시 자동 적용). `main`을 merge하면서 기존
  forward-only 단일 마이그레이션 파일을 `20260723110000_add_audit_log_camp_and_snapshots
  .{up,down}.sql` 쌍으로 재작성했다. merge 과정에서 git이 `schema.sql`→
  `20260723100000_init_schema.up.sql` rename을 감지해 내 컬럼 추가분을 베이스라인
  마이그레이션에 잘못 섞어 넣었던 것을 발견해 원본으로 되돌리고, 증분 마이그레이션으로
  분리했다. 로컬 임시 Postgres 컨테이너에 `migrate-tool up` → `down` → `up`을 실제로
  실행해 컬럼/인덱스가 정확히 생성되고 롤백되는지 확인했다.

## Context

GitHub에 열려 있는 감사 로그 관련 이슈 3건을 조사했다.

- **#151** 감사 로그를 캠프 단위로 분리 조회 — `GET /audit-logs`가 전역 조회만 지원해 관리자가
  특정 캠프의 감사 로그 화면에 들어가도 다른 캠프 로그까지 섞여 보인다.
- **#152** actor/target을 ID 대신 사람이 읽을 수 있는 스냅샷으로 표시 — 대상 엔티티가
  이후 삭제/변경되면 ID만으로는 추적 불가능.
- **#153** 감사 로그 행 클릭 시 metadata 팝업 표시 — metadata는 이미 저장/응답되지만
  테이블에 노출되지 않는다.

세 이슈를 조사하는 과정에서 이슈 본문에는 없지만 **#152의 전제를 무너뜨리는 선행 결함**을
추가로 발견했고, 사용자 확인을 거쳐 이번 계획의 범위에 포함했다(UC-0).

추가로 사용자가 명시적으로 지정한 요구사항이 있다: **관리자 화면에서 행위자를 사람이 읽을 수
있게 표시해야 한다.** 최초 초안은 이를 위해 `actor` 컬럼 자체를 username/트랙 레이블로 치환하는
방식을 검토했으나, 리뷰 과정에서 **식별자(ID) 유실로 인한 추적성 상실** 문제가 지적되어 재검토했다.
최종적으로 `actor`는 원시 식별자(admin UUID 또는 트랙 ID)를 그대로 유지하고, 신규 `actor_name`
컬럼에 사람이 읽을 수 있는 표시값을 스냅샷으로 별도 저장하는 **이중 기록(Dual Recording)** 구조로
확정했다 — `target`/`target_name`과 대칭을 이루며, 시스템 계층(조회·통계·GROUP BY)은 `actor`를,
화면 렌더링과 영구 증빙은 `actor_name`을 사용한다. UC-0/UC-2 설계에 직접 반영했다(§설계 1, §설계 4).

### 조사로 확인한 핵심 사실 (근거)

| 사실 | 위치 |
|---|---|
| `audit_logs` 테이블에 `camp_id` 컬럼이 없음 — `actor`/`target`은 `VARCHAR(255)` 원시 문자열뿐 | `backend/db/schema.sql:225-243` |
| `GET /audit-logs`는 `actor`/`action`/`result`/`limit`/`before`만 필터 가능, campId 없음 | `backend/internal/infrastructure/web/audit_handler.go:46-53`, `api/swagger.yaml:1064-1139` |
| **[UC-0] `CornerService`/`BadgeService`/`GroupService`/`TrackService`의 다수 메서드는 인증된 관리자 ID를 파라미터로 받지 않고 `recordAuditLog`에 리터럴 문자열 `"admin"`을 하드코딩** — 즉 "누가"에 대한 실제 ID 자체가 없음 | `corner.go:78,82,151,155,185,189`, `badge.go:61,65,90,167,171`, `group.go:139,143`, `track.go:130,134,203,207,314,318,388,392,470` |
| AdminAuth 미들웨어는 이미 `adminSession`(관리자 ID 포함)을 echo Context에 저장하지만, 위 4개 서비스의 핸들러가 이를 usecase로 전달하지 않음 | `auth_middleware.go:34,72`, `corner_handler.go:123,195,232` (call 시 `c.Request().Context()`만 전달) |
| 반대로 `CampService`/`AdminAuthService`/`DeviceTrustService`/`AuthFacilitatorService`/`MessageService`/`VisitService`는 이미 실제 액터(관리자ID/트랙ID)를 전달받지만, **admin 액터의 경우도 UUID 문자열 그대로 저장 중**(username 아님) | `camp.go`, `auth_admin.go`, `device_trust.go` 등 `recordAuditLog(ctx, string(actorAdminID), ...)` 호출부 |
| `domain.AdminSession`은 `adminID`만 갖고 username은 없음 — AdminAuth 미들웨어가 세팅하는 `adminSession`만으로는 username을 알 수 없고, 반드시 `AdminRepository.Get(ctx, adminID)`로 조회해야 함(`AdminRepository.GetByUsername`과 별개로 `Get(id)` 메서드가 이미 존재) | `internal/domain/admin.go:14-31`, `internal/usecase/port.go:135-142` |
| `CampService`/`CornerService`/`BadgeService`/`GroupService`/`TrackService`/`DeviceTrustService` 6개는 생성자에 `AdminRepository`가 주입돼 있지 않음(`AdminAuthService`만 이미 보유) — username 조회를 하려면 6곳 모두 생성자 시그니처 확장 + `cmd/server/main.go` 와이어링 수정 필요 | `internal/usecase/camp.go:12-24`, `corner.go:12-23`, `badge.go:12-20`, `group.go:12-24`, `track.go:13-25`, `device_trust.go:12-21`, `cmd/server/main.go:154-166` |
| `domain.FacilitatorSession`은 `trackID`만 갖고 개인 식별자(이름/닉네임)가 아예 없음 — 진행자는 계정이 아니라 트랙 PIN으로 로그인하므로 "누가"가 아니라 "어느 트랙"만 식별 가능. 즉 admin의 username과 대응하는 개념 자체가 존재하지 않는다 | `internal/domain/facilitator_session.go:7-14` |
| `FacilitatorAuthService`/`MessageService`/`VisitService`는 이미 `tracks TrackRepository`와 `corners CornerRepository`를 모두 생성자에 보유 — 트랙 레이블 조회에 추가 의존성 주입이 필요 없음 | `auth_facilitator.go:20-32`, `message.go:13-22`, `visit.go:12-26` |
| 관리자 화면은 이미 트랙을 사람이 읽는 형태로 `"{코너명} · {트랙번호}번 트랙"` 포맷으로 표시하는 관례가 있음 — 진행자 액터 레이블도 이 포맷을 그대로 재사용해야 admin/facilitator 화면 표기가 일관됨 | `frontend/lib/admin/features/track_direct/_track_list_pane.dart:48` |
| `actor`/`target`은 액션별로 campID 조달 난이도가 다름 — 이미 메서드 파라미터로 있는 경우(예: `CAMP_END`의 `campID`)와, 엔티티 조회가 필요한 경우(예: `TRACK_DELETE`의 `trackID`→corner→camp)가 섞여 있음 | §설계 5 표 참고 |
| `metadata`는 이미 `map[string]any`로 저장·응답되고(`AuditLogResponse.Metadata`), Dart 생성 모델에도 `BuiltMap<String, JsonObject?>? metadata`로 존재함 — 화면에만 없음 | `audit_handler.go:32`, `audit_log_response.dart:36-37` |
| `audit_log_table.dart`는 시각/행위자/행위종류/대상/결과 5컬럼 고정, metadata·campId 표시 지점 없음 | `frontend/lib/admin/features/audit_log/widgets/audit_log_table.dart` |
| 프론트에는 이미 현재 선택된 캠프를 담는 `selectedCampIdProvider`(`CampId?`)가 존재 — #151의 "화면 진입 시 자동 필터"에 재사용 가능 | `frontend/lib/admin/session/selected_camp_provider.dart:7-9` |
| API 문서(`api/swagger.yaml`)는 손으로 고치는 파일이 아니라 `swag` 주석에서 `make swag`(`backend/Makefile:28-29`)로 생성됨 — 어노테이션만 수정 후 재생성 | `backend/Makefile:28-29` |
| DB 접근 계층(`internal/infrastructure/postgres/db/*.go`)도 `db/query.sql` + `sqlc.yaml`에서 `sqlc generate`로 생성됨 — 손으로 고치지 않음 | `backend/sqlc.yaml`, `backend/db/query.sql:357-367` |
| 과거 마이그레이션은 `ALTER TABLE ... ADD COLUMN IF NOT EXISTS` 단일 forward-only 파일 관례를 따름 | `backend/db/migrations/20260721_add_corner_deleted_at.sql` |
| 도메인 계층에 nullable 값을 표현하는 기존 관례는 포인터가 아니라 `domain.Optional[T]`(`Some`/`None`/`Value()`) | `backend/internal/domain/optional.go` |

---

## 유즈케이스

| 우선순위 | 유즈케이스 | 설명 | 용도 |
|---|---|---|---|
| **P0** | UC-0: 실제 행위자 표시값 기록 (선행 작업, 이슈 범위 밖·사용자 승인됨) | **admin 액터**: Corner/Badge/Group/Track 4개 서비스는 `"admin"` 리터럴 대신 실제 `actorAdminID`를 `actor`에 기록하고, 그 외 6개 서비스는 기존처럼 admin UUID를 `actor`에 유지하되, 10개 서비스 모두 `AdminRepository.Get(adminID).Username()`으로 조회한 username을 신규 `actor_name`에 스냅샷 저장. **facilitator/트랙 액터**: `FACILITATOR_LOGIN/FACILITATOR_LOGOUT/SESSION_MIGRATE/MESSAGE_DIRECT/VISIT_START/VISIT_COMPLETE`는 `actor`에 트랙ID를 그대로 유지하고 `"{코너명} · {트랙번호}번 트랙"` 레이블을 `actor_name`에 기록(§설계 4-b) | **#152의 전제 조건** — `actor`(ID)는 시스템 계층 조회·추적용 식별자, `actor_name`은 화면 가독성용 스냅샷으로 역할을 분리한다(Dual Recording). ID를 버리면 동명이인/username 변경 시 역추적이 불가능해진다 |
| **P0** | UC-1: 감사 로그 campID 저장 + 조회 필터 (#151) | `audit_logs.camp_id` 추가, 기록 시점에 채우고 `GET /audit-logs?campId=`로 필터, 프론트는 `selectedCampIdProvider`로 자동 스코프 | **운영 핵심** — 캠프 간 로그 혼입 제거 |
| **P0** | UC-2: target 사람이 읽을 수 있는 스냅샷 저장 (#152) | 기록 시점에 조회한 대상 표시 이름(트랙 번호·코너명·조 이름 등)을 `target_name`에 저장, API/화면에 노출. actor 쪽도 UC-0에서 동일하게 `actor`(ID)/`actor_name`(스냅샷)으로 대칭 구성했다(§설계 2 참고) | 대상이 이후 삭제/변경돼도 로그 해석 가능 |
| P1 | UC-3: metadata 팝업 표시 (#153) | 로그 행 클릭 시 metadata를 모달로 표시. action별로 실제 채워지는 metadata 키를 §설계 8 가이드라인에 따라 점검·보강, 성공 경로에도 민감 키 필터 적용 | 실패 사유·변경 전후 값 등 세부 컨텍스트 노출, 성공 로그의 민감정보 유입 방지 |

---

## 설계

### 1. 스키마 변경 (신규 migration, forward-only)

```sql
-- backend/db/migrations/20260722_add_audit_log_camp_and_target_snapshot.sql
ALTER TABLE audit_logs
    ADD COLUMN IF NOT EXISTS camp_id VARCHAR(50),
    ADD COLUMN IF NOT EXISTS target_name VARCHAR(255),
    ADD COLUMN IF NOT EXISTS actor_name VARCHAR(255);

COMMENT ON COLUMN audit_logs.camp_id IS '연관된 캠프 ID. 캠프와 무관한 계정 단위 행위(예: ADMIN_LOGIN)는 NULL';
COMMENT ON COLUMN audit_logs.target_name IS '기록 시점 대상 표시 이름 스냅샷';
COMMENT ON COLUMN audit_logs.actor IS '행위자 식별자(admin UUID 또는 트랙 ID/anonymous). 조회·통계는 이 컬럼 기준';
COMMENT ON COLUMN audit_logs.actor_name IS '기록 시점 행위자 표시 이름 스냅샷(admin username 또는 "{코너명}·{트랙번호}번 트랙")';

CREATE INDEX IF NOT EXISTS idx_audit_logs_camp_id_occurred_at_id
    ON audit_logs (camp_id, occurred_at DESC, id DESC);
CREATE INDEX IF NOT EXISTS idx_audit_logs_actor_occurred_at_id
    ON audit_logs (actor, occurred_at DESC, id DESC);
```

`actor_name` 컬럼을 추가한다 — `target`/`target_name`과 동일한 대칭 구조를 `actor`에도 적용한다.
`actor`(ID)는 시스템 계층의 식별자 기반 조회·통계(동일 주체의 이상행동 패턴 분석, `GROUP BY actor`
등)를 위해 유지하고, `actor_name`은 화면 렌더링과 영구 증빙(엔티티가 삭제되거나 username이
변경돼도 "그 시점에 어떤 이름을 쓰던 사용자가 무엇을 했는지"를 보존)을 위한 스냅샷으로 별도
저장한다(Dual Recording). 최초 초안은 `actor` 필드 자체를 username/트랙 레이블로 치환해 컬럼
추가를 생략했으나, 식별자 유실로 인한 추적성 상실 문제가 지적되어 이중 기록 구조로 변경했다.
`idx_audit_logs_actor_occurred_at_id`는 `actor` 단독 필터(동일 행위자의 캠프 무관 전역 로그 조회,
예: `ADMIN_LOGIN` 이력 추적)를 위해 추가한다.

`camps(id)`로의 FK 제약은 두지 않는다 — 감사 로그는 append-only이며 캠프가 삭제되더라도
로그 자체는 남아야 하기 때문(현재 `camps` 테이블에 소프트 삭제가 있는지와 무관하게 원칙적으로).
`camp_id`/`target_name`/`actor_name` 모두 nullable: 과거 로그(마이그레이션 이전 기록)는 NULL로
남고, 화면은 이를 "표시 불가" 폴백(`actor_name`이 없으면 `actor` 원시 ID로 표시)으로 처리한다
(§7, §검증).

`db/schema.sql`도 동일 내용으로 갱신(기존 관례상 마이그레이션과 schema.sql을 함께 유지).

### 2. Domain 계층 (`internal/domain/audit_log.go`)

```go
type AuditLog struct {
    id         AuditLogID
    actor      string // 행위자 식별자: admin UUID 또는 트랙ID/anonymous — 조회·통계 기준
    actorName  string // 행위자 표시 이름 스냅샷("" = 스냅샷 없음, 과거 로그 등) — UC-0
    action     string
    target     string
    targetName string           // "" = 스냅샷 없음(과거 로그 또는 이름 없는 target)
    campID     Optional[CampID] // None = 캠프 무관 행위
    success    bool
    occurredAt time.Time
    metadata   map[string]any
}

type AuditLogProps struct {
    ID         AuditLogID
    Actor      string
    ActorName  string
    Action     string
    Target     string
    TargetName string
    CampID     Optional[CampID]
    Success    bool
    OccurredAt time.Time
    Metadata   map[string]any
}

func (a *AuditLog) ActorName() string
func (a *AuditLog) TargetName() string
func (a *AuditLog) CampID() Optional[CampID]
```

기존 `NewAuditLog(...)` 포지셔널 생성자는 필드가 4개(`campID`/`targetName`/`actorName` 등) 늘어나면
호출부 10여 곳이 전부 깨지므로 **제거하고 `NewAuditLogFromProps(AuditLogProps)`만 남긴다** —
어차피 이미 존재하는 패턴이고, UC-0~UC-2가 모든 호출부를 수정해야 하므로 이번이 통합할 시점이다.

### 3. `recordAuditLog` 공통 시그니처 확장

현재 10개 서비스(`CampService`/`CornerService`/`BadgeService`/`GroupService`/`TrackService`/
`DeviceTrustService`/`AdminAuthService`/`FacilitatorAuthService`/`MessageService`/
`VisitService`)에 동일한 private 헬퍼가 복붙돼 있다. 시그니처를 아래와 같이 통일 확장한다
(10곳 전부 동일 패턴이므로 하나만 예시):

```go
func (s *CampService) recordAuditLog(
    ctx context.Context,
    campID domain.Optional[domain.CampID],
    actor, actorName string,
    action AuditAction,
    target, targetName string,
    success bool,
    metadata map[string]any,
) {
    log := domain.NewAuditLogFromProps(domain.AuditLogProps{
        ID: domain.AuditLogID(s.uuidFn()), CampID: campID,
        Actor: actor, ActorName: actorName,
        Action: string(action), Target: target, TargetName: targetName,
        Success: success, OccurredAt: s.nowFn(), Metadata: metadata,
    })
    _ = s.auditLogs.Save(ctx, log)
}
```

`actor`에는 원시 식별자(admin UUID/트랙ID/anonymous)를 그대로 넘긴다. `actorName`에는
**호출부에서 이미 사람이 읽을 수 있는 값으로 변환한 문자열**을 넘긴다(admin 액터 → username,
facilitator/트랙 액터 → 트랙 레이블). 변환은 공유 헬퍼로 둔다:

```go
// internal/usecase/audit_actor.go (신규) — 여러 서비스가 공통으로 참조
//
// preloaded가 넘어오면(호출부가 비즈니스 로직 수행 중 이미 Admin을 로드해 둔 경우,
// 예: AdminAuthService.Login) 그 값을 그대로 쓰고 DB 재조회를 하지 않는다. 없으면
// (nil) 그때만 폴백으로 조회한다 — 로깅 때문에 매 요청마다 추가 쿼리가 발생하는 것을 피한다.
func adminActorLabel(ctx context.Context, admins AdminRepository, adminID domain.AdminID, preloaded *domain.Admin) string {
    if preloaded != nil {
        return preloaded.Username()
    }
    admin, err := admins.Get(ctx, adminID)
    if err != nil || admin == nil {
        return string(adminID) // 조회 실패 시에만 최후 폴백(정상 경로에서는 발생하지 않음 — 행위자는 행위 시점에 반드시 존재)
    }
    return admin.Username()
}

// trackDisplayLabel은 프론트엔드 기존 표시 관례("{코너명} · {트랙번호}번 트랙",
// track_direct/_track_list_pane.dart:48)와 동일한 포맷으로 트랙을 스냅샷 문자열화한다.
// facilitator 액터(§4-b)와 트랙 target_name(§5-표) 양쪽에서 재사용한다 — 진행자는 개인
// 식별자가 없으므로 "어느 트랙"이 곧 행위자 식별자다. preloadedTrack도 admin 헬퍼와 동일한
// 이유로 지원한다(호출부가 이미 Track을 로드해 둔 경우 재사용).
func trackDisplayLabel(ctx context.Context, tracks TrackRepository, corners CornerRepository, trackID domain.TrackID, preloadedTrack *domain.Track) string {
    track := preloadedTrack
    if track == nil {
        var err error
        track, err = tracks.Get(ctx, trackID)
        if err != nil || track == nil {
            return string(trackID) // 폴백: 조회 실패(예: 이미 삭제됨)
        }
    }
    corner, err := corners.Get(ctx, track.CornerID())
    if err != nil || corner == nil {
        return string(trackID)
    }
    return fmt.Sprintf("%s · %d번 트랙", corner.Name(), track.TrackNo())
}
```

`preloaded`/`preloadedTrack`은 각 호출부에서 이미 로드한 엔티티가 있을 때만 넘기고, 없으면 `nil`을
넘겨 헬퍼가 내부에서 조회하도록 한다 — 감사 로그는 10개 서비스의 핫패스에서 매번 기록되므로,
이미 메모리에 있는 엔티티를 두고 강제로 재조회하면 불필요한 DB 부하와 트랜잭션 점유 시간 증가로
이어진다. 어떤 호출부가 실제로 엔티티를 미리 갖고 있는지는 Phase B 구현 시점에 각 서비스 메서드를
확인해 결정한다(§4, §4-b에 확인된 것만 명시).

### 4. UC-0: admin 액터 username 기록 대상

| 서비스 · 메서드 | 현재 문제 | 조치 |
|---|---|---|
| `CornerService.AddLearningCorner/ModifyCornerSpecification/RemoveCornerFromCamp` | `actorAdminID` 파라미터 없음, `"admin"` 하드코딩(`corner.go:78,151,185`) — `actor`/`actorName` 둘 다 없음 | 메서드 시그니처에 `actorAdminID domain.AdminID` 추가, 생성자에 `admins AdminRepository` 주입. `actor`에는 `actorAdminID`를 그대로, `actorName`에는 `adminActorLabel(ctx, s.admins, actorAdminID, nil)`로 조회한 값을 기록 |
| `BadgeService.IssueInitialBadges/ExportBadges/AssignBadge` (`assignBadgeInternal` 경유) | 동일(`badge.go:61,90,167`) | 동일 |
| `GroupService.registerBadge` 경유 `AssignBadge/ScanAssignBadge` | 동일(`group.go:139`) | 동일 |
| `TrackService.CreateTrack/DeleteTrack/ReplaceTrack/RegeneratePIN/ExportTrackPINs` | 동일(`track.go:130,203,314,388,470`) | 동일 |
| `CampService`(전 메서드), `DeviceTrustService`(전 메서드) | `actorAdminID`는 이미 파라미터로 받아 `actor`에 올바르게 기록 중이지만, `actorName`을 채울 곳이 없음 | 생성자에 `admins AdminRepository` 주입, `actor`는 기존 `string(actorAdminID)` 그대로 유지, `actorName`을 `adminActorLabel(ctx, s.admins, actorAdminID, nil)`로 추가 |
| `AdminAuthService.CreateAdmin/ChangePassword/DeleteAdmin/RevokeSession/ForceTrackLogout` | 동일 — `actor`는 이미 올바른 UUID, `actorName`이 없음. `s.admins`는 이미 주입돼 있어 생성자 변경 불필요 | `actorName`만 `adminActorLabel(ctx, s.admins, actorAdminID, nil)`로 추가 |
| `AdminAuthService.Login` (성공 경로) | `actor`는 이미 `string(admin.ID())`로 올바름(`auth_admin.go:107`), `actorName`이 없음 | 이미 로드된 `admin` 엔티티를 `adminActorLabel(ctx, s.admins, admin.ID(), admin)`처럼 `preloaded`로 전달해 추가 조회 없이 `actorName` 채움 |

핸들러 계층(`corner_handler.go`, `badge_handler.go`, `group_handler.go`, `track_handler.go`)에서
`c.Get("adminSession").(*domain.AdminSession).AdminID()`로 추출해 usecase 호출에 넘긴다 —
`auth_middleware.go:34`가 이미 이 값을 세팅해 두므로 미들웨어 변경은 불필요하다. username 조회
자체는 핸들러/미들웨어가 아니라 **usecase 계층에서**(`adminActorLabel`) 수행한다 — `AdminSession`에는
username이 없고(§Context 근거), 매 요청마다 미들웨어에서 추가 DB 조회를 하지 않기 위함이다.

### 4-b. facilitator/트랙 액터 — `trackDisplayLabel` 적용 대상

admin과 달리 facilitator는 개인 계정이 없으므로(§Context 근거) "행위자 이름"에 대응하는 것은
사람 이름이 아니라 **트랙 레이블**이다. 아래 6개 액션은 기존에 `actor`로 raw `trackID`를 그대로
기록하던 지점이며, `actor`는 트랙ID를 그대로 유지하고 `actorName`을
`trackDisplayLabel(ctx, s.tracks, s.corners, trackID, preloadedTrack)`로 채운다. 세 서비스 모두 이미
`tracks`/`corners`를 생성자에 보유하고 있어(§Context) 생성자 변경이 필요 없다. `preloadedTrack`은
해당 메서드가 비즈니스 로직 수행 중 이미 `Track` 엔티티를 로드해 둔 경우에만 넘기고(Phase B 구현
시점에 각 메서드를 확인해 결정), 없으면 `nil`을 넘겨 헬퍼가 조회하도록 한다.

| 서비스 · 액션 | 현재 actor 값 | 조치 |
|---|---|---|
| `FacilitatorAuthService.Login` → `FACILITATOR_LOGIN`(`auth_facilitator.go:190`) | `string(trackID)` | `actor`는 `string(trackID)` 유지, `actorName = trackDisplayLabel(ctx, s.tracks, s.corners, trackID, preloadedTrack)` |
| `FacilitatorAuthService.MigrateSession` → `SESSION_MIGRATE`(`auth_facilitator.go:271`) | `string(oldSession.TrackID())` | 동일(이전 트랙 기준 레이블) |
| `FacilitatorAuthService.Logout` → `FACILITATOR_LOGOUT`(`auth_facilitator.go:333`) | `string(session.TrackID())` | 동일 |
| `MessageService.SendDirect` → `MESSAGE_DIRECT`(`message.go:63`) | `string(trackID)` | 동일 |
| `VisitService.StartVisit(QR/Manual)` → `VISIT_START`(`visit.go:176,289`) | `actor`(이미 트랙 기반 문자열) | 동일 |
| `VisitService.CompleteVisit` → `VISIT_COMPLETE`(`visit.go:396`) | `actor` | 동일 |

로그인/방문 시작처럼 트랙이 아직 세션에 묶이기 전 실패 케이스(예: `auth_facilitator.go:87,95,111,145`의
`"anonymous"`)는 트랙 신원이 확정되기 전이므로 `actor`/`actorName` 모두 그대로 `"anonymous"` 유지 —
트랙이 특정된 이후 지점만 `trackDisplayLabel`로 `actorName`을 채운다.

### 5. UC-1: 액션별 campID 조달 방법

| 액션 | campID 출처 |
|---|---|
| `CAMP_CREATE/CAMP_ACTIVATE/CAMP_END/CAMP_SETTINGS_UPDATE` | 이미 메서드 파라미터 `campID` |
| `CORNER_CREATE`, `TRACK_CREATE` | 이미 메서드 파라미터 `campID` |
| `CORNER_UPDATE/CORNER_DELETE` | `CornerID`로 메서드 내부에서 이미 로드한 `Corner.CampID()` |
| `TRACK_DELETE/TRACK_REPLACE/PIN_REGENERATE/TRACK_FORCE_LOGOUT` | `TrackID` → 기존 `CornerService.GetCornerByTrack` 결과의 `CampID()` |
| `BADGE_ASSIGN` | `GroupID` → `groups.FindByID(...).CampID()` |
| `BADGE_BULK_GENERATE/BADGE_EXPORT` | 배지는 캠프 무관 전역 풀이므로 `camp_id` = `None`(정상) |
| `GROUP_CREATE` | 메서드 내 이미 조회된 `registrationCamp()` 결과 |
| `DEVICE_REQUEST/DEVICE_APPROVED/DEVICE_REJECTED/DEVICE_REVOKED/PIN_LOCK_RESET` | `DeviceRegistration.CampID()`(이미 로드됨) |
| `FACILITATOR_LOGIN/FACILITATOR_LOGOUT/SESSION_MIGRATE/MESSAGE_DIRECT/VISIT_START/VISIT_COMPLETE` | `TrackID` → `GetCornerByTrack(...).CampID()` (동일 lookup 재사용) |
| `MESSAGE_BROADCAST` | 이미 메서드 파라미터 `campID`(`announcement.go:63`) |
| `ADMIN_LOGIN/ADMIN_CREATE/ADMIN_PASSWORD_CHANGE/ADMIN_DELETE/ADMIN_SESSION_REVOKE` | 계정 단위 행위 — `camp_id` = `None`(정상) |

트랙 기반 조회가 5개 서비스(Track/Auth-facilitator/Message/Visit/Auth-admin의 강제로그아웃)에서
반복되므로, 새 인터페이스를 만들기보다 **각 서비스가 이미 보유한 `corners`(또는 동등) 리포지토리의
기존 `GetCornerByTrack` 조회를 그대로 재사용**한다(포트 신규 생성 없음, `workflow/plan.md` §3.2 원칙).

**삭제 계열 액션의 로깅 순서**: `TRACK_DELETE`/`CORNER_DELETE`처럼 대상 엔티티 자체를 지우는
액션은, campID/targetName 조달에 필요한 조회(`GetCornerByTrack`, corner 이름 등)를 **엔티티 삭제
전에** 먼저 수행하고 그 결과를 들고 있다가 삭제 후 `recordAuditLog`를 호출한다 — 삭제부터 먼저
실행하면 조회가 실패해 폴백(원시 ID)으로 떨어질 수 있다. 각 서비스의 기존 삭제 메서드가 이미
"조회 → 삭제" 순서(soft delete 전 존재 확인 등)를 따르는지 Phase B/D 구현 시 확인한다.

### 6. API 계약 (`swag` 주석 수정 → `make swag`로 재생성, 손으로 `swagger.yaml` 편집 금지)

```go
// audit_handler.go
type AuditLogResponse struct {
    ...
    CampID     *string `json:"campId,omitempty" format:"uuid"`
    TargetName string  `json:"targetName,omitempty"`
    ActorName  string  `json:"actorName,omitempty"`
}

// @Param campId query string false "캠프 ID로 범위 제한"
```

`actor` 필드는 스키마 변경 없이 기존 그대로 노출한다 — 여전히 원시 식별자(admin UUID/트랙 ID)다.
화면 표시는 신규 `actorName`을 우선 사용하고, `actorName`이 없는 과거 로그만 `actor`로 폴백한다
(target/targetName과 동일 패턴).

`usecase/port.go`의 `AuditLogQuery`에 `CampID domain.Optional[domain.CampID]` 추가,
`db/query.sql`의 `ListAuditLogs`에 `AND (sqlc.narg(camp_id)::VARCHAR IS NULL OR camp_id = sqlc.narg(camp_id)::VARCHAR)`
추가하고 `SaveAuditLog`도 4개 컬럼(`camp_id`/`target_name`/`actor_name` 등)을 INSERT하도록 확장 —
**수정 후 `sqlc generate` 실행, 생성 파일
(`db/models.go`,`db/querier.go`,`db/query.sql.go`)은 손으로 고치지 않는다.**

### 7. 프론트엔드

- `audit_log_page_notifier.dart`: `build()`/`_fetch()`에서 `ref.watch(selectedCampIdProvider)`를
  읽어 `auditLogListProvider(..., campId: selectedCampId?.value)`로 전달 — 필터 UI에는 노출하지
  않고(필터는 여전히 actor/action/result 3축, `AuditLogFilter` 변경 없음) 화면 진입 시 항상
  현재 캠프로 자동 스코프한다(#151 요구사항 그대로).
- `audit_log_providers.dart`/`GAuditLogsApi`: `campId` 쿼리 파라미터 추가 — OpenAPI 코드 생성
  파이프라인 재실행 필요(`frontend/lib/shared/api/gen` 갱신, 손으로 고치지 않음).
- `audit_log_table.dart`: 행위자 열과 대상 열 모두 동일한 스냅샷 우선 패턴 적용.
  행위자 열은 `log.actorName?.isNotEmpty == true ? log.actorName : (log.actor ?? '-')`,
  대상 열은 `log.targetName?.isNotEmpty == true ? log.targetName : (log.target ?? '-')`로
  표시(과거 로그는 원시 ID로 폴백). 원시 ID는 필요 시 `Tooltip`으로 보조 노출.
- 신규 `audit_log_metadata_dialog.dart`: 행 `InkWell`로 감싸 탭 시 `metadata`를 key-value 리스트로
  보여주는 `AlertDialog`. `metadata`가 비어있으면 "추가 정보 없음" 표시.

```dart
class AuditLogMetadataDialog extends StatelessWidget {
  const AuditLogMetadataDialog({required this.metadata, super.key});
  final BuiltMap<String, JsonObject?>? metadata;

  static Future<void> show(BuildContext context, AuditLog log);
}
```

### 8. UC-3: metadata 콘텐츠 가이드라인 (신규 — #153, Phase E-1의 점검 기준)

현재 코드는 액션마다 metadata에 무엇을 넣을지 정해진 기준 없이 개별 판단으로 채워져 있다
(예: `CORNER_CREATE`는 `campID`/`name`을 넣지만 `CORNER_DELETE`·`PIN_REGENERATE`·`CAMP_END`
등 다수는 성공 시 `nil`). Phase E-1("action별 실제 metadata 키 점검·보강")은 아래 기준으로
수행한다 — "일단 채운다"가 아니라 "다른 컬럼으로 설명되지 않는 사실만 채운다"가 목표다.

**판단 기준**: metadata 포함 여부는 "성공/실패"라는 상태값 자체가 아니라, **기본 컬럼
(`actor`/`target`/`campID`/`success`)만으로 그 행위의 결과적 파급력(consequential impact)을
온전히 설명할 수 있는가**로 판단한다. 설명이 안 되는 부분만 채운다 — "일단 채운다"가 아니라
"기본 컬럼이 놓치는 사실만 채운다"가 목표다. 성공/실패는 그 "설명 안 되는 부분"의 **종류**를
가르는 축으로만 쓴다:

- **실패 시 → 진단 컨텍스트(Diagnostic Context)**: 왜 실패했는지, 무엇이 거부됐는지를 담는다
  — 실패 사유, 거부된 권한 레벨, 오류 코드 등. 계속 `errorAuditMetadata(err, base)`를 사용해
  `error`/`error_type`/`operation`/`stage`를 채우는 기존 패턴을 유지하되, 오류 메시지만으로
  설명되지 않는 결정 정보(예: 어떤 권한 레벨이 요구됐는데 어떤 레벨이었길래 거부됐는지)가 있다면
  `base` 인자로 함께 넘긴다(기존에도 `auth_facilitator.go:145`가 `device_failures`를 `base`로
  넘기는 사례가 있음 — 이 패턴을 다른 실패 경로에도 점검·확대 적용).
- **성공 시 → 운영 컨텍스트(Operational Context)**: 처리된 건수, 연관된 외부 엔티티 ID 등
  **선별적으로**만 담는다 — 이미 있는 패턴이 기준이다: 집계 값(`count`,
  `BADGE_BULK_GENERATE`), 관련 엔티티의 다른 식별자(`groupID`, `BADGE_ASSIGN`), 선택된
  방식/경로(`method`, `VISIT_START`), 이전 상태와의 비교(`oldTrackID`, `TRACK_REPLACE`;
  `isLastTrack`, `TRACK_DELETE`). "선별적"이 핵심 — 성공 경로는 실패와 달리 굳이 설명이
  필요한 이상 상황이 아니므로, 기본 컬럼을 넘어서는 운영상 의미가 있는 값만 추가한다.
- `actor`/`actor_name`/`target`/`target_name`/`campID`/`success`로 이미 표현되는 정보는 위
  어느 경우든 metadata에 중복 기재하지 않는다(예: `target_name`이 이미 코너명을 담으므로
  metadata에 코너명을 다시 넣지 않음).
- 기본 컬럼이 이미 파급력을 온전히 설명하면(예: `ADMIN_DELETE`는 `target`이 곧 삭제 대상
  adminID라 그 자체로 완결) 진단/운영 컨텍스트 어느 쪽도 추가하지 않고 `nil`을 유지한다 —
  Phase E-1은 액션마다 이 판단 기준을 하나씩 적용해 점검한다.

**보안 기준 — 기존 코드의 실제 공백**
- `filterErrorAttributes`/`isSensitiveErrorAttribute`(`error_context.go`, `token`/`pin`/
  `password`/`hash`/`cipher`/`registration_code`/`qr`/`secret` 포함 키를 차단)는 현재
  **실패 경로(`errorAuditMetadata`)에만 적용되고, 성공 경로의 리터럴
  `map[string]any{...}`에는 전혀 적용되지 않는다** — 성공 로그에 실수로 민감 키를 넣어도
  걸러지지 않는다. 이를 막기 위해 `recordAuditLog` 공통 헬퍼(§설계 3, 10곳 모두)에서
  DB 저장 직전 **성공/실패 관계없이 모든 metadata**를 `filterErrorAttributes`로 한 번 더
  통과시켜 방어적으로 차단한다(Phase E-1과 함께 처리, 새 파일 불필요 — `error_context.go`의
  기존 함수 재사용).

Phase E-1 항목에 "각 액션의 metadata를 위 기준으로 점검·보강, `recordAuditLog`에 성공 경로도
`filterErrorAttributes`를 통과하도록 수정"을 추가한다. 검증 체크리스트에도 성공 경로 metadata가
민감 키를 걸러내는지 확인 항목을 추가한다(§검증).

---

## 계층별 책임 분리

- **`internal/domain/audit_log.go`**: `AuditLog`/`AuditLogProps`에 `campID`/`targetName`/`actorName`
  추가 — 외부 의존성 없는 순수 도메인 모델 유지.
- **`internal/usecase/audit_actor.go`** (신규): `adminActorLabel`(admin username 해석)과
  `trackDisplayLabel`(facilitator/트랙 레이블 해석) 공유 헬퍼 — 여러 서비스가 재사용(포트 신규
  생성 없이 기존 `AdminRepository`/`TrackRepository`/`CornerRepository` 재사용). 둘 다 이미 로드된
  엔티티를 `preloaded`로 받으면 재조회를 생략하는 폴백 구조(§설계 3)로 N+1을 방지한다.
- **`internal/usecase/*.go`** (10개 서비스): `recordAuditLog` 시그니처 통일 확장, 각 호출부에서
  campID/targetName 조달(§5), admin 액터는 `adminActorLabel` 경유(§4). Service는 여전히
  `AuditLogRepository`/`AdminRepository` 인터페이스에만 의존.
- **`internal/infrastructure/postgres/`**: `query.sql` 확장 → `sqlc generate` → `audit_log_repo.go`의
  `Save`/`List` 매핑에 필드 추가.
- **`internal/infrastructure/web/`**: 핸들러가 `adminSession`에서 `AdminID` 추출해 usecase로 전달,
  `AuditLogResponse`에 `campId`/`targetName` 추가, `campId` 쿼리 파라미터 파싱.
- **`frontend/lib/admin/features/audit_log/`**: 화면/상태 계층 — `selectedCampIdProvider` 구독,
  target 스냅샷 우선 표시, metadata 다이얼로그. `lib/shared/api/gen/**`는 코드 생성 결과이므로 재생성만.

---

## Phase 구성 (구현은 별도 PR, 300 LOC 내외로 분할)

### Phase A: 스키마 + 도메인 (예상 3시간) — ✅ 완료 (커밋 `4de9851`)

| 순서 | 작업 | 파일 |
|---|---|---|
| A-1 | migration 작성 + `schema.sql` 반영 (신규) | `backend/db/migrations/20260722_add_audit_log_camp_and_snapshots.sql`, `backend/db/schema.sql` |
| A-2 | `AuditLog`/`AuditLogProps`에 4필드(`campID`/`targetName`/`actorName` 등) 추가, 포지셔널 `NewAuditLog` 제거 (기존 파일 확장) | `backend/internal/domain/audit_log.go` |
| A-3 | `query.sql` 확장 + `sqlc generate` 실행 (기존 파일 확장 + 생성) | `backend/db/query.sql`, 생성 산출물 |

### Phase B: UC-0 실제 행위자 표시값 기록 (예상 7시간) — ✅ 완료 (커밋 `cd0cd8a`~`1ed1780`)

| 순서 | 작업 | 파일 |
|---|---|---|
| B-1 | `adminActorLabel`/`trackDisplayLabel` 공유 헬퍼 구현, 둘 다 `preloaded`/`preloadedTrack` 파라미터로 N+1 방지 (신규) | `internal/usecase/audit_actor.go` |
| B-2 | Corner/Badge/Group/Track 4개 서비스 메서드에 `actorAdminID` 파라미터 추가 + 생성자에 `admins AdminRepository` 주입, `actor`는 `actorAdminID` 그대로, `actorName`은 `adminActorLabel(..., nil)` 호출로 채움 | `corner.go`, `badge.go`, `group.go`, `track.go` |
| B-3 | 대응 핸들러에서 `adminSession`으로부터 `AdminID` 추출해 전달 | `corner_handler.go`, `badge_handler.go`, `group_handler.go`, `track_handler.go` |
| B-4 | `CampService`/`DeviceTrustService` 생성자에 `admins AdminRepository` 주입, `actor`는 기존 `string(actorAdminID)` 유지, `actorName`을 `adminActorLabel(..., nil)`로 추가 | `camp.go`, `device_trust.go` |
| B-5 | `AdminAuthService`의 `actorName`이 비어 있던 호출부에 `adminActorLabel(..., nil)`로 채움(생성자 변경 불필요, `s.admins` 이미 보유), `Login` 성공 경로는 이미 로드된 `admin`을 `preloaded`로 전달해 추가 조회 없이 `actorName` 채움 | `auth_admin.go` |
| B-6 | 6개 서비스 생성자 시그니처 변경에 맞춰 와이어링 갱신 | `cmd/server/main.go:154-166` |
| B-7 | §4-b 표에 따라 `FacilitatorAuthService`/`MessageService`/`VisitService`의 `actor`는 트랙ID 유지, `actorName`을 `trackDisplayLabel(...)`로 채움(가능한 경우 이미 로드된 Track을 `preloadedTrack`으로 전달해 N+1 방지, 생성자 변경 불필요) | `auth_facilitator.go`, `message.go`, `visit.go` |

### Phase C: UC-1 campID 기록 + 조회 필터 (예상 5시간) — 백엔드 완료, 프론트 잔여

| 순서 | 작업 | 파일 |
|---|---|---|
| C-1 | ~~`AuditLogQuery`에 `CampID` 추가~~ ✅ Phase A에서 완료. `recordAuditLog` 시그니처에 `campID` 추가(10개 서비스) ✅ 완료 | `usecase/port.go`, 10개 서비스 파일 |
| C-2 | ✅ 완료 — §5 표에 따라 각 호출부에 campID 조달 로직 반영 | 동일 10개 파일 |
| C-3 | ~~`audit_handler.go`에 `campId` 쿼리 파라미터 + 응답 필드, swag 주석 갱신 → `make swag`~~ ✅ Phase A에서 완료 | `audit_handler.go`, 생성된 `api/swagger.yaml` |
| C-4 | (미착수, 프론트엔드 세션에서 진행 예정) `audit_log_page_notifier.dart`가 `selectedCampIdProvider` 반영해 자동 조회 | `audit_log_page_notifier.dart`, `audit_log_providers.dart`, OpenAPI 클라이언트 재생성 |

### Phase D: UC-2 target 스냅샷 (예상 3시간) — 백엔드 완료, 프론트 잔여

| 순서 | 작업 | 파일 |
|---|---|---|
| D-1 | ✅ 완료 — 각 서비스 호출부에서 대상 이름 조회(트랙 번호/코너명/조 이름 등) 후 `targetName` 전달 | 10개 서비스 파일 |
| D-2 | ~~`AuditLogResponse`에 `targetName` 추가 → `make swag`~~ ✅ Phase A에서 완료 | `audit_handler.go` |
| D-3 | (미착수, 프론트엔드 세션에서 진행 예정) `audit_log_table.dart`가 target 스냅샷 우선 표시(폴백: 원본 ID) | `audit_log_table.dart` |

### Phase E: UC-3 metadata 팝업 (예상 3시간, P1이므로 A~D 이후) — 백엔드(E-1) 완료

| 순서 | 작업 | 파일 |
|---|---|---|
| E-1 | ✅ 완료 — §설계 8 가이드라인에 따라 action별 metadata 키 점검·보강(campID/actorName/targetName과 중복되던 `name`/`campID`/`cornerID`/`trackID` 키 제거), `recordAuditLog` 공통 헬퍼(10곳 전부)가 성공 경로 metadata도 `filterErrorAttributes`로 거르도록 수정 | 10개 서비스 파일 중 metadata 채우는 부분 + 각 서비스의 `recordAuditLog` 헬퍼 |
| E-2 | (미착수, 프론트엔드 세션에서 진행 예정 — 별도로 작업 중이던 미커밋 변경 있음) `AuditLogMetadataDialog` 구현 + 행 탭 연결 (신규) | `frontend/lib/admin/features/audit_log/widgets/audit_log_metadata_dialog.dart`, `audit_log_table.dart` |

---

## 검증 체크리스트

### 아키텍처 검증

- [ ] `domain` 패키지가 `infrastructure`를 import하지 않음
- [ ] nullable 값(`camp_id`)은 포인터가 아니라 `domain.Optional[CampID]`로 표현
- [ ] 새 리포지토리 인터페이스를 만들지 않고 기존 `GetCornerByTrack` 등을 재사용(§5)
- [ ] `internal/infrastructure/postgres/db/**`(sqlc 생성물), `api/swagger.yaml`(swag 생성물),
      `frontend/lib/shared/api/gen/**`(openapi-generator 생성물)을 手동 수정하지 않음

### 유즈케이스 검증

- [ ] UC-0: 코너/배지/조/트랙 관련 액션 수행 후 `audit_logs.actor`는 여전히 `"admin"` 리터럴이
      아니라 실제 관리자 UUID(식별자)로 남아있고, `actor_name`이 실제 관리자 **username**인지 DB
      조회로 확인. 이미 올바르게 ID를 넘기던 Camp/DeviceTrust/AdminAuth 계열 액션도 `actor`는
      UUID 그대로, `actor_name`만 username인지 함께 확인
- [ ] UC-0: 진행자 로그인/방문 시작/다이렉트 메시지 등 트랙 기반 액션 수행 후 `audit_logs.actor`는
      raw 트랙ID 그대로, `actor_name`이 `"{코너명} · {트랙번호}번 트랙"` 형식인지, 관리자 화면의
      트랙 표시와 동일한 포맷인지 확인
- [ ] UC-0: `preloaded`/`preloadedTrack`을 전달하는 호출부에서 `adminActorLabel`/`trackDisplayLabel`이
      추가 DB 조회를 하지 않는지(리포지토리 mock의 호출 횟수 검증) 확인 — N+1 방지 목적
- [ ] UC-1: 캠프 A에서 코너 생성, 캠프 B에서 트랙 생성 후 캠프 A의 감사 로그 화면에 캠프 B
      로그가 보이지 않는지 확인. `ADMIN_LOGIN` 같은 계정 단위 로그는 `camp_id NULL`로 어느
      캠프 화면에서도 보이지 않는지(또는 별도 처리 방침) 확인
- [ ] UC-2: 트랙/코너/조를 삭제한 뒤에도 과거 로그의 `target_name`이 여전히 그 이름을 보여주는지 확인
- [ ] UC-3: metadata가 있는 로그 행을 탭하면 팝업에 키-값이 보이고, metadata가 없는 로그는
      "추가 정보 없음"으로 표시되는지 확인
- [ ] UC-3: §설계 8 기준대로 각 액션의 metadata가 actor/target/campID와 중복 없이 부가 컨텍스트만
      담고 있는지, 성공 경로에서 `token`/`pin`/`password`/`hash`/`cipher`/`registration_code`/`qr`/
      `secret` 계열 키를 의도적으로 넣어도 `filterErrorAttributes`에 걸러져 저장되지 않는지 확인
- [ ] 마이그레이션 이전에 기록된 기존 로그(`camp_id`/`target_name`/`actor_name` 모두 NULL, `actor`는
      여전히 구 UUID/`"admin"` 리터럴/raw 트랙ID)가 화면에서 에러 없이 원본 `actor`/`target` 값으로
      폴백 표시되는지 확인
- [ ] 인덱스 효과 검증: `camp_id` 없이 `actor`/`action`만으로 필터링하는 기존 조회 패턴이
      `idx_audit_logs_actor_occurred_at_id`를 타는지, `camp_id IS NULL` 전역 로그 조회가 Full Table
      Scan을 유발하지 않는지 `EXPLAIN`으로 확인(범위 밖 항목 참고)

### 자동화 테스트 (Go: `ShoudXxxWhenYyy` + arrange-act-assert, Flutter: 기존 위젯 테스트 패턴)

- `audit_log_test.go`: `AuditLogProps`의 `CampID`가 `None`일 때/`Some`일 때 `CampID()` 정상 반환
- `audit_actor_test.go`(신규): `adminActorLabel`이 존재하는 관리자 ID에 대해 username을 반환하는지
  (`TestAdminActorLabelShoudReturnUsernameWhenAdminExists`), `preloaded`가 주어지면 리포지토리를
  호출하지 않는지(`TestAdminActorLabelShoudSkipRepositoryWhenPreloadedProvided`), `trackDisplayLabel`이
  `"{코너명} · {트랙번호}번 트랙"` 포맷을 반환하는지(`TestTrackDisplayLabelShoudFormatCornerAndTrackNoWhenTrackExists`)
- 10개 서비스 테스트: campID/targetName이 §5 표대로 채워지고, `actor`는 여전히 원시 ID(UUID/트랙ID)로
  기록되며 `actor_name`만 username/트랙 레이블인지(예: `TestRecordAuditLogShoudIncludeCampIDWhenTrackDeleted`,
  `TestAddLearningCornerShoudRecordAdminIDAsActorAndUsernameAsActorNameWhenSucceeded`)
- 10개 서비스의 `recordAuditLog` 헬퍼 테스트: 성공 경로 metadata에 `token`/`pin`/`password` 등
  민감 키를 넣어 호출해도 저장되는 로그에는 해당 키가 빠져 있는지
  (`TestRecordAuditLogShoudStripSensitiveKeysFromSuccessMetadata`) — §설계 8 보안 기준 검증
- `audit_handler_test.go`: `campId` 쿼리 파라미터가 `usecase.AuditLogQuery.CampID`로 올바르게 매핑되는지
- `audit_log_page_notifier_test.dart`: `selectedCampIdProvider` 변경 시 재조회되고 `campId`가 요청에 실리는지
- `audit_log_table_test.dart`(또는 기존 `audit_log_screen_test.dart` 확장): 스냅샷 값 우선 표시, 팝업 오픈 동작

### 실기기/수동 테스트

- 관리자 iPad에서 두 개의 서로 다른 캠프를 오가며 감사 로그 화면 진입 시 스코프가 바뀌는지 확인
- 트랙/코너/조/배지 삭제 후 감사 로그에서 대상 이름이 여전히 읽히는지 확인

---

## 범위 밖 (별도 논의 필요)

- **과거 로그 backfill**: 마이그레이션 이전에 쌓인 기존 `audit_logs` 레코드의 `camp_id`를
  소급 계산해 채울지 여부는 이번 계획에 포함하지 않았다. `target`이 여전히 살아있는 엔티티라면
  일회성 스크립트로 역산이 가능하지만(예: `target`이 `trackID`면 현재 코너/캠프 조인), 이미
  삭제된 엔티티는 원천적으로 복원 불가능하다. 필요 여부와 허용 가능한 정확도를 사용자와 별도로
  확인 후 진행.
- **`ADMIN_LOGIN` 등 계정 단위 로그의 캠프 화면 노출 방침**: `camp_id NULL` 로그를 캠프별
  화면에서 완전히 숨길지, 별도 "전역" 탭으로 노출할지는 UX 결정이 필요해 이번 계획은 "숨김"을
  기본값으로 제안만 하고 화면 설계 확정은 범위 밖으로 둔다.
