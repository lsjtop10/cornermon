# 진행자 트랙 로그아웃 및 TRACK_NOT_FOUND 처리 계획 (이슈 #200)

## 배경

- 원래 한 기기 = 한 트랙 구조라 로그아웃이 불필요했지만, 세션 마이그레이션 실패 등 예외 상황에서 진행자가
  스스로 세션을 정리할 방법이 없다.
- 트랙 스코프 API(메시지 unread-count, 조 목록 등)가 `404 TRACK_NOT_FOUND`를 반환하는 경로가 백엔드에
  이미 존재하는데(`backend/internal/infrastructure/web/message_handler.go:364`,
  `group_handler.go:185`), 프론트는 이 코드를 전혀 처리하지 않아 해당 트랙 진행자가 막다른 상태에 놓인다.
- `TrackSessionTerminationReason`·`lastTerminationReason`(`frontend/lib/facilitator/session/track_session_provider.dart:15,27`)은
  이미 세 가지 강제종료 사유(`trackDeleted`/`forceLogout`/`campEnded`)를 들고 있고
  `docs/front/screen-spec-facilitator.md:45`에 사유별 안내 토스트가 명시돼 있지만, 어떤 화면도 이 값을
  읽지 않아 미완성 상태다. 이번 작업에서 같이 완결한다.

## 유즈케이스

| 우선순위 | 유즈케이스 | 설명 | 용도 |
| --- | --- | --- | --- |
| **P0** | UC-1: 수동 트랙 로그아웃 | B2(메인 트랙 화면)에서 진행자가 스스로 트랙 세션을 종료할 수 있다. | **프로덕션 핵심 로직** |
| **P0** | UC-2: TRACK_NOT_FOUND 자동 감지 | 트랙 스코프 API가 404 `TRACK_NOT_FOUND`를 반환하면 세션을 자동 종료하고 B1로 전환한다. | **프로덕션 핵심 로직** |
| P1 | UC-3: 사유별 B1 안내 배너 | 세션 종료 사유(`trackNotFound`/`trackDeleted`/`forceLogout`/`campEnded`)별로 B1에 안내 문구를 보여준다(`loggedOut`은 제외 — 본인이 누른 로그아웃이므로 안내 불필요). | 기존 스펙 완결 / UX |

## 아키텍처 결정

### 1. `SessionTokenSource`에 404 위임 훅 추가 (shared 경계 유지)

`AuthInterceptor`는 admin/facilitator를 모른 채 `SessionTokenSource`만 참조하는 기존 규칙
(`auth_interceptor.dart:7` 주석)을 그대로 지킨다. 401과 같은 패턴으로 404 전용 훅을 하나 추가한다.

```dart
// frontend/lib/shared/auth/session_token_source.dart
abstract interface class SessionTokenSource {
  String? get currentAccessToken;
  Future<void> onUnauthorized();

  /// 401 외에 세션을 더 이상 쓸 수 없게 만드는 응답(예: 404 TRACK_NOT_FOUND)을 감지했을 때
  /// 위임한다. true = 이 앱이 처리함(추가 동작 없이 원래 에러를 그대로 흘려보낸다),
  /// false = 이 앱과 무관한 404(admin은 항상 false).
  Future<bool> onResourceNotFound(DioException error);
}
```

`AuthInterceptor.onError`에 401 분기와 나란히 404 분기 추가 — 재시도 로직 없이 side-effect만 호출:

```dart
// frontend/lib/shared/api/client/auth_interceptor.dart (onError 상단, 401 분기 이전)
if (response?.statusCode == 404) {
  await ref.read(sessionTokenSourceProvider).onResourceNotFound(err);
}
```

`AdminSessionTokenSource`는 no-op:

```dart
// frontend/lib/admin/session/admin_session_token_source.dart
@override
Future<bool> onResourceNotFound(DioException error) async => false;
```

### 2. `TrackSessionTerminationReason` 확장 + 수동 로그아웃 메서드

```dart
// frontend/lib/facilitator/session/track_session_provider.dart
enum TrackSessionTerminationReason {
  trackDeleted,
  forceLogout,
  campEnded,
  trackNotFound, // 신규 — track-scope API 404 TRACK_NOT_FOUND
  loggedOut,     // 신규 — 진행자 수동 로그아웃(B2 메뉴)
}
```

