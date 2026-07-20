import 'package:cornermon/admin/features/track_bulk_manage/track_bulk_manage_screen.dart';
import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/corner_track_providers.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _SelectedCampId extends SelectedCampId {
  _SelectedCampId(this._id);
  final CampId? _id;

  @override
  CampId? build() => _id;
}

CornerResponse _corner(String id, String name) =>
    CornerResponse((b) => b..id = id..name = name..targetMinutes = 10);

TrackResponse _track(
  String id,
  String cornerId,
  int trackNo, {
  TrackResponseOperationalStatusEnum status =
      TrackResponseOperationalStatusEnum.IDLE,
}) => TrackResponse(
  (b) => b
    ..id = id
    ..cornerId = cornerId
    ..trackNo = trackNo
    ..status = TrackResponseStatusEnum.ACTIVE
    ..operationalStatus = status,
);

Future<void> _pumpScreen(
  WidgetTester tester, {
  required CampId campId,
  required List<CornerResponse> corners,
  required List<TrackResponse> tracks,
  List<String>? deletedCornerIds,
}) async {
  final router = GoRouter(
    initialLocation: '/corner-track-manage',
    routes: [
      GoRoute(
        path: '/corner-track-manage',
        builder: (_, _) => const TrackBulkManageScreen(),
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
        trackListProvider(campId).overrideWith((ref) async => tracks),
        if (deletedCornerIds != null)
          for (final corner in corners)
            deleteCornerProvider(CornerId(corner.id!)).overrideWith((
              ref,
            ) async {
              deletedCornerIds.add(corner.id!);
            }),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  final campId = CampId('camp-1');

  testWidgets(
    'ShouldEnableDeleteButtonWhenNoBusyTrackInCorner',
    (tester) async {
      // arrange: c1은 IDLE 트랙만 있음, c2는 BUSY 트랙이 있음(진행 중인 방문)
      await _pumpScreen(
        tester,
        campId: campId,
        corners: [_corner('c1', '코너 A'), _corner('c2', '코너 B')],
        tracks: [
          _track('t1', 'c1', 1),
          _track(
            't2',
            'c2',
            1,
            status: TrackResponseOperationalStatusEnum.BUSY,
          ),
        ],
      );

      // act
      final deleteButtons = tester
          .widgetList<AppButton>(find.byType(AppButton))
          .where((button) => button.label == '코너 삭제')
          .toList();

      // assert: IDLE 트랙만 있는 코너(c1)는 삭제 가능, BUSY 트랙이 있는 코너(c2)는 불가
      expect(find.text('코너 A'), findsOneWidget);
      expect(find.text('코너 B'), findsOneWidget);
      expect(deleteButtons, hasLength(2));
      expect(deleteButtons.where((b) => b.onPressed == null), hasLength(1));
      expect(deleteButtons.where((b) => b.onPressed != null), hasLength(1));
    },
  );

  testWidgets(
    'ShouldCallDeleteCornerProviderWhenDeleteConfirmed',
    (tester) async {
      // arrange: 트랙 없는 좀비 코너 하나만 존재
      final deletedIds = <String>[];
      await _pumpScreen(
        tester,
        campId: campId,
        corners: [_corner('zombie', '좀비 코너')],
        tracks: [],
        deletedCornerIds: deletedIds,
      );

      // act: 삭제 버튼 탭 후 확인 다이얼로그의 '진행' 버튼 탭
      await tester.tap(find.text('코너 삭제'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('진행'));
      await tester.pumpAndSettle();

      // assert: deleteCornerProvider가 해당 코너 id로 호출됨
      expect(deletedIds, ['zombie']);
      expect(find.text('코너가 삭제되었습니다'), findsOneWidget);
    },
  );

  testWidgets(
    'ShouldAllowDeleteWhenCornerHasOnlyIdleTracks',
    (tester) async {
      // arrange: 트랙이 연결돼 있어도(IDLE) 삭제 가능해야 한다
      // (코너 삭제는 DB CASCADE로 트랙·방문 기록까지 함께 제거됨)
      final deletedIds = <String>[];
      await _pumpScreen(
        tester,
        campId: campId,
        corners: [_corner('c1', '코너 A')],
        tracks: [_track('t1', 'c1', 1)],
        deletedCornerIds: deletedIds,
      );

      // act
      await tester.tap(find.text('코너 삭제'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('진행'));
      await tester.pumpAndSettle();

      // assert
      expect(deletedIds, ['c1']);
    },
  );
}
