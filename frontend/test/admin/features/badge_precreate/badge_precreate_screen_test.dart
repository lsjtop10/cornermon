import 'package:cornermon/admin/features/badge_precreate/badge_precreate_screen.dart';
import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/badge_providers.dart';
import 'package:cornermon/shared/api/providers/group_providers.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:flutter/material.dart';
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
