import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cornermon/admin/features/admin_stub_screen.dart';
import 'package:cornermon/admin/features/login/login_screen.dart';
import 'package:cornermon/admin/features/setup_wizard/setup_wizard_screen.dart';
import 'package:cornermon/admin/session/admin_session_provider.dart';
import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/admin/widgets/admin_scaffold.dart';
import 'package:cornermon/shared/api/domain_aliases.dart';
import 'package:cornermon/shared/api/providers/camp_providers.dart';

const _campIndependentLocations = {
  '/login',
  '/setup-wizard',
  '/camps',
  '/badges',
};
const _preparingLocations = {
  '/corner-track-manage',
  '/groups',
  '/devices',
  '/settings',
};

final adminRouterProvider = Provider<GoRouter>((ref) {
  final refresh = _AdminRouterRefresh(ref);
  ref.onDispose(refresh.dispose);
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: refresh,
    redirect: (_, state) => _redirect(ref, state.matchedLocation),
    routes: [
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(
        path: '/setup-wizard',
        builder: (_, _) => const SetupWizardScreen(),
      ),
      _plainRoute('/camps', 'A0-c 캠프 목록'),
      _plainRoute('/camps/start', 'A0-e 코너학습 시작'),
      _plainRoute('/badges', 'A0-d QR 배지'),
      _screenRoute('/dashboard', 'A1 대시보드'),
      _screenRoute('/corners/:cornerId', 'A2 코너 상세'),
      _screenRoute('/corner-track-manage', 'A2B 코너·트랙 관리'),
      _screenRoute('/groups', 'A5 조 현황'),
      _screenRoute('/groups/:groupId', 'A6 조 상세'),
      _screenRoute('/devices', 'A8 기기 관리'),
      _screenRoute('/sessions', 'A9 세션 관리'),
      _screenRoute('/messages/broadcast', 'A10 공지 메시지'),
      _screenRoute('/messages/direct', 'A11 다이렉트 메시지'),
      _screenRoute('/report', 'A12 리포트'),
      _screenRoute('/audit-log', 'A13 감사 로그'),
      _screenRoute('/settings', 'A15 설정'),
    ],
  );
});

GoRoute _plainRoute(String path, String title) => GoRoute(
  path: path,
  builder: (_, _) => AdminStubScreen(title: title),
);

GoRoute _screenRoute(String path, String title) => GoRoute(
  path: path,
  builder: (_, _) => AdminScaffold(body: AdminStubScreen(title: title)),
);

String? _redirect(Ref ref, String location) {
  if (ref.read(adminSessionProvider) is AdminSessionUnauthenticated) {
    return location == '/login' ? null : '/login';
  }
  if (location == '/login') {
    return ref
        .read(campListProvider)
        .whenOrNull(
          data: (camps) => camps.isEmpty ? '/setup-wizard' : '/camps',
        );
  }
  if (_campIndependentLocations.contains(location)) return null;
  if (ref.read(selectedCampIdProvider) == null) return '/camps';

  final selectedCamp = ref.read(selectedCampProvider);
  final camp = selectedCamp.hasValue ? selectedCamp.value : null;
  if (camp?.status == null) return null;
  return switch (camp!.status!) {
    CampStatus.PENDING =>
      _preparingLocations.contains(location) ? null : '/corner-track-manage',
    CampStatus.ACTIVE =>
      _preparingLocations.contains(location) ? '/dashboard' : null,
    CampStatus.ENDED => location == '/report' ? null : '/report',
    _ => '/camps',
  };
}

class _AdminRouterRefresh extends ChangeNotifier {
  _AdminRouterRefresh(Ref ref) {
    _subscriptions = [
      ref.listen(adminSessionProvider, (_, _) => notifyListeners()),
      ref.listen(selectedCampIdProvider, (_, _) => notifyListeners()),
      ref.listen(selectedCampProvider, (_, _) => notifyListeners()),
      ref.listen(campListProvider, (_, _) => notifyListeners()),
    ];
  }

  late final List<ProviderSubscription<Object?>> _subscriptions;

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.close();
    }
    super.dispose();
  }
}
