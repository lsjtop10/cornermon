# Phase 13 — 관리자 앱 테스트 인프라

> 선행조건: `01_api_codegen_sync.md`(provider 시그니처 확정), `02_admin_skeleton_router_sidebar.md`(라우터·사이드바·세션 확정). 대상 독자: 1~2년차 프론트엔드 개발자 1명, 예상 소요 6~8시간.
> 목적: `03`~`11`(19개 화면), `12_admin_sse_integration.md`가 각자 작성할 테스트가 공유할 공통 인프라(fixture, fake Dio/API, 위젯 테스트 헬퍼, 라우터/SSE 단위 테스트 패턴)를 이 Phase에서 먼저 세운다. `01`과 병행 가능(`00_overview.md` §1 실행 순서).
> 근거: `workflow/implement.md`("테스트 이름 규칙: ShouldXxxWhenYyy", "arrange-act-assert 프레임워크, 주석에도 명시"), `frontend/docs/artifacts/plan/진행자_앱_플로우_완성_plan_20260710/08_test_infrastructure.md`(선행 Phase, 이미 구현됨 — 이 문서의 대응 문서).
>
> **재사용 원칙**: `frontend/test/test_utils/widget_test_helpers.dart`(`buildTestable`, `buildFakeDio`, `buildContainer`)와 `frontend/test/shared/api/**`는 진행자/관리자 공용이다. 이미 존재하는 것은 다시 만들지 않는다 — 이 Phase는 **admin 전용 net-new 인프라**(`frontend/test/admin/**`)와, 기존 공용 헬퍼로는 부족한 부분(예: 관리자 세션 override, `campId` 파라미터가 붙은 provider용 fake API)만 추가한다.

## 0. 현재 상태 조사 결과

| 항목 | 위치 | 상태 |
|---|---|---|
| `buildTestable(Widget, {overrides})` | `frontend/test/test_utils/widget_test_helpers.dart` | 기존, 재사용 |
| `buildContainer({overrides})` | 〃 | 기존, 재사용 |
| `buildFakeDio(responder)` | 〃 | 기존, 재사용(단 JSON 바디 고정 응답 전용 — SSE 등 스트림 응답에는 부적합, §4 참고) |
| 개별 API concrete class를 override하는 fake 패턴(`_FakeVisitScanFlowApi extends CVisitScanFlowApi`) | `frontend/test/shared/api/providers/visit_providers_test.dart` | 기존 패턴, 그대로 답습 |
| 라우터 redirect 테스트(`_buildApp` + `GoRouter.of(context).go(...)` 직접 호출) | `frontend/test/facilitator/router/facilitator_router_test.dart` | 기존 패턴, 그대로 답습 |
| SSE 프레임 파싱 테스트(`_FakeStreamAdapter implements HttpClientAdapter`) | `frontend/test/shared/api/sse/sse_client_test.dart` | 기존, `SseClient` 자체는 공용 — admin은 이 계층 위(이벤트→invalidation 매핑)만 새로 테스트 |
| `frontend/test/admin/**` | — | **존재하지 않음, 이 Phase에서 신규 생성** |

`SseClient`(공용, `frontend/lib/shared/api/sse/sse_client.dart`)의 프레임 파싱 자체는 이미 테스트돼 있다. Admin이 새로 테스트할 것은 `12_admin_sse_integration.md`가 만들 "이벤트 enum → invalidate 대상 provider" 매핑 로직이지, SSE 프로토콜 파싱이 아니다 — 중복 테스트하지 않는다.

## 1. 유즈케이스

