# GitHub Issue #69 — 다이렉트 메시지 읽음 처리 API 추가/변경 구현 계획

> 이슈: https://github.com/lsjtop10/cornermon/issues/69

## 배경 / 문제 정의

프론트엔드(진행자 앱)에서 다이렉트 메시지(트랙 ↔ 운영자 1:1 스레드) 미확인 개수를 배지로 보여주려 하는데, 집계 API가 없다. 이슈 요구사항은 다음 두 가지다.

1. `GET /tracks/{trackId}/messages`에 `background`(읽음 처리 여부), `after`(이후 시각 필터) 쿼리 파라미터 추가
2. `GET /tracks/{trackId}/messages/unread-count` 신규 — 매번 집계 쿼리를 날리지 않고 별도 컬럼으로 관리(CQRS), 도메인 모델 전체 로딩 후 애플리케이션 집계 금지

### 코드베이스 조사 결과

- `domain.Message`에는 이미 `ReadAt Optional[time.Time]`과 `MarkRead(now)` 메서드가 있다 (`internal/domain/message.go:22-41`). 다만 **DIRECT 메시지 경로에서는 전혀 사용되지 않는다** — `messages` 테이블에 `read_at` 컬럼 자체가 없다 (`db/schema.sql:180-186`), `mapMessage`도 `ReadAt`을 세팅하지 않는다 (`internal/infrastructure/postgres/message_repo.go:28-39`).
- BROADCAST(공지) 메시지는 이미 `announcement_receipts` 테이블로 트랙별 읽음 여부를 추적한다 (`db/schema.sql:194-`). DIRECT는 1:1 스레드라 수신자가 항상 한 명(발신자의 반대 역할)이므로, 공지처럼 별도 receipts 테이블을 둘 필요 없이 `messages.read_at` 컬럼 하나로 충분하다.
- **현재 라우터에는 트랙(진행자) 인증으로 메시지를 조회하는 GET 경로가 없다.** `admin.GET("/tracks/:trackId/messages", ...)`만 등록되어 있고 (`internal/infrastructure/web/router.go:113`), `track` 그룹에는 발신(`POST .../from-track`)만 있다 (`router.go:141`). 진행자 앱이 배지를 계산하려면 이 조회 경로도 함께 열어야 이슈의 취지(진행자 미확인 개수 배지)를 만족한다.
- 이 서비스는 관리자(ADMIN)와 진행자(TRACK) 양쪽이 같은 스레드를 주고받는 구조이므로, "읽음"과 "미확인 개수"는 **호출자 역할의 반대편이 보낸 메시지** 기준으로 정의한다. 즉 관리자가 조회하면 `senderRole=TRACK`인 미확인 메시지, 진행자가 조회하면 `senderRole=ADMIN`인 미확인 메시지를 센다. 이렇게 하면 엔드포인트를 역할별로 분기하지 않고 기존 `SendDirect`가 이미 쓰는 세션 기반 역할 판별(`c.Get("adminSession")` / `c.Get("facilitatorSession")`, `message_handler.go:208-215`)을 그대로 재사용할 수 있다.

### CQRS 설계 — "별도 컬럼" 요구사항 반영

이슈가 명시한 "매번 집계 쿼리 금지, 별도 컬럼 관리"를 만족시키기 위해 `tracks` 테이블에 미확인 카운터 컬럼 두 개를 추가한다(역할별 별도 카운트가 필요하므로):

- `tracks.unread_by_admin_count` — TRACK이 보내고 ADMIN이 아직 안 읽은 메시지 수
- `tracks.unread_by_track_count` — ADMIN이 보내고 TRACK이 아직 안 읽은 메시지 수

메시지 발송 시 해당 카운터를 `+1`, 읽음 처리(`background=true`) 시 해당 카운터를 `0`으로 원자적 `UPDATE`한다. 조회는 항상 이 컬럼을 읽기만 하므로 집계 쿼리가 요청마다 발생하지 않는다.

