# Phase 12 — Admin SSE 연동: 중앙 디스패치 → REST 재조회 트리거

> 선행조건: `01_api_codegen_sync.md`(특히 `admin_event_stream.dart`의 `adminEventsProvider(campId)` raw 스트림), `02_admin_skeleton_router_sidebar.md`(`selectedCampIdProvider`, `AdminSidebar`). `03`~`11`의 각 화면 provider가 REST 기준으로 먼저 동작해야 이 Phase에서 "재조회 트리거"를 얹을 대상이 생긴다 — 반드시 마지막에 실행.
> 대상 독자: 1~2년차 프론트엔드 개발자 1명, 예상 소요 4~6시간.
> 목적: 화면마다 각자 SSE를 구독하는 방식이 아니라, **앱 전역에 단 하나의 구독**을 두고 이벤트를 받아 "어떤 provider를 무효화할지"를 중앙에서 결정하는 디스패치 계층을 만든다. 이 계층은 REST 재조회 자체를 하지 않는다 — `ref.invalidate(...)`만 호출하고, 실제 재조회는 각 화면이 이미 구독 중인 Riverpod provider가 다음 `watch` 시점에 알아서 수행한다(`00_overview.md` §2.3 notify-then-refetch).

## 0. 왜 화면별 구독이 아니라 중앙 디스패치인가

- `GET /camps/{campId}/events/admin`는 캠프 하나당 커넥션 하나만 열려야 한다. 화면마다(A1, A5, A8 …) 각자 `adminEventsProvider(campId)`를 구독하면 Riverpod의 `Stream` provider는 구독자가 있는 동안만 살아있는 autoDispose가 기본이라 동작 자체는 되지만, "재연결 시 무엇을 재조회할지"를 화면마다 따로 판단하게 되어 캠프 목록 화면처럼 SSE와 무관한 화면에서도 로직이 흩어진다.
- 또한 `ConnectionBanner`(B2 헤더, `frontend/lib/shared/design_system/widgets/connection_banner.dart`)는 화면이 아니라 **앱 셸** 수준에 한 번만 배치돼야 하므로, 연결 상태도 앱 전역에서 한 곳으로 수렴해야 한다.
- 따라서 이 Phase는 `frontend/lib/admin/session/` 아래에 `AdminSseDispatcher`라는 단일 Riverpod provider를 만들고, `AdminApp`(`frontend/lib/admin/app.dart`) 빌드 트리 최상단에서 딱 한 번 `ref.watch`해 살아있게 유지한다. 화면 provider들은 이 파일을 전혀 몰라도 된다 — `ref.invalidate`를 당하면 다음에 `watch`될 때 알아서 새 요청을 보낼 뿐이다.

## 1. 유즈케이스

| 우선순위 | 유즈케이스 | 설명 | 용도 |
|---|---|---|---|
| **P0** | UC-1: 캠프 선택 중 Admin SSE 단일 구독 유지 | `selectedCampIdProvider`가 non-null인 동안 `adminEventsProvider(campId)`를 정확히 하나만 구독 | 프로덕션 핵심 |
| **P0** | UC-2: 이벤트 → provider 무효화 매핑 | 12종 이벤트 각각을 화면 provider invalidate 목록으로 라우팅 | 프로덕션 핵심 |
| **P0** | UC-3: 재연결 시 전체 재조회 | 유실 가능성이 있으므로 재연결 성사 시점에 개별 이벤트 매핑과 무관하게 "현재 캠프에서 보일 수 있는 모든 목록" 일괄 invalidate | 프로덕션 핵심, best-effort 유실 보완 |
| **P0** | UC-4: 캠프 전환 시 구독 교체 | `selectedCampIdProvider`가 캠프 A→B로 바뀌면 A용 스트림을 완전히 끊고 B용 스트림을 새로 연다(A 이벤트가 B 화면에 영향 주면 안 됨) | 프로덕션 핵심, 격리 보장 |
| **P0** | UC-5: `ConnectionBanner` 상태 노출 | `AdminConnectionState` → `ConnectionBannerState` 매핑, 끊겼을 때만 배너 노출 | 프로덕션 핵심 |
| P1 | UC-6: 캠프 미선택(`/camps`, `/login`, `/badges`) 시 구독 없음 | `selectedCampIdProvider == null`이면 스트림 자체를 만들지 않음(불필요한 연결 방지) | 리소스 절약 |

