# 도메인 모델 구현 계획서 (domain_model_plan_20260709.md)

> 근거 문서: `docs/domain/domain-model.md`(유비쿼터스 언어·엔티티·상태머신), `docs/technical-design.md`(§1 아키텍처 원칙, §2 도메인→구현 매핑), `api/openapi.yaml`(필드명·타입 계약).
> 대상 범위: `backend/internal/domain` 패키지 신규 구현. `usecase`(포트/트랜잭션), `infrastructure`(Postgres/SSE), `interfaces/http`(DTO/핸들러) 계층은 이 계획의 범위 밖이며 후속 Plan에서 다룬다.
> `docs/domain/analytics-model.md`의 집계 지표는 "모든 지표는 파생값"(§0-1) 원칙에 따라 Visit/AuditLog로부터 계산되는 조회 전용 결과이므로, 상태를 갖는 도메인 엔티티가 아니다 — 이 Plan에서는 다루지 않고 리포트 조회 유즈케이스(usecase 계층) Plan에서 별도로 다룬다.

---

## 1. 유즈케이스 정의

| 우선순위 | 유즈케이스 | 설명 | 용도 |
| --- | --- | --- | --- |
| **P0** | UC-0: 공통 기반 타입 구현 | ID 타입, 도메인 sentinel 에러 정의 | 이후 모든 UC의 전제 조건 |
| **P0** | UC-1: 캠프 생명주기 구현 (Camp) | PENDING→ACTIVE→ENDED 단방향 전이, 병목 판정 파라미터 보유 | **프로덕션 핵심 로직** — 전체 스코프 경계 |
| **P0** | UC-2: 배지·조 도메인 구현 (Badge, Group) | 배지 등록→조 생성, 10개 코너 순회표, 완주 판정, 단일 진행/중복 방문 불변식 | **프로덕션 핵심 로직** |
| **P0** | UC-3: 코너·트랙 도메인 구현 (Corner, Track) | 트랙 생명주기(ACTIVE/DELETED), 동시 진행 제약, 삭제 하드 블록, PIN 재발급 | **프로덕션 핵심 로직** |
| **P0** | UC-4: 방문 도메인 구현 (Visit) | 시작/종료, 소요시간·목표시간편차 계산 | **프로덕션 핵심 로직** |
| P1 | UC-5: 기기 신뢰·진행자 세션 구현 (DeviceRegistration, FacilitatorSession) | 신뢰 토큰 상태머신, PIN 실패 점증형 지연 정책 | 인증/보안 핵심 |
| P1 | UC-6: 관리자·세션 구현 (Admin, AdminSession) | 액세스/리프레시 이원화, 슬라이딩 만료, 즉시 회수 | 인증/보안 핵심 |
| P1 | UC-7: 메시지·감사로그 구현 (Message, BroadcastReceipt, AuditLog) | 공지/다이렉트 채널, 감사 이벤트 불변 기록 | 운영 지원 |
| P2 | UC-8: 단위 테스트 작성 | UC-1~7의 불변식별 테이블 기반 테스트 | 검증/회귀 방지 |

---

## 2. 아키텍처 원칙 명시 (§technical-design.md 1.1 준수)

1. **도메인 순수성**: `domain` 패키지는 `infrastructure`, `interfaces`, DB 드라이버(pgx), HTTP, SSE 등 어떤 프레임워크 타입도 import하지 않는다. 표준 라이브러리(`time`, `errors`)와 `domain` 내부 타입만 사용한다.
2. **의존성 역전**: Repository/Broadcaster 등 포트 인터페이스는 이 Plan의 범위가 아니라 `usecase` 계층이 정의한다. `domain` 타입은 저장 방식을 모른다 — 메서드는 순수 계산/상태 전이만 수행하고 `error`를 반환할 뿐 IO를 하지 않는다.
3. **컨텍스트 인자 규칙의 예외**: 개발 가이드라인의 "모든 메서드 첫 인자는 `context.Context`"는 IO를 수행하는 Service/Infra 계층 규칙이다. `domain` 계층 메서드는 IO가 없는 순수 함수이므로 `context.Context`를 받지 않는다(표준 Go 관례와도 일치).
4. **네이밍 일관성**: 모든 타입·필드명은 `docs/domain/domain-model.md`의 유비쿼터스 언어 및 `api/openapi.yaml`의 스키마 필드명과 1:1 대응시킨다(예: `TargetMinutes` ↔ `targetMinutes`, `DeviationSeconds` ↔ `deviationSeconds`).
5. **포인터로 "값 없음"을 표현하지 않는다**: 포인터(`*T`)는 오직 실제 간접 참조(예: `func (t *Track) ...` 리시버, `*Track`을 인자로 받아 그 엔티티를 참조하는 경우)에만 쓴다. "이 필드가 아직 지정되지 않았을 수 있다"는 의미는 `nil` 컨벤션 대신 `Optional[T]`(§3.0)로 명시적으로 표현한다. 상세 근거는 §2-f 참고.