## 1. 유즈케이스 우선 정의

| 우선순위 | 유즈케이스 | 설명 | 용도 |
| --- | --- | --- | --- |
| **P0** | UC-1: 트랙 메시지 목록 조회 + 선택적 읽음 처리 | `after` 이후 메시지만 반환, `background=true`면 상대측이 보낸 미확인 메시지를 읽음 처리 | **관리자/진행자 스레드 화면** |
| **P0** | UC-2: 트랙 미확인 개수 조회 | 호출자 역할 기준 미확인 메시지 개수를 컬럼에서 즉시 반환 | **진행자 앱 배지, 관리자 대시보드 배지** |
| P1 | UC-3: 진행자 인증으로 메시지 목록 조회 | 트랙 세션으로 GET 접근 허용 (현재 admin 전용) | **진행자 앱 스레드 화면 — UC-1의 전제조건** |

## 2. 객체 중심 설계

### Domain Layer

```go
// internal/domain/message.go — 변경 없음. 기존 ReadAt/MarkRead 재사용.
```

```go
// internal/domain/track.go — 미확인 카운터를 트랙 애그리거트에 추가
type Track struct {
    // ...기존 필드...
    UnreadByAdminCount int
    UnreadByTrackCount int
}

// 책임: 메시지 발송 시 상대측 미확인 카운터 증가
func (t *Track) IncrementUnread(recipient SenderRole)

// 책임: 읽음 처리 시 호출자 측 미확인 카운터 초기화
func (t *Track) ResetUnread(reader SenderRole)
```

> 대안으로 카운터를 `usecase.TrackUnreadCounts` DTO로만 두고 `Track` 애그리거트에는 넣지 않는 방법도 있다(순수 조회 전용 값이라 도메인 불변식과 무관). 다만 "메시지 발송"이라는 쓰기 트랜잭션 안에서 함께 원자적으로 갱신되어야 하므로, `MessageService.SendDirect`가 이미 로드하는 `Track` 애그리거트에 필드로 두고 같은 트랜잭션에서 `tracks.Save`로 함께 저장하는 편이 별도 포트 호출보다 트랜잭션 경계가 단순하다. 두 방식 중 최종 선택은 구현 시 `TrackRepository.Save`가 부분 업데이트를 지원하는지 확인 후 결정한다 (아래 3.3 참고).

### Usecase Layer

```go
// internal/usecase/port.go
type MessageRepository interface {
    Save(ctx context.Context, msg *domain.Message) error
    ListMessageByTrack(ctx context.Context, trackID domain.TrackID) ([]*domain.Message, error)
    // 신규: after 필터 + role 무관 원본 리스트 (핸들러에서 after 조건을 명시적으로 넘김)
    ListMessageByTrackAfter(ctx context.Context, trackID domain.TrackID, after domain.Optional[time.Time]) ([]*domain.Message, error)
    // 신규: recipient가 아직 읽지 않은 메시지들을 읽음 처리 (조건부 원자적 UPDATE, 3.3 참고)
    MarkAllReadByRecipient(ctx context.Context, trackID domain.TrackID, recipient domain.SenderRole, readAt time.Time) error
}
```

```go
// internal/usecase/message.go
// 책임: after 필터 적용 조회 + background=true일 때 호출자 반대편 발신 메시지 읽음 처리
// CQRS 사유: 목록 조회 자체는 트랜잭션 상태 변이가 없는 단순 조회이나, background=true 분기에서
// "읽음 처리"라는 쓰기가 섞이므로 usecase를 경유한다(2절 "리팩토링 트리거" 원칙).
func (s *MessageService) ListDirectMessages(
    ctx context.Context,
    trackID domain.TrackID,
    viewerRole domain.SenderRole,
    after domain.Optional[time.Time],
    markRead bool,
) ([]*domain.Message, error)

// 책임: tracks 테이블의 미확인 카운터 컬럼을 호출자 역할 기준으로 즉시 반환 (집계 쿼리 없음)
func (s *MessageService) GetUnreadCount(
    ctx context.Context,
    trackID domain.TrackID,
    viewerRole domain.SenderRole,
) (int, error)
```