| 우선순위 | 유즈케이스 | 설명 | 용도 |
|---|---|---|---|
| **P0** | UC-1: 모든 admin provider가 네트워크 없이 fake API concrete class로 검증된다 | `campId` 파라미터가 붙은 신규/갱신 provider 포함 | 프로덕션 핵심 로직 검증 |
| **P0** | UC-2: 19개 화면 각각 최소 1개의 위젯 테스트로 렌더링·핵심 인터랙션이 검증된다 | `pumpAdminScreen` 공통 헬퍼 사용 | 프로덕션 핵심 로직 검증 |
| **P0** | UC-3: `adminRouter`의 3모드 redirect 우선순위 7단계가 위젯 트리 없이 또는 최소 트리로 검증된다 | `02_admin_skeleton_router_sidebar.md` §2.5 로직 | 프로덕션 핵심 로직 검증 |
| **P1** | UC-4: SSE 이벤트→invalidate 매핑표(12개 이벤트)가 실제 SSE 연결 없이 fake `Stream<SseEvent>`로 검증된다 | `12_admin_sse_integration.md` 대응 | 프로덕션 핵심 로직 검증 |
| **P1** | UC-5: 코너 단건 수정(A2)과 일괄 수정(A2B)이 동일한 `BulkUpdateCornersRequest`를 재사용함이 회귀되지 않는다 | §00 overview 2.2 결정 고정 | 회귀 방지 |

## 2. 객체 정의

### 2.1 Fixture 전략 — builder 기반 채택(hand-written JSON 기각)

**결정: hand-written JSON 파일을 만들지 않는다. `cornermon_api_gen`의 built_value 생성 클래스가 제공하는 `Xxx((b) => b..field = value)` 빌더 생성자로 fixture를 코드로 구성한다.**

근거:
- `cornermon_api_gen`의 모든 DTO(`Camp`, `Corner`, `Track`, `Group`, `Badge`, `Message`, `AuditLogEntry`, `CampReport` 등, `frontend/lib/shared/api/gen/lib/src/model/*.dart`)는 built_value로 생성되며 `factory Camp([void updates(CampBuilder b)]) = _$Camp;` 형태의 빌더 생성자를 갖는다(`frontend/lib/shared/api/gen/lib/src/model/camp.dart` 확인됨).
- hand-written JSON은 `api/swagger.yaml`이 바뀌어도 컴파일 에러 없이 조용히 드리프트한다(필드 이름 오타, 타입 불일치가 런타임에야 드러남).
- 빌더 기반 fixture는 스키마가 바뀌면(필드 삭제/타입 변경) **컴파일 자체가 깨진다** — 드리프트가 CI에서 즉시 드러난다.
- 기존 코드베이스가 이미 이 패턴을 쓰고 있다(`frontend/test/shared/api/providers/visit_providers_test.dart`의 `_buildVisitSummary()`, `frontend/test/facilitator/router/facilitator_router_test.dart`의 `Track((b) => b..id = ...)`) — 새 컨벤션을 도입하지 않고 답습한다.

파일: `frontend/test/admin/fixtures/admin_fixtures.dart`(신규)

```dart
// frontend/test/admin/fixtures/admin_fixtures.dart
// 관리자 화면 테스트 전반에서 재사용하는 최소 유효 DTO 빌더 모음.
// 각 함수는 "이 테스트에서 중요하지 않은 필드"에 대해 화면별 오버라이드가 쉬운
// 명명 파라미터를 제공한다 — 진행자 쪽 _buildVisitSummary() 패턴과 동일.

Camp buildCamp({String id = 'camp-1', String name = '2026 여름 캠프', CampStatus status = CampStatus.ACTIVE});
Corner buildCorner({String id = 'corner-1', String name = '입장', int targetMinutes = 10, CornerOperationalStatus status = CornerOperationalStatus.IDLE});
Track buildTrack({String id = 'track-1', String cornerId = 'corner-1', int trackNo = 1, TrackStatus status = TrackStatus.ACTIVE});
Group buildGroup({String id = 'group-1', String name = '1조'});
Badge buildBadge({String id = 'badge-1', BadgeStatus status = BadgeStatus.UNASSIGNED});
DeviceRegistration buildDeviceRegistration({String id = 'device-1', DeviceRegistrationStatus status = DeviceRegistrationStatus.PENDING});
Message buildMessage({String id = 'msg-1', MessageChannelType channelType = MessageChannelType.BROADCAST, MessageSenderRole senderRole = MessageSenderRole.ADMIN});
AuditLogEntry buildAuditLogEntry({String id = 'audit-1', String actor = 'admin-1', String action = 'CAMP_START'});
CampReport buildCampReport({String campId = 'camp-1'});
```