### 2-a. 계층별 책임 분리 (이 Plan에서의 경계)

- **Domain (이 Plan의 범위)**: 엔티티 구조체 + 불변식을 강제하는 메서드.
- **Usecase (범위 밖)**: 여러 애그리게잇에 걸친 트랜잭션 조율(예: 트랙 교체 = 기존 `Track.Delete()` + 신규 `Track` 생성을 한 트랜잭션으로 묶음), Repository/Broadcaster 포트 정의, DB 커밋 후 SSE 스냅샷 브로드캐스트.
- **Infrastructure/Interfaces (범위 밖)**: Postgres 구현체, HTTP DTO 매핑, 인증 미들웨어.

### 2-b. 재시도/로깅 전략 — 해당 없음

도메인 계층은 IO를 수행하지 않으므로 `technical-design.md`가 언급하는 재시도(HTTP 5xx/타임아웃)나 구조화 로깅은 이 계층에 존재하지 않는다. 두 항목 모두 `usecase`/`infrastructure` Plan에서 다룬다.

### 2-c. 설계 판단 및 근거 (사용자 확인 완료, 2026-07-09)

1. **트랙 교체(Track Replacement)는 별도 도메인 타입을 두지 않는다.** `domain-model.md` §2.3은 이를 "관리자 오퍼레이션"으로 정의하며 자체 영속 상태가 없다 — 기존 `Track.Delete()`와 신규 `Track` 생성을 `usecase`가 한 트랜잭션으로 원자 처리하는 것으로 충분하다.
2. **코너 목표시간의 트랙별 override 필드는 이번 구현에서 제외하되, 조회 진입점은 지금 단일화해둔다.** `domain-model.md` §2.2는 "목표시간(트랙별 override 가능)"을 언급하지만, 이미 확정된 `api/openapi.yaml`의 `Track`/`TrackSummary` 스키마에는 해당 필드가 없다(코너 레벨 `targetMinutes`만 존재). API 계약을 따라 `Track.TargetMinutesOverride Optional[int]` 필드는 지금 추가하지 않는다. 다만 향후 확장 시 호출부(`usecase`) 변경 없이 도메인 내부만 수정할 수 있도록, 목표시간 조회를 `Corner.EffectiveTargetMinutes(track *Track) int` 단일 진입점으로 두고 지금은 `Track` 인자를 무시한 채 `c.TargetMinutes`만 반환한다(§3.4 참고).
3. **`Camp.ID`는 `Group`/`Corner`에 필드로 보관하지만 `api/openapi.yaml` 응답 바디에는 없다.** OpenAPI는 `/camps/{campId}/...` 경로로 스코프를 표현해 바디에서 생략했을 뿐이며, 도메인/영속 계층은 멀티 캠프 무결성을 위해 `CampID`를 명시적으로 들고 있어야 한다. DTO 매핑 시 이 필드를 제외하는 것은 `interfaces/http` 계층의 몫이다.

### 2-d. 결정론적 시간 주입 원칙

`domain` 계층은 어떤 메서드 내부에서도 `time.Now()`를 직접 호출하지 않는다. 상태 전이 시각이 필요한 모든 메서드는 `now time.Time`을 인자로 받는다.

- **이유 1 — 테스트 결정성**: 내부에서 `time.Now()`를 호출하면 테스트가 실제 시각에 의존하게 되어 재현 불가능해진다. 인자로 주입하면 테스트가 고정된 `time.Time` 값으로 모든 분기(예: PIN 지연 정책의 3회/4회/5회 경계)를 검증할 수 있다.
- **이유 2 — 한 트랜잭션 내 여러 애그리게잇 간 시각 일관성**: 예를 들어 방문 종료 처리 1건은 `Visit.Complete(now)`와 `Track.CompleteVisit(now)`를 같은 트랜잭션에서 함께 호출한다. `usecase`가 트랜잭션 시작 시 캡처한 `now` 값 하나를 두 호출에 동일하게 전달하면, 두 애그리게잇의 기록 시각이 밀리초 단위로 어긋나는 일이 구조적으로 불가능해진다.
- **적용 대상**: 상태나 시각을 기록하는 모든 전이 메서드(`Camp.Activate`, `Camp.End`, `Track.CompleteVisit`, `Track.Delete`, `Track.RegeneratePIN` 등). 반대로 시각을 기록하지도, 다른 애그리게잇과 시각을 맞출 필요도 없는 메서드(`Track.StartVisit`, `Group.MarkVisitStarted/Completed` — 시작/완료 시각은 `Visit`이 유일하게 소유)는 `now`를 받지 않는다. 즉 "모든 메서드에 무조건 추가"가 아니라 "시각을 실제로 쓰는 메서드에만 추가"가 원칙이다.

