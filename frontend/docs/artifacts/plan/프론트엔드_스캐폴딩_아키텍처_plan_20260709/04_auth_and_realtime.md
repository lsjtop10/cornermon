# Phase 04 — 인증/세션/실시간(SSE) 계층

> 선행조건: Phase 01, 03(`shared/api/providers`·`shared/api/client` 존재).
> 목적: 트랙 PIN 세션, 관리자 액세스/리프레시 세션, 기기 신뢰 토큰을 보안 저장소에만 저장하고 자동 갱신·강제 종료를 처리하며, SSE 클라이언트(하트비트/좀비연결 감지)를 구현한다. 세션 상태는 각 앱에만 존재하는 개념이므로 `admin/session`·`facilitator/session`에 두고, `shared` 계층의 `AuthInterceptor`는 `SessionTokenSource` 인터페이스로만 느슨하게 결합한다.
> 근거: technical-design.md §2.2-a(불투명 토큰), §2.2-b(관리자 액세스/리프레시), §2.3/2.3-b(SSE), domain-model.md §2.4(세션 생명주기), §2.4-b(기기 신뢰), `00_overview.md` §4-a(DI 경계 결정).

## 1. 유즈케이스
| 우선순위 | 유즈케이스 | 용도 |
|---|---|---|
| **P0** | UC-4: 트랙/관리자 세션이 보안 저장소에만 저장되고 규정된 4가지 조건에서만 즉시 종료 | 프로덕션 핵심(보안) |
| **P0** | UC-3: SSE 재연결 시 항상 전체 스냅샷 재수신, 40초 무응답 시 자가 재연결 | 프로덕션 핵심(실시간) |
| **P0** | `shared/api/client/auth_interceptor.dart`가 `admin/session`·`facilitator/session`을 직접 참조하지 않고 DI로만 결합 | 아키텍처 경계(FSD 단방향 의존) |

## 2. 객체 정의

```dart
// lib/shared/auth/secure_token_store.dart
abstract class SecureTokenStore {
  Future<void> write(String key, String value); // flutter_secure_storage 래핑 — Keychain/Keystore 전용, 평문 저장 금지(§2.2-a)
  Future<String?> read(String key);
  Future<void> delete(String key);
}
```

```dart
// lib/shared/auth/session_token_source.dart — AuthInterceptor가 의존하는 DI 경계(§00 개요 §4-a)
abstract interface class SessionTokenSource {
  String? get currentAccessToken;
  Future<void> onUnauthorized(); // 401 수신 시 처리를 각 앱의 세션 로직에 위임(관리자: silent refresh / 진행자: 세션 강제종료)
}

@riverpod
SessionTokenSource sessionTokenSource(Ref ref) =>
    throw UnimplementedError('main_admin.dart 또는 main_facilitator.dart에서 반드시 override');
// shared 계층은 구현을 모른다 — main_*.dart(합성 지점)가 ProviderScope(overrides:)로 앱별 구현체를 주입한다.
```

```dart
// lib/shared/api/client/auth_interceptor.dart
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this.ref);
  final Ref ref;
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler); // ref.read(sessionTokenSourceProvider).currentAccessToken 첨부
  @override
  void onError(DioException err, ErrorInterceptorHandler handler); // 401 감지 시 ref.read(sessionTokenSourceProvider).onUnauthorized() 후 1회 재시도
}
```

```dart
// lib/facilitator/session/device_trust_provider.dart
enum DeviceTrustStatus { none, pending, approved, rejected, revoked } // §2.4-b

@riverpod
class DeviceTrust extends _$DeviceTrust {
  @override
  Future<DeviceTrustStatus> build(); // 앱 시작 시 저장된 토큰으로 상태 조회
  Future<void> requestRegistration(String registrationCode); // POST /device-registrations
}
```

```dart
// lib/admin/session/admin_session_provider.dart
sealed class AdminSessionState {} // Unauthenticated / Authenticated(accessToken 보유) 등 하위 타입

@riverpod
class AdminSession extends _$AdminSession {
  @override
  AdminSessionState build(); // 저장된 리프레시 토큰으로 자동 복원 시도

  Future<void> login(String id, String password); // POST /auth/admin/login
  Future<void> silentRefresh(); // 401 감지 또는 만료 임박 시 자동 호출(§2.2-b), 실패 시에만 로그인 화면 노출
  Future<void> logout();
}
```

```dart
// lib/admin/session/admin_session_token_source.dart — SessionTokenSource 구현체
class AdminSessionTokenSource implements SessionTokenSource {
  AdminSessionTokenSource(this.ref);
  final Ref ref;
  @override
  String? get currentAccessToken => ref.read(adminSessionProvider).accessTokenOrNull;
  @override
  Future<void> onUnauthorized() => ref.read(adminSessionProvider.notifier).silentRefresh();
}
```

