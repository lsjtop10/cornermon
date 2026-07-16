# 브로드캐스트 메시지 campId 필터링 복구 계획

## 구현 현황

- [x] 작업 브랜치 생성: `fix/broadcast-message-camp-scope`
- [x] Phase A-C: 스키마·도메인·저장소·유스케이스 구현
- [x] Phase D: 유스케이스 회귀 테스트
- [x] Phase E: HTTP 경로·Swagger 생성 문서 갱신
- [x] 최종 검증 및 자체 리뷰
- [ ] 개발 DB 수동 반영: `ALTER TABLE messages ADD COLUMN camp_id VARCHAR(50) REFERENCES camps(id) ON DELETE CASCADE;` (마이그레이션 도구 부재)

## 1. 개요 및 변경 사유

`GET /messages/broadcast?campId=...`(`MessageHandler.ListBroadcasts`)는 `campId` 쿼리 파라미터를 받아 `MessageService.ListBroadcastsByCamp(ctx, campID)`까지 전달하지만, 실제 SQL(`ListBroadcastMessagesByCamp`)은 `WHERE channel_type = 'BROADCAST'`만 있고 `campId`를 전혀 사용하지 않는다.

원인은 스키마 자체에 있다: `messages` 테이블에 `camp_id` 컬럼이 없다. `SendBroadcast`가 `campID`를 인자로 받으면서도 `domain.Message`에 저장하지 않는다. 결과적으로 캠프가 여러 개 존재하면 한 캠프의 공지 목록 조회에 다른 캠프의 BROADCAST 메시지까지 섞여 반환된다.

부수적으로 `ListBroadcastMessagesByCamp`/`ListDirectMessagesByTrack` 모두 `ORDER BY`가 없어 정렬 순서가 보장되지 않는다. 같은 쿼리를 손대는 김에 `sent_at` 오름차순 정렬을 추가한다(범위 밖 로직 변경 없음, 동일 쿼리의 결정성 확보 목적).

`camp_id`는 `broadcast_receipts → tracks → corners`를 조인해 간접 유추하는 대안도 검토했으나, 브로드캐스트 발송 시점에 활성 트랙이 0개였던 메시지는 receipt이 없어 어떤 캠프 조회에서도 조회되지 않는 엣지 케이스가 있어 기각했다(사용자 확인 완료). `messages.camp_id` 컬럼을 직접 추가하는 방식으로 확정한다.

이 저장소에는 마이그레이션 툴이 없고 `db/schema.sql`이 sqlc의 스키마 소스 역할만 한다. DB 반영은 개발자가 수동으로 적용해야 한다(§6.4 참고).

### 1.1 API 엔드포인트 정합성 (누락분 추가)