### 2-e. 애그리게잇 경계를 넘는 후속 조치 — 도메인 이벤트(신호) 반환

`domain-model.md` §2.4는 진행자 세션이 "강제 로그아웃, 트랙 삭제, 캠프 종료, 트랙 PIN 재발급" 4가지 조건에서만 즉시 무효화된다고 명시한다. 이 중 뒤 3가지(`Track.Delete`, `Camp.End`, `Track.RegeneratePIN`)는 **`Track`/`Camp` 애그리게잇이 스스로는 알 수 없는 `FacilitatorSession` 컬렉션에 대한 후속 조치**를 필요로 한다. `domain`은 `FacilitatorSessionRepository`를 모르므로(§2 원칙 2) 직접 회수할 수 없다 — 대신 "이 조치가 일어났다"는 최소 신호(이벤트 구조체)를 반환값으로 돌려주고, 실제 세션 조회·회수는 그 신호를 받은 `usecase`가 수행한다.

- 이 이벤트는 메시지 브로커에 발행하는 무거운 개념이 아니라, 함수 반환값으로 전달되는 순수 데이터 구조체다(§3.0-b).
- 이런 후속 조치가 없는 전이(`Camp.Activate`, `Track.CompleteVisit`처럼 세션 무효화를 유발하지 않는 경우)는 이벤트를 반환하지 않거나, 감사 로그 등 부가 용도로만 쓰이는 가벼운 신호만 반환한다.

### 2-f. Nil 포인터로 옵셔널을 표현하지 않는다 — `Optional[T]` 사용

Go에서 `*T` 필드가 `nil`이면 "값 없음"이라는 관례는 코드만 봐서는 그 필드가 "선택적 값"인지 "아직 로딩되지 않은 참조"인지 "버그로 초기화가 누락된 것"인지 구분할 수 없다. 이 도메인에는 `AssignedGroupID`(배지 미배정), `CurrentVisitID`(트랙 유휴), `EndedAt`(방문 진행 중), `RevokedAt`(세션 유효) 등 "아직 지정되지 않음"이 정상 상태인 필드가 많으므로, 이를 전부 `Optional[T]`(§3.0)로 표현해 의도를 타입에 새긴다.

- **포인터를 계속 쓰는 경우**: 엔티티 자체를 가리키는 진짜 참조(`func (t *Track) StartVisit(...)`의 리시버, `Corner.EffectiveTargetMinutes(track *Track)`의 인자 등). 이런 포인터는 "간접 참조"이지 "옵셔널 값"이 아니다.
- **`Optional[T]`로 바꾸는 경우**: ID 값(`GroupID`, `VisitID`, `TrackID`), 시각(`time.Time`), 숫자(`int`) 등 값 타입인데 "지정되지 않을 수 있는" 모든 필드/반환값. §3의 각 엔티티 정의에 이미 반영했다.
- **이점**: `if v, ok := badge.AssignedGroupID.Value(); ok { ... }`처럼 값 접근이 항상 존재 여부 확인을 강제하므로, nil 역참조 패닉이 컴파일 타임 관용구 수준에서 원천 차단된다.

---

## 3. 객체 중심 설계

### 3.0 Optional 값 타입 — `domain/optional.go` (§2-f 근거)

```go
// Optional[T]는 값이 명시적으로 지정되었는지 여부를 도메인 계층에서 표현하는 타입입니다.
//
// Go의 포인터(*T)가 "없을 수 있음"을 암묵적 컨벤션으로 표현하는 것과 달리,
// Optional[T]는 "지정되지 않음"이라는 상태를 도메인이 직접 소유합니다.
//
// 생성: Some(v) 또는 None[T]()
// 읽기: Value() — (T, bool) 튜플, IsSet() — bool
//
// Optional[T]는 불변(immutable) 값 타입이므로 별도의 동기화 없이 동시 읽기가 안전합니다.
type Optional[T any] struct {
    value T
    set   bool
}

// Some는 값이 지정된 Optional[T]를 반환합니다.
func Some[T any](v T) Optional[T] {
    return Optional[T]{value: v, set: true}
}

// None은 값이 지정되지 않은 Optional[T]를 반환합니다.
// Optional[T]의 zero value와 동일하게 동작합니다.
func None[T any]() Optional[T] {
    return Optional[T]{}
}

// IsSet은 값이 명시적으로 지정되었는지 반환합니다.
func (o Optional[T]) IsSet() bool {
    return o.set
}

// Value는 값과 지정 여부를 함께 반환합니다.
// 값이 지정되지 않은 경우 T의 zero value와 false를 반환합니다.
func (o Optional[T]) Value() (T, bool) {
    return o.value, o.set
}
```