## 2. 객체 정의

### 2.1 연결 상태 (`frontend/lib/admin/session/admin_sse_dispatcher.dart`, 신규)

`facilitator`의 `TrackConnectionState`(`frontend/lib/shared/api/sse/track_event_stream.dart:12`)와 동일한 3값 enum을 관리자 쪽에 그대로 복제한다(공유 타입으로 묶지 않는 이유: `shared/api/sse/`는 raw 전송 계층 전용이고, 연결 상태는 도메인적으로 "관리자 세션"에 속하는 개념이라 `admin/session/`에 둔다 — facilitator와 대칭되는 별도 enum).

```dart
enum AdminConnectionState { connected, reconnecting, disconnected }
```

`connected`/`reconnecting`는 `TrackConnectionState`와 동일한 의미(스트림 `data`/`error`·`loading`). 캠프 미선택으로 구독 자체가 없는 상태는 `disconnected`가 아니라 `connected`로 간주한다 — 배너는 "끊겼을 때만" 뜨는데, 캠프를 아직 안 골랐을 때는 SSE가 애초에 필요 없는 정상 상태이므로 배너를 띄우면 안 된다(§2.4 `adminConnectionBannerStateProvider`에서 처리).

### 2.2 디스패처 (`frontend/lib/admin/session/admin_sse_dispatcher.dart`)

```dart
@riverpod
class AdminSseDispatcher extends _$AdminSseDispatcher {
  @override
  AdminConnectionState build() {
    final campId = ref.watch(selectedCampIdProvider);
    if (campId == null) {
      // 캠프 미선택 — 구독 없음. build()가 selectedCampIdProvider를 watch하고 있으므로
      // 캠프가 선택되는 순간 이 build()가 재실행되며 아래 분기로 넘어간다(=자동 재구독).
      // 캠프가 A→B로 바뀔 때도 동일하게 build() 전체가 재실행되어
      // 이전 ref.listen 등록(및 그 안에서 구독하던 adminEventsProvider(A))이 자동 해제된다
      // (Riverpod: build() 재실행 시 이전 build()가 등록한 ref.listen은 폐기됨 — 별도 dispose 코드 불필요).
      return AdminConnectionState.connected;
    }

    var everConnectedThisBuild = false; // 이번 campId 구독 동안 최소 1회 connected였는지

    ref.listen<AsyncValue<SseEvent>>(
      adminEventsProvider(campId),
      (previous, next) => _handle(ref, campId, previous, next, onFirstConnect: () {
        everConnectedThisBuild = true;
      }),
      fireImmediately: true,
    );

    return AdminConnectionState.reconnecting;
  }

  // 실제 상태 갱신 + 이벤트 디스패치. build() 밖에 둬서 단위 테스트 가능하게 분리.
  void _handle(
    Ref ref,
    CampId campId,
    AsyncValue<SseEvent>? previous,
    AsyncValue<SseEvent> next, {
    required void Function() onFirstConnect,
  });
  // 의사코드:
  // next.when(
  //   data: (event) {
  //     final wasConnected = state == AdminConnectionState.connected;
  //     if (!wasConnected) {
  //       onFirstConnect();
  //       fullRefresh(ref, campId);       // UC-3: 재연결(또는 최초 연결) 시 전체 재조회
  //     }
  //     state = AdminConnectionState.connected;
  //     dispatchEvent(ref, campId, event); // UC-2: 이번 이벤트 단건에 대한 매핑
  //   },
  //   error: (_, __) => state = AdminConnectionState.reconnecting,
  //   loading: () => state = AdminConnectionState.reconnecting,
  // );
}
```

