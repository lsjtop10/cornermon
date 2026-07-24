import 'package:cornermon/admin/features/camp_list/camp_list_screen.dart';
import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/camp_providers.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

CampResponse _camp(String id, String name, CampResponseStatusEnum status) =>
    CampResponse(
      (b) => b
        ..id = id
        ..name = name
        ..status = status,
    );

void main() {
  testWidgets('ShoudRenderOnlyNonEmptySectionsWhenCampsAreGrouped', (
    tester,
  ) async {
    // arrange
    final active = [_camp('active-1', '진행 캠프', CampResponseStatusEnum.ACTIVE)];
    final pending = [
      _camp('pending-1', '준비 캠프', CampResponseStatusEnum.PENDING),
    ];

    // act
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              CampSection(status: api.CampStatus.ACTIVE, camps: active),
              CampSection(status: api.CampStatus.PENDING, camps: pending),
              const CampSection(status: api.CampStatus.ENDED, camps: []),
            ],
          ),
        ),
      ),
    );

    // assert
    expect(find.text('진행 중'), findsNWidgets(2));
    expect(find.text('준비 중'), findsNWidgets(2));
    expect(find.text('종료됨'), findsNothing);
    expect(find.text('진행 캠프'), findsOneWidget);
    expect(find.text('준비 캠프'), findsOneWidget);
  });

  testWidgets('ShoudSelectCampAndNavigateWhenCampCardTapped', (tester) async {
    // arrange
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => Scaffold(
            body: Column(
              children: [
                CampCard(camp: _camp('active', '진행 캠프', api.CampStatus.ACTIVE)),
                CampCard(
                  camp: _camp('pending', '준비 캠프', api.CampStatus.PENDING),
                ),
                CampCard(camp: _camp('ended', '종료 캠프', api.CampStatus.ENDED)),
              ],
            ),
          ),
        ),
        GoRoute(path: '/dashboard', builder: (_, _) => const Text('dashboard')),
        GoRoute(
          path: '/corner-track-manage',
          builder: (_, _) => const Text('manage'),
        ),
        GoRoute(path: '/report', builder: (_, _) => const Text('report')),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    // act / assert
    await tester.tap(find.text('진행 캠프'));
    await tester.pumpAndSettle();
    expect(container.read(selectedCampIdProvider), CampId('active'));
    expect(find.text('dashboard'), findsOneWidget);

    router.go('/');
    await tester.pumpAndSettle();
    await tester.tap(find.text('준비 캠프'));
    await tester.pumpAndSettle();
    expect(container.read(selectedCampIdProvider), CampId('pending'));
    expect(find.text('manage'), findsOneWidget);

    router.go('/');
    await tester.pumpAndSettle();
    await tester.tap(find.text('종료 캠프'));
    await tester.pumpAndSettle();
    expect(container.read(selectedCampIdProvider), CampId('ended'));
    expect(find.text('report'), findsOneWidget);
  });

  testWidgets('ShoudNavigateToBadgesAndSetupWizardWhenHeaderActionsTapped', (
    tester,
  ) async {
    // arrange
    final router = GoRouter(
      initialLocation: '/camps',
      routes: [
        GoRoute(path: '/camps', builder: (_, _) => const CampListScreen()),
        GoRoute(path: '/badges', builder: (_, _) => const Text('badges')),
        GoRoute(path: '/setup-wizard', builder: (_, _) => const Text('setup')),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [campListProvider.overrideWith((ref) async => const [])],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    // act / assert
    await tester.tap(find.text('QR 배지 관리'));
    await tester.pumpAndSettle();
    expect(find.text('badges'), findsOneWidget);

    router.go('/camps');
    await tester.pumpAndSettle();
    await tester.tap(find.text('새 캠프 시작').first);
    await tester.pumpAndSettle();
    expect(find.text('setup'), findsOneWidget);
  });

  testWidgets(
    'ShoudPushAdminManagementAndReturnViaBackButtonWhenEntryTapped',
    (tester) async {
      // arrange: '/admins'는 push로 진입해야 뒤로가기 버튼이 특정 경로를
      // 하드코딩하지 않고도 캠프 목록으로 정확히 돌아갈 수 있다.
      final router = GoRouter(
        initialLocation: '/camps',
        routes: [
          GoRoute(path: '/camps', builder: (_, _) => const CampListScreen()),
          GoRoute(
            path: '/admins',
            builder: (_, _) =>
                Scaffold(appBar: AppBar(title: const Text('admins'))),
          ),
        ],
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [campListProvider.overrideWith((ref) async => const [])],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      // act
      await tester.tap(find.text('관리자 계정 관리'));
      await tester.pumpAndSettle();
      expect(find.text('admins'), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // assert
      expect(find.text('캠프 목록'), findsOneWidget);
    },
  );

  testWidgets('ShoudRetryWhenCampListProviderFails', (tester) async {
    // arrange
    var calls = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          campListProvider.overrideWith((ref) async {
            calls++;
            throw StateError('failed');
          }),
        ],
        child: const MaterialApp(home: CampListScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // act
    await tester.tap(find.text('재시도'));
    await tester.pump();

    // assert
    expect(calls, 2);
  });
}
