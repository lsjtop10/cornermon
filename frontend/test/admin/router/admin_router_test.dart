import 'package:cornermon/admin/router/admin_router.dart';
import 'package:cornermon/admin/session/admin_session_provider.dart';
import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/admin/widgets/sidebar/admin_sidebar.dart';
import 'package:cornermon/shared/api/domain_aliases.dart' hide AdminSession;
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/badge_providers.dart';
import 'package:cornermon/shared/api/providers/camp_providers.dart';
import 'package:cornermon/shared/api/providers/corner_track_providers.dart';
import 'package:cornermon/shared/api/providers/report_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAdminSession extends AdminSession {
  _FakeAdminSession(this._initialState);

  final AdminSessionState _initialState;

  @override
  AdminSessionState build() => _initialState;
}

class _FakeSelectedCampId extends SelectedCampId {
  _FakeSelectedCampId(this._id);

  final CampId? _id;

  @override
  CampId? build() => _id;
}

Camp _camp(CampStatus status) => Camp(
  (builder) => builder
    ..id = 'camp-1'
    ..name = '테스트 캠프'
    ..status = status,
);

ProviderContainer _container({
  required AdminSessionState session,
  Camp? camp,
  CampId? campId,
  List<Camp> camps = const [],
}) => ProviderContainer(
  overrides: [
    adminSessionProvider.overrideWith(() => _FakeAdminSession(session)),
    selectedCampIdProvider.overrideWith(() => _FakeSelectedCampId(campId)),
    selectedCampProvider.overrideWith((ref) async => camp),
    campListProvider.overrideWith((ref) async => camps),
  ],
);