`adminEventsProvider(campId)`는 `01_api_codegen_sync.md` §2.2가 정의한 raw 스트림(`frontend/lib/shared/api/sse/admin_event_stream.dart`)을 그대로 재사용한다 — `SseClient.connect()`의 에러 삼킴+1초 backoff 재연결 루프(`frontend/lib/shared/api/sse/track_event_stream.dart:24-33`와 동일 패턴)를 그 파일이 이미 구현하므로, 이 Phase는 그 위에서 "이번에 새로 들어온 이벤트가 무엇인지"만 소비한다. `AdminSseDispatcher`가 직접 재연결 backoff를 구현하지 않는다.

**확인 필요**: `admin_event_stream.dart`가 `track_event_stream.dart`의 `trackEvents` 함수(async* + while 루프)를 그대로 복제하는지, 아니면 `SseClient.connect()`를 감싸지 않고 얇게 한 번만 노출하는지는 `01`의 작업(C-3)에서 확정된다. 위 `AdminSseDispatcher`는 `adminEventsProvider(campId)`가 **스스로 재연결하며 절대 완료(done)되지 않는 무한 스트림**이라는 전제로 설계했다 — `01`이 다르게 구현했다면(예: 1회 연결만 하고 끝) 이 파일도 `while(!disposed)` 재연결 루프를 직접 감아야 하므로 `01` 구현체를 확인 후 조정할 것.

### 2.3 이벤트 → provider 무효화 매핑

```dart
typedef AdminInvalidationRule = void Function(Ref ref, CampId campId);

/// 이벤트 1건에 대한 디스패치. dispatchEvent 하나로 여러 화면의 provider를
/// 동시에 무효화할 수 있다(예: tracks_updated는 대시보드와 코너·트랙 화면 둘 다 영향).
void dispatchEvent(Ref ref, CampId campId, SseEvent event) {
  for (final rule in _rulesFor(event.event)) {
    rule(ref, campId);
  }
}

List<AdminInvalidationRule> _rulesFor(SseEventEventEnum? eventType) => switch (eventType) {
  SseEventEventEnum.tracksUpdated => const [_invalidateTrackList, _invalidateCornerList, _invalidateLiveSummary],
  SseEventEventEnum.trackUpdated => const [_invalidateTrackList, _invalidateCornerDetailAll, _invalidateLiveSummary],
  SseEventEventEnum.cornersUpdated => const [_invalidateCornerList, _invalidateCornerDetailAll, _invalidateLiveSummary],
  SseEventEventEnum.groupsUpdated => const [_invalidateGroupList, _invalidateGroupDetailAll, _invalidateGroupVisitsAll],
  SseEventEventEnum.campUpdated => const [_invalidateSelectedCamp],
  SseEventEventEnum.messagesChanged => const [_invalidateBroadcastMessageList, _invalidateTrackMessageListAll],
  SseEventEventEnum.trackDeleted => const [_invalidateTrackList, _invalidateCornerList, _invalidateCornerDetailAll],
  SseEventEventEnum.trackReplaced => const [_invalidateTrackList, _invalidateCornerDetailAll],
  SseEventEventEnum.sessionRevoked => const [_invalidateAdminSessionList],
  SseEventEventEnum.campEnded => const [_invalidateSelectedCamp],
  SseEventEventEnum.deviceRegistrationUpdated => const [_invalidateDeviceRegistrationList],
  SseEventEventEnum.lockoutAlert => const [_invalidateDeviceRegistrationList /* 확인 필요, 아래 표 참고 */],
  null => const [],
};

// 각 _invalidateXxx는 한 줄짜리 ref.invalidate 호출이다. 예:
void _invalidateTrackList(Ref ref, CampId campId) {
  // ref.invalidate(trackListProvider(campId));
}
void _invalidateCornerDetailAll(Ref ref, CampId campId) {
  // ref.invalidate(cornerDetailProvider);
  // ※ family를 인자 없이 invalidate하면 그 family의 "모든" 인스턴스가 무효화된다
  //   (어떤 cornerId가 바뀐 건지 admin 스트림은 알려주지 않으므로 — §00 overview 2.3
  //   "scope.kind는 camp만 온다"에 따라 개별 cornerId 단위 invalidate는 불가능).
}
// _invalidateGroupDetailAll / _invalidateGroupVisitsAll / _invalidateTrackMessageListAll도 동일하게
// family 전체 invalidate 패턴을 따른다.
```