`GET /messages/broadcast?campId=...`는 `?campId=` 쿼리 파라미터로 캠프를 스코핑하는데, 이는 `20260713_issue_45_explicit_camp_scope_plan_.md`(#45)에서 이미 폐기된 관례다. 그 작업에서 코너·트랙·조·리포트·SSE admin 구독의 "캠프 컬렉션 조회" 엔드포인트를 전부 `GET /camps/{campId}/<resource>` 경로 파라미터 방식으로 통일했고(`router.go`의 `admin.GET("/camps/:campId/corners", ...)` 등), 캠프 스코프를 쿼리스트링이나 활성 캠프 자동 탐색으로 넘기는 방식은 제거했다. `messages/broadcast` 목록 조회만 이 마이그레이션에서 누락되어 구관례로 남아있다.

동시에 이번 SQL 필터 버그 수정을 하면서 `campId` 파라미터를 신뢰해야 하므로, 같은 이유로 방치할 수 없는 정합성 문제다. 이번 계획에 함께 반영한다.

**피드백 반영**: GET/POST 두 엔드포인트가 같은 리소스(캠프의 브로드캐스트 메시지)를 가리키므로 경로를 맞춘다. `POST /corners`류의 "컬렉션 경로에 중첩하지 않는 관례"보다, 이 저장소에 이미 있는 더 가까운 선례를 따른다: 다이렉트 메시지는 `POST /tracks/:trackId/messages`(발송)와 `GET /tracks/:trackId/messages`(조회)가 **동일한 경로**를 `trackId` path 파라미터로 공유한다(`router.go` L112-113). 브로드캐스트 메시지도 같은 패턴으로 GET/POST 모두 `/camps/:campId/messages/broadcast`를 공유하도록 통일한다.

- **GET(목록 조회) + POST(발송) 공통**: `/camps/:campId/messages/broadcast`. 두 핸들러 모두 `c.Param("campId")`로 캠프를 스코핑한다.
- `BroadcastMessageRequest`에서 `CampID` 필드를 제거한다 — path param으로 이미 전달되므로 본문에 중복 보관하지 않는다(단일 출처 원칙, `DirectMessageRequest`가 이미 `TrackID`를 본문에 두지 않는 것과 동일 패턴).
- `Collaborate.md`의 API 변경 절차(프론트 PR 선행 → 백엔드 반영 + openapi 갱신 → 프론트 연동)를 적용하되, 이 저장소에는 아직 `frontend/` 디렉토리가 없다(#45 작업에서도 동일 사유로 "Flutter 클라이언트 변경은 사용자 지시에 따라 범위 제외"로 처리됨). 따라서 이번 계획도 백엔드 라우트/Swagger 변경까지만 수행하고, 프론트 연동은 `frontend/` 생성 이후 별도로 진행한다. `CLAUDE.md`의 "백엔드 작업은 백엔드 폴더만 수정" 원칙과도 일치한다.

---

## 2. 유즈케이스 정의 및 우선순위

| 우선순위 | 유즈케이스 | 설명 | 용도 |
| :--- | :--- | :--- | :--- |
| **P0** | UC-MSG-1: `messages.camp_id` 컬럼 추가 | BROADCAST 메시지 발송 시 소속 캠프를 영속화 | **프로덕션 핵심 데이터 모델** |
| **P0** | UC-MSG-2: `ListBroadcastsByCamp`가 실제로 campId로 필터링 | 쿼리에 `WHERE camp_id = $1` 반영, 결과를 `sent_at` 오름차순 정렬 | **프로덕션 핵심 로직 (버그 수정)** |
| **P0** | UC-MSG-4: GET/POST 브로드캐스트 엔드포인트를 `/camps/{campId}/messages/broadcast`로 통일 | `GET`은 `?campId=` 쿼리 → 경로 파라미터로, `POST`도 같은 경로로 이동해 본문의 `campId` 중복 제거. 기존 `/tracks/:trackId/messages` GET·POST 공유 패턴과 통일 | **프로덕션 API 계약 정합성** |
| P1 | UC-MSG-3: 기존 테스트/목(Mock)의 campId 무시 동작 수정 | `MockMessageRepository.ListBroadcastsByCamp`가 campID로 필터링하도록 수정, 회귀 테스트 추가 | 테스트 정합성 |

`ListDirectMessagesByTrack`은 이미 `track_id = $1`로 정상 필터링되므로 변경 대상이 아니다(정렬만 함께 추가).

---

## 3. 객체 및 변경 정의

### 3.1 도메인 (`backend/internal/domain/message.go`, 기존 파일 수정)

```go
type Message struct {
	ID          MessageID
	ChannelType MessageChannelType
	CampID      Optional[CampID] // BROADCAST일 때만 설정, DIRECT는 None (TrackID와 대칭되는 패턴)
	TrackID     Optional[TrackID]
	SenderRole  SenderRole
	Content     string
	SentAt      time.Time
}
```

- 책임: `CampID`는 BROADCAST 메시지가 어느 캠프에 속하는지 나타낸다. DIRECT 메시지는 이미 `TrackID`로 스코프가 정해지므로 `CampID`는 채우지 않는다(범위 밖 확장 지양).

### 3.2 스키마 (`backend/db/schema.sql`, 기존 파일 수정)

```sql
CREATE TABLE messages (
    id VARCHAR(50) PRIMARY KEY,
    channel_type VARCHAR(50) NOT NULL,
    camp_id VARCHAR(50) REFERENCES camps(id) ON DELETE CASCADE,
    track_id VARCHAR(50),
    sender_role VARCHAR(50) NOT NULL,
    content TEXT NOT NULL,
    sent_at TIMESTAMP WITH TIME ZONE NOT NULL
);
COMMENT ON COLUMN messages.camp_id IS 'BROADCAST 채널인 경우 소속 캠프 식별자 (DIRECT면 NULL)';
```

- `camp_id`는 `track_id`와 동일하게 nullable로 둔다(채널 타입에 따라 둘 중 하나만 채워지는 기존 관례 유지).

### 3.3 쿼리 (`backend/db/query.sql`, 기존 파일 수정 → `sqlc generate`로 재생성)

```sql
-- name: SaveMessage :exec
INSERT INTO messages (id, channel_type, camp_id, track_id, sender_role, content, sent_at)
VALUES ($1, $2, $3, $4, $5, $6, $7);

-- name: ListBroadcastMessagesByCamp :many
SELECT * FROM messages WHERE channel_type = 'BROADCAST' AND camp_id = $1 ORDER BY sent_at;

-- name: ListDirectMessagesByTrack :many
SELECT * FROM messages WHERE track_id = $1 AND channel_type = 'DIRECT' ORDER BY sent_at;
```

`internal/infrastructure/postgres/db/query.sql.go`, `models.go`는 `sqlc generate` 실행 결과로 갱신하며 직접 손으로 편집하지 않는다.

### 3.4 리포지토리 어댑터 (`backend/internal/infrastructure/postgres/message_repo.go`, 기존 파일 수정)

```go
// 책임: domain.Message.CampID <-> db.Message.CampID(pgtype.Text) 매핑 추가 (TrackID 매핑과 동일 패턴)
func mapMessage(row db.Message) *domain.Message

// 책임: Save 시 msg.CampID를 params.CampID(pgtype.Text)로 채움
func (r *pgMessageRepository) Save(ctx context.Context, msg *domain.Message) error

// 책임: 생성된 ListBroadcastMessagesByCamp(ctx, campID)를 호출하도록 campID 인자 전달
func (r *pgMessageRepository) ListBroadcastsByCamp(ctx context.Context, campID domain.CampID) ([]*domain.Message, error)
```

### 3.5 유스케이스 (`backend/internal/usecase/message.go`, 기존 파일 수정)

```go
// SendBroadcast 내부에서 msg 생성 시 CampID를 채운다.
msg := &domain.Message{
	ID:          msgID,
	ChannelType: domain.MessageBroadcast,
	CampID:      domain.Some(campID),
	TrackID:     domain.None[domain.TrackID](),
	SenderRole:  domain.RoleAdmin,
	Content:     content,
	SentAt:      now,
}
```

`ListBroadcastsByCamp`/포트 시그니처(`usecase/port.go`의 `MessageRepository.ListBroadcastsByCamp`)는 이미 `campID`를 받고 있어 변경 불필요.

### 3.6 테스트 목(Mock) (`backend/internal/usecase/mock_test.go`, 기존 파일 수정)

```go
// 책임: ChannelType == BROADCAST && CampID == campID인 메시지만 반환하도록 수정
func (r *MockMessageRepository) ListBroadcastsByCamp(ctx context.Context, campID domain.CampID) ([]*domain.Message, error)
```

### 3.7 라우터 (`backend/internal/infrastructure/web/router.go`, 기존 파일 수정)

```go
// 변경 전:
// admin.POST("/messages/broadcast", h.Message.SendBroadcast)
// admin.GET("/messages/broadcast", h.Message.ListBroadcasts)

// 변경 후 (corners/tracks/groups/reports/events와 동일한 위치, 캠프 그룹 안으로 이동.
// GET/POST가 /tracks/:trackId/messages처럼 같은 경로를 공유):
admin.POST("/camps/:campId/messages/broadcast", h.Message.SendBroadcast)
admin.GET("/camps/:campId/messages/broadcast", h.Message.ListBroadcasts)
```

### 3.8 핸들러 & Swagger 주석 (`backend/internal/infrastructure/web/message_handler.go`, 기존 파일 수정)

```go
type BroadcastMessageRequest struct {
	Content string `json:"content"` // CampID 필드 제거 — path param으로 대체
} // @name BroadcastMessageRequest

// @Summary      전체 공지 발송
// @Description  모든 활성 트랙에 BROADCAST 메시지를 보낸다.
// @Tags         E. Message
// @Security     AdminAuth
// @Accept       json
// @Produce      json
// @Param        campId path string true "캠프 ID"
// @Param        request body BroadcastMessageRequest true "메시지 내용"
// @Success      201 {object} MessageResponse
// @Failure      400 {object} ErrorResponse
// @Router       /camps/{campId}/messages/broadcast [post]
func (h *MessageHandler) SendBroadcast(c echo.Context) error {
	campID := domain.CampID(c.Param("campId")) // 변경 전: req.CampID(본문)
	if campID == "" {
		return c.JSON(http.StatusBadRequest, ErrorResponse{Code: "BAD_REQUEST", Message: "campId is required"})
	}
	// req 바인딩 후 h.message.SendBroadcast(ctx, campID, req.Content, session.AdminID) 호출은 동일
}

// @Summary      발송된 공지사항 목록
// @Description  관리자가 보낸 BROADCAST 메시지들의 목록을 조회한다.
// @Tags         E. Message
// @Security     AdminAuth
// @Produce      json
// @Param        campId path string true "캠프 ID"
// @Success      200 {array} MessageResponse
// @Failure      400 {object} ErrorResponse
// @Router       /camps/{campId}/messages/broadcast [get]
func (h *MessageHandler) ListBroadcasts(c echo.Context) error {
	campID := domain.CampID(c.Param("campId")) // 변경 전: c.QueryParam("campId")
	if campID == "" {
		return c.JSON(http.StatusBadRequest, ErrorResponse{Code: "BAD_REQUEST", Message: "campId is required"})
	}
	// 이하 로직 동일
}
```

- 다른 캠프 컬렉션 핸들러(`CornerHandler.ListCorners` 등)와 동일하게 빈 문자열 체크 메시지를 `"campId is required"`로 통일한다(기존 `"missing campId"`는 이 저장소의 다른 핸들러들과 문구가 달랐던 부분).
- `SendBroadcast`도 동일한 검증 문구/응답 형태(`400 BAD_REQUEST`)를 사용해 GET과 일관되게 만든다.

---

## 4. 구현 단계 (Implementation Phases)

### Phase A: 스키마 & 도메인 (예상 소요: 0.5시간)
| 순서 | 작업 | 파일 |
| :--- | :--- | :--- |
| A-1 | `messages` 테이블에 `camp_id` 컬럼 추가(스키마 + 코멘트) | `backend/db/schema.sql` |
| A-2 | `domain.Message`에 `CampID Optional[CampID]` 필드 추가 | `backend/internal/domain/message.go` |

### Phase B: 쿼리 & 생성 코드 (예상 소요: 0.5시간)
| 순서 | 작업 | 파일 |
| :--- | :--- | :--- |
| B-1 | `SaveMessage`에 `camp_id` 파라미터 추가, `ListBroadcastMessagesByCamp`에 `WHERE camp_id = $1` + `ORDER BY sent_at` 추가, `ListDirectMessagesByTrack`에도 `ORDER BY sent_at` 추가 | `backend/db/query.sql` |
| B-2 | `sqlc generate` 실행하여 생성 코드 갱신 | `backend/internal/infrastructure/postgres/db/*.go` |

### Phase C: 어댑터 & 유스케이스 (예상 소요: 0.5시간)
| 순서 | 작업 | 파일 |
| :--- | :--- | :--- |
| C-1 | `mapMessage`에 `CampID` 매핑 추가, `Save`에 `CampID` 파라미터 반영, `ListBroadcastsByCamp`가 생성된 쿼리에 `campID` 전달 | `backend/internal/infrastructure/postgres/message_repo.go` |
| C-2 | `SendBroadcast`에서 `msg.CampID = domain.Some(campID)` 설정 | `backend/internal/usecase/message.go` |

### Phase D: 테스트 (예상 소요: 1시간)
| 순서 | 작업 | 파일 |
| :--- | :--- | :--- |
| D-1 | `MockMessageRepository.ListBroadcastsByCamp`가 campID로 필터링하도록 수정 | `backend/internal/usecase/mock_test.go` |
| D-2 | 캠프 A/B에 각각 브로드캐스트 발송 후 `ListBroadcastsByCamp("camp-A")`가 캠프 A 메시지만 반환하는지 검증하는 신규 테스트 | `backend/internal/usecase/message_test.go` |
| D-3 | (선택) postgres 리포지토리 레벨 통합 테스트가 이미 존재하면 campID 필터 케이스 추가, 없으면 생략 | `backend/internal/infrastructure/postgres/message_repo_test.go` (존재 시) |

### Phase E: API 엔드포인트 이관 & 문서 (예상 소요: 1.5시간)
| 순서 | 작업 | 파일 |
| :--- | :--- | :--- |
| E-1 | `GET /messages/broadcast`, `POST /messages/broadcast` 라우트를 각각 `GET`/`POST /camps/:campId/messages/broadcast`로 이동(캠프 그룹 안, corners/tracks/groups/reports/events 옆) | `backend/internal/infrastructure/web/router.go` |
| E-2 | `ListBroadcasts`가 `c.Param("campId")`를 읽도록, `SendBroadcast`가 본문 `CampID` 대신 `c.Param("campId")`를 쓰도록 수정. `BroadcastMessageRequest`에서 `CampID` 필드 제거. 두 핸들러 Swagger 주석(`@Param campId path`, `@Router`) 갱신 | `backend/internal/infrastructure/web/message_handler.go` |
| E-3 | 라우트 변경을 반영해 핸들러 테스트(존재 시)의 요청 URL을 경로 파라미터 형태로 수정, `BroadcastMessageRequest` 본문에서 `campId` 제거 | `backend/internal/infrastructure/web/message_handler_test.go` (존재 시) |
| E-4 | `make swag` (`swag init -g internal/infrastructure/web/doc.go -d . -o ../api --parseDependency --parseInternal`) 실행하여 `api/swagger.yaml`/`swagger.json`/`docs.go` 재생성 | `api/swagger.yaml`, `api/swagger.json`, `api/docs.go` |

---

## 5. 검증 체크리스트

### 5.1 아키텍처 검증
- [x] `domain` 패키지에 infrastructure import 없음 (`Optional[CampID]` 추가만, 순수 타입)
- [x] `usecase`는 여전히 `MessageRepository` 포트에만 의존, 포트 시그니처는 변경하지 않음(이미 campID 인자 보유)

### 5.2 유즈케이스 검증
- [x] UC-MSG-1: BROADCAST 메시지 저장 시 DB `messages.camp_id`에 값이 채워짐
- [x] UC-MSG-2: 캠프 A에서 조회한 `GET /camps/{campId}/messages/broadcast` 응답에 캠프 B의 BROADCAST 메시지가 섞이지 않음
- [x] UC-MSG-2: 응답이 `sent_at` 오름차순으로 정렬됨
- [x] UC-MSG-3: 기존 `TestMessageService_SendBroadcast`/`SendDirect` 테스트가 회귀 없이 통과
- [x] UC-MSG-4: `GET /messages/broadcast?campId=...`, `POST /messages/broadcast`(구 경로)는 더 이상 라우팅되지 않고, `GET`/`POST /camps/{campId}/messages/broadcast`가 정상 동작함
- [x] UC-MSG-4: `BroadcastMessageRequest` 본문에 더 이상 `campId` 필드가 없고, path의 `campId`만으로 발송이 스코핑됨

### 5.3 API 계약 검증
- [x] `admin.GET`/`admin.POST("/camps/:campId/messages/broadcast", ...)` 라우트가 Swagger 주석 및 `api/swagger.yaml`/`swagger.json`과 일치
- [x] `api/swagger.yaml`에서 `/camps/{campId}/messages/broadcast`가 `/camps/{campId}/corners`, `/camps/{campId}/tracks`, `/camps/{campId}/groups`, `/camps/{campId}/reports/*`와 동일한 스타일(campId path 파라미터, 400 응답 문서화)로 정의됨
- [ ] `workflow/Collaborate.md` 절차에 따라, `frontend/` 생성 후 이 엔드포인트 경로 변경 사실을 프론트엔드와 공유(현재는 `frontend/` 미존재로 실제 연동 작업 없음, #45와 동일 처리)

### 5.4 실행 검증
- [x] `sqlc generate` 실행 후 diff가 예상 범위(models.go/query.sql.go)로 한정됨
- [x] `make swag` 실행 후 `api/swagger.yaml`/`swagger.json`/`docs.go` diff가 `/camps/{campId}/messages/broadcast` 경로 변경으로 한정됨
- [x] `go test ./...`
- [ ] 개발 DB에 `db/schema.sql`의 `ALTER TABLE messages ADD COLUMN camp_id ...` 반영(수동, 마이그레이션 툴 부재) 후 실서버로 `POST /camps/{campId}/messages/broadcast` → `GET /camps/{campId}/messages/broadcast` 수동 확인
