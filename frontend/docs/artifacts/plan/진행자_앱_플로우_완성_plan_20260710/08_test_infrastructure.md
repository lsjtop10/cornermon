# Phase 08 — 테스트 인프라 및 전체 자동화 테스트

> 선행조건: Phase 03~07(테스트 대상 화면 존재).
> 목적: `frontend/test/`가 처음 생기는 Phase다. Riverpod override 기반 unit/widget 테스트만 다룬다(§00 §0-b, 실기기/에뮬레이터 통합테스트는 이번 스코프 밖).
> 근거: `workflow/implement.md` "테스트 이름 규칙: ShouldXxxWhenYyy", "arrange-act-assert", `workflow/plan.md` §5(검증 방법 명시 필수).

## 1. 유즈케이스

| 우선순위 | 유즈케이스 | 용도 |
|---|---|---|
| **P1** | UC-8: 모든 신규 provider/화면이 네트워크 없이 Riverpod override + fake Dio만으로 검증된다 | 품질 검증 |

## 2. 객체 정의

```dart
// frontend/test/test_utils/widget_test_helpers.dart
Widget buildTestable(Widget child, {List<Override> overrides = const []}) =>
    ProviderScope(overrides: overrides, child: MaterialApp(home: child));

/// fake Dio — 실제 HTTP 없이 DioAdapter/interceptor로 응답을 고정한다.
/// (Dio 자체는 이미 의존성에 있으므로 신규 패키지 추가 없이 `Dio()..httpClientAdapter = ...`로 구현 가능한지 우선 확인,
///  필요 시 `http_mock_adapter` 등 테스트 전용 패키지 추가 여부를 이 Phase 착수 시 확인한다.)
Dio buildFakeDio(Map<String, dynamic> Function(RequestOptions) responder);
```

**테스트 명명 규칙**(`implement.md` 준수): `test('ShouldTransitionToBusyWhenVisitStarted', () { ... })` 형태로, 각 테스트 바디는 `// arrange` / `// act` / `// assert` 3구간 주석을 명시한다.

## 3. 작업 단계

| 순서 | 작업 | 파일 |
|---|---|---|
| H-1 | `buildTestable`, `buildFakeDio` 테스트 헬퍼 | `frontend/test/test_utils/widget_test_helpers.dart` |
| H-2 | `visit_providers.dart`, `SseClient` unit 테스트(Phase 01 §4 항목) | `frontend/test/shared/api/providers/visit_providers_test.dart`, `frontend/test/shared/api/sse/sse_client_test.dart` |
| H-3 | `facilitator_router.dart` redirect 로직 테스트(Phase 02 §4 항목) | `frontend/test/facilitator/router/facilitator_router_test.dart` |
| H-4 | B0/B1/B1-b 위젯 테스트(Phase 03 §4 항목) | `frontend/test/facilitator/features/{device_pending,pin_login,track_confirm}_test.dart` |
| H-5a | `TrackEventCoordinator` unit 테스트 — scope 가드, 강제종료 3종 분기(Phase 04 §4 항목, 위젯 아님) | `frontend/test/facilitator/features/track_event_coordinator_test.dart` |
| H-5b | B2 위젯 테스트 — 2회탭, 진행률바, 코디네이터 dispose(Phase 04 §4 항목) | `frontend/test/facilitator/features/main_track_test.dart` |
| H-6 | B3/B4 테스트(Phase 05 §4 항목) | `frontend/test/facilitator/features/{qr_scan,manual_checkin}_test.dart` |
| H-7 | B5 테스트(Phase 06 §4 항목) | `frontend/test/facilitator/features/visit_summary_test.dart` |
| H-8 | B6/B7 테스트(Phase 07 §4 항목) | `frontend/test/facilitator/features/{broadcast_inbox,track_direct}_test.dart` |

각 항목은 해당 Phase 문서 §4에 이미 나열한 검증 항목을 실제 테스트 코드로 옮기는 작업이다 — 새 검증 기준을 여기서 추가하지 않는다.

## 4. 검증

- [x] `flutter test`가 `frontend/test/` 전체에서 그린 — 60개 전체 통과(2026-07-11)
- [x] `flutter analyze`가 그린(신규 facilitator 코드 기준 warning 0) — "No issues found!"
- [x] 모든 테스트가 실제 네트워크 호출 없이(fake Dio/fake API 클래스/fake MobileScannerPlatform) 통과함 — `apiClientProvider`를 override하지 않은 테스트 없음(모두 개별 API concrete class를 override)

### 2026-07-11 재개 시점 보완 사항

중단됐던 워크플로우 재개 후 누락 확인된 항목(H-3, H-6, H-8 일부)을 직접 작성해 채웠다:
- `test/facilitator/router/facilitator_router_test.dart` (H-3) — redirect 우선순위 4가지 분기 + 강제종료 시 스택 깊이 무관 즉시 전환
- `test/facilitator/features/qr_scan_test.dart` (H-6) — `MobileScannerPlatform`을 직접 fake 구현해 실제 카메라 플랫폼 채널 없이 busy 가드/에러 매핑/dispose 검증
- `test/facilitator/features/manual_checkin_test.dart` (H-6) — 검색 필터, 완료된 조 비활성화, 확인 모달 확정 흐름
- `test/facilitator/features/track_direct_test.dart` (H-8) — 빈 스레드 안내, 선전송, 빠른답장, 정렬, 전송 실패 스낵바

기존에 있었으나 `flutter analyze` 기준 문제가 있던 부분도 함께 수정: `flutter_riverpod` 3.3.2에서 `Override` 타입이 `package:flutter_riverpod/misc.dart`로만 노출되는 점(`test_utils/widget_test_helpers.dart`), `extension type` ID들이 const 생성자가 아닌 점(`visit_providers_test.dart`), 미사용 import 4건.