### 3.0-a 공통 기반 — `domain/id.go`, `domain/errors.go`

```go
// domain/id.go
type CampID string
type GroupID string
type CornerID string
type TrackID string
type VisitID string
type BadgeID string
type DeviceRegistrationID string
type FacilitatorSessionID string
type AdminID string
type AdminSessionID string
type MessageID string
type AuditLogID string
```

```go
// domain/errors.go (책임: 각 애그리게잇 메서드가 반환할 sentinel 에러)
var (
    ErrCampInvalidTransition = errors.New("camp: invalid status transition")
    ErrGroupBusy             = errors.New("group: already in progress at another corner")
    ErrDuplicateVisit        = errors.New("group: corner already completed")
    ErrTrackNotActive        = errors.New("track: not active")
    ErrTrackBusy             = errors.New("track: visit already in progress")
    ErrTrackDeleteBlocked    = errors.New("track: cannot delete while visit in progress")
    ErrVisitAlreadyCompleted = errors.New("visit: already completed")
    ErrBadgeAlreadyAssigned  = errors.New("badge: already assigned")
    ErrBadgeNotAssigned      = errors.New("badge: not assigned")
    ErrDeviceNotApproved     = errors.New("device: not approved")
    ErrDeviceLocked          = errors.New("device: locked due to pin failures")
    ErrSessionRevoked        = errors.New("session: already revoked")
    ErrCornerNotInItinerary  = errors.New("group: corner not found in itinerary")
    ErrVisitNotInProgress    = errors.New("group: visit not in progress for this corner")
)
```

### 3.0-b 애그리게잇 간 신호 — `domain/event.go` (§2-e 근거)

```go
// 책임: 다른 애그리게잇(FacilitatorSession 등)에 대한 후속 조치가 필요함을
// usecase에 알리는 최소 데이터. domain은 이 신호를 만들기만 하며 발행/저장하지 않는다.

// Track.Delete 성공 시 반환 — 해당 트랙의 진행자 세션은 즉시 무효화되어야 한다 (§domain-model.md 2.4, 5-8)
type TrackDeletedEvent struct {
    TrackID    TrackID
    OccurredAt time.Time
}

// Track.RegeneratePIN 성공 시 반환 — 기존 진행자 세션은 즉시 무효화되어야 한다 (§domain-model.md 2.5)
type TrackPINRegeneratedEvent struct {
    TrackID    TrackID
    OccurredAt time.Time
}

// Camp.End 성공 시 반환 — 이 캠프에 속한 모든 트랙의 진행자 세션이 무효화되어야 한다 (§domain-model.md 2.4, 5-10)
// Camp는 소속 Track 목록을 모르므로(애그리게잇 분리), 실제 트랙 조회·전파는 usecase가 수행한다.
type CampEndedEvent struct {
    CampID     CampID
    OccurredAt time.Time
}

// Track.CompleteVisit 성공 시 반환 — 세션 무효화와는 무관하지만, usecase가 감사 로그/SSE 스냅샷을
// Visit.Complete(now)와 동일한 시각으로 정합성 있게 구성할 수 있도록 트랙이 비워진 시각을 함께 돌려준다.
type TrackFreedEvent struct {
    TrackID    TrackID
    OccurredAt time.Time
}
```

### 3.1 캠프 — `domain/camp.go` (UC-1)

```go
type CampStatus string

const (
    CampPending CampStatus = "PENDING"
    CampActive  CampStatus = "ACTIVE"
    CampEnded   CampStatus = "ENDED"
)

type Camp struct {
    ID                   CampID
    Name                 string
    StartAt, EndAt       time.Time            // 계획된 캠프 기간 (생성 시 입력)
    ActivatedAt          Optional[time.Time]  // 실제 ACTIVE 전이 시각 (Activate 성공 시 Some(now))
    EndedAt              Optional[time.Time]  // 실제 ENDED 전이 시각 (End 성공 시 Some(now))
    Status               CampStatus
    BottleneckMinSamples int // 기본값 3
    BottleneckRatioPct   int // 기본값 20
}

// 책임: PENDING -> ACTIVE -> ENDED 단방향 전이만 허용 (§domain-model.md 2.0, 5-12)
// now는 ActivatedAt/EndedAt에 그대로 기록되며(§2-d), 재현 가능한 테스트를 위해 호출부에서 주입한다.
func (c *Camp) Activate(now time.Time) error
// 반환된 CampEndedEvent는 usecase가 이 캠프 소속 전체 트랙의 진행자 세션을 무효화하는 트리거로 쓴다 (§2-e)
func (c *Camp) End(now time.Time) (CampEndedEvent, error)
func (c *Camp) IsActive() bool
```

