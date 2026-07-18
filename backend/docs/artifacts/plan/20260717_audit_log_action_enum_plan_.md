# 감사 로그 Action Enum화 (Issue #118)

## 배경

`GET /audit-logs`의 `action` 쿼리 파라미터(`api/swagger.yaml:921~948`)가 정확 일치 문자열 필터인데
유효값 목록(enum)이 API 계약 어디에도 없다. 실제로는 11개 usecase 파일에 33개의 action 문자열
리터럴이 하드코딩되어 있고 이를 모아둔 상수가 없다.

## 채택 대안

usecase 계층에 `AuditAction` 상수 레지스트리를 신설한다 (`usecase.NotificationEvent`,
`port.go:185~203`와 동일 패턴). `domain.AuditLog.action`은 그대로 `string`으로 두어 도메인
계층은 변경하지 않는다.

## 1. 유즈케이스 우선 정의

| 우선순위 | 유즈케이스 | 설명 | 용도 |
| --- | --- | --- | --- |
| **P0** | UC-1: action 상수 레지스트리 | 33개 action 리터럴을 `usecase.AuditAction` 단일 소스로 통합 | **API 계약 갭 해소** |
| **P0** | UC-2: `GET /audit-logs` action 검증/문서화 | swagger enum 노출 + 알 수 없는 action 값 400 처리 | **프로덕션 핵심 로직** |
| P1 | UC-3: 회귀 테스트 | 상수 완전성 검증 + 핸들러 검증 테스트 | 테스트/검증용 |

## 2. 객체 중심 설계

```go
// internal/usecase/audit_action.go (신규)
type AuditAction string

const (
	ActionAdminLogin          AuditAction = "ADMIN_LOGIN"
	ActionAdminCreate         AuditAction = "ADMIN_CREATE"
	ActionAdminPasswordChange AuditAction = "ADMIN_PASSWORD_CHANGE"
	ActionAdminDelete         AuditAction = "ADMIN_DELETE"
	ActionAdminSessionRevoke  AuditAction = "ADMIN_SESSION_REVOKE"
	ActionTrackForceLogout    AuditAction = "TRACK_FORCE_LOGOUT"
	ActionFacilitatorLogin    AuditAction = "FACILITATOR_LOGIN"
	ActionSessionMigrate      AuditAction = "SESSION_MIGRATE"
	ActionFacilitatorLogout   AuditAction = "FACILITATOR_LOGOUT"
	ActionBadgeAssign         AuditAction = "BADGE_ASSIGN"
	ActionBadgeBulkGenerate   AuditAction = "BADGE_BULK_GENERATE"
	ActionBadgeExport         AuditAction = "BADGE_EXPORT"
	ActionCampActivate        AuditAction = "CAMP_ACTIVATE"
	ActionCampEnd             AuditAction = "CAMP_END"
	ActionCampCreate          AuditAction = "CAMP_CREATE"
	ActionCampSettingsUpdate  AuditAction = "CAMP_SETTINGS_UPDATE"
	ActionCornerUpdate        AuditAction = "CORNER_UPDATE"
	ActionCornerDelete        AuditAction = "CORNER_DELETE"
	ActionCornerCreate        AuditAction = "CORNER_CREATE"
	ActionDeviceApproved      AuditAction = "DEVICE_APPROVED"
	ActionDeviceRejected      AuditAction = "DEVICE_REJECTED"
	ActionDeviceRevoked       AuditAction = "DEVICE_REVOKED"
	ActionPinLockReset        AuditAction = "PIN_LOCK_RESET"
	ActionDeviceRequest       AuditAction = "DEVICE_REQUEST"
	ActionGroupCreate         AuditAction = "GROUP_CREATE"
	ActionMessageDirect       AuditAction = "MESSAGE_DIRECT"
	ActionMessageBroadcast    AuditAction = "MESSAGE_BROADCAST"
	ActionTrackCreate         AuditAction = "TRACK_CREATE"
	ActionTrackDelete         AuditAction = "TRACK_DELETE"
	ActionTrackReplace        AuditAction = "TRACK_REPLACE"
	ActionPinRegenerate       AuditAction = "PIN_REGENERATE"
	ActionTrackPinExport      AuditAction = "TRACK_PIN_EXPORT"
	ActionVisitStart          AuditAction = "VISIT_START"
	ActionVisitComplete       AuditAction = "VISIT_COMPLETE"
)

// AuditActions는 swag Enums() 주석 및 검증 로직의 단일 소스다.
func AuditActions() []AuditAction { /* 위 33개 반환 */ }

// IsValidAuditAction은 웹 핸들러의 쿼리 파라미터 검증에 사용된다.
func IsValidAuditAction(raw string) bool
```

각 서비스에 중복 정의된 `recordAuditLog` 헬퍼 시그니처 변경 (예: `internal/usecase/corner.go:141`):

```go
// before
func (s *CornerService) recordAuditLog(ctx context.Context, actor, action, target string, success bool, metadata map[string]any)

// after — action만 타입 변경, 나머지 파라미터/바디 로직 동일
func (s *CornerService) recordAuditLog(ctx context.Context, actor string, action AuditAction, target string, success bool, metadata map[string]any) {
	// 내부에서 domain.NewAuditLog(..., string(action), ...) 로 캐스팅 — domain 계층은 그대로 string
}
```

`announcement.go`는 `recordAuditLog` 헬퍼가 없고 `domain.NewAuditLog(...)`를 2곳에서 직접
호출하므로, 리터럴 `"MESSAGE_BROADCAST"`를 `string(ActionMessageBroadcast)`로 개별 치환한다.

## 3. 아키텍처 원칙 명시

