# 공지사항 목록 조회(ListBroadcasts) TrackAuth 허용

## 배경

`GET /camps/{campId}/messages/broadcast` (`MessageHandler.ListBroadcasts`)는 현재 `admin` 라우트
그룹(`AdminAuthMiddleware`)에만 등록되어 있어 관리자 세션이 없으면 미들웨어 단계에서 401로
막힌다. 진행자(Track) 앱에서도 자신의 캠프 공지사항 목록을 조회해야 하므로 TrackAuth도 허용한다.

공지사항은 캠프 단위 리소스이고 세션 검증은 이미 미들웨어에서 처리하므로, 핸들러/유스케이스에
캠프-트랙 스코프 매칭 로직을 추가하지 않는다. 유효한 세션(Admin 또는 Facilitator)만 있으면
요청한 `campId`의 공지사항 목록을 그대로 반환한다.

> 이전 설계안(`AnnouncementUsecase.GetCampIDByTrack` 추가 후 트랙-캠프 스코프 검증)은 폐기.
> 사유: 세션 유효성은 미들웨어가 이미 보장하고, 공지사항 조회는 트랙 개인정보가 아닌 캠프
> 단위 공개 정보이므로 usecase 계층에 스코프 검증 책임을 추가할 필요가 없음.

## 유즈케이스

| 우선순위 | 유즈케이스 | 설명 | 용도 |
|---|---|---|---|
| **P0** | UC-1: 관리자가 캠프 공지 목록 조회 | AdminSession으로 `campId`의 공지사항 목록 조회 | 프로덕션 핵심 로직 (기존 동작 유지) |
| **P0** | UC-2: 진행자가 캠프 공지 목록 조회 | FacilitatorSession으로 `campId`의 공지사항 목록 조회 | 프로덕션 핵심 로직 (신규) |
| P1 | UC-3: 인증 정보 없음 | 토큰 미제공/무효 시 미들웨어 단계에서 401 | 보안 (기존 미들웨어 그대로 적용) |

## 기존 코드 확인 사항

- `MessageAuthMiddleware` (`auth_middleware.go:63`)는 Admin/Facilitator 토큰을 모두 시도하여
  성공한 세션을 `c.Set("adminSession", ...)` 또는 `c.Set("facilitatorSession", ...)`로 저장한다.
  이미 `GET /tracks/:trackId/messages`, `GET /tracks/:trackId/messages/unread-count`가 이 패턴으로
  `message` 그룹(`router.go:119-122`)에 등록되어 있다.
- Echo는 동일 method+path를 두 그룹에 중복 등록할 수 없으므로(`router.go:117` 주석 참고),
  `GET /camps/:campId/messages/broadcast`를 `admin` 그룹에서 제거하고 `message` 그룹으로 옮긴다.
- `MessageHandler.ListBroadcasts` (`message_handler.go:106`) 자체는 세션 종류를 구분하지 않고
  이미 `campID` 하나로 `ListNoticesByCamp`를 호출하므로 **핸들러 코드 변경 불필요**.
- `AnnouncementUsecase`, `AnnouncementService`(`usecase/announcement.go`) 변경 불필요.

## 설계

### 1. 라우팅 변경 (유일한 코드 변경)

```go
// backend/internal/infrastructure/web/router.go

// ── E. Message (Admin) ──
if h.Message != nil {
    admin.POST("/camps/:campId/messages/broadcast", h.Message.SendBroadcast)
    // 제거: admin.GET("/camps/:campId/messages/broadcast", h.Message.ListBroadcasts)
    admin.GET("/messages/broadcast/:id/receipts", h.Message.GetBroadcastReceipts)
    admin.POST("/tracks/:trackId/messages", h.Message.SendDirect)

    // Both administrator and facilitator sessions may access these paths.
    message := v1.Group("")
    message.Use(MessageAuthMiddleware(adminAuth, trackAuth))
    message.GET("/camps/:campId/messages/broadcast", h.Message.ListBroadcasts) // 이동
    message.GET("/tracks/:trackId/messages", h.Message.ListDirectMessages)
    message.GET("/tracks/:trackId/messages/unread-count", h.Message.GetUnreadCount)
}
```