### 3.2 배지 — `domain/badge.go` (UC-2)

```go
type BadgeStatus string // UNASSIGNED / ASSIGNED

type Badge struct {
    ID              BadgeID
    ShortID         string
    QRPayload       string
    Status          BadgeStatus
    AssignedGroupID Optional[GroupID] // 미배정(UNASSIGNED)이면 None
}

// 책임: 배지 등록(조 생성의 유일한 경로) 및 캠프 종료 후 재사용 전이 (§domain-model.md 2.1-a)
func (b *Badge) AssignTo(groupID GroupID) error
func (b *Badge) Release() error
```

### 3.3 조 — `domain/group.go` (UC-2, 도메인 핵심 불변식 집중)

```go
type GroupStatus string // IDLE_MOVING / AT_CORNER / FINISHED
type VisitStatusPerCorner string // NOT_VISITED / IN_PROGRESS / COMPLETED

type CornerProgress struct {
    CornerID CornerID
    Status   VisitStatusPerCorner
}

type Group struct {
    ID        GroupID
    CampID    CampID
    Name      string
    BadgeID   BadgeID
    Itinerary []CornerProgress // 10개 코너 순회표, 캠프의 코너 목록으로 초기화
}

// 책임: 순회표로부터 파생 상태 계산 (§domain-model.md 3.2)
func (g *Group) Status() GroupStatus
func (g *Group) IsFinished() bool

// 책임: 방문 시작/종료 시 순회표 갱신 + 핵심 불변식 강제
//   - 단일 진행 제약: 이미 다른 코너가 IN_PROGRESS면 ErrGroupBusy (§domain-model.md 2.1, 5-5)
//   - 중복 방문 금지: 대상 코너가 이미 COMPLETED면 ErrDuplicateVisit (§domain-model.md 2.1, 5-2)
func (g *Group) MarkVisitStarted(cornerID CornerID) error
func (g *Group) MarkVisitCompleted(cornerID CornerID) error
```

### 3.4 코너 — `domain/corner.go` (UC-3)

```go
type CornerOperationalStatus string // INACTIVE / IDLE / BUSY

type Corner struct {
    ID            CornerID
    CampID        CampID
    Name          string
    TargetMinutes int  // 기본값 10
    IsMandatory   bool // 확장 예약 필드, 현재 로직 미사용 (§domain-model.md 6-2)
}

// 책임: 소속 트랙들의 상태를 조합해 코너 파생 상태 계산 (§domain-model.md 3.3, api Corner.status)
func (c *Corner) OperationalStatus(tracks []*Track) CornerOperationalStatus

// 책임: 목표시간 조회 단일 진입점 (§2-c 근거)
// 현재는 track 인자를 쓰지 않고 c.TargetMinutes만 반환하지만, 트랙별 override가 필요해지면
// 이 메서드 내부만 수정하면 되고 호출부(usecase)는 시그니처 변경 없이 그대로 쓸 수 있다.
func (c *Corner) EffectiveTargetMinutes(track *Track) int
```

### 3.5 트랙 — `domain/track.go` (UC-3, 동시성 불변식 집중)

```go
type TrackStatus string            // ACTIVE / DELETED
type TrackOperationalStatus string // IDLE / BUSY

type Track struct {
    ID             TrackID
    CornerID       CornerID // 생성 후 불변 (§domain-model.md 5-7)
    TrackNo        int
    Status         TrackStatus
    PINHash        string
    CurrentVisitID Optional[VisitID]   // 진행 중인 방문이 없으면(IDLE) None
    DeletedAt      Optional[time.Time] // 실제 DELETED 전이 시각 (Delete 성공 시 Some(now))
}

// 책임: 트랙 단위 동시 진행 제약(최대 1개) 강제 (§domain-model.md 2.2, 5-1)
// 시작 시각은 Visit이 유일하게 소유하므로(§2-d) now를 받지 않는다.
func (t *Track) StartVisit(visitID VisitID) error

// 책임: 진행 중이던 방문을 트랙에서 해제. 반환된 TrackFreedEvent.OccurredAt은 같은 트랜잭션에서
// 호출되는 Visit.Complete(now)에 전달한 now와 동일한 값이어야 usecase 쪽 기록이 어긋나지 않는다 (§2-d, §2-e)
func (t *Track) CompleteVisit(now time.Time) (TrackFreedEvent, error)
func (t *Track) OperationalStatus() TrackOperationalStatus

// 책임: 진행 중인 방문이 있으면 하드 블록 (§domain-model.md 2.2, 5-8)
// 반환된 TrackDeletedEvent는 usecase가 이 트랙의 진행자 세션을 즉시 무효화하는 트리거로 쓴다 (§2-e)
func (t *Track) Delete(now time.Time) (TrackDeletedEvent, error)

// 책임: 엔티티/이력 유지한 채 PIN 값만 갱신 (§domain-model.md 2.5, 트랙 교체와 구분)
// 반환된 TrackPINRegeneratedEvent는 usecase가 기존 진행자 세션을 즉시 무효화하는 트리거로 쓴다 (§2-e)
func (t *Track) RegeneratePIN(newHash string, now time.Time) (TrackPINRegeneratedEvent, error)
```

