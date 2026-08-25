import 'package:cornermon/admin/features/group_detail/group_detail_screen.dart';
import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/group_providers.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _SelectedCampId extends SelectedCampId {
  _SelectedCampId(this._id);
  final CampId? _id;

  @override
  CampId? build() => _id;
}

CornerProgressResponse _progress(String cornerId, String cornerName) =>
    CornerProgressResponse(
      (b) => b
        ..cornerId = cornerId
        ..cornerName = cornerName
        ..status = CornerProgressResponseStatusEnum.NOT_VISITED,
    );

Future<void> _pump(WidgetTester tester, {required GroupId groupId}) async {
  final router = GoRouter(
    initialLocation: '/group',
    routes: [
      GoRoute(
        path: '/group',
        builder: (_, _) => GroupDetailScreen(groupId: groupId),
      ),
      GoRoute(path: '/groups', builder: (_, _) => const Text('groups')),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        selectedCampIdProvider.overrideWith(() => _SelectedCampId(null)),
        groupDetailProvider(groupId).overrideWith(
          (ref) async => GroupResponse(
            (b) => b
              ..id = groupId.value
              ..name = '3'
              ..isFinished = false
              ..itinerary.replace([
                for (var i = 1; i <= 10; i++) _progress('c$i', '$i코너'),
              ]),
          ),
        ),
        groupVisitsProvider(groupId).overrideWith((ref) async => []),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  // #241 — 코너 방문 현황 그리드가 childAspectRatio로 셀 높이를 폭에 비례시켜서,
  // 2열(폰 폭)에서 카드 높이가 코너 이름+상태 태그를 못 담아 "BOTTOM OVERFLOWED"가
  // 났다. 실제 신고 폭(2열이 되는 좁은 폭)에서 오버플로가 없는지 확인한다.
  testWidgets(
    'ShouldRenderItineraryGridWithoutOverflowAtPhoneWidth',
    (tester) async {
      // arrange
      addTearDown(tester.view.reset);
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;

      // act
      await _pump(tester, groupId: GroupId('g1'));

      // assert
      expect(find.text('1코너'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