```dart
// lib/facilitator/session/track_session_provider.dart
enum TrackSessionTerminationReason { trackDeleted, forceLogout, campEnded } // §2.4 — B2 안내 문구 분기 근거(3종 각각 다른 토스트)

sealed class TrackSessionState {}

@riverpod
class TrackSession extends _$TrackSession {
  @override
  TrackSessionState build();
  Future<void> loginWithPin(String pin); // POST /auth/track/login — 세션 무만료(유휴 타임아웃 없음, §2.4)
  Future<void> confirmAssignment(); // B1-b "예, 맞습니다" — 세션 확정
  Future<void> rejectAssignment(); // B1-b "아니요" — 방금 발급된 세션 폐기(POST /auth/track/logout)
  void handleTermination(TrackSessionTerminationReason reason); // SSE 감지 시 BUSY 여부 무관 즉시 종료(§2.4 "유예 없이")
}
```

```dart
// lib/facilitator/session/track_session_token_source.dart — SessionTokenSource 구현체
class TrackSessionTokenSource implements SessionTokenSource {
  TrackSessionTokenSource(this.ref);
  final Ref ref;
  @override
  String? get currentAccessToken => ref.read(trackSessionProvider).accessTokenOrNull;
  @override
  Future<void> onUnauthorized() =>
      ref.read(trackSessionProvider.notifier).handleTermination(TrackSessionTerminationReason.forceLogout);
  // 트랙 세션은 유휴 타임아웃이 없어(§2.4) silent refresh 대상이 아니다 — 401은 서버측 강제무효화 신호이므로 즉시 종료 처리한다.
}
```

```dart
// lib/main_admin.dart / lib/main_facilitator.dart — 합성 지점(composition root)
void main() {
  runApp(ProviderScope(
    overrides: [
      sessionTokenSourceProvider.overrideWith((ref) => AdminSessionTokenSource(ref)), // facilitator는 TrackSessionTokenSource
    ],
    child: const AdminApp(),
  ));
}
```

```dart
// lib/shared/api/sse/sse_client.dart
class SseClient {
  SseClient({required this.heartbeatTimeout}); // 기본 40초(§2.3-b, 서버 하트비트 15~20초 주기의 2배)
  final Duration heartbeatTimeout;

  Stream<Map<String, dynamic>> connect(Uri uri, {Map<String, String>? headers});
  // Dio ResponseType.stream 기반 수동 파싱(EventSource 미지원 대응).
  // 책임: (1) ':'로 시작하는 하트비트 주석 라인은 이벤트로 발행하지 않고 마지막 수신 시각만 갱신
  //       (2) heartbeatTimeout 동안 침묵 시 스스로 연결을 끊고 재연결(자동 재연결을 기다리지 않음)
}
```

```dart
// lib/shared/api/sse/track_event_stream.dart
// ⚠️ 2026-07-10 openapi.yaml 하이브리드 알림+풀 모델로 변경(main 병합, sse_policy_redesign_plan_20260710.md).
// 더 이상 스냅샷을 push하지 않는다 — SSE는 {event, data: {scope}} 알림만 흘려보내고, 화면은
// (1) 진입 시 REST로 최초 조회 (2) 알림 수신 시 scope에 대응하는 REST 재조회를 직접 수행해야 한다.
// TrackSseSnapshot/AdminSseSnapshot 스키마 자체가 openapi.yaml에서 삭제됨 — 아래 시그니처는 폐기.
@riverpod
Stream<api.SseNotificationData> trackEvents(Ref ref, TrackId trackId); // GET /events/track/{trackId}
// track_updated/messages_changed 알림만 흘려보낸다. track_deleted/session_revoked/camp_ended는
// TrackSession.handleTermination()으로 직접 라우팅(재조회 없이 즉시 B1 전환). 연속 알림 디바운스(100ms)는
// 이 provider 또는 구독하는 화면 쪽에서 처리.
```

```dart
// lib/shared/api/sse/admin_event_stream.dart
@riverpod
Stream<api.SseNotificationData> adminEvents(Ref ref); // GET /events/admin — 위와 동일하게 알림 전용
```

## 3. 작업 단계