### 3.6 방문 — `domain/visit.go` (UC-4)

```go
type VisitInputMethod string // QR_SCAN / MANUAL
type VisitStatus string      // IN_PROGRESS / COMPLETED

type Visit struct {
    ID          VisitID
    GroupID     GroupID
    CornerID    CornerID
    TrackID     TrackID
    Status      VisitStatus
    InputMethod VisitInputMethod
    StartedAt   time.Time
    EndedAt     Optional[time.Time] // 진행 중(IN_PROGRESS)이면 None
}

// 책임: 방문 생성 및 종료, 파생 시간 지표 계산 (§domain-model.md 2.6)
func NewVisit(id VisitID, groupID GroupID, cornerID CornerID, trackID TrackID, method VisitInputMethod, startedAt time.Time) *Visit
func (v *Visit) Complete(endedAt time.Time) error
func (v *Visit) DurationSeconds() Optional[int]
func (v *Visit) DeviationSeconds(targetMinutes int) Optional[int]
```

> `Track.StartVisit`/`CompleteVisit`과 `Group.MarkVisitStarted`/`MarkVisitCompleted`, `Visit` 자체는 서로 다른 애그리게잇에 속한 독립된 불변식이다. 한 번의 스캔 처리에서 셋을 함께 갱신하는 트랜잭션 조율은 `usecase` 계층의 책임이며, 이 Plan은 각 애그리게잇의 개별 규칙만 정의한다.
> **방문 종료 처리 시 usecase 호출 순서 예시**: 트랜잭션 시작 시 `now := time.Now()`를 한 번만 캡처 → `visit.Complete(now)` → `track.CompleteVisit(now)` (동일 `now` 전달, §2-d) → `corner.EffectiveTargetMinutes(track)`로 목표시간 조회 후 `visit.DeviationSeconds(targetMinutes)` 계산 → 커밋 → `TrackFreedEvent`를 참고해 SSE 스냅샷 브로드캐스트.

### 3.7 기기 신뢰 — `domain/device_registration.go` (UC-5)

```go
type DeviceRegistrationStatus string // PENDING / APPROVED / REJECTED / REVOKED

type DeviceRegistration struct {
    ID                DeviceRegistrationID
    DeviceName        string
    Status            DeviceRegistrationStatus
    TokenHash         string
    FailedPinAttempts int
    LockedUntil       Optional[time.Time] // 지연 미적용 상태면 None
    ApprovedAt        Optional[time.Time] // 아직 APPROVED 전이 전이면 None
}

// 책임: 신뢰 상태 전이 (§domain-model.md 2.4-b)
func (d *DeviceRegistration) Approve() error
func (d *DeviceRegistration) Reject() error
func (d *DeviceRegistration) Revoke() error

// 책임: PIN 로그인 실패 점증형 지연 정책 계산·적용 (§domain-model.md 3.4)
//   1~2회: 즉시 재시도 / 3회: 5초 / 4회: 30초 / 5회+: 2분 + 관리자 경고 필요 여부 반환
func (d *DeviceRegistration) RecordPinFailure(now time.Time) (delay time.Duration, needsAdminAlert bool)
func (d *DeviceRegistration) ResetPinFailures()
func (d *DeviceRegistration) IsLocked(now time.Time) bool
```

### 3.8 진행자 세션 — `domain/facilitator_session.go` (UC-5)

```go
type FacilitatorSession struct {
    ID        FacilitatorSessionID
    TrackID   TrackID
    TokenHash string
    CreatedAt time.Time
    RevokedAt Optional[time.Time] // 유효한 세션이면 None
}

// 책임: 유휴 만료 없음, 4가지 조건(강제 로그아웃/트랙 삭제/캠프 종료/PIN 재발급)에서만 즉시 무효화 (§domain-model.md 2.4, 5-10)
func (s *FacilitatorSession) Revoke(now time.Time) error
func (s *FacilitatorSession) IsActive() bool
```