**확인 필요**: `Group`, `Badge`, `DeviceRegistration`, `Message`, `AuditLogEntry`, `CampReport` DTO의 정확한 필수 필드 목록은 `01_api_codegen_sync.md` 실행(코드젠 재생성) 후 `frontend/lib/shared/api/gen/lib/src/model/*.dart`를 직접 열어 확정한다 — 이 문서 작성 시점에는 `Camp`만 실물 확인했다. 이 fixture 파일의 첫 커밋에서 각 함수 시그니처를 실제 생성 코드에 맞춰 조정할 것.

### 2.2 Provider 테스트 패턴 — 기존 concrete-class override 답습

신규 헬퍼를 만들지 않는다. `visit_providers_test.dart`가 쓴 패턴을 그대로 따른다: provider가 내부적으로 호출하는 `*Api` concrete class(예: `BCampCornerTrackApi`, `CVisitScanFlowApi`)를 상속한 `_FakeXxxApi`를 테스트 파일마다 정의하고, `xxxApiProvider.overrideWithValue(fakeApi)`로 주입한다.

```dart
// 예시: frontend/test/shared/api/providers/camp_providers_test.dart (01의 갱신 대상 provider 검증용, 신규)
class _FakeCampCornerTrackApi extends BCampCornerTrackApi {
  _FakeCampCornerTrackApi() : super(Dio(), serializers);

  List<Corner>? cornerListData;
  String? capturedCampId; // campId가 경로 파라미터로 잘 전달되는지 검증하는 용도(§00 overview 2.4)

  @override
  Future<Response<CampsCampIdCornersGet200Response>> campsCampIdCornersGet({
    required String campId,
    // ...
  }) async {
    capturedCampId = campId;
    return Response(data: ..., requestOptions: RequestOptions(path: '/camps/$campId/corners'));
  }
}
```

핵심 검증 포인트(§00 overview 2.4): `campId`가 URL 경로에 정확히 반영되는지를 `capturedCampId` 필드로 캡처해 assert한다 — 01에서 갱신되는 모든 `campId` 파라미터 provider(`cornerList(campId)`, `groupList(campId)`, `trackList(campId)` 등) 테스트에 공통으로 넣는다.

`apiClientProvider`/`sessionTokenSourceProvider`를 직접 override하지 않는다(진행자 쪽과 동일한 이유 — 개별 API class override가 더 정밀하다, `08_test_infrastructure.md` §4 마지막 항목 참고). 다만 `selectedCampIdProvider`는 admin 전용이므로 관리자 화면 위젯 테스트에서 직접 override가 필요하다 — §2.3에서 다룬다.

### 2.3 위젯 테스트 패턴 — `pumpAdminScreen`

파일: `frontend/test/admin/test_utils/admin_widget_test_helpers.dart`(신규)

```dart
// frontend/test/admin/test_utils/admin_widget_test_helpers.dart
// buildTestable(진행자 공용, test/test_utils/widget_test_helpers.dart)을 감싸되
// adminTheme + 관리자 화면 전제(선택된 캠프 컨텍스트)를 기본값으로 채워준다.

/// admin/features/* 화면 위젯 테스트 공통 진입점.
/// - MaterialApp(theme: adminTheme)로 감싼다(라이트/다크 모드 스냅샷 차이를 피하기 위해 라이트 고정 — 필요시 theme 파라미터로 교체 가능하게 열어둔다).
/// - selectedCampIdProvider를 기본으로 buildCamp().id로 override해 "캠프 선택됨" 상태를 기본 전제로 삼는다
///   (대부분의 03~11 화면이 캠프 선택 후 진입하는 화면이므로) — A0/A0-b/A0-c/A0-d처럼 캠프 미선택을 전제로 하는
///   화면은 overrides에 selectedCampIdProvider.overrideWith(() => ...null 반환하는 fake)를 명시적으로 다시 얹어 상쇄한다.
Future<void> pumpAdminScreen(
  WidgetTester tester,
  Widget screen, {
  List<Override> overrides = const [],
  CampId? selectedCampId, // null이면 override 생략(호출부가 직접 selectedCampIdProvider를 override했다는 뜻으로 취급)
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        if (selectedCampId != null)
          selectedCampIdProvider.overrideWith(() => _FixedSelectedCampId(selectedCampId)),
        ...overrides,
      ],
      child: MaterialApp(theme: adminTheme, home: screen),
    ),
  );
  await tester.pump();
}

class _FixedSelectedCampId extends SelectedCampId {
  _FixedSelectedCampId(this._id);
  final CampId _id;
  @override
  CampId? build() => _id;
}
```

