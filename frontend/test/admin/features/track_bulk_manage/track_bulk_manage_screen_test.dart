import 'package:cornermon/admin/features/track_bulk_manage/track_bulk_manage_screen.dart';
import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/corner_track_providers.dart';
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
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  final campId = CampId('camp-1');

  testWidgets(
    'ShouldRenderTracksGroupedByCornerWithoutAnyActionButtons',
    (tester) async {
      // arrange
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

      // assert: 코너·트랙 정보는 보이되, 이 화면엔 어떤 관리 액션도 없어야 한다
      // (코너 생성/삭제는 대시보드로, 트랙 추가/PIN/교체/삭제는 코너 상세로 이동됨)
      expect(find.text('코너 A'), findsOneWidget);
      expect(find.text('코너 B'), findsOneWidget);
      expect(find.text('1번 트랙'), findsNWidgets(2));
      expect(find.text('코너 삭제'), findsNothing);
      expect(find.text('코너 추가'), findsNothing);
      expect(find.text('트랙 추가'), findsNothing);
      expect(find.byIcon(Icons.delete_outline), findsNothing);
      expect(find.byIcon(Icons.key_outlined), findsNothing);
      expect(find.byIcon(Icons.swap_horiz), findsNothing);
    },
  );

  testWidgets(
    'ShouldShowZombieCornerWithNoTracksAsEmptyGroup',
    (tester) async {
      // arrange: 트랙 없는 좀비 코너도 그룹으로는 보여야 한다
      await _pumpScreen(
        tester,
        campId: campId,
        corners: [_corner('zombie', '좀비 코너')],
        tracks: [],
      );

      // assert
      expect(find.text('좀비 코너'), findsOneWidget);
      expect(find.text('연결된 트랙이 없습니다'), findsOneWidget);
    },
  );
}