```dart
/// B2 메뉴 "로그아웃" — POST /auth/track/logout 후 세션을 종료한다.
/// rejectAssignment()와 같은 API를 쓰지만 트리거 화면·종료 사유가 다르다.
Future<void> logout() async {
  final api = ref.read(authDeviceTrustApiProvider);
  await api.authTrackLogoutPost();
  handleTermination(TrackSessionTerminationReason.loggedOut);
}
```

### 3. `TrackSessionTokenSource.onResourceNotFound` 구현

```dart
// frontend/lib/facilitator/session/track_session_token_source.dart
@override
Future<bool> onResourceNotFound(DioException error) async {
  if (errorCodeOf(error) != ErrorCode.CodeTrackNotFound) return false;
  ref
      .read(trackSessionProvider.notifier)
      .handleTermination(TrackSessionTerminationReason.trackNotFound);
  return true;
}
```

(`errorCodeOf`는 `frontend/lib/shared/api/dio_error.dart`에 이미 있는 헬퍼 재사용 — `pin_login_error_provider.dart`와
동일한 패턴.)

## 구현 Phase

### Phase A: 세션/토큰 소스 확장 (예상 90분)

| 순서 | 작업 | 파일 | 상태 |
| --- | --- | --- | --- |
| A-1 | `SessionTokenSource`에 `onResourceNotFound` 추가 | `frontend/lib/shared/auth/session_token_source.dart` (기존 파일 확장) | 완료 |
| A-2 | `AuthInterceptor.onError`에 404 분기 추가 | `frontend/lib/shared/api/client/auth_interceptor.dart` (기존 파일 확장) | 완료 |
| A-3 | `AdminSessionTokenSource` no-op 구현 | `frontend/lib/admin/session/admin_session_token_source.dart` (기존 파일 확장) | 완료 |
| A-4 | `TrackSessionTerminationReason`에 `trackNotFound`/`loggedOut` 추가, `TrackSession.logout()` 추가 | `frontend/lib/facilitator/session/track_session_provider.dart` (기존 파일 확장) | 완료 |
| A-5 | `TrackSessionTokenSource.onResourceNotFound` 구현 | `frontend/lib/facilitator/session/track_session_token_source.dart` (기존 파일 확장) | 완료 |

### Phase B: UI — 수동 로그아웃 (예상 60분)

| 순서 | 작업 | 파일 | 상태 |
| --- | --- | --- | --- |
| B-1 | B2 헤더에 로그아웃 아이콘 버튼 추가(기존 `_IconWithBadge`/`AppButton(iconOnly)` 패턴 재사용, `Icons.logout`) | `frontend/lib/facilitator/features/main_track/_main_track_header.dart` (기존 파일 확장) | 완료 |
| B-2 | 확인 모달(`ConfirmModalKind.softConfirm`, destructive 버튼) → 확인 시 `trackSessionProvider.notifier.logout()` 호출. 본문에 "진행 중인 방문은 미완료로 남는다"는 기존 강제종료 안내와 동일한 문구 포함 | `frontend/lib/facilitator/features/main_track/_main_track_header.dart` (기존 파일 확장) | 완료 |

### Phase C: UI — B1 사유별 안내 배너 (예상 60분)

| 순서 | 작업 | 파일 | 상태 |
| --- | --- | --- | --- |
| C-1 | `PinLoginScreen`이 `trackSessionProvider`의 `TrackSessionUnauthenticated.lastTerminationReason`을 읽어 PIN 입력 위에 배너 표시. `loggedOut`은 배너 없음. 문구는 `screen-spec-facilitator.md:45` 기준("이 트랙이 삭제되어…" / "관리자에 의해…" / "코너학습이 종료되어…") + `trackNotFound`용 신규 문구 | `frontend/lib/facilitator/features/pin_login/pin_login_screen.dart` (기존 파일 확장) | 완료 |

### Phase D: 테스트 (예상 90분)