`adminTheme`은 이미 존재(`02_admin_skeleton_router_sidebar.md` F-3 "이미 존재하는 `admin_theme.dart` 재사용" 참고) — import 위치는 실제 구현 시 `frontend/lib/admin/theme/admin_theme.dart` 등을 확인해 채운다.

**확인 필요**: `adminTheme`의 정확한 파일 경로/심볼명은 `02`에서 F-3으로 확정되는데 이 문서 작성 시점엔 아직 구현되지 않았다. `13`을 `01`과 병행 실행할 경우 이 심볼이 없을 수 있으므로, `pumpAdminScreen`의 첫 구현 커밋은 `02`가 완료된 뒤로 미루거나(권장) 실제 심볼 확인 후 import를 채워 넣는다.

### 2.4 라우터 redirect 테스트 패턴

`facilitator_router_test.dart`와 동일한 접근: `adminRouterProvider`를 구독하는 `_buildApp(overrides)`를 만들고, `GoRouter.of(context).go(path)`로 직접 네비게이션을 트리거해 최종적으로 어느 화면이 렌더링됐는지 `find.byType`으로 검증한다. `_redirect` 함수 자체를 top-level로 노출해 순수 함수로 단위 테스트하는 방식은 쓰지 않는다 — 진행자 라우터가 `_redirect(Ref ref, GoRouterState state)`를 파일 내부 private 함수로 유지하고 위젯 트리 기반으로만 테스트해온 기존 관례를 따른다(새 패턴 도입 금지, `workflow/plan.md` "특별한 이유가 없으면 이미 존재하는 코드의 관례를 따릅니다").

파일: `frontend/test/admin/router/admin_router_test.dart`(신규)

```dart
// frontend/test/admin/router/admin_router_test.dart
Widget _buildApp(List<Override> overrides) => ProviderScope(
      overrides: overrides,
      child: Consumer(
        builder: (context, ref, _) =>
            MaterialApp.router(routerConfig: ref.watch(adminRouterProvider)),
      ),
    );

// _FakeAdminSession(AdminSessionState) — admin_session_provider.dart의 AdminSession을 상속,
//   facilitator_router_test.dart의 _MutableTrackSession과 동일한 형태로 setState(newState)를 제공한다.
// _FakeSelectedCampId(CampId?) — 위 §2.3 _FixedSelectedCampId와 동일 개념(가변 버전 필요시 setState 추가).
```

`02` §2.5의 redirect 우선순위 7단계 각각을 최소 1개 테스트로 매핑한다(§5 커버리지 체크리스트 참고). 특히 "PENDING 캠프에서 `/dashboard` 강제 `go()` 후 최종 위치가 `/corner-track-manage`인지"처럼 **URL 직접 조작 우회 시도**를 재현하는 테스트가 `02` §4 검증 체크리스트 항목과 1:1로 대응해야 한다(새 검증 기준을 여기서 추가하지 않는다 — `08_test_infrastructure.md` §3 말미와 동일 원칙).

### 2.5 SSE 이벤트→invalidate 매핑 테스트 패턴

`12_admin_sse_integration.md`가 아직 작성되지 않았으므로(§1 실행 순서상 `13`이 먼저 병행 실행됨), 이 절은 **`12`가 구현할 형태를 이 문서가 선(先) 가정**하고 그에 맞춰 테스트 인프라만 준비해 둔다. `12` 작성 시 아래 가정과 실제 설계가 다르면 `12`가 이 절을 갱신한다.