| 순서 | 작업 | 파일 | 상태 |
|---|---|---|---|
| D-1 | `SecureTokenStore` 구현체(`flutter_secure_storage`) | `frontend/lib/shared/auth/secure_token_store.dart` | [x] |
| D-2 | `SessionTokenSource` 인터페이스 + 미구현 provider | `frontend/lib/shared/auth/session_token_source.dart` | [x] |
| D-3 | `AuthInterceptor` — `SessionTokenSource`만 참조, `api_client.dart`의 Dio에 부착 | `frontend/lib/shared/api/client/auth_interceptor.dart` | [x] |
| D-4 | `DeviceTrust` provider(PENDING/APPROVED/REJECTED/REVOKED 폴링 또는 SSE 감지) | `frontend/lib/facilitator/session/device_trust_provider.dart` | [x] (PENDING→APPROVED 자동 감지는 미해결 — 아래 참고) |
| D-5 | `TrackSession` provider + `TrackSessionTokenSource` 구현체(PIN 로그인, B1-b 확인/거부, 강제종료 3종) | `frontend/lib/facilitator/session/{track_session_provider,track_session_token_source}.dart` | [x] |
| D-6 | `AdminSession` provider + `AdminSessionTokenSource` 구현체(로그인, silent refresh, 로그아웃, 공동관리자 세션 회수 §2.5-b) | `frontend/lib/admin/session/{admin_session_provider,admin_session_token_source}.dart` | 이번 스코프 제외(진행자 앱 우선 — 관리자는 Phase 06에서 착수) |
| D-7 | `main_admin.dart`/`main_facilitator.dart`에서 `sessionTokenSourceProvider` override 배선 | `frontend/lib/main_{admin,facilitator}.dart` | [x] (facilitator만 — main_admin.dart는 Phase 06에서) |
| D-8 | `SseClient`(하트비트/좀비연결 감지, §2.3-b) | `frontend/lib/shared/api/sse/sse_client.dart` | [ ] |
| D-9 | `adminEvents`/`trackEvents` StreamProvider(⚠️ 스냅샷 아님 — `SseNotificationData{scope}` 알림만, 수신 측이 REST 재조회) | `frontend/lib/shared/api/sse/{admin,track}_event_stream.dart` | [ ] (trackEvents만) |
| D-10 | 관리자 대시보드용 30초 주기 REST 폴백 재조회(§2.3-b "최후 안전망") — provider 레벨 타이머 | `frontend/lib/shared/api/providers/camp_providers.dart` 내 보조 provider | 이번 스코프 제외(관리자 전용) |

예상 소요시간: **12~16시간** (SSE 좀비연결 감지 + silent refresh 흐름이 가장 까다로운 부분 — 실제 네트워크 단절 테스트 포함).

### 3-a. 미해결 과제

- **D-4 PENDING→APPROVED 자동 감지 불가**: `api/openapi.yaml`에 기기가 자신의 등록 상태를 스스로 조회하는 GET 엔드포인트가 없다(`GET /device-registrations`는 `AdminAuth` 전용). `/events/track/{trackId}` SSE도 트랙 세션 확보(=PIN 로그인 성공) 이후에만 구독 가능해 등록 대기 중인 기기는 구독할 수 없다. 현재는 `DeviceTrust.build()`가 로컬에 저장된 마지막 상태만 반환한다 — 실제 승인 여부는 Phase 05의 B1 PIN 로그인 시도가 성공/실패하는 것으로 간접 확인해야 한다. 백엔드에 상태조회 엔드포인트를 추가하거나, B0 화면에 "다시 로그인 시도" 수동 재시도 버튼을 두는 방식 중 상위 로드맵에서 결정 필요.

## 4. 검증
- [ ] 트랙 삭제/강제로그아웃/캠프종료 SSE 이벤트 수신 시 BUSY 여부와 무관하게 `TrackSession`이 즉시 미인증 상태로 전환된다(scenarios.md Feature 3 "유예 없이 즉시")
- [ ] 액세스 토큰 401 응답 시 사용자가 로그인 화면을 보지 않고 `AdminSessionTokenSource.onUnauthorized` → `silentRefresh` 후 원 요청이 자동 재시도된다(§2.2-b)
- [ ] `shared/api/client/auth_interceptor.dart`에 `admin/session`, `facilitator/session` import가 없다(`grep -rl "admin/session\|facilitator/session" frontend/lib/shared/api/client` 결과 없음) — 오직 `shared/auth/session_token_source.dart`만 참조
- [ ] `main_admin.dart`/`main_facilitator.dart`가 각각 `sessionTokenSourceProvider`를 override하지 않으면 앱 부팅 시 `UnimplementedError`로 즉시 실패한다(누락을 조용히 지나치지 않음을 확인)
- [ ] `SseClient`가 40초 무응답 시 스스로 연결을 끊고 재연결하며, 재연결 즉시 전체 스냅샷을 받는다(비행기모드 on/off 수동 테스트 1건 포함)
- [ ] 모든 토큰이 `SecureTokenStore`를 통해서만 저장되고, `SharedPreferences`/`shared_preferences` 등 비보안 저장소를 `shared/auth`, `admin/session`, `facilitator/session` 어디서도 import하지 않는다
- [ ] B1-b에서 "아니요" 선택 시 발급됐던 세션이 즉시 폐기되어 이후 API 호출이 거부됨을 확인
