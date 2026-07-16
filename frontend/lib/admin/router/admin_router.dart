import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cornermon/admin/features/admin_stub_screen.dart';
import 'package:cornermon/admin/features/login/login_screen.dart';
import 'package:cornermon/admin/features/camp_list/camp_list_screen.dart';
import 'package:cornermon/admin/features/badge_precreate/badge_precreate_screen.dart';
import 'package:cornermon/admin/features/dashboard/dashboard_screen.dart';
import 'package:cornermon/admin/features/corner_detail/corner_detail_screen.dart';
import 'package:cornermon/admin/features/track_bulk_manage/track_bulk_manage_screen.dart';
import 'package:cornermon/admin/features/group_list/group_list_screen.dart';
import 'package:cornermon/admin/features/group_detail/group_detail_screen.dart';
import 'package:cornermon/admin/features/setup_wizard/setup_wizard_screen.dart';
import 'package:cornermon/admin/features/device_manage/device_manage_screen.dart';
import 'package:cornermon/admin/session/admin_session_provider.dart';
import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/admin/widgets/admin_scaffold.dart';
import 'package:cornermon/shared/api/domain_aliases.dart';
import 'package:cornermon/shared/api/ids.dart';
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
      GoRoute(path: '/camps', builder: (_, _) => const CampListScreen()),
      _plainRoute('/camps/start', 'A0-e 코너학습 시작'),
      GoRoute(path: '/badges', builder: (_, _) => const BadgePrecreateScreen()),
      GoRoute(
        path: '/dashboard',
        builder: (_, _) => const AdminScaffold(body: DashboardScreen()),
      ),
      GoRoute(
        path: '/dashboard/corners/:cornerId',
        builder: (_, state) => AdminScaffold(
          body: CornerDetailScreen(
            cornerId: CornerId(state.pathParameters['cornerId']!),
          ),
        ),
      ),
      GoRoute(
        path: '/corner-track-manage',
        builder: (_, _) => const AdminScaffold(body: TrackBulkManageScreen()),
      ),
      GoRoute(
        path: '/groups',
        builder: (_, _) => const AdminScaffold(body: GroupListScreen()),
      ),
      GoRoute(
        path: '/groups/:groupId',
        builder: (_, state) => AdminScaffold(
          body: GroupDetailScreen(
            groupId: GroupId(state.pathParameters['groupId']!),
          ),
        ),
      ),
      GoRoute(
        path: '/devices',
        builder: (_, _) => const AdminScaffold(body: DeviceManageScreen()),
      ),
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
    CampStatus.ACTIVE => null,
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
