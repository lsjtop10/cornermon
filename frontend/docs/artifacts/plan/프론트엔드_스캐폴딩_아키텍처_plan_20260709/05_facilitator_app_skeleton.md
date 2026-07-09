# Phase 05 — 진행자 앱 골격 (B0~B8)

> 선행조건: Phase 02(디자인시스템), 03(API 계층/entities), 04(인증/SSE).
> 목적: 진행자 앱(`FacilitatorApp`)의 스택 기반 라우팅과 기기신뢰/트랙세션 가드를 세우고, B0~B8 9개 화면을 빈 Scaffold로 스캐폴딩한다. 실제 레이아웃(§screen-spec-facilitator.md 상세)은 이 Phase의 범위 밖 — 화면별 후속 Plan에서 채운다.
> 실행 순서 근거: 상위 로드맵이 "화면 수가 적은 진행자 앱(9개)으로 공유 기반을 먼저 검증"하도록 정함 — 관리자 앱(Phase 06, 20개)보다 먼저 착수.

## 1. 유즈케이스
| 우선순위 | 유즈케이스 | 용도 |
|---|---|---|
| **P0** | UC-1 후속: `main_facilitator.dart`가 독립 바이너리로 기동 | 프로덕션 핵심 |
| **P0** | 미등록 기기는 B1(PIN 로그인)에 어떤 경로로도 도달 불가(하드 블록) | scenarios.md Feature 3-b |
| **P0** | PIN 로그인 성공 직후 B1-b를 건너뛰고 B2로 가는 경로가 없음 | scenarios.md Feature 3 "건너뛸 수 없다" |

## 2. 객체 정의

```dart
// lib/facilitator/app.dart
class FacilitatorApp extends ConsumerWidget {
  const FacilitatorApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref); // MaterialApp.router(theme: facilitatorTheme, routerConfig: ref.watch(facilitatorRouterProvider))
}
```

```dart
// lib/facilitator/router/facilitator_router.dart
@riverpod
GoRouter facilitatorRouter(Ref ref);
// redirect 로직(우선순위 순):
//   1. DeviceTrust != approved            → /device-pending (B0)
//   2. TrackSession == unauthenticated    → /pin-login (B1)
//   3. TrackSession == awaitingConfirm    → /pin-login/confirm (B1-b), 뒤로가기로도 못 건너뜀
//   4. 그 외                               → /main (B2) 및 그 하위 스택(B3~B8)
```

각 화면은 `ConsumerWidget` 1개로 스텁을 시작한다. 예:
```dart
// lib/facilitator/features/main_track/main_track_screen.dart
class MainTrackScreen extends ConsumerWidget {
  const MainTrackScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref); // TODO(후속 Plan): screen-spec-facilitator.md B2 레이아웃
}
```

## 3. 작업 단계

| 순서 | 작업 | 파일 |
|---|---|---|
| E-1 | `FacilitatorApp` + `facilitatorTheme` 연결 | `frontend/lib/facilitator/app.dart` |
| E-2 | `facilitatorRouter`(§2 가드 로직) | `frontend/lib/facilitator/router/facilitator_router.dart` |
| E-3 | B0 기기등록대기 스텁 | `frontend/lib/facilitator/features/device_pending/` |
| E-4 | B1 PIN로그인 + B1-b 확인모달 스텁(별도 라우트, 뒤로가기 차단) | `frontend/lib/facilitator/features/pin_login/`, `track_confirm/` |
| E-5 | B2 메인 트랙화면 스텁 | `frontend/lib/facilitator/features/main_track/` |
| E-6 | B3 QR스캔, B4 수동처리 스텁 | `frontend/lib/facilitator/features/{qr_scan,manual_checkin}/` |
| E-7 | B5 방문완료요약 스텁 | `frontend/lib/facilitator/features/visit_summary/` |
| E-8 | B6 공지함, B7 다이렉트메시지 스텁 | `frontend/lib/facilitator/features/{broadcast_inbox,track_direct}/` |
| E-9 | B8 트랙교체확인 모달 스텁 | `frontend/lib/facilitator/features/track_replaced_modal/` |
| E-10 | 공유 위젯 스텁: `pin_otp_input.dart`(§4.6 숨은 input 1개 구조), `double_tap_confirm_button.dart`(2회탭 무장 패턴), `qr_scan_frame.dart` | `frontend/lib/facilitator/widgets/*.dart` |

예상 소요시간: **8~10시간** (스텁 수준이므로 화면당 대략 30~40분, 라우팅 가드 로직이 핵심 난이도).

## 4. 검증
- [ ] `DeviceTrust`가 `approved`가 아닌 모든 상태에서 B1(PIN 로그인) 진입 시도가 라우터 redirect로 즉시 B0로 튕겨진다(URL 직접 조작 시도 포함, 딥링크 우회 불가 확인)
- [ ] PIN 로그인 성공 직후 라우터가 자동으로 B1-b로 이동하며, 뒤로가기(Android 백버튼 포함)로 B1-b를 건너뛰고 B2에 도달하는 경로가 없다
- [ ] `TrackSession`이 강제종료 상태가 되면 현재 어느 화면에 있든(B3 스캔 중이어도) 즉시 B1로 리다이렉트된다
- [ ] `flutter run -t lib/main_facilitator.dart --flavor facilitator`로 실기기 또는 에뮬레이터에서 B0→(가짜 승인)→B1→B1-b→B2 흐름이 목업 provider override로 수동 구동된다
