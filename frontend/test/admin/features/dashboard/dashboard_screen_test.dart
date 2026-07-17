import 'dart:async';

import 'package:cornermon/admin/features/dashboard/dashboard_screen.dart';
import 'package:cornermon/admin/features/track_direct/track_direct_providers.dart';
import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/corner_track_providers.dart';
import 'package:cornermon/shared/api/providers/report_providers.dart';
import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _SelectedCampId extends SelectedCampId {
  _SelectedCampId(this._id);
  final CampId? _id;

  @override
  CampId? build() => _id;
}

CornerResponse _corner(
  String id,
  String name,
  CornerResponseStatusEnum status, {
  bool bottleneck = false,
}) => CornerResponse(
  (b) => b
    ..id = id
    ..name = name
    ..status = status
    ..isBottleneck = bottleneck
    ..targetMinutes = 10
    ..cornerMetric.replace(
      CornerMetricResponse(
        (metric) => metric
          ..avgDurationSeconds = 640
          ..sampleCount = 10,
      ),
    ),
);

CampSummaryStatsResponse _summary() => CampSummaryStatsResponse(
  (b) => b
    ..completionRate = 0.7
    ..totalGroups = 10
    ..finishedGroupCount = 3
    ..programDurationSeconds = 3600,
);

Future<void> _pumpDashboard(
  WidgetTester tester, {
  required CampId campId,
  required List<CornerResponse> corners,
  CampSummaryStatsResponse? summary,
}) async {
  final router = GoRouter(
    initialLocation: '/dashboard',
    routes: [
      GoRoute(path: '/dashboard', builder: (_, _) => const DashboardScreen()),
      GoRoute(
        path: '/corners/:cornerId',
        builder: (_, state) =>
            Text('corner ${state.pathParameters['cornerId']}'),
      ),
      GoRoute(
        path: '/corner-track-manage',
        builder: (_, _) => const Text('manage'),
      ),
      GoRoute(
        path: '/messages/broadcast',
        builder: (_, _) => const Text('broadcast'),
      ),
      GoRoute(
        path: '/messages/direct',
        builder: (_, _) => const Text('direct'),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        selectedCampIdProvider.overrideWith(() => _SelectedCampId(campId)),
        selectedCampProvider.overrideWith(
          (ref) async => CampResponse(
            (b) => b
              ..id = campId.value
              ..name = '테스트 캠프'
              ..status = CampResponseStatusEnum.ACTIVE,
          ),
        ),
        cornerListProvider(campId).overrideWith((ref) async => corners),
        liveSummaryProvider(
          campId,
        ).overrideWith((ref) async => summary ?? _summary()),
        trackDirectSummariesProvider(campId).overrideWith((ref) async => []),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('Dashboard entries', () {
    test('ShoudSortNumericallyWhenCornerNamesContainNumbers', () {
      // arrange
      final entries = buildDashboardEntries([
        _corner('10', '코너 10', CornerResponseStatusEnum.BUSY),
        _corner('2', '코너 2', CornerResponseStatusEnum.BUSY),
        _corner('1', '코너 1', CornerResponseStatusEnum.BUSY),
      ], []);
      // act
      final sorted = sortEntries(entries, CornerSortOption.cornerNo);
      // assert
      expect(sorted.map((entry) => entry.corner.id), ['1', '2', '10']);
    });

    test('ShoudPlaceInactiveLastWhenSortingByDeviation', () {
      // arrange
      final entries = [
        CornerDashboardEntry(
          _corner('inactive', '코너 1', CornerResponseStatusEnum.INACTIVE),
          avgDeviationSeconds: 99,
        ),
        CornerDashboardEntry(
          _corner('busy', '코너 2', CornerResponseStatusEnum.BUSY),
          avgDeviationSeconds: 1,
        ),
      ];
      // act / assert
      expect(
        sortEntries(entries, CornerSortOption.avgDeviationDesc).last.corner.id,
        'inactive',
      );
      expect(
        sortEntries(entries, CornerSortOption.avgDeviationAsc).last.corner.id,
        'inactive',
      );
    });

    test('ShoudSortByNameAndDeviationWhenSortOptionChanges', () {
      // arrange
      final entries = [
        CornerDashboardEntry(
          _corner('b', '나 코너', CornerResponseStatusEnum.BUSY),
          avgDeviationSeconds: 20,
        ),
        CornerDashboardEntry(
          _corner('a', '가 코너', CornerResponseStatusEnum.BUSY),
          avgDeviationSeconds: -5,
        ),
      ];

      // act / assert
      expect(
        sortEntries(entries, CornerSortOption.name).map((e) => e.corner.id),
        ['a', 'b'],
      );
      expect(
        sortEntries(
          entries,
          CornerSortOption.avgDeviationDesc,
        ).map((e) => e.corner.id),
        ['b', 'a'],
      );
      expect(
        sortEntries(
          entries,
          CornerSortOption.avgDeviationAsc,
        ).map((e) => e.corner.id),
        ['a', 'b'],
      );
    });

    test('ShoudFilterEntriesByOperationalStatus', () {
      // arrange
      final entries = buildDashboardEntries([
        _corner('busy', '코너 1', CornerResponseStatusEnum.BUSY),
        _corner('idle', '코너 2', CornerResponseStatusEnum.IDLE),
        _corner('inactive', '코너 3', CornerResponseStatusEnum.INACTIVE),
      ], []);

      // act / assert
      expect(
        filterEntries(entries, CornerFilterChip.busy).single.corner.id,
        'busy',
      );
      expect(
        filterEntries(entries, CornerFilterChip.idle).single.corner.id,
        'idle',
      );
      expect(
        filterEntries(entries, CornerFilterChip.inactive).single.corner.id,
        'inactive',
      );
    });

    test('ShoudFilterOnlyBottlenecksWhenBottleneckFilterSelected', () {
      // arrange
      final entries = buildDashboardEntries([
        _corner('yes', '코너 1', CornerResponseStatusEnum.BUSY, bottleneck: true),
        _corner('no', '코너 2', CornerResponseStatusEnum.BUSY),
      ], []);
      // act / assert
      expect(
        filterEntries(
          entries,
          CornerFilterChip.bottleneckOnly,
        ).single.corner.id,
        'yes',
      );
    });

    test('ShoudOmitDeviationWhenNoRankingExists', () {
      // arrange / act / assert
      expect(
        formatCornerCardSubtitle(avgDurationSeconds: 640, sampleCount: 10),
        '평균 10:40 · 최근 10건',
      );
    });
  });

  group('Dashboard screen', () {
    testWidgets('ShoudRenderBottleneckBorderWhenCornerIsBottleneck', (
      tester,
    ) async {
      // arrange
      await _pumpDashboard(
        tester,
        campId: CampId('camp-1'),
        corners: [
          _corner(
            'corner-1',
            '코너 1',
            CornerResponseStatusEnum.BUSY,
            bottleneck: true,
          ),
        ],
      );

      // assert
      expect(
        find.byWidgetPredicate((widget) {
          if (widget is! Container || widget.decoration is! BoxDecoration) {
            return false;
          }
          final decoration = widget.decoration! as BoxDecoration;
          final border = decoration.border;
          return border is Border &&
              border.left.color == AppColors.light.statusAlert;
        }),
        findsOneWidget,
      );
    });

    testWidgets('ShouldRenderQuietAndInactiveCardAffordances', (tester) async {
      // arrange
      await _pumpDashboard(
        tester,
        campId: CampId('camp-1'),
        corners: [
          _corner('corner-1', '코너 1', CornerResponseStatusEnum.IDLE),
          _corner('corner-2', '코너 2', CornerResponseStatusEnum.INACTIVE),
        ],
      );

      // assert
      expect(find.text('○  유휴'), findsOneWidget);
      expect(find.text('✕  미가동'), findsOneWidget);
      expect(find.text('트랙 생성'), findsOneWidget);
      expect(
        find.byWidgetPredicate((widget) {
          if (widget is! Container || widget.decoration is! BoxDecoration) {
            return false;
          }
          final border = (widget.decoration! as BoxDecoration).border;
          return border is Border && border.left.color == AppColors.light.quiet;
        }),
        findsOneWidget,
      );
    });

    testWidgets('ShouldRenderCornerSkeletonWhenCornersAreLoading', (
      tester,
    ) async {
      // arrange
      final campId = CampId('camp-1');
      final completer = Completer<List<CornerResponse>>();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            selectedCampIdProvider.overrideWith(() => _SelectedCampId(campId)),
            selectedCampProvider.overrideWith(
              (ref) async => CampResponse(
                (b) => b
                  ..id = campId.value
                  ..name = '테스트 캠프'
                  ..status = CampResponseStatusEnum.ACTIVE,
              ),
            ),
            cornerListProvider(campId).overrideWith((ref) => completer.future),
            liveSummaryProvider(campId).overrideWith((ref) async => _summary()),
            trackDirectSummariesProvider(
              campId,
            ).overrideWith((ref) async => []),
          ],
          child: const MaterialApp(home: DashboardScreen()),
        ),
      );
      await tester.pump();

      // assert
      expect(find.byType(GridView), findsOneWidget);
      expect(find.byType(CornerStatusCard), findsNothing);
    });

    testWidgets('ShoudShowEmptyStateWhenFilterResultIsEmpty', (tester) async {
      // arrange
      await _pumpDashboard(
        tester,
        campId: CampId('camp-1'),
        corners: [_corner('corner-1', '코너 1', CornerResponseStatusEnum.BUSY)],
      );

      // act
      await tester.tap(find.text('병목만'));
      await tester.pumpAndSettle();

      // assert
      expect(find.text('조건에 맞는 코너가 없습니다'), findsOneWidget);
      expect(find.byType(GridView), findsNothing);
    });

    testWidgets('ShouldShowCornerManagementActionWhenNoCornersExist', (
      tester,
    ) async {
      // arrange
      await _pumpDashboard(tester, campId: CampId('camp-1'), corners: const []);

      // assert
      expect(find.text('아직 생성된 코너가 없습니다'), findsOneWidget);
      expect(find.text('코너·트랙 관리'), findsOneWidget);
    });

    testWidgets('ShoudNavigateWhenDashboardActionsAreTapped', (tester) async {
      // arrange
      final campId = CampId('camp-1');
      await _pumpDashboard(
        tester,
        campId: campId,
        corners: [
          _corner('corner-1', '코너 1', CornerResponseStatusEnum.BUSY),
          _corner('corner-2', '코너 2', CornerResponseStatusEnum.IDLE),
        ],
      );

      // act / assert
      await tester.tap(find.text('안읽은 다이렉트'));
      await tester.pumpAndSettle();
      expect(find.text('direct'), findsOneWidget);

      await _pumpDashboard(
        tester,
        campId: campId,
        corners: [_corner('corner-1', '코너 1', CornerResponseStatusEnum.BUSY)],
      );
      await tester.tap(find.text('트랙 일괄 관리 →'));
      await tester.pumpAndSettle();
      expect(find.text('manage'), findsOneWidget);

      await _pumpDashboard(
        tester,
        campId: campId,
        corners: [_corner('corner-1', '코너 1', CornerResponseStatusEnum.BUSY)],
      );
      await tester.tap(find.text('공지 발송'));
      await tester.pumpAndSettle();
      expect(find.text('broadcast'), findsOneWidget);
    });

    testWidgets('ShoudRefreshCornerAndSummaryProvidersWhenPulled', (
      tester,
    ) async {
      // arrange
      final campId = CampId('camp-1');
      var cornerCalls = 0;
      var summaryCalls = 0;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            selectedCampIdProvider.overrideWith(() => _SelectedCampId(campId)),
            cornerListProvider(campId).overrideWith((ref) async {
              cornerCalls++;
              return [
                _corner('corner-1', '코너 1', CornerResponseStatusEnum.BUSY),
              ];
            }),
            liveSummaryProvider(campId).overrideWith((ref) async {
              summaryCalls++;
              return _summary();
            }),
            trackDirectSummariesProvider(
              campId,
            ).overrideWith((ref) async => []),
          ],
          child: const MaterialApp(home: DashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // act
      await tester.drag(find.byType(ListView), const Offset(0, 400));
      await tester.pumpAndSettle();

      // assert
      expect(cornerCalls, greaterThanOrEqualTo(2));
      expect(summaryCalls, greaterThanOrEqualTo(2));
    });
  });
}
