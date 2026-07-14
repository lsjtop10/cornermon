# SSE Broadcaster 캠프 격리 및 Scope 타입화 구현 계획

> 구현 상태 (2026-07-14): Phase A-E 및 Swagger/자동 검증 완료. 인증된 로컬 서버 수동 연결만 미실행.

## 1. 개요 및 변경 사유

`internal/infrastructure/sse/broadcaster.go` 검토 및 논의 끝에 아래 항목을 확정한다.

1. **캠프 간 이벤트 누수**: `Broadcast(ctx, campID, event, scope)`가 `campID` 파라미터를 완전히 무시한다. `adminSubs`/`trackSubs`가 캠프별로 파티셔닝되어 있지 않아, 캠프 A의 이벤트가 캠프 B에 연결된 admin/track 구독자에게도 전달된다. 호출부(`camp.go`, `track.go`, `message.go`, `visit.go` 등)는 모두 실제 `domain.CampID`를 넘기므로 멀티 캠프 운영을 전제로 하며, 이는 캠프 간 격리 위반이다.
2. **`scope string` 매직 스트링**: `"broadcast"`/`"camp"`/`"track:"+trackID`를 문자열 파싱(`strings.HasPrefix`)으로 처리한다. `"broadcast"`와 `"camp"`는 현재 로직상 완전히 동일하게 동작하므로 구분할 실익이 없다. → `Scope` 구조체(`ScopeCamp`/`ScopeTrack`)로 대체한다. **`Scope`에는 `CampID`를 넣지 않는다** — campID는 이미 `Broadcast`의 별도 파라미터로 전달되고, Scope는 "그 캠프 내부에서 누구에게 보낼지"만 표현하는 별개의 축이기 때문이다.
3. **SSE payload가 domain/usecase 타입을 그대로 문자열 포맷팅**: `fmt.Sprintf("event: %s\ndata: {\"scope\": \"%s\"}", ...)`는 web 계층 밖(`infra/sse`)에서 조립되고 있어, Swagger 문서만 봐서는 프론트가 실제 SSE payload 모양을 알 수 없다. `f960f76`(#57)에서 확립된 "web DTO는 handler에 응집, `@name`으로 Swagger 모델명 명시" 관례에 따라 **SSE 텍스트 프레이밍(직렬화)은 web 계층으로 옮긴다.**
4. **계층 분리 원칙**: `CLAUDE.md`의 패키지 레이아웃(`adapter/sse`가 `adapter/http`와 별도 어댑터로 명시됨)에 따라 `sse` 패키지는 계속 독립적으로 유지한다. 단, `sse`는 **구조화된 값(`event`, `scope`)의 구독자 레지스트리 + fan-out만 담당**하고, SSE 텍스트 프레이밍(`event: ...\ndata: ...\n\n`)은 하지 않는다. 근거:
   - `usecase`의 정합성 규칙("커밋 후에만 broadcast")은 이미 usecase 계층에만 존재하고 어댑터 구현과 무관 — 포트/어댑터 분리가 정상 동작 중이라는 신호.
   - 구독자 레지스트리(campID 파티셔닝, ctx 기반 정리, 버퍼 full 처리)는 전송 포맷과 무관하게 재사용 가능해야 하고, 텍스트 프레이밍만 전송 포맷(SSE)에 종속적이므로 이 둘을 분리해야 향후 전송 방식이 바뀌어도(예: protobuf) 레지스트리 로직을 그대로 재사용할 수 있다.
5. **버퍼 full 구독자 처리**: 클라이언트가 하트비트 미수신으로 재연결 여부를 판단하는 흐름을 고려해, non-blocking 전송 버퍼(cap 100)가 가득 찬 구독자는 "죽은 연결"로 간주하고 즉시 채널을 제거·close하여 클라이언트가 빠르게 재연결하도록 한다.
6. **라우트 경로**: Admin 인증은 캠프에 종속되지 않는 전역 세션이므로 admin 구독의 캠프 소속은 URL 경로로 명시한다. 이 프로젝트는 이미 issue #45에서 "쿼리스트링/활성 캠프 자동 탐색 → 명시적 path param(`/camps/{campId}/...`)"으로 마이그레이션한 전례가 있고, `reports`/`corners`/`tracks`/`groups`가 전부 `/camps/:campId/<리소스>` 하위에 있으므로 admin SSE 구독도 동일 관례를 따라 `/camps/:campId/events/admin`으로 둔다.

---

## 2. 유즈케이스 정의 및 우선순위

| 우선순위 | 유즈케이스 | 설명 | 용도 |
| :--- | :--- | :--- | :--- |
| **P0** | UC-SSE-8: `Scope` 타입 도입 | `scope string` → `usecase.Scope`(`ScopeCamp`/`ScopeTrack`) | **프로덕션 핵심 포트 변경** |
| **P0** | UC-SSE-9: Admin 구독 캠프 격리 | `/camps/:campId/events/admin` 라우트, `adminSubs`를 캠프별로 파티셔닝 | **프로덕션 핵심 로직** |
| **P0** | UC-SSE-10: Track 구독 캠프 격리 | `SubscribeTrack`이 트랙의 소속 campID를 함께 저장, `Broadcast`가 campID 불일치 트랙 제외 | **프로덕션 핵심 로직** |
| **P0** | UC-SSE-13: SSE 프레이밍 web 계층 이관 | `sse`는 구조화 메시지(`SSEMessage`)만 채널로 전달, `event_handler.go`가 SSE 텍스트/JSON 직렬화 | **프로덕션 계층 정리** |
| **P1** | UC-SSE-11: 버퍼 풀 구독자 강제 종료 | non-blocking 전송 실패(버퍼 full) 시 해당 구독 채널을 즉시 제거·close | **프로덕션 안정성 개선** |
| **P1** | UC-SSE-12: 호출부 마이그레이션 | `camp.go`/`track.go`/`message.go`/`visit.go`/`device_trust.go`/`auth_facilitator.go`의 문자열 scope 호출을 `Scope` 값으로 교체 | **기존 기능 유지 보수** |

---

## 3. 객체 및 인터페이스 정의

### 3.1 `Scope` 및 `SSEMessage` 타입 (internal/usecase/port.go, 기존 파일 확장)

```go
type ScopeKind string

const (
	ScopeCamp  ScopeKind = "camp"
	ScopeTrack ScopeKind = "track"
)

// Scope는 campID로 식별된 캠프 내부에서 이벤트를 받을 대상을 좁히는 기준이다.
// CampID는 Broadcast의 별도 파라미터로 전달되므로 Scope에는 포함하지 않는다.
type Scope struct {
	Kind    ScopeKind
	TrackID domain.TrackID // Kind == ScopeTrack일 때만 사용
}

func CampScope() Scope
func TrackScope(trackID domain.TrackID) Scope

// SSEMessage는 Broadcaster가 구독 채널로 전달하는 구조화된 알림이다.
// 텍스트/JSON 직렬화는 이 타입을 소비하는 web 계층의 책임이다.
type SSEMessage struct {
	Event NotificationEvent
	Scope Scope
}

type Broadcaster interface {
	Broadcast(ctx context.Context, campID domain.CampID, event NotificationEvent, scope Scope) error
}
```

### 3.2 `BroadcasterImpl` 재설계 (internal/infrastructure/sse/broadcaster.go, 기존 파일 수정)

`sse` 패키지는 **구독자 레지스트리 + campID/Scope 기반 fan-out만** 담당한다. 텍스트 조립은 하지 않는다.

```go
type trackSubscription struct {
	campID domain.CampID
	chans  map[chan usecase.SSEMessage]struct{}
}

type BroadcasterImpl struct {
	mu        sync.RWMutex
	adminSubs map[domain.CampID]map[chan usecase.SSEMessage]struct{}
	trackSubs map[domain.TrackID]*trackSubscription
}

func NewBroadcaster() *BroadcasterImpl

// 책임: campID의 adminSubs와, campID가 일치하는 trackSubs에만
// usecase.SSEMessage를 non-blocking 전송한다.
// 전송 실패(버퍼 full)한 구독은 즉시 목록에서 제거하고 채널을 닫는다.
func (b *BroadcasterImpl) Broadcast(ctx context.Context, campID domain.CampID, event usecase.NotificationEvent, scope usecase.Scope) error

// 책임: campID에 소속된 admin 구독 채널을 등록하고 ctx 취소 시 정리한다.
func (b *BroadcasterImpl) SubscribeAdmin(ctx context.Context, campID domain.CampID) (<-chan usecase.SSEMessage, error)

// 책임: trackID(및 소속 campID)로 구독 채널을 등록하고 ctx 취소 시 정리한다.
func (b *BroadcasterImpl) SubscribeTrack(ctx context.Context, campID domain.CampID, trackID domain.TrackID) (<-chan usecase.SSEMessage, error)
```

- **버퍼 풀 처리(UC-SSE-11)**: `Broadcast` 순회 중 `select { case ch <- msg: default: <제거 대상으로 표시> }`로 처리하되, `RLock` 상태에서 맵을 직접 수정하지 않는다. 순회 중 발견한 "죽은 채널" 목록을 모았다가 순회 종료 후 `Lock`으로 전환해 일괄 제거 + `close(ch)`한다. `ctx.Done()` 감시 goroutine과 이중 close가 나지 않도록, 제거 시점에 맵에 채널이 여전히 존재하는지 확인 후 삭제한다.

### 3.3 SSE 텍스트 프레이밍 및 DTO (internal/infrastructure/web/event_handler.go, 기존 파일 수정)

```go
type EventSubscriber interface {
	SubscribeAdmin(ctx context.Context, campID domain.CampID) (<-chan usecase.SSEMessage, error)
	SubscribeTrack(ctx context.Context, campID domain.CampID, trackID domain.TrackID) (<-chan usecase.SSEMessage, error)
}

// SSENotification은 SSE data 라인에 실리는 JSON 페이로드의 Swagger 문서화용 모델이다.
// Event의 enums 태그는 수동으로 유지되므로, 3.1의 usecase.NotificationEvents()와
// 어긋나면 TestSSENotificationEventEnumSync(Phase E)가 실패하도록 강제한다.
type SSENotification struct {
	Event string `json:"event" enums:"tracks_updated,track_updated,corners_updated,groups_updated,camp_updated,messages_changed,track_deleted,track_replaced,session_revoked,camp_ended,device_registration_updated,lockout_alert" example:"tracks_updated"`
	Scope SSEScope `json:"scope"`
} // @name SSENotification

type SSEScope struct {
	Kind    string `json:"kind" enums:"camp,track" example:"camp"`
	TrackID string `json:"trackId,omitempty" format:"uuid"`
} // @name SSEScope

// 책임: usecase.SSEMessage를 받아 "event: <event>\ndata: <json>\n\n" 형태로 직렬화해 응답에 쓴다.
func formatSSEMessage(msg usecase.SSEMessage) (string, error)

// @Router /api/v1/camps/{campId}/events/admin [get]
func (h *EventHandler) AdminEvents(c echo.Context) error
```

- `AdminEvents`/`TrackEvents`의 `for { select { case msg, ok := <-ch: ... } }` 루프에서 `msg`(이제 `usecase.SSEMessage`)를 `formatSSEMessage`로 변환한 뒤 `Write`한다.
- `TrackEvents`는 URL에 `trackId`만 있으므로, 핸들러가 트랙 조회(기존 `TrackRepository` 포트 재사용)로 campID를 얻어 `SubscribeTrack`에 전달한다. 신규 포트를 만들지 않는다(3.2 원칙 준수).
- Swagger는 SSE 스트림 바디를 정식 스키마로 표현하는 표준 방법이 없으므로, `@Description`에 `SSENotification` 예시를 명시해 프론트가 참조할 수 있게 한다.

**드리프트 방지 (누락 감지)**: Go 구조체 태그는 컴파일 타임 문자열이라 상수 목록에서 자동 생성할 수 없다. 대신 3.1의 `NotificationEvent` 상수 블록 옆에 그 목록을 그대로 반영하는 헬퍼를 추가하고, 테스트로 태그와의 일치를 강제한다.

```go
// port.go, NotificationEvent 상수 블록 바로 아래에 위치시켜 상수 추가 시 눈에 띄게 한다.
func NotificationEvents() []NotificationEvent {
	return []NotificationEvent{
		EventTracksUpdated, EventTrackUpdated, EventCornersUpdated, EventGroupsUpdated,
		EventCampUpdated, EventMessagesChanged, EventTrackDeleted, EventTrackReplaced,
		EventSessionRevoked, EventCampEnded, EventDeviceRegistrationUpdated, EventLockoutAlert,
	}
}
```

```go
// event_handler_test.go
func TestSSENotificationEventEnumSync(t *testing.T) {
	tag := reflect.TypeOf(SSENotification{}).Field(0).Tag.Get("enums")
	tagValues := strings.Split(tag, ",")

	want := make([]string, 0, len(usecase.NotificationEvents()))
	for _, e := range usecase.NotificationEvents() {
		want = append(want, string(e))
	}

	sort.Strings(tagValues)
	sort.Strings(want)
	if !slices.Equal(tagValues, want) {
		t.Fatalf("SSENotification.Event enums 태그가 NotificationEvents()와 불일치: tag=%v want=%v", tagValues, want)
	}
}
```

이렇게 하면 `NotificationEvent` 상수를 추가하고 `NotificationEvents()`나 struct tag 중 하나만 갱신을 잊어도 `go test`가 즉시 실패한다. 여전히 사람이 두 곳을 손으로 맞춰야 하지만, "조용히 문서만 stale해지는" 상태에서 "테스트 빨간불"로 바뀐다.

### 3.4 라우터 (internal/infrastructure/web/router.go, 기존 파일 수정)

```go
// 변경 전: admin.GET("/events/admin", h.Event.AdminEvents)
// 변경 후:
admin.GET("/camps/:campId/events/admin", h.Event.AdminEvents)
```

---

## 4. 호출부 마이그레이션 (UC-SSE-12)

기존 문자열 scope 호출을 `Scope` 값으로 교체한다. 대상 범위(누구에게 보내는지)는 변경하지 않는다.

| 파일 | 변경 전 | 변경 후 |
| :--- | :--- | :--- |
| `internal/usecase/camp.go` (L100, 133, 180, 181) | `"camp"` | `CampScope()` |
| `internal/usecase/track.go` (L106, 180, 285, 349) | `"camp"` | `CampScope()` |
| `internal/usecase/track.go` (L181, 286, 350) | `"track:"+string(trackID)` | `TrackScope(trackID)` |
| `internal/usecase/message.go` (L109) | `"broadcast"` | `CampScope()` |
| `internal/usecase/message.go` (L165) | `"track:"+string(trackID)` | `TrackScope(trackID)` |
| `internal/usecase/visit.go`, `device_trust.go`, `auth_facilitator.go` | 동일 패턴 | 동일 규칙 적용 |

`cmd/server/main.go`의 `sse.NewBroadcaster()` 호출부는 시그니처 변경이 없으므로 그대로 둔다.

---

## 5. 구현 단계 (Implementation Phases)

### Phase A: 포트 계층 타입 도입 (예상 소요: 0.5시간)
| 순서 | 작업 | 파일 |
| :--- | :--- | :--- |
| A-1 | `Scope`/`ScopeKind`/`SSEMessage`/생성자 함수 정의, `Broadcaster` 인터페이스 시그니처 변경 | `backend/internal/usecase/port.go` |

### Phase B: Broadcaster 구독자 레지스트리 재작성 (예상 소요: 2시간)
| 순서 | 작업 | 파일 |
| :--- | :--- | :--- |
| B-1 | `adminSubs`/`trackSubs`를 캠프 인지 구조로 재작성, `Broadcast`에 campID/Scope 필터링 적용 (채널 타입 `chan usecase.SSEMessage`) | `backend/internal/infrastructure/sse/broadcaster.go` |
| B-2 | 버퍼 full 구독자 감지 시 제거+close 로직 추가 (Lock 전환 방식) | `backend/internal/infrastructure/sse/broadcaster.go` |

### Phase C: web 계층 프레이밍 및 라우팅 반영 (예상 소요: 1.5시간)
| 순서 | 작업 | 파일 |
| :--- | :--- | :--- |
| C-1 | `EventSubscriber` 인터페이스 시그니처 변경, `SSENotification`/`SSEScope` DTO 추가, `formatSSEMessage` 구현 | `backend/internal/infrastructure/web/event_handler.go` |
| C-2 | `AdminEvents`/`TrackEvents`가 `usecase.SSEMessage`를 받아 직렬화하도록 루프 수정, `TrackEvents`에서 트랙 조회로 campID 획득 | `backend/internal/infrastructure/web/event_handler.go` |
| C-3 | 라우트를 `/camps/:campId/events/admin`으로 변경 | `backend/internal/infrastructure/web/router.go` |
| C-4 | Swagger 주석(`@Router`, `@Param campId`, `@Description` 예시) 갱신 후 산출물 재생성 | `backend/internal/infrastructure/web/event_handler.go`, `api/swagger.yaml` |

### Phase D: 호출부 마이그레이션 (예상 소요: 1시간)
| 순서 | 작업 | 파일 |
| :--- | :--- | :--- |
| D-1 | 문자열 scope → `Scope` 값 치환 | `backend/internal/usecase/camp.go`, `track.go`, `message.go`, `visit.go`, `device_trust.go`, `auth_facilitator.go` |
| D-2 | `MockBroadcaster` 및 관련 테스트 헬퍼가 `Scope`/`SSEMessage` 값을 기록하도록 수정 | `backend/internal/usecase/mock_test.go` |

### Phase E: 테스트 (예상 소요: 2시간)
| 순서 | 작업 | 파일 |
| :--- | :--- | :--- |
| E-1 | 기존 usecase 테스트의 scope 문자열 단언을 `Scope` 값 단언으로 수정 | `backend/internal/usecase/camp_test.go`, `track_test.go`, `message_test.go` |
| E-2 | 캠프 A/B 동시 구독 시 이벤트가 서로 격리되는지 검증하는 신규 테스트 | `backend/internal/infrastructure/sse/broadcaster_test.go` |
| E-3 | 버퍼 full 상황에서 구독 채널이 close되는지 검증하는 테스트 | `backend/internal/infrastructure/sse/broadcaster_test.go` |
| E-4 | `formatSSEMessage` 직렬화 결과(JSON 필드/이벤트 이름) 검증 및 라우트/시그니처 변경 반영 | `backend/internal/infrastructure/web/event_handler_test.go` |
| E-5 | `TestSSENotificationEventEnumSync` 추가 — `SSENotification.Event`의 `enums` 태그와 `usecase.NotificationEvents()`가 항상 일치하도록 강제 | `backend/internal/infrastructure/web/event_handler_test.go` |

---

## 6. 검증 체크리스트

### 6.1 아키텍처 검증
- [x] `domain` 패키지에 infrastructure import 없음
- [x] `usecase`는 `Broadcaster` 인터페이스에만 의존(구체 구현 모름), `sse`/`web` 어느 쪽도 `usecase`가 import하지 않음
- [x] `sse` 패키지에 SSE 텍스트 프레이밍(`fmt.Sprintf("event: ...")`) 코드가 없음 — 구독자 레지스트리/fan-out만 존재
- [x] 모든 신규/변경 메서드의 첫 번째 인자는 `context.Context`

### 6.2 유즈케이스 검증
- [x] UC-SSE-8: `scope` 문자열을 전달하던 모든 호출부가 `Scope` 값으로 컴파일 성공
- [x] UC-SSE-9: 캠프 A admin 구독이 캠프 B의 `Broadcast` 이벤트를 받지 않음 (동시성 테스트)
- [x] UC-SSE-10: 캠프 A의 `ScopeCamp` 브로드캐스트가 캠프 B 소속 track 구독자에게 전달되지 않음
- [x] UC-SSE-11: 구독 채널 버퍼(100)가 가득 찬 상태에서 `Broadcast` 호출 시 해당 채널이 close되고 `adminSubs`/`trackSubs`에서 제거됨
- [x] UC-SSE-12: 기존 admin/track 단일 캠프 시나리오에서 알림 수신 동작이 회귀 없이 동일함(`go test ./...` 통과)
- [x] UC-SSE-13: `event_handler.go`에서 만들어진 SSE 텍스트가 기존과 동일한 `event: X\ndata: {...}` 형태를 유지함(클라이언트 파싱 회귀 없음)

### 6.3 API 계약 검증
- [x] `admin.GET("/camps/:campId/events/admin", ...)` 라우트가 Swagger 주석 및 `api/swagger.yaml`과 일치
- [x] `SSENotification`/`SSEScope`가 Swagger 문서에 `@name`으로 노출되어 프론트가 payload 모양을 문서만으로 파악 가능
- [x] `SSENotification.Event`의 `enums` 태그가 `port.go`의 `NotificationEvent` 상수 전체와 정확히 일치 — enum 동기화 테스트가 통과함으로써 수동 확인이 아니라 테스트로 보증
- [x] `workflow/Collaborate.md` 프로토콜에 따라 API 경로 변경 사실을 PR에 명시해 프론트엔드에 공유

### 6.4 실행 검증
- [x] `go test ./...`
- [x] `go test -race ./internal/infrastructure/sse ./internal/infrastructure/web ./internal/usecase`
- [ ] 로컬 서버 기동 후 `curl -N .../camps/{campId}/events/admin`으로 SSE 연결, JSON payload 형태, heartbeat 수신 수동 확인
