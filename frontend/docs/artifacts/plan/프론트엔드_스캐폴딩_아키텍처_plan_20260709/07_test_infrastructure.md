# Phase 07 — 테스트 인프라

> 선행조건: Phase 05(진행자 골격) 또는 06(관리자 골격) 중 하나 이상 완료(위젯 테스트 대상 화면이 존재해야 함).
> 목적: Riverpod override 기반 단위·위젯 테스트 스캐폴딩과, 핵심 시나리오 1건을 검증하는 통합테스트 하네스를 갖춘다.
> 근거: `workflow/plan.md` §5(검증 방법 명시 필수), `implement.md`(검증 중심 완료 원칙).

## 1. 유즈케이스
| 우선순위 | 유즈케이스 | 용도 |
|---|---|---|
| P1 | UC-7: 네트워크 없이 Riverpod override만으로 화면 위젯을 렌더링·검증 | 품질 검증용 |
| P2 | UC-8: 핵심 시나리오(시작 스캔→종료확인 2회탭)가 실기기/에뮬레이터 통합테스트로 재현 | 회귀 검증용 |

## 2. 객체 정의

```dart
// test/admin/entities/group_ext_test.dart 패턴 예시
void main() {
  test('AdminGroupX.isFinished는 전 코너 completed일 때만 true', () {
    // api.Group fixture(openapi.yaml example 값)로 검증 — 도메인 클래스 없이 DTO 위 extension을 직접 테스트
  });
}
```

```dart
// test/facilitator/features/main_track_test.dart 패턴 예시
Widget buildTestable(Widget child, {List<Override> overrides = const []}) =>
  ProviderScope(overrides: overrides, child: MaterialApp(home: child));

void main() {
  testWidgets('BUSY 상태에서 종료확인 버튼 2회 탭 시 완료 처리', (tester) async {
    // trackSessionProvider, trackEventsProvider를 override해 BUSY 스냅샷(api.TrackSnapshot) 주입
    // 1차 탭 → "다시 탭해 확인" 상태로 전환 확인
    // 2차 탭 → 완료 콜백 호출 확인(실제 API 호출은 fake repository override)
  });
}
```

```dart
// integration_test/facilitator_visit_flow_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('시작 스캔 → 종료 확인 2회 탭 → 완료 요약', (tester) async {
    // scenarios.md Feature 1 "정상적인 방문 시작과 종료" 재현
    // 대상 서버: Mock 서버(prism mock api/openapi.yaml) 또는 로컬 개발 서버
  });
}
```

## 3. 작업 단계

| 순서 | 작업 | 파일 |
|---|---|---|
| G-1 | `shared/api/providers` 단위테스트 샘플(fake Dio adapter로 `groupListProvider` 검증 — `api.Group` DTO를 그대로 반환하는지 확인) | `frontend/test/shared/api/providers/group_providers_test.dart` |
| G-2 | `admin/entities` 단위테스트 샘플(`AdminGroupX` 파생 게터 1건 이상) | `frontend/test/admin/entities/group_ext_test.dart` |
| G-3 | `facilitator/entities` 단위테스트 샘플(`FacilitatorGroupX` 파생 게터 1건 이상) | `frontend/test/facilitator/entities/group_ext_test.dart` |
| G-4 | 위젯 테스트 헬퍼(`buildTestable` 공통 함수) | `frontend/test/test_utils/widget_test_helpers.dart` |
| G-5 | 진행자 위젯 테스트 샘플(B2 메인화면 2회탭 시나리오) | `frontend/test/facilitator/features/main_track_test.dart` |
| G-6 | 관리자 위젯 테스트 샘플(A1 대시보드 카드 렌더링) | `frontend/test/admin/features/dashboard_test.dart` |
| G-7 | `integration_test` 하네스 설정(`integration_test` 패키지 의존성, 실기기 실행 스크립트) | `frontend/integration_test/facilitator_visit_flow_test.dart` |

예상 소요시간: **5~7시간** (도메인/매퍼 계층이 없어져 단위테스트 대상이 provider·entities 확장으로 축소됨).

## 4. 검증
- [ ] `flutter test`가 전체 그린(provider/entities/위젯 각 최소 1건 이상)
- [ ] `flutter test test/facilitator/features/main_track_test.dart`가 실제 네트워크 요청 없이 provider override만으로 통과
- [ ] `flutter test integration_test/facilitator_visit_flow_test.dart`가 에뮬레이터 또는 실기기 1대에서 통과
- [ ] `admin/entities`, `facilitator/entities` 단위테스트가 생성 DTO fixture(JSON, openapi.yaml example 값)만으로 실행되고 네트워크·Riverpod 의존이 없다

## 5. 이번 Plan 전체 완료 기준
`00_overview.md` §6 전체 검증 체크리스트와 이 Phase의 §4를 모두 통과하면, 상위 로드맵의 F-1~F-6가 "골격 수준"에서 완료된 것으로 간주하고, 화면별 실제 레이아웃 구현(§screen-spec-admin.md/screen-spec-facilitator.md 상세 반영)을 다루는 후속 Plan 착수로 넘어간다.