가정하는 형태(§00 overview 2.3 "notify-then-refetch" 기준):

```dart
// frontend/lib/admin/session/admin_sse_dispatcher.dart (12에서 구현 예정, 여기서는 시그니처만 가정)
// SSENotification.event(12종 enum) -> invalidate할 provider 집합의 매핑을 담당하는 순수 함수/클래스.
// 실제 SSE 연결(SseClient)과는 별도 계층으로 분리되어 있어야 fake Stream<SseEvent>만으로 테스트 가능하다.
void dispatchAdminSseEvent(Ref ref, SseEvent event);
```

테스트 파일: `frontend/test/admin/session/admin_sse_dispatcher_test.dart`(신규, `12` 구현 시점에 실제 작성)

```dart
test('ShouldInvalidateCornerListWhenCornersUpdatedEventReceived', () {
  // arrange: ProviderContainer + cornerListProvider를 감시하는 listener 등록
  // act: dispatchAdminSseEvent(ref, SseEvent(event: cornersUpdated, ...))
  // assert: cornerListProvider가 invalidate(dirty 상태로 전환)됨을 listener 호출로 확인
});
```

`SseClient`의 프레임 파싱은 재테스트하지 않는다(§0 표 참고) — 여기서는 이미 파싱된 `SseEvent` 객체를 fake `Stream<SseEvent>`로 주입해 "이벤트 종류 → 어떤 provider가 invalidate되는가" 매핑표만 검증한다. 12종 이벤트 각각 최소 1개 테스트(§5 체크리스트).

### 2.6 코너 단건/일괄 수정 공용 경로 회귀 테스트

§00 overview 2.2 결정(`PUT /corners/bulk-update`를 A2 단건/A2B 다중 모두에서 사용)이 향후 리팩터링으로 깨지지 않도록, A2와 A2B 양쪽 위젯 테스트가 **동일한 fake API의 동일한 메서드**(`campsCampIdCornersBulkUpdatePut` 류)가 호출됨을 각각 assert한다(새 통합 테스트 파일을 따로 만들지 않고, `06_a2_a2b_a3_a4_corner_track.md`가 작성할 `corner_detail_test.dart`/`corner_bulk_manage_test.dart` 양쪽에 동일 assert를 심는 방식 — 이 문서는 그 요구사항만 명시한다).

## 3. 작업 단계

| 순서 | 작업 | 파일 |
|---|---|---|
| T-1 | admin fixture 빌더 함수 모음 | `frontend/test/admin/fixtures/admin_fixtures.dart` |
| T-2 | `pumpAdminScreen` 위젯 테스트 헬퍼 | `frontend/test/admin/test_utils/admin_widget_test_helpers.dart` |
| T-3 | `campId` 파라미터 갱신 provider용 fake API 클래스 및 provider 단위 테스트(01 §4 대응 항목) | `frontend/test/shared/api/providers/{camp,corner_track,group,badge,message,report,audit_log}_providers_test.dart` |
| T-4 | `adminRouter` redirect 7단계 테스트(02 §4 대응 항목) | `frontend/test/admin/router/admin_router_test.dart` |
| T-5 | `AdminSession`/`SelectedCampId` notifier 단위 테스트(02 §4 대응 항목) | `frontend/test/admin/session/{admin_session,selected_camp}_provider_test.dart` |
| T-6 | 19개 화면 위젯 테스트 스텁(각 화면 plan(`03`~`11`)이 실제 내용으로 채움 — 이 Phase는 디렉터리와 최소 "렌더링됨" 테스트 1개만 선구축) | `frontend/test/admin/features/<screen>/<screen>_test.dart` |
| T-7 | SSE 매핑 테스트 골격(`12` 구현 시 채움 — 이 Phase는 fixture/헬퍼만) | `frontend/test/admin/session/admin_sse_dispatcher_test.dart`(placeholder, `12`가 채움) |