### Infrastructure Layer (Web)

```go
// internal/infrastructure/web/message_handler.go
type MessageUsecase interface {
    SendDirect(ctx context.Context, trackID domain.TrackID, content string, senderRole domain.SenderRole) (*domain.Message, error)
    ListDirectMessages(ctx context.Context, trackID domain.TrackID, viewerRole domain.SenderRole, after domain.Optional[time.Time], markRead bool) ([]*domain.Message, error)
    GetUnreadCount(ctx context.Context, trackID domain.TrackID, viewerRole domain.SenderRole) (int, error)
}

type UnreadCountResponse struct {
    UnreadCount int `json:"unreadCount"`
} // @name UnreadCountResponse

// @Param background query bool false "true면 상대측 미확인 메시지를 읽음 처리"
// @Param after query string false "RFC3339 UTC 이후 메시지만 반환"
func (h *MessageHandler) ListDirectMessages(c echo.Context) error

// @Router /tracks/{trackId}/messages/unread-count [get]
func (h *MessageHandler) GetUnreadCount(c echo.Context) error
```

`MessageResponse`는 이미 `IsRead`, `ReadAt` 필드를 갖고 있으므로(`message_handler.go:38-39`) DTO 변경 없이 `mapMessage`/handler 매핑만 채워 넣으면 된다.

### Router

```go
// internal/infrastructure/web/router.go
// Echo는 같은 method/path에 하나의 handler만 등록할 수 있으므로,
// 관리자/진행자 세션을 모두 허용하는 전용 그룹에 GET을 한 번만 등록한다.
message := v1.Group("")
message.Use(MessageAuthMiddleware(adminAuth, trackAuth))
message.GET("/tracks/:trackId/messages", h.Message.ListDirectMessages)
message.GET("/tracks/:trackId/messages/unread-count", h.Message.GetUnreadCount)
```

handler 내부에서 `c.Get("adminSession")`/`c.Get("facilitatorSession")`으로 `viewerRole`을 판별한다. 또한 진행자 세션의 `TrackID`와 요청 트랙 ID가 일치하지 않으면 `domain.ErrTrackScopeForbidden`을 반환한다.

## 3. 아키텍처 원칙 명시

### 3.1 헥사고날 아키텍처 준수
- Domain: `Track`에 순수 카운터 필드/메서드만 추가, 외부 의존성 없음.
- Service: `MessageRepository`, `TrackRepository` 포트에만 의존.
- Infrastructure: sqlc 쿼리와 pgx 구현은 postgres 어댑터에 격리.

### 3.2 기존 포트 활용 우선
- 새 `UnreadCountRepository` 신규 생성 ❌ → 기존 `MessageRepository`/`TrackRepository` 확장 ✅

### 3.3 조건부 원자적 업데이트 (동시성)
발송과 읽음 처리가 동시에 일어날 수 있으므로(관리자가 보내는 순간 진행자가 읽음 처리), 카운터 갱신은 애플리케이션에서 `Get → +1 → Save` 하지 않고 DB 레벨 원자적 `UPDATE ... SET count = count + 1` / `UPDATE ... SET count = 0`으로 수행한다.

```go
// internal/usecase/port.go에 TrackRepository 확장 (기존 포트 활용, 신규 포트 아님)
type TrackRepository interface {
    // ...기존 메서드...
    IncrementUnreadCount(ctx context.Context, trackID domain.TrackID, recipient domain.SenderRole) error
    ResetUnreadCount(ctx context.Context, trackID domain.TrackID, reader domain.SenderRole) error
}
```

