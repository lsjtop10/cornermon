# 이슈 143: 진행자 다이렉트 메시지 발송 시 401 강제 로그아웃 수정 계획

## 유즈케이스

| 우선순위 | 유즈케이스 | 설명 | 용도 |
| --- | --- | --- | --- |
| **P0** | UC: 진행자 다이렉트 메시지 발송 | 진행자가 자신의 트랙에서 관리자에게 DIRECT 메시지를 보낼 때 TrackAuth 세션으로 정상 인증되어야 한다 | **프로덕션 핵심 로직** |

## 원인 분석

- `POST /tracks/{trackId}/messages`는 `router.go:124`에서 `admin` 그룹(`AdminAuthMiddleware`)에만 등록되어 있었다.
- 진행자 세션으로 보낼 수 있는 경로는 `track.POST("/tracks/:trackId/messages/from-track", ...)` (`router.go:164`) 뿐이었는데, 이 경로는 swaggo 주석(`message_handler.go:227-236`, `@Router /tracks/{trackId}/messages [post]` 하나뿐)과 `api/swagger.yaml`에 전혀 반영되지 않았다. 두 라우트가 같은 핸들러(`SendDirect`)를 공유해 swag이 `/from-track`을 문서화하지 못한 것으로 보인다.
- 결과적으로 프론트엔드 codegen 클라이언트(`EMessageApi`)에는 `/from-track`을 호출하는 메서드가 아예 없었다.
- Flutter 진행자 앱(`track_direct_actions_provider.dart:13`)은 문서화된 `POST /tracks/{trackId}/messages`를 호출하며, 주석에도 "발신자 role은 서버가 세션(TrackAuth)으로 판단한다"라고 되어 있어 같은 리소스의 GET과 동일하게 관리자/진행자 공유 인증을 기대했다.
- 실제로는 `AdminAuthMiddleware`만 걸려 있어 진행자 세션 토큰으로 관리자 세션 저장소를 조회 → `session_found:false` → 401 `UNAUTHORIZED` → 앱이 로그인 화면으로 강제 이동했다. 로그의 `operation":"auth_admin.validate_token"`이 이 경로를 그대로 보여준다.
- 같은 리소스의 `GET /tracks/{trackId}/messages`, `GET .../unread-count`, `GET /camps/{campId}/messages/broadcast`는 이미 `MessageAuthMiddleware`(관리자 또는 진행자 세션 모두 허용, `router.go:129-133`)를 공유 그룹으로 사용 중이다 — POST만 이 패턴에서 누락되어 있었다.
- 이 패턴(공유 경로 + 미들웨어/핸들러 레벨 role 분기)은 GET 라우트에서 커밋 `2d6d009`("fix: 메시지 GET 인증 라우트 중복 제거", 2026-07-15)로 이미 결정 및 적용된 방식이다. POST는 그 정리가 적용되지 않은 채 남아 있었다.
- 핸들러 내부의 트랙 스코프 검증(`requireFacilitatorTrackScope`, `message_handler.go:249`)은 이미 존재하므로, 인증 미들웨어만 GET과 맞추면 추가 보안 구멍 없이 해결된다.

**결론: 서버측(라우팅/OpenAPI 계약) 이슈. 프론트엔드 코드는 문서화된 계약을 정확히 따르고 있었다.**

## 변경

- `router.go`: `admin.POST("/tracks/:trackId/messages", ...)` 등록을 제거하고, POST를 기존 `message` 공유 그룹(`MessageAuthMiddleware`)으로 이동해 GET들과 동일하게 관리자/진행자 세션을 모두 허용한다.
- `track.POST("/tracks/:trackId/messages/from-track", ...)` 중복 경로는 제거한다 (문서화된 적 없고 프론트에서 호출하지 않는 죽은 경로).
- `message_handler.go`의 `SendDirect` swaggo 주석에 `@Security TrackAuth`와 `@Failure 403 TRACK_SCOPE_FORBIDDEN`을 추가한다 (기존 GET 주석과 동일한 스타일).
- `make swag`로 `api/swagger.yaml`(및 `docs.go`, `swagger.json`)을 재생성해 두 시큐리티 스킴이 반영됐는지 확인한다.
- `message_handler_test.go`의 `/from-track` 경로 문자열을 `/tracks/track-2/messages`로 정리한다 (핸들러 직접 호출 단위 테스트라 라우팅과 무관하지만 일관성 유지).
- `router_test.go`에 POST 라우트가 관리자/진행자 세션 모두로 인증되고, 세션 없이는 401을 반환하는 회귀 테스트를 추가한다 (기존 GET 라우트 테스트와 동일한 패턴).

### 코드 스니펫 (개요)

```go
// router.go — E. Message
if h.Message != nil {
    admin.POST("/camps/:campId/messages/broadcast", h.Message.SendBroadcast)
    admin.GET("/messages/broadcast/:id/receipts", h.Message.GetBroadcastReceipts)

    message := v1.Group("")
    message.Use(MessageAuthMiddleware(adminAuth, trackAuth))
    message.GET("/camps/:campId/messages/broadcast", h.Message.ListBroadcasts)
    message.POST("/tracks/:trackId/messages", h.Message.SendDirect) // admin-only 그룹에서 이동
    message.GET("/tracks/:trackId/messages", h.Message.ListDirectMessages)
    message.GET("/tracks/:trackId/messages/unread-count", h.Message.GetUnreadCount)
}

// ── Track Auth Required Routes ──
if h.Message != nil {
    track.POST("/messages/broadcast/:id/read", h.Message.ReadBroadcast)
    // /from-track 제거: 위 공유 경로로 대체됨
}
```

```go
// message_handler.go
// @Summary      다이렉트 메시지 발송
// @Description  관리자가 특정 트랙에, 또는 특정 트랙이 관리자에게 DIRECT 메시지를 발송한다.
// @Security     AdminAuth
// @Security     TrackAuth
// @Failure      403 {object} ErrorResponse "TRACK_SCOPE_FORBIDDEN: 세션 트랙과 요청 트랙이 불일치"
// @Router       /tracks/{trackId}/messages [post]
```

## 검증

- [x] `go test ./internal/infrastructure/web/...` 통과 — 진행자 세션으로 POST 성공, 관리자 세션으로도 여전히 성공, 세션 없이는 401 회귀 테스트 추가 (`router_test.go`)
- [x] `go test ./internal/usecase/...` 통과 — `SendDirect` senderRole 분기 회귀 없음 확인
- [x] `make swag` 실행 후 `api/swagger.yaml`에서 `/tracks/{trackId}/messages` POST가 `AdminAuth` + `TrackAuth` 둘 다 명시됨, `/from-track` 경로는 (원래도 없었지만) 여전히 없음 확인
- [ ] 실기기 Flutter 진행자 앱에서 다이렉트 메시지 발송 시 401/로그인 화면 강제 이동이 재현되지 않는지 확인 (이슈 143 재현 시나리오) — 백엔드 배포 후 확인 필요
- [x] 이번 변경은 기존에 문서화된 경로(`/tracks/{trackId}/messages`)의 보안 스킴만 확장하는 것이라 생성된 Dart 클라이언트의 메서드 시그니처는 바뀌지 않는다 — `workflow/Collaborate.md` 프로토콜상 API 변경 알림은 필요하지만 프론트 코드 수정은 불필요