### 2. Swagger 주석 갱신

`ListBroadcasts` 주석에 `@Security TrackAuth` 추가 (핸들러 로직은 불변, 주석만 갱신).

```go
// @Summary      발송된 공지사항 목록
// @Description  관리자 또는 진행자가 캠프에 발송된 BROADCAST 메시지들의 목록을 조회한다.
// @Tags         E. Message
// @Security     AdminAuth
// @Security     TrackAuth
// @Produce      json
// @Param        campId path string true "캠프 ID"
// @Success      200 {array} MessageResponse
// @Failure      400 {object} ErrorResponse
// @Failure      401 {object} ErrorResponse
// @Router       /camps/{campId}/messages/broadcast [get]
func (h *MessageHandler) ListBroadcasts(c echo.Context) error {
    // 기존 코드 그대로 유지 — 변경 없음
}
```

### 3. 변경 없는 항목 (명시적 확인용)

- `AnnouncementUsecase` 인터페이스: 변경 없음
- `AnnouncementService`: 변경 없음
- `domain` 패키지: 변경 없음
- `MessageHandler.ListBroadcasts` 함수 본문: 변경 없음 (라우팅 위치만 이동)

## 검증 항목

### 아키텍처 검증
- [x] `domain`/`usecase` 패키지 diff 없음
- [x] 라우팅 외 핸들러 로직 diff 없음 (swagger 주석만 갱신)
- [x] `router.go`에서 `GET /camps/:campId/messages/broadcast`가 `admin` 그룹에서 제거되고
      `message` 그룹(`MessageAuthMiddleware`)으로 이동, 중복 등록 없음

### 유즈케이스 검증 (테스트 케이스)
- [x] UC-1: AdminSession으로 `GET /camps/{campId}/messages/broadcast` 호출 시 200 + 목록 반환 (회귀)
      — `TestListBroadcastsShoudReturnNoticesWhenAdminSessionPresent`,
      `TestListBroadcastsRouteShoudAuthenticateBothAdminAndTrackSessions/admin`
- [x] UC-2: FacilitatorSession으로 동일 엔드포인트 호출 시 200 + 목록 반환 (신규)
      — `TestListBroadcastsShoudReturnNoticesWhenFacilitatorSessionPresent`,
      `TestListBroadcastsRouteShoudAuthenticateBothAdminAndTrackSessions/track`
- [x] UC-3: 토큰 없이 호출 시 401 — `TestListBroadcastsRouteShoudRejectRequestWithoutSession`

### API 문서
- [x] `api/swagger.yaml`(`api/openapi.yaml`은 이 저장소에 없음 — swag 생성 소스가 `api/swagger.yaml`)
  `/camps/{campId}/messages/broadcast` GET의 `security`에 TrackAuth 추가
  (`swag init -g internal/infrastructure/web/doc.go -o ../api --parseDependency --parseInternal`로 재생성)
- [x] swag 주석과 swagger.yaml/json/docs.go 정합성 확인 완료 (재생성 시 이전 미반영분인
  X-Device-Token 헤더 수정 diff도 함께 동기화됨 — 별도 커밋으로 분리)

## 결과

- 변경 파일: `backend/internal/infrastructure/web/router.go`,
  `backend/internal/infrastructure/web/message_handler.go` (swagger 주석만),
  `backend/internal/infrastructure/web/message_handler_test.go`,
  `backend/internal/infrastructure/web/router_test.go`,
  `api/swagger.yaml`, `api/swagger.json`, `api/docs.go` (자동 생성)
- `go build ./...`, `go vet ./...`, `go test ./...` 전체 통과
- `gofmt -l`로 변경 파일 포맷 확인 완료
