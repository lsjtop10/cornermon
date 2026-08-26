import 'package:cornermon/admin/features/badge_precreate/badge_precreate_screen.dart';
import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/badge_providers.dart';
import 'package:cornermon/shared/api/providers/group_providers.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _SelectedCampId extends SelectedCampId {
  _SelectedCampId(this._id);
  final CampId? _id;

  @override
  CampId? build() => _id;
}

BadgeResponse _badge(
  String id,
  BadgeResponseStatusEnum status, {
  String? assignedGroupId,
}) => BadgeResponse(
  (b) => b
    ..id = id
    ..shortId = 'B-$id'
    ..qrPayload = 'payload-$id'
    ..status = status
    ..assignedGroupId = assignedGroupId,
);

void main() {
  testWidgets('ShoudDisableGenerateButtonWhenQuantityIsInvalid', (
    tester,
  ) async {
    // arrange
    await tester.pumpWidget(
      ProviderScope(
        overrides: [badgeListProvider.overrideWith((ref) async => const [])],
        child: const MaterialApp(home: BadgePrecreateScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // act / assert
    for (final value in ['', '0', '-1', 'abc']) {
      await tester.enterText(find.byType(TextField), value);
      await tester.pump();
      final button = tester.widget<AppButton>(
        find.widgetWithText(AppButton, '배지 생성'),
      );
      expect(button.onPressed, isNull);
    }
  });

  testWidgets('ShoudRefreshBadgeListWhenGenerateSucceeds', (tester) async {
    // arrange
    var generated = false;
    var listCalls = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          badgeListProvider.overrideWith((ref) async {
            listCalls++;
            return generated
                ? [_badge('0001', BadgeResponseStatusEnum.UNASSIGNED)]
                : const <BadgeResponse>[];
          }),
          bulkGenerateBadgesProvider(40).overrideWith((ref) async {
            generated = true;
            return [_badge('0001', BadgeResponseStatusEnum.UNASSIGNED)];
          }),
        ],
        child: const MaterialApp(home: BadgePrecreateScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // act
    await tester.tap(find.text('배지 생성'));
    await tester.pumpAndSettle();

    // assert
    expect(listCalls, greaterThanOrEqualTo(2));
    expect(find.text('미배정 1장 · 배정됨 0장'), findsOneWidget);
    expect(find.text('B-0001'), findsOneWidget);
  });

  testWidgets('ShoudSwitchToImageResolutionOptionsWhenImageFormatIsSelected', (
    tester,
  ) async {
    // arrange
    await tester.pumpWidget(
      ProviderScope(
        overrides: [badgeListProvider.overrideWith((ref) async => const [])],
        child: const MaterialApp(home: BadgePrecreateScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // act
    await tester.tap(find.text('스티커 내보내기'));
    await tester.pumpAndSettle();
    expect(find.text('A4'), findsOneWidget);
    expect(find.text('해상도 보통(512px)'), findsNothing);

    await tester.tap(find.text('PDF 시트'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('개별 이미지').last);
    await tester.pumpAndSettle();

    // assert
    expect(find.text('A4'), findsNothing);
    expect(find.text('해상도 보통(512px)'), findsOneWidget);
  });

  testWidgets(
    'ShoudShowCustomPaperAndQrSizeFieldsWithoutLayoutErrorWhenCustomIsSelected',
    (tester) async {
      // arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [badgeListProvider.overrideWith((ref) async => const [])],
          child: const MaterialApp(home: BadgePrecreateScreen()),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('스티커 내보내기'));
      await tester.pumpAndSettle();

      // act
      await tester.tap(find.text('A4'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('커스텀(mm)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('QR 보통(35mm)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('QR 커스텀(mm)').last);
      await tester.pumpAndSettle();

      // assert — 다이얼로그 고정폭이 없으면 Column stretch가 폭을 못 구해 레이아웃 오류가 난다.
      expect(tester.takeException(), isNull);
      expect(find.widgetWithText(TextField, '가로mm'), findsOneWidget);
      expect(find.widgetWithText(TextField, '세로mm'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'QR mm'), findsOneWidget);
    },
  );

  testWidgets('ShoudRenderAssignedBadgeWithGroupNameWhenGroupExists', (
    tester,
  ) async {
    // arrange
    final campId = CampId('camp-1');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          selectedCampIdProvider.overrideWith(() => _SelectedCampId(campId)),
          badgeListProvider.overrideWith(
            (ref) async => [
              _badge(
                '0001',
                BadgeResponseStatusEnum.ASSIGNED,
                assignedGroupId: 'group-1',
              ),
            ],
          ),
          groupListProvider(campId).overrideWith(
            (ref) async => [
              GroupResponse(
                (b) => b
                  ..id = 'group-1'
                  ..name = '1조',
              ),
            ],
          ),
        ],
        child: const MaterialApp(home: BadgePrecreateScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // assert
    expect(find.text('배정됨'), findsOneWidget);
    expect(find.text('1조'), findsOneWidget);
  });
}
