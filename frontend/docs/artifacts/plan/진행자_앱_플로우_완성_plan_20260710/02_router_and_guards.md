# Phase 02 — 라우터 및 인증 가드

> 선행조건: Phase 01(위젯/provider 존재, 화면은 아직 스텁이어도 무방 — 이 Phase는 라우트 트리와 redirect 로직이 핵심).
> 목적: `DeviceTrust`/`TrackSession` 상태에 따라 B0~B7 사이를 강제 전환하는 `GoRouter`를 만든다. B8은 §00 §0-c 결정에 따라 별도 라우트를 두지 않는다.
> 근거: `go_router` v17(Context7 확인 — `redirect` 콜백 + `refreshListenable`로 외부 상태 변화 시 재평가하는 패턴은 0.8.0부터 guard 객체를 대체), scenarios.md Feature 3 "건너뛸 수 없다", §00 §0-c(B0 `pending` 허용 결정).

## 1. 유즈케이스

| 우선순위 | 유즈케이스 | 용도 |
|---|---|---|
| **P0** | UC-1: `DeviceTrust`가 `none`/`rejected`/`revoked`면 어떤 URL 직접 조작으로도 B1 진입 불가 | 보안 핵심 |
| **P0** | UC-2: `TrackSession`이 `pendingConfirmation`이면 뒤로가기를 포함해 B1-b를 건너뛸 방법이 없다 | 보안 핵심 |
| **P0** | UC-4: `TrackSession`이 강제종료로 전환되면 현재 스택 깊이와 무관하게 즉시 B1로 이동 | scenarios.md Feature 3 |

## 2. 객체 정의

```dart
// lib/facilitator/router/facilitator_router.dart

/// GoRouter는 redirect 콜백 안에서 ref.read로 현재 상태를 동기적으로 읽는다(ref.watch 아님 —
/// redirect는 위젯 빌드가 아니므로 매 상태변화마다 재실행되지 않는다. 재실행 트리거는 refreshListenable이 담당).
@riverpod
GoRouter facilitatorRouter(Ref ref) {
  final refresh = _FacilitatorRouterRefresh(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/device-pending',
    refreshListenable: refresh,
    redirect: (context, state) => _redirect(ref, state),
    routes: [
      GoRoute(path: '/device-pending', builder: (_, __) => const DevicePendingScreen()),
      GoRoute(
        path: '/pin-login',
        builder: (_, __) => const PinLoginScreen(),
        routes: [GoRoute(path: 'confirm', builder: (_, __) => const TrackConfirmScreen())],
      ),
      GoRoute(
        path: '/main',
        builder: (_, __) => const MainTrackScreen(),
        routes: [
          GoRoute(path: 'scan', builder: (_, __) => const QrScanScreen()),
          GoRoute(path: 'manual', builder: (_, __) => const ManualCheckinScreen()),
          GoRoute(path: 'broadcast', builder: (_, __) => const BroadcastInboxScreen()),
          GoRoute(path: 'direct', builder: (_, __) => const TrackDirectScreen()),
        ],
      ),
    ],
  );
}

/// redirect 우선순위(위에서부터 순서대로 평가, 첫 매치가 결정):
/// 1. deviceTrust ∈ {none, rejected, revoked}         → /device-pending
///    (deviceTrust ∈ {pending, approved}는 통과 — §00 §0-c, 실제 게이트는 PIN 로그인 API 자체)
/// 2. trackSession == Unauthenticated                  → /pin-login
/// 3. trackSession == PendingConfirmation               → /pin-login/confirm (뒤로가기로도 못 건너뜀)
/// 4. 그 외(Authenticated) + 현재 위치가 위 세 화면 중 하나 → /main
/// 5. 그 외                                              → null(현재 라우트 유지)
String? _redirect(Ref ref, GoRouterState state);

class _FacilitatorRouterRefresh extends ChangeNotifier {
  _FacilitatorRouterRefresh(Ref ref) {
    _subs = [
      ref.listen(deviceTrustProvider, (_, __) => notifyListeners()),
      ref.listen(trackSessionProvider, (_, __) => notifyListeners()),
    ];
  }
  late final List<ProviderSubscription<Object?>> _subs;
  void dispose() { for (final s in _subs) { s.close(); } }
}
```

**B5(방문완료요약)는 독립 라우트가 아니라 B2 위에 뜨는 오버레이**로 구현한다(screen-spec: "2~3초 후 자동으로 B2로 복귀" — 별도 화면 스택에 쌓이면 뒤로가기 시 어색해짐). `MainTrackScreen`이 자체 상태로 오버레이 표시 여부를 들고 있다(§04 참고).

**세션 강제종료 시 즉시 전환 보장**: `_redirect`가 `refreshListenable`을 통해 상태 변화 즉시 재평가되므로, `/main/scan`처럼 스택 깊이가 있어도 `trackSession`이 `Unauthenticated`(강제종료)로 바뀌는 순간 다음 redirect 평가에서 바로 `/pin-login`으로 이동한다 — 중간 화면들을 하나씩 pop할 필요 없이 go_router가 스택을 교체한다.

## 3. 작업 단계

| 순서 | 작업 | 파일 |
|---|---|---|
| B-1 | `facilitatorRouter` + `_redirect` + `_FacilitatorRouterRefresh` | `frontend/lib/facilitator/router/facilitator_router.dart` |
| B-2 | `FacilitatorApp`이 위 라우터를 사용하도록 교체 (Phase 01 A-정리와 함께) | `frontend/lib/facilitator/app.dart`, `frontend/lib/main_facilitator.dart` |

## 4. 검증

- [ ] `deviceTrust == pending`일 때 `/pin-login`으로 직접 `context.go()`해도 redirect가 되돌리지 않는다(§00 §0-c 결정 반영) — `deviceTrust == none`일 때는 되돌린다
- [ ] `trackSession == PendingConfirmation`일 때 `/main`으로 직접 이동 시도해도 `/pin-login/confirm`으로 되돌아간다(뒤로가기 시뮬레이션 포함)
- [ ] `trackSession`을 테스트 중 `Unauthenticated(forceLogout)`로 override 변경하면, `/main/scan`에 있던 라우터가 다음 pump에서 `/pin-login`으로 전환됨을 위젯 테스트로 확인
- [ ] `main_facilitator.dart` 부팅 시 `facilitatorRouterProvider`가 정상적으로 `/device-pending`부터 시작함을 위젯 테스트로 확인