| 순서 | 작업 | 파일 | 상태 |
| --- | --- | --- | --- |
| D-1 | `TrackSession.logout()` / `handleTermination(trackNotFound)` 단위 테스트 | `frontend/test/facilitator/session/track_session_provider_test.dart` (신규, 3 tests) | 완료 |
| D-2 | `TrackSessionTokenSource.onResourceNotFound` 단위 테스트(TRACK_NOT_FOUND면 handleTermination 호출 + true 반환, 그 외 404는 false) | `frontend/test/facilitator/session/track_session_token_source_test.dart` (신규, 2 tests) | 완료 |
| D-3 | B2 로그아웃 버튼 → 확인 모달 → `logout()` 호출/취소 시 미호출 위젯 테스트 | `frontend/test/facilitator/features/main_track_test.dart` (기존 파일 확장, +2 tests) | 완료 |
| D-4 | B1 사유별 배너 텍스트 위젯 테스트(4개 사유 + `loggedOut` 시 배너 없음) | `frontend/test/facilitator/features/pin_login_test.dart` (기존 파일 확장, +5 tests) | 완료 |

## 검증 체크리스트

- [x] 트랙 스코프 API(예: `GET /messages/unread-count`, `GET /tracks/{id}/groups`)가 404
      `TRACK_NOT_FOUND`를 반환하면 세션이 즉시 종료되고 라우터가 `/pin-login`으로 전환한다.
      (`track_session_token_source_test.dart` 단위 테스트로 확인 — `AuthInterceptor` → `onResourceNotFound`
      → `handleTermination(trackNotFound)` 경로. 라우터 전환 자체는 기존 `_redirect` 로직이
      `TrackSessionUnauthenticated`만 보고 판단하므로 새 사유 추가와 무관하게 그대로 동작한다.)
- [x] B2에서 로그아웃 버튼 → 확인 모달 → 확인 시 `POST /auth/track/logout` 호출 후 `/pin-login`으로
      전환된다. 취소 시 세션 유지, API 호출 없음. (`main_track_test.dart` 위젯 테스트 2건)
- [x] B1 화면에 `trackDeleted`/`forceLogout`/`campEnded`/`trackNotFound` 사유별 배너 문구가 각각
      다르게 노출된다. `loggedOut`은 배너 없음. (`pin_login_test.dart` 위젯 테스트, 4개 사유 + no-banner 케이스)
- [x] Admin 앱 회귀 없음 — `AdminSessionTokenSource.onResourceNotFound`는 항상 `false`, 기존 401
      silent refresh 흐름은 그대로 동작. (admin 전체 테스트 스위트 실행, 회귀 없음 확인 — 아래 참고)
- [x] `flutter analyze`(lib/ 전체) 통과, 관련 테스트 스위트 통과.
- [ ] 실기기/에뮬레이터에서 B2 → 로그아웃 → B1 재로그인 플로우 수동 검증. (미실행 — CLI 환경 제약)

### 검증 상세 로그

- `flutter analyze lib/` — **0 issues**.
- 진행자 세션 관련 테스트(`test/facilitator/session/`, `test/facilitator/features/`,
  `test/facilitator/router/`) 전체 실행 — **50 passed, 0 failed**.
- 프로젝트 전체 테스트 스위트 실행(사전에 이미 main에 존재하던 구문 오류 파일
  `test/admin/features/report/report_screen_test.dart` — 이슈 #200과 무관, `frontend/test/admin/features/report/report_screen_test.dart:89`의
  trailing comma 오타로 `flutter analyze` 자체가 실패해 전체 스위트에서 제외하고 실행) —
  **271 passed, 2 failed**. 두 실패 모두 이 브랜치와 무관하게 main 단독 체크아웃에서도 동일하게
  재현됨을 격리 실행으로 확인:
  - `test/admin/features/end_camp/end_camp_bar_button_test.dart: ShoudKeepDialogOpenAndShowServerMessageWhenEndFails`
    — 다른 plan(`20260723_admin_direct_unread_read_state_plan_.md`)에도 이미 기록된 기존 실패.
  - `test/shared/api/sse/track_event_stream_test.dart: TrackConnection ShouldResetConsecutiveMissCounterOnSuccessfulReconnect`
    — 30초 타임아웃, sse 스트림 테스트 타이밍 이슈로 추정. 이 브랜치의 변경 파일과 무관.
- `make docker-check`는 위 `report_screen_test.dart` 구문 오류 때문에 `flutter analyze` 단계에서
  전체가 실패해 이 브랜치만으로는 끝까지 실행할 수 없었다(사전 조건인 main 자체가 깨져 있음).