**중요 — family 전체 invalidate에 대한 전제**: `cornerDetailProvider(campId, cornerId)`, `groupDetailProvider`, `groupVisitsProvider`, `trackMessageListProvider(trackId)`처럼 두 번째 인자가 있는 family provider는 admin SSE의 `scope`가 `{kind: "camp"}`뿐이라 "어느 인스턴스가 바뀌었는지" 알 수 없다. 따라서 이 Phase는 해당 family의 **모든 캐시된 인스턴스**를 무효화한다(`ref.invalidate(providerName)`을 인자 없이 호출 — Riverpod은 family provider의 이름 자체를 invalidate하면 캐시된 모든 인스턴스를 무효화하는 것을 지원한다). 현재 화면 하나만 그 상세를 보고 있는 게 일반적이므로(A2 코너 상세, A6 조 상세 등 한 번에 한 건만 진입) 실질적으로는 "현재 보고 있는 상세 1건"만 재조회가 트리거된다.

### 2.4 재연결 시 전체 재조회 (UC-3)

```dart
/// 스트림이 (재)연결에 처음 성공한 시점에 1회 호출.
/// 개별 이벤트 매핑을 신뢰하지 않고 "이 캠프에서 관리자가 볼 수 있는 모든 목록"을
/// 무조건 다시 부른다 — best-effort 유실(§00 overview 2.3) 보완.
void fullRefresh(Ref ref, CampId campId) {
  _invalidateTrackList(ref, campId);
  _invalidateCornerList(ref, campId);
  _invalidateCornerDetailAll(ref, campId);
  _invalidateLiveSummary(ref, campId);
  _invalidateGroupList(ref, campId);
  _invalidateGroupDetailAll(ref, campId);
  _invalidateGroupVisitsAll(ref, campId);
  _invalidateSelectedCamp(ref, campId);
  _invalidateBroadcastMessageList(ref, campId);
  _invalidateTrackMessageListAll(ref, campId);
  _invalidateAdminSessionList(ref, campId);
  _invalidateDeviceRegistrationList(ref, campId);
}
```

이 목록은 §3 매핑 표의 "invalidate 대상" 컬럼에 등장하는 provider 전체의 합집합이다 — 새 화면이 SSE 대상 provider를 추가할 때마다 `fullRefresh`에도 같은 줄을 추가해야 한다(체크리스트 항목으로도 남김).

### 2.5 배너 상태 파생 (`ConnectionBanner` 연결)

```dart
@riverpod
ConnectionBannerState adminConnectionBannerState(Ref ref) {
  final campId = ref.watch(selectedCampIdProvider);
  if (campId == null) return ConnectionBannerState.hidden; // SSE 대상 자체가 없음
  final state = ref.watch(adminSseDispatcherProvider);
  return switch (state) {
    AdminConnectionState.connected => ConnectionBannerState.hidden,
    AdminConnectionState.reconnecting => ConnectionBannerState.reconnecting,
    AdminConnectionState.disconnected => ConnectionBannerState.disconnected,
  };
}
```

`AdminConnectionState`에 실질적으로 `disconnected` 값이 만들어지는 경로가 없다는 점에 주의(§2.2에서 `connected`/`reconnecting`만 씀 — facilitator의 `TrackConnectionState`와 동일하게 "무한 재연결 루프이므로 완전히 끊긴 상태는 없고 항상 재시도 중"이 전제). enum에 `disconnected`를 남겨두는 이유는 (a) `ConnectionBannerState`와 3값을 대칭시켜 향후 "N회 재시도 실패 시 포기" 정책이 추가될 여지를 남기고 (b) facilitator 쪽 명명 관례를 그대로 따르기 위함이다 — 이번 Phase에서 `disconnected`로 전이시키는 로직은 만들지 않는다.

### 2.6 `AdminApp` 배선 (`frontend/lib/admin/app.dart`, 기존 파일 수정)

