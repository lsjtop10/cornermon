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
import 'package:cornermon/admin/features/session_manage/session_manage_screen.dart';
import 'package:cornermon/admin/features/broadcast/broadcast_screen.dart';
import 'package:cornermon/admin/features/track_direct/track_direct_screen.dart';
import 'package:cornermon/admin/features/settings/settings_screen.dart';
import 'package:cornermon/admin/features/audit_log/audit_log_screen.dart';
import 'package:cornermon/admin/session/admin_session_provider.dart';
import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/admin/widgets/admin_scaffold.dart';
import 'package:cornermon/shared/api/domain_aliases.dart';
import 'package:cornermon/shared/api/ids.dart';

const _campIndependentLocations = {
  '/login',
  '/setup-wizard',
  '/camps',
  '/badges',
};
const _preparingLocations = {
  '/dashboard',
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
      _route('/login', (_, _) => const LoginScreen()),
      _route('/setup-wizard', (_, _) => const SetupWizardScreen()),
      _route('/camps', (_, _) => const CampListScreen()),
      _plainRoute('/camps/start', 'A0-e 코너학습 시작'),
      _route('/badges', (_, _) => const BadgePrecreateScreen()),
      _route(
        '/dashboard',
        (_, _) => const AdminScaffold(body: DashboardScreen()),
      ),
      _route(
        '/dashboard/corners/:cornerId',
        (_, state) => AdminScaffold(
          body: CornerDetailScreen(
            cornerId: CornerId(state.pathParameters['cornerId']!),
          ),
        ),
      ),
      _route(
        '/corner-track-manage',
        (_, _) => const AdminScaffold(body: TrackBulkManageScreen()),
      ),
      _route('/groups', (_, _) => const AdminScaffold(body: GroupListScreen())),
      _route(
        '/groups/:groupId',
        (_, state) => AdminScaffold(
          body: GroupDetailScreen(
            groupId: GroupId(state.pathParameters['groupId']!),
          ),
        ),
      ),
      _route(
        '/devices',
        (_, _) => const AdminScaffold(body: DeviceManageScreen()),
      ),
      _route(
        '/sessions',
        (_, _) => const AdminScaffold(body: SessionManageScreen()),
      ),
      _route(
        '/messages/broadcast',
        (_, _) => const AdminScaffold(body: BroadcastScreen()),
      ),
      _route(
        '/messages/direct',
        (_, _) => const AdminScaffold(body: TrackDirectScreen()),
      ),
      _screenRoute('/report', 'A12 리포트'),
      _route(
        '/audit-log',
        (_, _) => const AdminScaffold(body: AuditLogScreen()),
      ),
      _route(
        '/settings',
        (_, _) => const AdminScaffold(body: SettingsScreen()),
      ),
    ],
  );
});

typedef _PageBuilder = Widget Function(BuildContext, GoRouterState);

/// 메뉴 전환 시 슬라이드/페이드 전환 없이 즉시 전환한다.
GoRoute _route(String path, _PageBuilder builder) => GoRoute(
  path: path,
  pageBuilder: (context, state) =>
      NoTransitionPage(key: state.pageKey, child: builder(context, state)),
);

GoRoute _plainRoute(String path, String title) =>
    _route(path, (_, _) => AdminStubScreen(title: title));

GoRoute _screenRoute(String path, String title) =>
    _route(path, (_, _) => AdminScaffold(body: AdminStubScreen(title: title)));

String? _redirect(Ref ref, String location) {
  if (ref.read(adminSessionProvider) is AdminSessionUnauthenticated) {
    return location == '/login' ? null : '/login';
  }

  if (location == '/login') {
    return '/camps';
  }

  if (_campIndependentLocations.contains(location)) return null;
  if (ref.read(selectedCampIdProvider) == null) return '/camps';

  final selectedCamp = ref.read(selectedCampProvider);
  final camp = selectedCamp.hasValue ? selectedCamp.value : null;
  if (camp?.status == null) return null;

  return switch (camp!.status!) {
    CampStatus.PENDING =>
      _preparingLocations.contains(location) ||
              location.startsWith('/dashboard/corners/')
          ? null
          : '/dashboard',
    CampStatus.ACTIVE => null,
    CampStatus.ENDED =>
      location == '/report' || location == '/audit-log' ? null : '/report',
    _ => '/camps',
  };
}

class _AdminRouterRefresh extends ChangeNotifier {
  _AdminRouterRefresh(Ref ref) {
    _subscriptions = [
      ref.listen(adminSessionProvider, (_, _) => notifyListeners()),
      ref.listen(selectedCampIdProvider, (_, _) => notifyListeners()),
      ref.listen(selectedCampProvider, (_, _) => notifyListeners()),
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