T-6, T-7은 이 Phase 시점에는 대상 위젯/로직이 아직 없으므로 **파일을 만들지 않는다** — 대신 §5 커버리지 체크리스트를 `14_verification_checklist.md`가 최종 게이트로 사용하도록 남겨둔다(각 화면 Phase가 완료될 때마다 해당 행에 체크). T-1~T-5만 이 Phase에서 실제로 구현한다.

## 4. 위젯 테스트 vs Provider 단위 테스트 배분 기준

- `shared/api/providers/*.dart` 함수: **provider 단위 테스트**(§2.2) — 위젯 없이 `ProviderContainer`로 검증. HTTP 호출 형태(경로, 메서드, body)가 핵심이므로 위젯까지 띄울 필요 없다.
- `admin/entities/*_ext.dart` extension: **순수 unit test** — `ProviderContainer`도 필요 없다, 입력 DTO(§2.1 fixture)를 만들어 extension 메서드를 직접 호출하고 반환값만 assert한다. `dio`/`flutter_riverpod`/`go_router` import 금지 규칙(§00 overview §3)과 대응되게, 이 테스트도 동일하게 순수해야 한다(import 시 `flutter_test`, DTO, extension 파일만).
- `admin/features/<screen>/*.dart` 위젯: **위젯 테스트**(§2.3) — `pumpAdminScreen`으로 렌더링 후 `tester.tap`/`find.text` 등으로 인터랙션 검증. Provider는 이미 §2.2에서 검증됐다는 전제 하에 화면 테스트에서는 provider 내부 HTTP 세부사항을 재검증하지 않고 fake data를 override로 직접 주입한다(예: `cornerListProvider(campId).overrideWith((ref) => [buildCorner()])`).
- `admin/router/admin_router.dart`: **라우터 위젯 테스트**(§2.4).
- `admin/session/admin_sse_dispatcher.dart`(12에서 생성): **dispatcher 단위 테스트**(§2.5).

## 5. 커버리지 체크리스트 (19개 화면 + 공유 로직)

각 화면 담당 Phase(`03`~`11`)가 위젯 테스트를 작성한 뒤 이 표의 해당 행을 체크한다. `14_verification_checklist.md`가 최종적으로 전체 체크 여부를 확인한다.

| 화면 ID | 화면명 | 담당 Phase | 테스트 파일 | 체크 |
|---|---|---|---|---|
| A0 | 로그인 | 03 | `frontend/test/admin/features/login/login_test.dart` | [ ] |
| A0-b | 초기 설정 마법사 | 03 | `frontend/test/admin/features/setup_wizard/setup_wizard_test.dart` | [ ] |
| A0-c | 캠프 목록 | 04 | `frontend/test/admin/features/camp_list/camp_list_test.dart` | [ ] |
| A0-d | QR 배지 사전 생성 | 04 | `frontend/test/admin/features/badge_export/badge_export_test.dart` | [ ] |
| A0-e | 코너학습 시작 | 04 | `frontend/test/admin/features/camp_start/camp_start_test.dart` | [ ] |
| A1 | 대시보드 | 05 | `frontend/test/admin/features/dashboard/dashboard_test.dart` | [ ] |
| A2 | 코너 상세 | 06 | `frontend/test/admin/features/corner_detail/corner_detail_test.dart` | [ ] |
| A2B | 트랙 일괄 관리 | 06 | `frontend/test/admin/features/corner_bulk_manage/corner_bulk_manage_test.dart` | [ ] |
| A3 | 트랙 교체(모달) | 06 | A2B 테스트 파일 내 케이스로 포함(별도 라우트 아님, §2.5 라우트 트리 참고) | [ ] |
| A4 | PIN 전체 내보내기 | 06 | A2B 테스트 파일 내 케이스로 포함 | [ ] |
| A5 | 조 현황 목록 | 07 | `frontend/test/admin/features/group_status/group_status_test.dart` | [ ] |
| A6 | 조 상세 | 07 | `frontend/test/admin/features/group_detail/group_detail_test.dart` | [ ] |
| A8 | 기기 등록 관리 | 08 | `frontend/test/admin/features/device_registration/device_registration_test.dart` | [ ] |
| A9 | PIN 잠금해제/세션 관리 | 08 | `frontend/test/admin/features/session_manage/session_manage_test.dart` | [ ] |
| A10 | 공지 메시지 | 09 | `frontend/test/admin/features/broadcast_message/broadcast_message_test.dart` | [ ] |
| A11 | 다이렉트 메시지 | 09 | `frontend/test/admin/features/direct_message/direct_message_test.dart` | [ ] |
| A12 | 리포트 | 10 | `frontend/test/admin/features/report/report_test.dart` | [ ] |
| A13 | 감사 로그 | 11 | `frontend/test/admin/features/audit_log/audit_log_test.dart` | [ ] |
| A14 | 코너학습 종료 | 11 | `frontend/test/admin/features/camp_end/camp_end_test.dart` | [ ] |
| A15 | 설정 | 11 | `frontend/test/admin/features/settings/settings_test.dart` | [ ] |

