import 'dart:async';

import 'package:cornermon/admin/features/dashboard/dashboard_entries.dart';
import 'package:cornermon/admin/features/dashboard/dashboard_screen.dart';
import 'package:cornermon/admin/features/dashboard/dashboard_state.dart';
import 'package:cornermon/admin/features/dashboard/track_pin_export_controller.dart';
import 'package:cornermon/admin/features/track_direct/track_direct_providers.dart';
import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/corner_track_providers.dart';
import 'package:cornermon/shared/api/providers/report_providers.dart';
import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

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
  bool hasBusyTrack = false,
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
    )
    ..activeTracks.replace(
      hasBusyTrack
          ? [
              TrackSummaryResponse(
                (track) => track
                  ..id = '$id-track'
                  ..cornerId = id
                  ..trackNo = 1
                  ..status = TrackSummaryResponseStatusEnum.ACTIVE
                  ..operationalStatus =
                      TrackSummaryResponseOperationalStatusEnum.BUSY,
              ),
            ]
          : const <TrackSummaryResponse>[],
    ),
);

CampSummaryStatsResponse _summary() => CampSummaryStatsResponse(
  (b) => b
    ..completionRate = 70
    ..totalGroups = 10
    ..finishedGroupCount = 3
    ..programDurationSeconds = 3600,
);