### 3.9 관리자 및 세션 — `domain/admin.go` (UC-6)

```go
type Admin struct {
    ID           AdminID
    PasswordHash string
}

type AdminSession struct {
    ID               AdminSessionID
    AdminID          AdminID
    AccessTokenHash  string
    RefreshTokenHash string
    DeviceInfo       string
    CreatedAt        time.Time
    LastUsedAt       time.Time
    RevokedAt        Optional[time.Time] // 유효한 세션이면 None
}

// 책임: 액세스/리프레시 이원화, 리프레시는 사용 시마다 슬라이딩 만료 (§technical-design.md 2.2-b)
func (s *AdminSession) TouchRefresh(now time.Time)
func (s *AdminSession) Revoke(now time.Time) error
func (s *AdminSession) IsRefreshExpired(now time.Time, idleTTL time.Duration) bool
```

### 3.10 메시지 — `domain/message.go` (UC-7)

```go
type MessageChannelType string // BROADCAST / DIRECT
type SenderRole string         // ADMIN / TRACK

type Message struct {
    ID          MessageID
    ChannelType MessageChannelType
    TrackID     Optional[TrackID] // DIRECT일 때만 Some (§domain-model.md 2.9)
    SenderRole  SenderRole
    Content     string
    SentAt      time.Time
}

type BroadcastReceipt struct {
    MessageID MessageID
    TrackID   TrackID
    ReadAt    Optional[time.Time] // 아직 읽지 않았으면 None
}

// 책임: 공지 읽음 상태 기록 (§domain-model.md 2.9, api BroadcastReceipt)
func (r *BroadcastReceipt) MarkRead(now time.Time) error
```

### 3.11 감사 로그 — `domain/audit_log.go` (UC-7)

```go
type AuditLog struct {
    ID         AuditLogID
    Actor      string
    Action     string
    Target     string
    Success    bool
    OccurredAt time.Time
    Metadata   map[string]any
}

// 책임: 생성 후 불변인 감사 기록 값객체 (§domain-model.md 4)
func NewAuditLog(id AuditLogID, actor, action, target string, success bool, occurredAt time.Time, metadata map[string]any) *AuditLog
```

---

## 4. 구현 단계 (Implementation Phases)

| Phase | 작업 | 파일 | 예상 소요 |
| --- | --- | --- | --- |
| **A** | [완료] 공통 기반 (신규) | `domain/optional.go`, `domain/id.go`, `domain/errors.go`, `domain/event.go` | 45분 |
| **B** | [완료] 캠프·배지·조 (신규) | `domain/camp.go`, `domain/badge.go`, `domain/group.go` | 2시간 |
| **C** | 코너·트랙·방문 (신규) | `domain/corner.go`, `domain/track.go`, `domain/visit.go` | 2.5시간 |
| **D** | 기기 신뢰·진행자 세션 (신규) | `domain/device_registration.go`, `domain/facilitator_session.go` | 1.5시간 |
| **E** | 관리자·메시지·감사로그 (신규) | `domain/admin.go`, `domain/message.go`, `domain/audit_log.go` | 1시간 |
| **F** | [완료] 단위 테스트 (신규) | `domain/*_test.go` | 2시간 |

각 Phase는 독립적으로 컴파일·테스트 가능해야 하며(Phase A만 완료돼도 `go build ./internal/domain/...` 통과), 300줄 내외로 커밋을 쪼갠다(`workflow/implement.md` 논리적 최소 커밋 원칙).

---

## 5. 검증 체크리스트

### 5.1 아키텍처 검증
- [x] `domain` 패키지에서 `infrastructure`/`interfaces` import 없음 (`go list -deps` 또는 `grep -r "cornermon/backend/internal/infrastructure" internal/domain`로 확인)
- [x] `domain` 패키지 메서드가 `context.Context`를 받지 않음(§2-b 사유로 의도적 예외)
- [x] 모든 필드명이 `api/openapi.yaml` 스키마 필드명과 camelCase↔PascalCase 1:1 대응 (Phase A, B 대상 검증 완료)
- [x] `go vet ./internal/domain/...`, `gofmt -l internal/domain` 통과
- [x] `domain` 패키지 내 `time.Now()` 직접 호출 없음(`grep -rn "time.Now()" internal/domain`로 확인) — 모든 시각은 `now time.Time` 인자로 주입 (§2-d) (Phase A, B 대상 검증 완료)
- [x] 값 타입(시각/ID/숫자)에 대해 "없을 수 있음"을 표현하는 포인터가 없음 — `grep -rnE "\*(time\.Time|.*ID|int|string)\b" internal/domain`로 남은 옵셔널 의미 포인터가 없는지 확인(엔티티 리시버·참조용 `*Track` 등은 제외, §2-f) (Phase A, B 대상 검증 완료)

