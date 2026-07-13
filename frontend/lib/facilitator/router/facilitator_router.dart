import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:cornermon/facilitator/features/broadcast_inbox/broadcast_inbox_screen.dart';
import 'package:cornermon/facilitator/features/device_pending/device_pending_screen.dart';
import 'package:cornermon/facilitator/features/main_track/main_track_screen.dart';
import 'package:cornermon/facilitator/features/manual_checkin/manual_checkin_screen.dart';
import 'package:cornermon/facilitator/features/pin_login/pin_login_screen.dart';
import 'package:cornermon/facilitator/features/qr_scan/qr_scan_screen.dart';
import 'package:cornermon/facilitator/features/track_confirm/track_confirm_screen.dart';
import 'package:cornermon/facilitator/features/track_direct/track_direct_screen.dart';
import 'package:cornermon/facilitator/session/device_trust_provider.dart';
import 'package:cornermon/facilitator/session/track_session_provider.dart';

part 'facilitator_router.g.dart';

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
      GoRoute(
        path: '/device-pending',
        builder: (_, _) => const DevicePendingScreen(),
      ),
      GoRoute(
        path: '/pin-login',
        builder: (_, _) => const PinLoginScreen(),
        routes: [
          GoRoute(
            path: 'confirm',
            builder: (_, _) => const TrackConfirmScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/main',
        builder: (_, _) => const MainTrackScreen(),
        routes: [
          GoRoute(path: 'scan', builder: (_, _) => const QrScanScreen()),
          GoRoute(
            path: 'manual',
            builder: (_, _) => const ManualCheckinScreen(),
          ),
          GoRoute(
            path: 'broadcast',
            builder: (_, _) => const BroadcastInboxScreen(),
          ),
          GoRoute(path: 'direct', builder: (_, _) => const TrackDirectScreen()),
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
String? _redirect(Ref ref, GoRouterState state) {
  final location = state.matchedLocation;

  final deviceTrustStatus =
      ref.read(deviceTrustProvider).value ?? DeviceTrustStatus.none;
  if (deviceTrustStatus == DeviceTrustStatus.none ||
      deviceTrustStatus == DeviceTrustStatus.rejected ||
      deviceTrustStatus == DeviceTrustStatus.revoked) {
    return location == '/device-pending' ? null : '/device-pending';
  }

  final trackSession = ref.read(trackSessionProvider);
  if (trackSession is TrackSessionUnauthenticated) {
    return location == '/pin-login' ? null : '/pin-login';
  }
  if (trackSession is TrackSessionPendingConfirmation) {
    return location == '/pin-login/confirm' ? null : '/pin-login/confirm';
  }

  // trackSession is TrackSessionAuthenticated
  if (location == '/device-pending' ||
      location == '/pin-login' ||
      location == '/pin-login/confirm') {
    return '/main';
  }
  return null;
}

class _FacilitatorRouterRefresh extends ChangeNotifier {
  _FacilitatorRouterRefresh(Ref ref) {
    _subs = [
      ref.listen(deviceTrustProvider, (_, _) => notifyListeners()),
      ref.listen(trackSessionProvider, (_, _) => notifyListeners()),
    ];
  }

  late final List<ProviderSubscription<Object?>> _subs;

  @override
  void dispose() {
    for (final s in _subs) {
      s.close();
    }
    super.dispose();
  }
}
