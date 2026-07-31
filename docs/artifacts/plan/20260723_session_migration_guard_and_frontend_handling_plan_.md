# 세션 마이그레이션 미들웨어 가드 + 프론트 처리 (Issue #204)

## 배경

#199에서 `migrationTargetTrackID` DB 영속화 버그를 고쳤지만(PR #202), 실제 운영 로그에서
후속 문제가 확인됐다:

```
POST /tracks/{trackId}/messages -> 404 TRACK_NOT_FOUND (internal=track: not active)
error_context: {"track_status":"DELETED", "track_found":true}
```

원인 두 가지가 겹쳐 있었다.

1. **백엔드**: `TrackAuthMiddleware`/`ValidateSession`(`auth_facilitator.go:280`)은 세션의
   `revokedAt`만 확인하고 `migrationTargetTrackID`가 설정돼 있는지는 보지 않는다. 트랙 교체
   후에도 세션은 의도적으로 active 상태를 유지하므로(마이그레이션 콜을 위해) 미들웨어를 그냥
   통과하고, 요청은 핸들러 깊숙한 곳(`message_handler.go`의 `requireFacilitatorTrackScope`
   → usecase의 트랙 상태 검증)에서야 막힌다 — 이때 나오는 에러가 "이 트랙이 진짜 없다"와
   "이 트랙은 교체됐으니 migrate-session을 호출해야 한다"를 구분하지 못하는 404였다.
2. **프론트**: 진행자 앱이 애초에 `track_replaced` SSE 이벤트를 처리하지 않았다
   (`track_event_coordinator.dart`의 `_handle`에 해당 case가 없어 `default`로 무시됨).
   생성된 `tracksIdMigrateSessionPost` API 클라이언트는 존재하지만 dead code였다.

## 설계

### 1. 백엔드 — 미들웨어 조립으로 게이트

`RequireNoPendingMigration()`(`auth_middleware.go`)을 독립 미들웨어로 추가한다. 세션을
직접 조회하지 않고, 앞서 실행된 `TrackAuthMiddleware`/`MessageAuthMiddleware`가
`c.Set("facilitatorSession", ...)`로 컨텍스트에 심어둔 값을 `c.Get`으로 읽기만 한다.
`migrationTargetTrackID`가 설정돼 있으면 `409 SESSION_MIGRATION_REQUIRED`를 반환한다.

라우팅은 그룹 단위로 조립한다(개별 라우트마다 미들웨어 2개씩 나열하지 않음):
- `track` 그룹: `logout`/`migrate-session`을 먼저 등록해 예외로 두고, 그 다음
  `track.Use(RequireNoPendingMigration())`을 호출해 이후 등록되는 나머지 트랙 라우트에만
  적용한다 — 새 라우트를 이 줄 아래에 추가하기만 하면 자동으로 가드가 적용된다.
- `message` 그룹(`POST /tracks/{trackId}/messages` 등, 실제 프로덕션 버그가 난 엔드포인트):
  예외가 없으므로 `MessageAuthMiddleware` 바로 뒤에 붙인다.

이 설계를 택한 이유(사용자와의 논의 결과):
- 인가 판단은 유즈케이스가 아니라 웹/미들웨어 계층 책임이다(`DEVELOPER_GUIDE.md` CQRS 섹션).
  유즈케이스에서 하면 트랙 스코프 유즈케이스 9곳(`StartVisit`, `SendDirect` 등)에 동일한
  가드를 중복 삽입해야 하고, 이들은 지금 세션 객체 자체를 모른 채 순수 trackID만 받는다.
- 별도 미들웨어로 쌓지 않고 `RequireNoPendingMigration()` 하나만 그룹 `.Use()` 체인에
  추가한다 — 라우트마다 두 미들웨어를 순서대로 등록해야 하는 부담(빼먹으면 버그 재발)을
  없애고, 그룹 등록 순서 하나로 exemption과 gate를 구조적으로 분리했다.

### 2. 프론트 — SSE 처리 + 폴백 복구

- `track_event_coordinator.dart`: `SseEventEventEnum.trackReplaced` 케이스 추가, 자기 트랙
  스코프일 때 `trackSessionProvider.migrateSession()`을 호출한다.