```dart
// MaterialApp.router(
//   ...
//   builder: (context, child) {
//     // ref.watch(adminSseDispatcherProvider)를 여기서 watch해 디스패처를 살려 둔다.
//     // (autoDispose 기본값이므로, 아무도 watch하지 않으면 즉시 폐기되어 구독이 끊긴다.)
//     final bannerState = ref.watch(adminConnectionBannerStateProvider);
//     return Column(
//       children: [
//         ConnectionBanner(state: bannerState),
//         Expanded(child: child ?? const SizedBox.shrink()),
//       ],
//     );
//   },
// )
```

`builder`는 라우터가 결정한 화면(`child`) 위/아래에 항상 렌더링되는 위치이므로, 13개 화면 스텁이 각자 배너를 넣을 필요가 없다 — `02_admin_skeleton_router_sidebar.md`의 F-3(`AdminApp` 작업)에 이 `builder` 배선이 없다면 이 Phase에서 추가한다(F-3과 겹치는 부분은 이 Phase 작업 E-4에서 명시).

## 3. 이벤트 → provider 무효화 매핑 표

`campId`는 모든 provider 호출에 공통으로 전달되므로 생략. "family 전체" 표시는 §2.3의 "인자 없이 invalidate" 패턴을 뜻한다.

| # | 이벤트 | 무효화 대상 provider | 근거 화면 |
|---|---|---|---|
| 1 | `tracks_updated` | `trackListProvider`, `cornerListProvider`, `liveSummaryProvider` | A1(`05`), A2/A2B/A3/A4(`06`) |
| 2 | `track_updated` | `trackListProvider`, `cornerDetailProvider`(family 전체), `liveSummaryProvider` | A2/A2B/A3/A4(`06`), A1(`05`) |
| 3 | `corners_updated` | `cornerListProvider`, `cornerDetailProvider`(family 전체), `liveSummaryProvider` | A1(`05`), A2/A2B/A3/A4(`06`) |
| 4 | `groups_updated` | `groupListProvider`, `groupDetailProvider`(family 전체), `groupVisitsProvider`(family 전체) | A5/A6(`07`) |
| 5 | `camp_updated` | `selectedCampProvider`(내부적으로 `campDetailProvider(campId)`) | `AdminSidebar` 모드(`02`), A1 헤더 |
| 6 | `messages_changed` | `broadcastMessageListProvider`, `trackMessageListProvider`(family 전체) | A10/A11(`09`) |
| 7 | `track_deleted` | `trackListProvider`, `cornerListProvider`, `cornerDetailProvider`(family 전체) | A2/A2B/A3/A4(`06`) |
| 8 | `track_replaced` | `trackListProvider`, `cornerDetailProvider`(family 전체) | A2/A2B/A3/A4(`06`) — A3 트랙 교체 |
| 9 | `session_revoked` | `adminSessionListProvider`(`auth_admin_providers.dart`) | A9(`08`) |
| 10 | `camp_ended` | `selectedCampProvider` | `AdminSidebar`가 `ENDED`로 전환 → 라우터 가드가 `/report`로 리다이렉트(`02` §2.5 규칙 6) |
| 11 | `device_registration_updated` | `deviceRegistrationListProvider` | A8(`08`) |
| 12 | `lockout_alert` | `ref.invalidate(lockedDeviceListProvider(campId))` | A9(`08`) |

**확인 필요 — `lockout_alert` — 해소함**: `08_a8_a9_device_session.md` §2.5가 `GET /device-registrations/locked`(`lockedDeviceListProvider`)를 정식 provider로 확정했다(단, 백엔드가 아직 `501`을 반환하는 동안엔 이 invalidate가 다시 `501`을 받아올 뿐 — 무해하다). `fullRefresh`(§2.4)에도 `lockedDeviceListProvider(campId)`와 `activeSessionListProvider(campId)` invalidate를 함께 추가할 것.

