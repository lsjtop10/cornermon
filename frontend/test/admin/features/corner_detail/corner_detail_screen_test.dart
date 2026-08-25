import 'package:cornermon/admin/features/corner_detail/corner_detail_screen.dart';
import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/corner_track_providers.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _SelectedCampId extends SelectedCampId {
  _SelectedCampId(this._id);
  final CampId? _id;

  @override
  CampId? build() => _id;
}

CornerResponse _corner(String id) => CornerResponse(
  (b) => b
    ..id = id
    ..name = '코너 1'
    ..status = CornerResponseStatusEnum.BUSY
    ..targetMinutes = 10,
);

TrackResponse _track(String id, int trackNo, String cornerId) => TrackResponse(
  (b) => b
    ..id = id
    ..trackNo = trackNo
    ..cornerId = cornerId
    ..status = TrackResponseStatusEnum.ACTIVE
    ..operationalStatus = TrackResponseOperationalStatusEnum.IDLE,
);

Future<void> _pump(
  WidgetTester tester, {
  required CampId campId,
  required CornerId cornerId,
  required List<TrackResponse> tracks,
  List<Override> extraOverrides = const [],
}) async {
  final router = GoRouter(
    initialLocation: '/corner',
    routes: [
      GoRoute(
        path: '/corner',
        builder: (_, _) => CornerDetailScreen(cornerId: cornerId),
      ),
      GoRoute(path: '/dashboard', builder: (_, _) => const Text('dashboard')),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        selectedCampIdProvider.overrideWith(() => _SelectedCampId(campId)),
        cornerDetailProvider(
          cornerId,
        ).overrideWith((ref) async => _corner(cornerId.value)),
        trackListProvider(campId).overrideWith((ref) async => tracks),
        ...extraOverrides,
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  final campId = CampId('camp-1');
  final cornerId = CornerId('c1');

  group('CornerDetailScreen', () {
    testWidgets('ShouldShowTableAtTabletWidth', (tester) async {
      // arrange / act
      await _pump(
        tester,
        campId: campId,
        cornerId: cornerId,
        tracks: [_track('t1', 1, 'c1')],
      );

      // assert
      expect(find.byType(DataTable), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    // #241 — DataTable 뒤쪽 열(PIN/액션)이 폰 폭에서 화면 밖으로 밀려 "잘려 보인다"는
    // 신고가 있었다. 표 대신 트랙 1개당 카드로 펼치는지, 오버플로가 없는지 확인한다.
    testWidgets('ShouldShowCardsWithoutOverflowAtPhoneWidth', (tester) async {
      // arrange
      addTearDown(tester.view.reset);
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;

      // act
      await _pump(
        tester,
        campId: campId,
        cornerId: cornerId,
        tracks: [_track('t1', 1, 'c1'), _track('t2', 2, 'c1')],
      );

      // assert
      expect(find.byType(DataTable), findsNothing);
      expect(find.text('1번 트랙'), findsOneWidget);
      expect(find.text('2번 트랙'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