### 5.2 유즈케이스별 불변식 검증 (테이블 기반 단위 테스트, `go test ./internal/domain/...`)
- [x] UC-1 Camp: PENDING→ACTIVE→ENDED만 허용, 역행 시도 시 `ErrCampInvalidTransition`, ENDED에서 재전이 불가
- [x] UC-1 Camp: `Activate(now)` 성공 시 `ActivatedAt.Value() == (now, true)`; `End(now)` 성공 시 `EndedAt.Value() == (now, true)`이며 반환된 `CampEndedEvent{CampID: c.ID, OccurredAt: now}` 값이 정확함; PENDING 상태에서 `End()` 호출 시 에러이고 이벤트는 zero-value
- [x] UC-2 Group: 다른 코너 IN_PROGRESS 상태에서 `MarkVisitStarted` 호출 시 `ErrGroupBusy`; COMPLETED 코너 재시작 시 `ErrDuplicateVisit`; 10개 전부 COMPLETED일 때만 `IsFinished() == true`
- [x] UC-2 Badge: UNASSIGNED가 아닌 배지 재등록 시 `ErrBadgeAlreadyAssigned`; `AssignTo` 성공 시 `AssignedGroupID.IsSet() == true`, `Release` 성공 시 `IsSet() == false`
- [ ] UC-3 Track: `CurrentVisitID.IsSet() == true`인 상태에서 `StartVisit` 재호출 시 `ErrTrackBusy`; 같은 상태에서 `Delete(now)` 시 `ErrTrackDeleteBlocked`; 마지막 ACTIVE 트랙 삭제는 도메인 계층에서 에러 없이 허용(경고 UX는 상위 계층 책임, §domain-model.md 5-8)
- [ ] UC-3 Track: `Delete(now)` 성공 시 `DeletedAt.Value() == (now, true)`이고 `TrackDeletedEvent{TrackID, OccurredAt: now}` 반환; `RegeneratePIN(hash, now)` 성공 시 `TrackPINRegeneratedEvent` 반환 및 `PINHash` 갱신; `CompleteVisit(now)` 성공 시 `CurrentVisitID.IsSet() == false`이고 `TrackFreedEvent.OccurredAt == now`
- [ ] UC-3 Corner: `EffectiveTargetMinutes(track)`이 현재 구현에서 `track` 값과 무관하게 항상 `c.TargetMinutes`를 반환(현재 스펙대로 override 없음을 회귀 방지)
- [ ] UC-4 Visit: `Complete()` 이후 재호출 시 `ErrVisitAlreadyCompleted`; `DurationSeconds`/`DeviationSeconds`가 종료 전엔 `IsSet() == false`, 종료 후 `Value()`로 정확한 값 반환
- [ ] 시각 일관성: 동일한 `now` 값을 `Visit.Complete(now)`와 `Track.CompleteVisit(now)`에 각각 전달했을 때 `visit.EndedAt.Value()`와 `trackFreedEvent.OccurredAt`이 항상 일치(§2-d 근거 회귀 테스트)
- [ ] UC-5 DeviceRegistration: 실패 횟수별 지연이 정확히 1~2회=0, 3회=5초, 4회=30초, 5회 이상=2분+`needsAdminAlert=true`; `ResetPinFailures()` 후 `IsLocked()==false`
- [ ] UC-6 AdminSession: `TouchRefresh` 호출 시 `LastUsedAt` 갱신되어 `IsRefreshExpired` 재계산됨; `Revoke()` 이후 재사용 시도 시 `ErrSessionRevoked`
- [ ] UC-7 BroadcastReceipt/AuditLog: `MarkRead`가 최초 1회만 `ReadAt` 설정, 재호출 시 최초 시각 유지(또는 명시적 정책 결정 후 테스트 반영)

### 5.3 검증 방법 및 도구
- **자동화 테스트**: `domain` 패키지는 IO가 없는 순수 구조체+메서드이므로 목킹 없이 표준 `testing` 패키지 + 테이블 기반 케이스로 전수 검증 가능. `go test ./internal/domain/... -v -cover`로 커버리지 확인.
- **실기기 테스트**: 이 Plan은 도메인 순수 로직만 다루므로 해당 없음 — Repository/HTTP/SSE가 연결되는 `usecase`/`infrastructure` Plan 단계에서 실기기·통합 테스트로 다룬다.
- **완료 기준**: `workflow/implement.md`에 따라 구현 완료는 위 체크리스트 전 항목이 테스트로 통과된 시점이며, 미해결 항목은 이 문서를 실시간 갱신해 추적한다.