Future<void> _pumpApp(WidgetTester tester, ProviderContainer container) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: Consumer(
        builder: (context, ref, _) =>
            MaterialApp.router(routerConfig: ref.watch(adminRouterProvider)),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  const authenticated = AdminSessionAuthenticated(
    accessToken: 'access',
    adminId: 'admin-1',
  );

  testWidgets('ShouldRedirectUnauthenticatedDashboardRequestToLogin', (
    tester,
  ) async {
    // arrange
    final container = _container(session: const AdminSessionUnauthenticated());
    addTearDown(container.dispose);
    await _pumpApp(tester, container);

    // act
    container.read(adminRouterProvider).go('/dashboard');
    await tester.pumpAndSettle();

    // assert
    expect(find.text('코너학습 관리자'), findsOneWidget);
  });

  testWidgets('ShouldRedirectLoginToCampListRegardlessOfCampCount', (
    tester,
  ) async {
    // arrange
    final emptyContainer = _container(session: authenticated);
    final campContainer = _container(
      session: authenticated,
      camps: [_camp(CampStatus.PENDING)],
    );
    addTearDown(emptyContainer.dispose);
    addTearDown(campContainer.dispose);

    // act & assert
    await _pumpApp(tester, emptyContainer);
    expect(find.text('캠프 목록'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await _pumpApp(tester, campContainer);
    expect(find.text('캠프 목록'), findsOneWidget);
  });

  testWidgets('ShouldBlockPendingAndEndedCampRoutes', (tester) async {
    // arrange
    final pendingContainer = _container(
      session: authenticated,
      campId: CampId('camp-1'),
      camp: _camp(CampStatus.PENDING),
    );
    final endedContainer = _container(
      session: authenticated,
      campId: CampId('camp-1'),
      camp: _camp(CampStatus.ENDED),
    );
    addTearDown(pendingContainer.dispose);
    addTearDown(endedContainer.dispose);

    // act & assert
    await _pumpApp(tester, pendingContainer);
    pendingContainer.read(adminRouterProvider).go('/dashboard');
    await tester.pumpAndSettle();
    expect(find.text('코너·트랙 관리'), findsOneWidget);
    expect(find.byType(AdminSidebar), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await _pumpApp(tester, endedContainer);
    endedContainer.read(adminRouterProvider).go('/settings');
    await tester.pumpAndSettle();
    expect(find.text('A12 리포트'), findsOneWidget);
  });

  testWidgets('ShouldAllowBadgesWithoutSelectedCamp', (tester) async {
    // arrange
    final container = ProviderContainer(
      overrides: [
        adminSessionProvider.overrideWith(
          () => _FakeAdminSession(authenticated),
        ),
        selectedCampIdProvider.overrideWith(() => _FakeSelectedCampId(null)),
        selectedCampProvider.overrideWith((ref) async => null),
        campListProvider.overrideWith((ref) async => const []),
        badgeListProvider.overrideWith((ref) async => const []),
      ],
    );
    addTearDown(container.dispose);
    await _pumpApp(tester, container);

    // act
    container.read(adminRouterProvider).go('/badges');
    await tester.pumpAndSettle();

    // assert
    expect(find.text('QR 배지 관리'), findsOneWidget);
    expect(find.byType(AdminSidebar), findsNothing);
  });

  testWidgets('ShouldRenderActiveDashboardWithOperatingSidebar', (
    tester,
  ) async {
    // arrange
    final campId = CampId('camp-1');
    final container = ProviderContainer(
      overrides: [
        adminSessionProvider.overrideWith(
          () => _FakeAdminSession(authenticated),
        ),
        selectedCampIdProvider.overrideWith(() => _FakeSelectedCampId(campId)),
        campDetailProvider(
          campId,
        ).overrideWith((ref) async => _camp(CampStatus.ACTIVE)),
        campListProvider.overrideWith(
          (ref) async => [_camp(CampStatus.ACTIVE)],
        ),
        cornerListProvider(campId).overrideWith((ref) async => const []),
        liveSummaryProvider(
          campId,
        ).overrideWith((ref) async => CampSummaryStats()),
      ],
    );
    addTearDown(container.dispose);
    await _pumpApp(tester, container);

    // act
    container.read(adminRouterProvider).go('/dashboard');
    await tester.pumpAndSettle();

    // assert
    expect(find.byType(AdminSidebar), findsOneWidget);
    expect(find.text('대시보드'), findsOneWidget);
    expect(find.text('아직 생성된 코너가 없습니다'), findsOneWidget);
  });

  testWidgets('ShouldNavigateToDashboardWhenStartCampSucceeds', (tester) async {
    // arrange
    final campId = CampId('camp-1');
    var calls = 0;
    final activeCamp = _camp(CampStatus.ACTIVE);
    final container = ProviderContainer(
      overrides: [
        adminSessionProvider.overrideWith(
          () => _FakeAdminSession(authenticated),
        ),
        selectedCampIdProvider.overrideWith(() => _FakeSelectedCampId(campId)),
        campDetailProvider(
          campId,
        ).overrideWith((ref) async => _camp(CampStatus.PENDING)),
        campListProvider.overrideWith(
          (ref) async => [_camp(CampStatus.PENDING)],
        ),
        startCampProvider(campId).overrideWith((ref) async {
          calls++;
          return activeCamp;
        }),
        cornerListProvider(campId).overrideWith((ref) async => const []),
        liveSummaryProvider(
          campId,
        ).overrideWith((ref) async => CampSummaryStats()),
      ],
    );
    addTearDown(container.dispose);
    await _pumpApp(tester, container);

    // act
    container.read(adminRouterProvider).go('/corner-track-manage');
    await tester.pumpAndSettle();
    await tester.tap(find.text('코너학습 시작'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('시작 확정'));
    await tester.pumpAndSettle();

    // assert
    expect(calls, 1);
    expect(find.text('대시보드'), findsOneWidget);
    expect(find.byType(AdminSidebar), findsOneWidget);
  });

  test('ShouldUseStartCampSnapshotWithoutRefetch', () async {
    // arrange
    final campId = CampId('camp-1');
    final activeCamp = _camp(CampStatus.ACTIVE);
    final container = ProviderContainer(
      overrides: [
        campDetailProvider(
          campId,
        ).overrideWith((ref) => Future<Camp>.error(StateError('재조회하면 안 됩니다.'))),
      ],
    );
    addTearDown(container.dispose);

    // act
    container.read(selectedCampIdProvider.notifier).select(campId);
    container.read(selectedCampSnapshotProvider.notifier).replace(activeCamp);
    final selectedCamp = await container.read(selectedCampProvider.future);

    // assert
    expect(selectedCamp, activeCamp);
    expect(sidebarModeFor(selectedCamp!.status!), SidebarMode.operating);
  });
}