- `track_session_provider.dart`: `migrateSession()` 추가 — `POST
  /tracks/{id}/migrate-session` 호출 후 B1-b 재확인 없이 곧바로 `TrackSessionAuthenticated`로
  전이하고 영구 저장한다. 응답 타입(`TrackLoginResponse.track/corner`)은
  `domain_aliases.dart`의 typedef(`Track = TrackResponse`,
  `AuthTrackLoginPost200ResponseCorner = CornerResponse`)로 기존 상태 모델과 완전히
  호환된다.
- `auth_interceptor.dart`: SSE를 놓쳤을 경우의 폴백 — 응답이 `409
  SESSION_MIGRATION_REQUIRED`면 `SessionTokenSource.onSessionMigrationRequired()`를 호출해
  마이그레이션 후 원 요청을 재시도한다. `camp_ended`가 `device-registrations/me`로 복구하는
  것과 같은 이중 안전망 패턴.
- `SessionTokenSource` 인터페이스에 `onSessionMigrationRequired()` 추가 —
  `TrackSessionTokenSource`는 `migrateSession()` 위임, `AdminSessionTokenSource`는 no-op
  (관리자 세션은 이 게이트에 걸릴 수 없음).

## 구현 중 발견한 제약과 대응

- **`BCampCornerTrackApi` 미배선**: swagger 태그가 갈려 `migrate-session`만 이 클래스에
  속해 있고, 기존에 이를 인스턴스화하는 provider가 전혀 없었다(dead code였던 이유).
  `track_session_provider.dart`에 `trackMigrationApiProvider`를 새로 추가했다.
- **Java 미설치**: `openapi-generator-cli`(dart-dio 생성)가 내부적으로 Java를 요구하는데
  이 환경엔 JRE가 없고 `sudo` 비밀번호 입력이 필요해 설치할 수 없었다. `ErrorCode` enum에
  `SESSION_MIGRATION_REQUIRED` 값 하나를 기존 생성 패턴(wireName 매핑, `_toWire`/`_fromWire`
  맵, `values` 세트 등)을 그대로 미러링해 손으로 추가했다 — **로컬에 Java가 있는 환경에서
  `npx @openapitools/openapi-generator-cli generate`(또는 동등한 스크립트)를 한 번 돌려
  실제 codegen 결과와 일치하는지 검증 권장**.
- **`dart run build_runner build`가 `lib/shared/api/gen/**`을 삭제하는 기존 이슈**
  (`frontend/docs/DEVELOPER_GUIDE.md`에 문서화됨)가 이번에도 재현됐다. 컨테이너에서 격리
  실행 후 `track_session_provider.g.dart`(내가 추가한 `trackMigrationApi` provider가 필요로
  하는 파일)만 선별 복사하고, 삭제된 `gen/` 폴더와 무관한 다른 `.g.dart` 파일들의 재생성
  결과(해시 상수/독립적인 사전 오탈자 수정 등)는 이번 작업 범위가 아니므로 가져오지 않았다.

## 검증

- [x] 백엔드: `internal/infrastructure/web/router_test.go`에 프로덕션 버그를 그대로
      재현하는 `TestSendDirectRouteShoudRejectSessionWithPendingMigration`(409 확인)과
      `TestMigrateSessionAndLogoutRoutesShoudBeExemptFromPendingMigrationGate`(예외 라우트
      확인) 추가, 통과 확인.
- [x] 백엔드: `go test ./...`, `gofmt -l .`(diff 없음), `go vet ./...` 전체 통과.
- [x] 백엔드: `make swag`로 `api/swagger.yaml`/`swagger.json`/`docs.go` 재생성 — 새
      `SESSION_MIGRATION_REQUIRED` enum 값만 추가된 최소 diff 확인.
- [x] 프론트: `test/facilitator/features/track_event_coordinator_test.dart`에
      `ShouldCallMigrateSessionWhenTrackReplacedScopeMatchesOwnTrack`/
      `ShouldNotCallMigrateSessionWhenTrackReplacedScopeIsAnotherTrack` 추가.
- [x] 프론트: Docker(`cornermon-flutter:3.44.7`)에서 `dart analyze lib/` — No issues found.
- [x] 프론트: Docker에서 `flutter test test/facilitator/` — 72개 전체 통과(신규 2개 포함).
- [x] 프론트: Docker에서 `flutter test`(전체) — 262 passed / 3 failed. 실패 3건 모두
      `git status`로 미변경 확인된 기존 버그(`report_screen_test.dart` 캐스케이드 오타,
      `end_camp_bar_button_test.dart` 사전 실패 어서션, `track_event_stream_test.dart`
      타임아웃 플레이키 테스트) — 이번 작업과 무관.