이 경우 2절의 `Track.IncrementUnread`/`ResetUnread` 도메인 메서드는 두지 않고, SQL 레벨 원자적 업데이트로 대체한다(위 "대안" 문단에서 언급한 선택지 중 이쪽을 채택 — 도메인 불변식 검증이 필요 없는 단순 카운터이므로 포트에서 직접 원자적 연산하는 것이 `Get→Save` 경쟁 조건을 원천 차단한다).

### 검증 항목
- [x] `domain` 패키지에서 `infrastructure` import 없음
- [x] 카운터 갱신이 `Get→+1→Save` 왕복이 아닌 단일 원자적 `UPDATE`로 수행됨
- [x] `GetUnreadCount`가 `messages`/`visits` 등에 대해 집계 쿼리(`COUNT`, `SUM`)를 실행하지 않음 — 컬럼 조회만 함

## 4. 계층별 책임 분리

### Domain Layer
- 카운터는 순수 값 필드이며 비즈니스 불변식이 없으므로 `Track` 구조체 필드로만 존재(3.3 참고, 증감 로직은 포트가 원자적으로 수행).

### Service Layer (`MessageService`)
- `after` 필터, `viewerRole` 기반 읽음 처리 여부 분기라는 애플리케이션 로직을 소유.
- `background=true`일 때: 트랙 카운터를 먼저 0으로 갱신해 행 잠금을 확보한 뒤 `MarkAllReadByRecipient`를 수행한다. `SendDirect`도 같은 행을 먼저 increment하여 잠근 뒤 메시지를 저장하므로, 발송과 읽음 처리가 같은 트랜잭션 경계에서 직렬화된다.
- `SendDirect`에 `IncrementUnreadCount` 호출을 추가한다(수신자 = 발신자 반대 역할).

### Infrastructure Layer
- postgres 어댑터: `db/schema.sql`에 `messages.read_at`, `tracks.unread_by_admin_count`, `tracks.unread_by_track_count` 컬럼 추가 마이그레이션, `db/query.sql`에 신규 쿼리 작성 후 sqlc 재생성.
- web 어댑터: 쿼리 파라미터 파싱(`background` bool, `after` RFC3339) 및 401/403 처리.

## 5. 구현 단계

### Phase A: 스키마 (예상 소요: 30분)
| 순서 | 작업 | 파일 |
| --- | --- | --- |
| A-1 | `messages.read_at TIMESTAMPTZ` 컬럼 추가 | `backend/db/schema.sql` |
| A-2 | `tracks.unread_by_admin_count INT DEFAULT 0`, `tracks.unread_by_track_count INT DEFAULT 0` 컬럼 추가 | `backend/db/schema.sql` |
| A-3 | `SaveMessage`에 `read_at` 반영, `ListMessagesByTrack`에 `after` 조건 및 `read_at` 기반 unread 쿼리 추가, `UpdateTrackUnreadCount`(increment/reset) 쿼리 작성 | `backend/db/query.sql` |
| A-4 | `sqlc generate` 실행하여 `internal/infrastructure/postgres/db/*` 재생성 | (생성물) |

### Phase B: 도메인/포트 (예상 소요: 20분)
| 순서 | 작업 | 파일 |
| --- | --- | --- |
| B-1 | `Track`에 `UnreadByAdminCount`/`UnreadByTrackCount` 필드 추가 | `internal/domain/track.go` |
| B-2 | `MessageRepository`, `TrackRepository` 포트 메서드 추가 | `internal/usecase/port.go` |
| B-3 | postgres 어댑터 구현 (`mapMessage`에 `ReadAt` 매핑, 신규 메서드 구현) | `internal/infrastructure/postgres/message_repo.go`, `track_repo.go` |