**확인 필요 — `camp_updated`/`camp_ended`와 A0-e 낙관적 갱신의 충돌 — 해소함(디바운스 가드 채택)**: `02_admin_skeleton_router_sidebar.md` 검증 체크리스트는 A0-e(`POST /camps/{id}/start`) 성공 시 "재조회 없이" 캐시를 직접 덮어쓰라고 명시한다. 이 Phase의 `camp_updated`/`camp_ended` 핸들러는 그 반대로 "재조회(invalidate)"를 트리거한다. 위 분석대로 두 로직이 실질적으로 같은 값을 받아오므로 정합성 문제는 없다고 판단되지만(하나는 로컬 액션 직후 동기 갱신, 하나는 SSE 수신 시 비동기 무효화), 화면 깜빡임(로딩 상태로 잠깐 빠짐)을 막기 위해 낙관적 갱신을 통째로 제거하는 대신 **디바운스 가드를 채택한다**: A0-e 로컬 갱신 직후 500ms 이내에 도착하는 `camp_updated`/`camp_ended` SSE 이벤트는 같은 캠프에 대해서라면 `invalidate`를 스킵한다(로컬 갱신이 이미 최신값을 반영했다고 간주). 500ms 이후 도착하는 이벤트는 정상적으로 invalidate한다 — 정합성보다 화면 깜빡임 방지가 이 케이스에서 더 중요하다고 판단(로컬 갱신 자체가 서버 응답의 `Camp`를 그대로 쓰므로 데이터 정합성은 이미 보장됨, §02 참고). `14_verification_checklist.md`에서 실기기로 깜빡임 없음을 확인할 것.

## 4. `SseEvent`/`scope` 형식에 대한 확인 필요 사항

현재 커밋된 `frontend/lib/shared/api/gen/lib/src/model/sse_event.dart`(재생성 전)은:
- `SseEventEventEnum`에 `track_replaced`가 **없다**(11종만 존재, `00_overview.md` §2.3의 12종과 불일치).
- `SseNotificationData.scope`가 객체가 아니라 **문자열**(`String get scope`, 예: `"camp"`)이다 — `00_overview.md` §2.3이 말하는 `scope.kind`/`scope.trackId` 객체 구조와 다르다.

이는 `01_api_codegen_sync.md`가 아직 실행되지 않은 시점의 구버전 생성 코드이기 때문이다(§00 overview 2.3, `01` A-2가 재생성하면 해결됨 전제). 이 문서의 §2.3 코드가 쓰는 `event.event`(`SseEventEventEnum` 비교)와 `SseEventEventEnum.trackReplaced`는 **재생성 후 실제로 생성되는 이름**을 다시 확인해야 한다 — built_value dart-dio generator가 `track_replaced`를 `trackReplaced`로 camelCase 변환하는 관례(기존 11종 모두 그 관례를 따름)를 그대로 따를 것으로 예상하지만, 재생성 직후 `frontend/lib/shared/api/gen/lib/src/model/sse_event.dart`를 열어 실제 상수명을 대조해야 한다. `scope`가 객체로 바뀌면 필드명도(`kind`/`trackId`) 재생성 결과를 보고 `_rulesFor`/`fullRefresh` 어디에서도 `scope`를 사용하지 않는 현재 설계(§2.3 주석 — admin 스트림은 `scope.kind`가 항상 `camp`라 무시 가능)에는 영향이 없지만, **A9(`08`)이 `track` 스코프를 구분해야 하는 경우가 생기면**(예: 특정 트랙만 세션이 revoke됐는지 표시) 이 가정을 재검토해야 한다.

## 5. 작업 단계

| 순서 | 작업 | 파일 |
|---|---|---|
| E-1 | `AdminConnectionState` enum + `AdminSseDispatcher` 클래스(§2.2) | `frontend/lib/admin/session/admin_sse_dispatcher.dart` |
| E-2 | `dispatchEvent`/`_rulesFor`/`fullRefresh`(§2.3, §2.4) — 같은 파일 또는 `admin_sse_invalidation_rules.dart`로 분리(파일이 너무 커지면 분리 권장, 100줄 넘어가면 분리) | `frontend/lib/admin/session/admin_sse_dispatcher.dart` (또는 `admin_sse_invalidation_rules.dart`) |
| E-3 | `adminConnectionBannerStateProvider`(§2.5) | `frontend/lib/admin/session/admin_sse_dispatcher.dart` |
| E-4 | `AdminApp`의 `MaterialApp.router(builder:)`에 `ConnectionBanner` + 디스패처 watch 배선(§2.6) — `02`의 F-3이 이미 `builder`를 썼다면 그 안에 추가만 함 | `frontend/lib/admin/app.dart` |
| E-5 | `dart run build_runner build --delete-conflicting-outputs` 후 `git status`로 `lib/shared/api/gen` 무변경 확인(`01` D-1과 동일한 상습 사고 지점) | 전체 |
| E-6 | §4의 재생성 후 실제 enum/필드명 대조, 코드와 표(§3) 갱신 | `frontend/lib/admin/session/admin_sse_dispatcher.dart` |

