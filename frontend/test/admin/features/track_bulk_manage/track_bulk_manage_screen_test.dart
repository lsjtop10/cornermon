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

TrackResponse _track(String id, String cornerId, int trackNo) => TrackResponse(
  (b) => b
    ..id = id
    ..cornerId = cornerId
    ..trackNo = trackNo
    ..status = TrackResponseStatusEnum.ACTIVE
    ..operationalStatus = TrackResponseOperationalStatusEnum.IDLE,
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
    'ShouldEnableDeleteButtonWhenCornerHasNoTracks',
    (tester) async {
      // arrange: 코너 2개 - c1은 트랙 있음, c2는 트랙 없는 좀비 코너
      await _pumpScreen(
        tester,
        campId: campId,
        corners: [_corner('c1', '코너 A'), _corner('c2', '코너 B')],
        tracks: [_track('t1', 'c1', 1)],
      );

      // act: 각 코너 그룹의 삭제 버튼(AppButton) 탐색
      final deleteButtons = tester
          .widgetList<AppButton>(find.byType(AppButton))
          .where((button) => button.label == '코너 삭제')
          .toList();

      // assert: 트랙 있는 코너(c1)는 비활성, 트랙 0개 코너(c2)만 활성화된 삭제 버튼을 가진다
      expect(find.text('코너 A'), findsOneWidget);
      expect(find.text('코너 B'), findsOneWidget);
      expect(find.text('연결된 트랙이 없습니다'), findsOneWidget);
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
}