### Phase C: Usecase (예상 소요: 30분)
| 순서 | 작업 | 파일 |
| --- | --- | --- |
| C-1 | `SendDirect`에 `IncrementUnreadCount` 호출 추가 | `internal/usecase/message.go` |
| C-2 | `ListDirectMessages` 시그니처 확장 (`viewerRole`, `after`, `markRead`) 및 트랜잭션 처리 | `internal/usecase/message.go` |
| C-3 | `GetUnreadCount` 구현 | `internal/usecase/message.go` |

### Phase D: Handler/Router (예상 소요: 30분)
| 순서 | 작업 | 파일 |
| --- | --- | --- |
| D-1 | 쿼리 파라미터 파싱, `viewerRole` 판별 재사용, `GetUnreadCount` handler | `internal/infrastructure/web/message_handler.go` |
| D-2 | `track` 그룹에 GET 라우트 2개 추가, 트랙 스코프 검증 확인 | `internal/infrastructure/web/router.go` |
| D-3 | swaggo 주석 추가 및 `swag init` 재생성 | `api/*` |

## 6. 검증 체크리스트

### 6.1 아키텍처 검증
- [x] `domain` 패키지에 `infrastructure` import 없음
- [x] 카운터 증감이 원자적 SQL `UPDATE`로만 이뤄짐 (트랙 행 잠금 순서로 발송/읽음 경합 직렬화)
- [x] `GetUnreadCount`가 O(1) 컬럼 조회이며 `messages` 전체를 로딩하지 않음

### 6.2 유즈케이스 검증
- [x] UC-1: `after` 파라미터 미지정 시 전체 스레드 반환 (기존 동작 유지)
- [x] UC-1: `after` 지정 시 해당 시각 이후 메시지만 반환
- [x] UC-1: `background=true`일 때 반대편이 보낸 미확인 메시지만 `read_at` 설정, 이미 읽은 메시지는 재갱신 안 함(`MarkRead`의 idempotent 규칙 유지)
- [x] UC-1: `background=false`(또는 미지정)일 때 읽음 상태 변화 없음
- [x] UC-2: 관리자가 조회 시 TRACK 발신 미확인 개수, 진행자가 조회 시 ADMIN 발신 미확인 개수 반환
- [x] UC-2: 읽음 처리 직후 같은 트랙의 unread-count가 0으로 즉시 반영
- [x] UC-3: 진행자 세션으로 다른 트랙의 메시지 조회 시 403(`ErrTrackScopeForbidden`)

### 6.3 자동화 테스트
- [x] 동시성 테스트: 트랙 행 잠금 획득 순서(`increment → save`, `reset → mark-read`)를 검증하고 `go test -race ./internal/usecase ./internal/infrastructure/web`를 통과했다.
- [x] repository/query 경계 테스트: `after`와 정확히 일치하는 `sent_at`은 제외하고 이후 메시지만 반환하는 계약을 검증했다.
- [x] handler 레벨 테스트: `background` 미지정 시 기본값(false)이 안전한 방향(읽음 처리 안 함)인지 확인했다.
- [x] router 레벨 테스트: 중복 GET 등록 없이 관리자와 진행자 토큰이 같은 endpoint로 각각 접근하고 올바른 `viewerRole`로 처리되는지 확인했다.

## 7. 완료 기록 (2026-07-15)

- 진행자 세션의 `TrackID`와 path `trackId` 불일치를 모든 DIRECT 메시지 읽기·미확인 수·발신 경로에서 403으로 차단했다.
- 카운터를 0으로 갱신하는 읽음 처리와 증가시키는 발송 처리는 동일한 `tracks` 행을 먼저 갱신해 직렬화한다.
- OpenAPI를 재생성해 두 GET endpoint가 `AdminAuth` 또는 `TrackAuth`를 허용하고 `background`, `after`, 403 계약을 명시한다.
- Echo의 동일 method/path 중복 등록 문제를 제거하고, 두 인증 방식을 판별하는 `MessageAuthMiddleware`로 단일 GET route를 등록한다.
- 검증 명령: `go test ./...`, `go test -race ./internal/usecase ./internal/infrastructure/web`.