- `domain` 패키지 변경 없음 — `AuditLog.action`은 그대로 `string`, 생성자 시그니처도 불변.
- `usecase.AuditLogQuery.Action`(`port.go`)도 `string` 유지 — 이건 DB 필터로 그대로 흘러가는
  값이라 도메인 타입으로 승격할 이유가 없음. 핸들러가 검증 후 `string`으로 넘긴다.
- 새 리포지토리/포트 인터페이스 신설 없음. `usecase.NotificationEvent`(`port.go:185~203`)와
  동일한 "usecase 계층 상수 레지스트리" 패턴을 재사용한다.

## 4. 계층별 책임 분리

### Usecase 계층 (신규 1 + 기존 11개 파일)

- `internal/usecase/audit_action.go` (신규): `AuditAction` 타입, 33개 상수, `AuditActions()`,
  `IsValidAuditAction()`.
- `recordAuditLog` 시그니처 변경 대상 10개 파일: `auth_admin.go`, `auth_facilitator.go`,
  `badge.go`, `camp.go`, `corner.go`, `device_trust.go`, `group.go`, `message.go`, `track.go`,
  `visit.go`.
- `announcement.go`: 직접 호출 2곳의 리터럴 치환.
- 위 11개 파일에 흩어진 79개 호출부의 문자열 리터럴을 대응 상수로 치환.

### Infrastructure/Web 계층

- `internal/infrastructure/web/audit_handler.go`
  - `// @Param action query string false "행위 종류 정확히 일치" Enums(ADMIN_LOGIN,...)` — 33개
    값을 swag 주석에 명시.
  - `AuditLogResponse.Action` 필드에 `enums:"ADMIN_LOGIN,..."` 태그 추가 (응답 스키마도 문서화).
  - 핸들러 바디에 `action` 쿼리 검증 추가 — `result` 파라미터와 동일한 패턴으로 알 수 없는
    값이면 400 (`usecase.IsValidAuditAction` 사용).
- `api/swagger.yaml` / `api/swagger.json` / `api/docs.go` — `make swag`로 재생성
  (`workflow/Collaborate.md` 프로토콜: PR에 반드시 포함).

## 5. 구현 단계

### Phase A: usecase 상수 레지스트리 (예상 소요: 1시간)

| 순서 | 작업 | 파일 |
| --- | --- | --- |
| A-1 | `AuditAction` 타입 + 33개 상수 + `AuditActions()`/`IsValidAuditAction()` 작성 | `internal/usecase/audit_action.go` (신규) |
| A-2 | 10개 서비스의 `recordAuditLog` 시그니처를 `action AuditAction`으로 변경, 내부 `string(action)` 캐스팅 | 위 10개 파일 |
| A-3 | 79개 호출부의 문자열 리터럴을 대응 상수로 치환 | 위 10개 파일 + `announcement.go` |

### Phase B: 핸들러 검증 및 스웨거 반영 (예상 소요: 1시간)

| 순서 | 작업 | 파일 |
| --- | --- | --- |
| B-1 | swag `Enums(...)` 주석 + 응답 DTO `enums` 태그 추가, action 쿼리 검증 로직(400) 추가 | `internal/infrastructure/web/audit_handler.go` |
| B-2 | `make swag` 재생성 | `api/swagger.yaml`, `api/swagger.json`, `api/docs.go` |

### Phase C: 테스트 (예상 소요: 30분)

| 순서 | 작업 | 파일 |
| --- | --- | --- |
| C-1 | 기존 `TestListAuditLogsShoudApplyFiltersAndCursorWhenValid`의 플레이스홀더 `action=UPDATE_CAMP`를 실제 유효값 `CAMP_SETTINGS_UPDATE`로 교체 (안 하면 새 검증 때문에 깨짐) | `audit_handler_test.go` |
| C-2 | `TestListAuditLogsShoudRejectInvalidParametersWhenMalformed` 테이블에 `"/audit-logs?action=UNKNOWN_ACTION"` 케이스 추가 | `audit_handler_test.go` |
| C-3 | `AuditActions()` 33개 유일성 검증 테스트 추가 (`ShouldReturnUniqueValuesWhenListed`) | `internal/usecase/audit_action_test.go` (신규) |

## 8. 검증 체크리스트

### 8.1 아키텍처 검증

- [x] `internal/domain/` 하위 변경 없음 (git status로 확인, backend/internal/domain 변경분 없음)
- [x] 신규 파일(`audit_action.go`)도 표준 라이브러리 외 아무것도 import하지 않음

### 8.2 유즈케이스 검증

- [x] UC-1: 잔여 action 리터럴 없음 확인 (`audit_action.go`의 상수 선언 자체만 매치, 호출부 없음)
- [x] UC-2: `swagger.yaml`의 `action` 파라미터와 `AuditLogResponse.action`에 33개 enum 반영
- [x] UC-2: `GET /audit-logs?action=존재하지않는값` 요청 시 400 반환 (테스트로 검증)
- [x] UC-3: `go test ./...` 전체 통과, `gofmt -w . && go vet ./...` 클린

## 결정 사항

- **런타임 400 검증**: 사용자 확인 결과 포함하기로 결정. `result` 파라미터와 동일한 패턴으로
  `usecase.IsValidAuditAction`을 이용해 검증하고, 알 수 없는 값은 400을 반환하도록 구현 완료.

## 구현 결과 요약

- Phase A~C 전항목 구현 완료. `internal/usecase/audit_action.go` 신규(33개 상수 + `AuditActions()`
  + `IsValidAuditAction()`), 11개 usecase 파일의 79개 리터럴 호출부 치환, `audit_handler.go`
  swag enum/검증 추가, `make swag` 재생성, 관련 테스트 3건 신규 + 기존 2건 갱신.
- `go build ./...`, `go vet ./...`, `go test ./...` 전체 통과. `internal/domain/` 무변경.