Future<void> _pumpDashboard(
  WidgetTester tester, {
  required CampId campId,
  required List<CornerResponse> corners,
  List<TrackResponse>? tracks,
  CampSummaryStatsResponse? summary,
  List<String>? deletedCornerIds,
  List<String>? createdCornerNames,
  CornerResponse? createdCorner,
  Future<ExportTracksResponse> Function()? exportTracks,
  ShareFile? shareFile,
  CampResponseStatusEnum status = CampResponseStatusEnum.ACTIVE,
}) async {
  final router = GoRouter(
    initialLocation: '/dashboard',
    routes: [
      GoRoute(path: '/dashboard', builder: (_, _) => const DashboardScreen()),
      GoRoute(
        path: '/dashboard/corners/:cornerId',
        builder: (_, state) =>
            Text('corner ${state.pathParameters['cornerId']}'),
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
              ..status = status,
          ),
        ),
        cornerListProvider(campId).overrideWith((ref) async => corners),
        trackListProvider(campId).overrideWith((ref) async => tracks ?? []),
        liveSummaryProvider(
          campId,
        ).overrideWith((ref) async => summary ?? _summary()),
        trackDirectSummariesProvider(campId).overrideWith((ref) async => []),
        if (deletedCornerIds != null)
          for (final corner in corners)
            deleteCornerProvider(CornerId(corner.id!)).overrideWith((
              ref,
            ) async {
              deletedCornerIds.add(corner.id!);
            }),
        if (createdCornerNames != null)
          createCornerProvider(campId, '새 코너', 10).overrideWith((ref) async {
            createdCornerNames.add('새 코너');
            return createdCorner ?? CornerResponse((b) => b..id = 'new-corner');
          }),
        if (exportTracks != null)
          exportAllTrackPinsProvider(
            campId,
          ).overrideWith((ref) => exportTracks()),
        if (shareFile != null)
          trackPinExportShareProvider.overrideWithValue(shareFile),
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
      final sorted = sortEntries(entries, CornerSortKey.cornerNo, true);
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
        sortEntries(entries, CornerSortKey.avgDeviation, false).last.corner.id,
        'inactive',
      );
      expect(
        sortEntries(entries, CornerSortKey.avgDeviation, true).last.corner.id,
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
        sortEntries(
          entries,
          CornerSortKey.name,
          true,
        ).map((e) => e.corner.id),
        ['a', 'b'],
      );
      expect(
        sortEntries(
          entries,
          CornerSortKey.avgDeviation,
          false,
        ).map((e) => e.corner.id),
        ['b', 'a'],
      );
      expect(
        sortEntries(
          entries,
          CornerSortKey.avgDeviation,
          true,
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
      // arrange / act
      final subtitle = formatCornerCardSubtitle(
        avgDurationSeconds: 640,
        sampleCount: 10,
      );

      // assert — #241 후속: 두 정보를 " · "로 이어붙인 문자열 하나가 아니라
      // 서로 다른 라벨로 분리돼야 한다(라벨을 왜 한 줄에 다 넣냐는 지적).
      expect(subtitle.duration, '평균 10:40');
      expect(subtitle.sampleCount, '최근 10건');
    });
  });

  group('Dashboard screen', () {
    testWidgets('ShoudRenderCompletionRateWithoutDoublingPercent', (
      tester,
    ) async {
      // arrange: 백엔드 completionRate는 이미 0~100 스케일의 퍼센트 값이다
      await _pumpDashboard(
        tester,
        campId: CampId('camp-1'),
        corners: [_corner('corner-1', '코너 1', CornerResponseStatusEnum.BUSY)],
      );

      // act / assert: ×100을 다시 하지 않고 그대로 반올림해 표시해야 한다 (이슈 #201)
      expect(find.text('70%'), findsOneWidget);
    });

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
          return border is Border &&
              border.left.color == AppColors.light.statusNormal;
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
      // 컨트롤 바의 상시 버튼 + 빈 상태 CTA, 총 2개가 보여야 한다
      expect(find.text('코너 추가'), findsNWidgets(2));
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

      // '공지 발송'은 사이드바 '메시지' 항목과 중복 진입 경로라 삭제됐다
      // (라우팅 재설계 — 한 화면 = 하나의 진입 경로).
    });

    testWidgets(
      'ShoudSwitchToTrackViewWhenViewToggleTappedRegardlessOfCampStatus',
      (tester) async {
        // arrange: 카드형/트랙별 전환은 화면 이동이 아니라 같은 대시보드 안의 뷰
        // 토글이다 — PENDING/ACTIVE 모두 항상 같은 자리에 있어야 한다(예전엔 PENDING만
        // 사이드바 '코너·트랙' 항목, ACTIVE만 '트랙별 보기 →' 버튼으로 진입 경로 자체가
        // 상태마다 달랐다).
        final campId = CampId('camp-1');
        await _pumpDashboard(
          tester,
          campId: campId,
          corners: [_corner('corner-1', '코너 1', CornerResponseStatusEnum.BUSY)],
          tracks: [
            TrackResponse(
              (b) => b
                ..id = 'track-1'
                ..cornerId = 'corner-1'
                ..trackNo = 1
                ..status = TrackResponseStatusEnum.ACTIVE
                ..operationalStatus = TrackResponseOperationalStatusEnum.IDLE,
            ),
          ],
          status: CampResponseStatusEnum.PENDING,
        );
        expect(find.byType(GridView), findsOneWidget);

        // act
        await tester.tap(find.text('트랙별'));
        await tester.pumpAndSettle();

        // assert: 카드 그리드 대신 코너별로 묶인 트랙 테이블이 보인다
        expect(find.byType(GridView), findsNothing);
        expect(find.byType(DataTable), findsOneWidget);
        expect(find.text('1번'), findsOneWidget);

        // act: 다시 카드형으로 되돌릴 수 있다
        await tester.tap(find.text('카드형'));
        await tester.pumpAndSettle();

        // assert
        expect(find.byType(GridView), findsOneWidget);
      },
    );

    testWidgets('ShouldShowZombieCornerAsEmptyGroupInTrackView', (
      tester,
    ) async {
      // arrange: 트랙 없는 좀비 코너도 트랙별 뷰에서 그룹으로는 보여야 한다
      await _pumpDashboard(
        tester,
        campId: CampId('camp-1'),
        corners: [_corner('zombie', '좀비 코너', CornerResponseStatusEnum.INACTIVE)],
        tracks: const [],
      );

      // act
      await tester.tap(find.text('트랙별'));
      await tester.pumpAndSettle();

      // assert
      expect(find.text('좀비 코너'), findsOneWidget);
      expect(find.text('연결된 트랙이 없습니다'), findsOneWidget);
    });

    // #241 polish — 트랙별 뷰의 코너 그룹 내부 트랙 표(DataTable, 3열)도 코너 상세와
    // 같은 시각 언어라던 문서 주석과 달리 폰 폭 대응이 안 돼 있었다. 폰 폭에서는
    // DataTable 대신 구분선 행으로 바뀌는지 확인한다.
    testWidgets(
      'ShouldShowTrackRowsInsteadOfDataTableAtPhoneWidth',
      (tester) async {
        // arrange
        addTearDown(tester.view.reset);
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1.0;
        await _pumpDashboard(
          tester,
          campId: CampId('camp-1'),
          corners: [_corner('corner-1', '코너 1', CornerResponseStatusEnum.BUSY)],
          tracks: [
            TrackResponse(
              (b) => b
                ..id = 'track-1'
                ..cornerId = 'corner-1'
                ..trackNo = 1
                ..status = TrackResponseStatusEnum.ACTIVE
                ..operationalStatus = TrackResponseOperationalStatusEnum.IDLE,
            ),
          ],
        );

        // act
        await tester.tap(find.text('트랙별'));
        await tester.pumpAndSettle();

        // assert
        expect(find.byType(DataTable), findsNothing);
        expect(find.text('1번 트랙'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'ShoudNavigateToCornerDetailWhenTrackViewGroupHeaderTapped',
      (tester) async {
        // arrange
        await _pumpDashboard(
          tester,
          campId: CampId('camp-1'),
          corners: [_corner('corner-1', '코너 A', CornerResponseStatusEnum.IDLE)],
          tracks: [
            TrackResponse(
              (b) => b
                ..id = 'track-1'
                ..cornerId = 'corner-1'
                ..trackNo = 1
                ..status = TrackResponseStatusEnum.ACTIVE
                ..operationalStatus = TrackResponseOperationalStatusEnum.IDLE,
            ),
          ],
        );
        await tester.tap(find.text('트랙별'));
        await tester.pumpAndSettle();

        // act
        await tester.tap(find.text('코너 A'));
        await tester.pumpAndSettle();

        // assert
        expect(find.text('corner corner-1'), findsOneWidget);
      },
    );

    testWidgets('ShouldCreateCornerWhenAddCornerDialogConfirmed', (
      tester,
    ) async {
      // arrange
      final campId = CampId('camp-1');
      final createdNames = <String>[];
      await _pumpDashboard(
        tester,
        campId: campId,
        corners: const [],
        createdCornerNames: createdNames,
      );

      // act: 컨트롤 바의 '코너 추가' 버튼(빈 상태 CTA가 아닌 첫 번째)을 눌러 이름을
      // 입력하고 저장한다
      await tester.tap(find.text('코너 추가').first);
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, '코너 이름'), '새 코너');
      await tester.tap(find.text('추가'));
      await tester.pumpAndSettle();

      // assert: createCornerProvider(campId, '새 코너', 10)가 호출됨
      expect(createdNames, ['새 코너']);
    });

    testWidgets(
      'ShouldDeleteCornerWhenDeleteIconConfirmedAndPreDisableWhenBusy',
      (tester) async {
        // arrange: corner-1은 IDLE 트랙만 있어 삭제 가능, corner-2는 BUSY 트랙이 있어
        // 삭제 아이콘 자체가 사전 비활성화된다(§design-system.md 4.2 — "누르고 나서
        // 막기"가 아니라 비활성화+이유 툴팁으로 안내한다).
        final campId = CampId('camp-1');
        final deletedIds = <String>[];
        await _pumpDashboard(
          tester,
          campId: campId,
          corners: [
            _corner('corner-1', '코너 1', CornerResponseStatusEnum.IDLE),
            _corner(
              'corner-2',
              '코너 2',
              CornerResponseStatusEnum.BUSY,
              hasBusyTrack: true,
            ),
          ],
          deletedCornerIds: deletedIds,
        );

        // assert: BUSY 트랙이 있는 코너의 삭제 아이콘은 눌러도 반응하지 않는다
        final deleteButtons = find.byIcon(Icons.delete_outline);
        expect(deleteButtons, findsNWidgets(2));
        final busyButton = tester.widget<IconButton>(
          find.ancestor(
            of: deleteButtons.at(1),
            matching: find.byType(IconButton),
          ),
        );
        expect(busyButton.onPressed, isNull);
        expect(busyButton.tooltip, '진행 중인 방문이 있어 삭제할 수 없습니다');

        // act: IDLE 트랙만 있는 코너는 소프트 확인 후 삭제된다
        await tester.tap(deleteButtons.at(0));
        await tester.pumpAndSettle();
        await tester.tap(find.text('진행'));
        await tester.pumpAndSettle();

        // assert
        expect(deletedIds, ['corner-1']);
      },
    );

    testWidgets('ShouldShowExportAllPinsActionInAppBar', (tester) async {
      // arrange
      await _pumpDashboard(
        tester,
        campId: CampId('camp-1'),
        corners: [_corner('corner-1', '코너 1', CornerResponseStatusEnum.BUSY)],
      );

      // assert: 전체 PIN 내보내기 액션이 대시보드 앱바로 옮겨와 있어야 한다
      expect(find.text('전체 PIN 내보내기'), findsOneWidget);
    });

    testWidgets('ShouldShareWorkbookAndShowSuccessWhenPinExportSucceeds', (
      tester,
    ) async {
      // arrange
      var shared = false;
      await _pumpDashboard(
        tester,
        campId: CampId('camp-1'),
        corners: [_corner('corner-1', '코너 1', CornerResponseStatusEnum.BUSY)],
        exportTracks: () async =>
            ExportTracksResponse((b) => b..tracks.replace([])),
        shareFile: (ShareParams params) async {
          shared = true;
          expect(params.fileNameOverrides, ['track-pins.xlsx']);
          expect(params.sharePositionOrigin, isNotNull);
          expect(params.sharePositionOrigin!.size, isNot(Size.zero));
        },
      );

      // act
      await tester.tap(find.text('전체 PIN 내보내기'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('다른 앱으로 공유'));
      await tester.pumpAndSettle();

      // assert
      expect(shared, isTrue);
      expect(find.text('PIN 엑셀을 내보냈습니다'), findsOneWidget);
    });

    testWidgets('ShouldShowFailureWhenPinWorkbookShareFails', (tester) async {
      // arrange
      await _pumpDashboard(
        tester,
        campId: CampId('camp-1'),
        corners: [_corner('corner-1', '코너 1', CornerResponseStatusEnum.BUSY)],
        exportTracks: () async =>
            ExportTracksResponse((b) => b..tracks.replace([])),
        shareFile: (ShareParams params) async {
          throw StateError('share unavailable');
        },
      );

      // act
      await tester.tap(find.text('전체 PIN 내보내기'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('다른 앱으로 공유'));
      await tester.pumpAndSettle();

      // assert
      expect(find.textContaining('PIN 엑셀 내보내기 실패:'), findsOneWidget);
      expect(find.textContaining('share unavailable'), findsOneWidget);
    });

    testWidgets('ShouldShowFailureWhenPinExportRequestFails', (tester) async {
      // arrange
      await _pumpDashboard(
        tester,
        campId: CampId('camp-1'),
        corners: [_corner('corner-1', '코너 1', CornerResponseStatusEnum.BUSY)],
        exportTracks: () async => throw StateError('server unavailable'),
      );

      // act
      await tester.tap(find.text('전체 PIN 내보내기'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('다른 앱으로 공유'));
      await tester.pumpAndSettle();

      // assert
      expect(find.textContaining('PIN 엑셀 내보내기 실패:'), findsOneWidget);
      expect(find.textContaining('server unavailable'), findsOneWidget);
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

    // #241 — 요약 타일 4개(다이렉트 안읽음 포함 4번째까지)와 필터 탭·코너 카드가
    // 스마트폰 폭(360px, iPhone SE급 최소 폭)에서 RenderFlex 오버플로 없이 렌더링되는지.
    // 회귀 시 pumpAndSettle 단계에서 FlutterError로 테스트가 실패한다.
    testWidgets('ShoudRenderWithoutOverflowAtPhoneWidth', (tester) async {
      // arrange
      addTearDown(tester.view.reset);
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      final campId = CampId('camp-1');

      // act — bottleneck + hasBusyTrack은 진행중/목표 줄과 병목 부제 줄을 모두
      // 채워서(#241 후속 신고: 전체 폭에서도 "목···"으로 잘림) 두 캡션 줄의
      // 오버플로 여지를 실제로 건드린다.
      await _pumpDashboard(
        tester,
        campId: campId,
        corners: [
          _corner(
            'corner-1',
            '아주 긴 코너 이름 테스트용',
            CornerResponseStatusEnum.BUSY,
            bottleneck: true,
            hasBusyTrack: true,
          ),
          _corner('corner-2', '코너 2', CornerResponseStatusEnum.IDLE),
        ],
      );

      // assert
      expect(tester.takeException(), isNull);
    });
  });
}