## 6. 검증 체크리스트

- [ ] 캠프 A를 선택한 상태에서 `adminEventsProvider` 구독이 정확히 1개만 열려 있다(Dio 요청 로그 또는 디버그 브레이크포인트로 확인 — 화면을 여러 개 띄워도 스트림 연결 자체는 늘어나지 않는다)
- [ ] 캠프 A를 보고 있을 때 서버가 보낸 이벤트의 `scope`가 캠프 B에 대한 것이면(실제로는 admin 스트림이 `campId` 경로로 이미 격리되므로 발생하지 않아야 정상 — 이 항목은 "경로 격리가 실제로 캠프별로 분리된 커넥션인지"를 재확인하는 회귀 테스트) 캠프 A 화면의 provider가 무효화되지 않는다
- [ ] `selectedCampIdProvider`를 캠프 A → 캠프 B로 바꾸면(사이드바 "← 캠프 목록" 후 다른 캠프 재선택) 캠프 A용 `adminEventsProvider(A)` 구독이 끊기고(HTTP 연결 종료 확인) 캠프 B용 구독이 새로 열린다 — A로 향하던 오래된 이벤트가 뒤늦게 도착해도 B 화면의 provider를 건드리지 않는다
- [ ] 캠프 미선택 상태(`/camps`, `/login`, `/badges`)에서는 `adminEventsProvider`가 전혀 호출되지 않는다(네트워크 탭에 `/events/admin` 요청 없음)
- [ ] 강제로 서버 연결을 끊었다가(예: 백엔드 재시작 또는 프록시로 커넥션 kill) 재연결되는 순간, 그 사이 발생했을 이벤트를 하나도 못 받았어도 §2.4 `fullRefresh` 목록의 모든 provider가 재조회된다(REST 요청 로그에서 목록 API들이 한꺼번에 다시 호출되는지 확인)
- [ ] 재연결 중(`reconnecting`)에는 화면 최상단에 `ConnectionBanner`(회색, "재연결 시도 중…")가 보이고, `connected`로 돌아오면 배너가 사라진다(상시 인디케이터 없음 — 평상시엔 배너 자체가 렌더링 트리에 없어야 함, `_ConnectionBannerState.hidden && controller.isDismissed` 시 `SizedBox.shrink()` 반환되는 기존 위젯 동작 그대로)
- [ ] `tracks_updated` 수신 시 A1 대시보드가 열려 있으면 데이터가 다시 불러와지고(로딩 스피너가 아주 짧게라도 나타나거나, 최소한 네트워크 탭에 재요청이 찍힘), A5(조 현황)처럼 무관한 화면이 열려 있을 때는 그 화면의 provider(`groupListProvider` 등)는 재요청되지 않는다
- [ ] `camp_ended` 수신 시(다른 관리자 기기가 A15/A0-e류 액션으로 캠프를 종료) 현재 기기의 사이드바가 자동으로 리포트 전용 모드로 전환되고 현재 라우트가 운영 모드 전용이었다면 `/report`로 리다이렉트된다(`02` §2.5 redirect 규칙 6과 연계 — `selectedCampProvider` invalidate만으로 라우터 `refreshListenable`이 재평가되는지 확인)
- [ ] A0-e(캠프학습 시작)를 누른 **본인** 세션에서, 로컬 낙관적 갱신 직후 도착하는 `camp_updated` SSE 이벤트로 인해 화면이 다시 로딩 상태로 깜빡이지 않는다
- [ ] `flutter analyze` 0 에러(`frontend/lib/admin/**`, `frontend/lib/shared/**` 범위)