공유 로직 커버리지:

| 대상 | 담당 Phase | 테스트 파일 | 체크 |
|---|---|---|---|
| `adminRouter` redirect 7단계 | 13(이 문서) | `frontend/test/admin/router/admin_router_test.dart` | [ ] |
| `AdminSession`/`SelectedCampId` notifier | 13(이 문서) | `frontend/test/admin/session/{admin_session,selected_camp}_provider_test.dart` | [ ] |
| SSE 이벤트→invalidate 매핑(12종) | 12 | `frontend/test/admin/session/admin_sse_dispatcher_test.dart` | [ ] |
| `campId` 경로 파라미터 반영(01 갱신 provider 전체) | 13(이 문서, T-3) | `frontend/test/shared/api/providers/*_providers_test.dart` | [ ] |
| 코너 단건/일괄 수정 공용 엔드포인트 회귀(§2.6) | 06 | A2/A2B 테스트 파일 내 assert | [ ] |
| PIN 내보내기 단건(PDF)/전체(CSV) 포맷 분기 | 06 | A2/A2B 테스트 파일 내 assert(Content-Type 분기 검증) | [ ] |

## 6. 검증 체크리스트

- [ ] `flutter test frontend/test/admin/` 및 `flutter test frontend/test/shared/` 전체가 그린으로 통과한다(네트워크 호출 0건 — 모든 테스트가 fake API concrete class 또는 fake `Stream`만 사용)
- [ ] `flutter analyze`가 `frontend/test/admin/` 기준 warning 0
- [ ] 신규 테스트 파일 각각의 테스트 이름이 `ShouldXxxWhenYyy` 규칙을 따르고, 각 테스트 바디에 `// arrange` / `// act` / `// assert` 3구간 주석이 있다(`workflow/implement.md`)
- [ ] `frontend/test/admin/fixtures/admin_fixtures.dart`의 모든 빌더 함수가 hand-written JSON이 아니라 `cornermon_api_gen` 빌더 생성자(`Xxx((b) => b..field = ...)`)만 사용한다 — grep으로 `jsonDecode`/하드코딩된 JSON 문자열이 fixture 파일에 없음을 확인
- [ ] §5 커버리지 표의 19개 화면 행 + 공유 로직 행이 각 담당 Phase 완료 시점에 모두 체크됨(최종 확인은 `14_verification_checklist.md`)
- [ ] 어떤 admin 테스트 파일도 `shared/api/client/api_client.dart`의 실제 `Dio` 인스턴스나 실기기 SecureStorage를 직접 사용하지 않는다(전부 override됨)
- [ ] `admin/entities/*_ext.dart` 대상 unit test 파일에 `dio`/`flutter_riverpod`/`go_router` import가 없다(entities 계층 제약이 테스트 코드에도 유지되는지 확인 — entities 자체 제약의 반영일 뿐 테스트 파일 자체엔 강제 규칙 아니지만 위반 시 설계 오류 신호로 간주)
