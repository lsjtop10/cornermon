import 'package:cornermon/admin/features/settings/widgets/camp_info_section.dart';
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/camp_providers.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

CampResponse _camp() => CampResponse(
  (b) => b
    ..id = 'camp-1'
    ..name = '테스트 캠프'
    ..startAt = DateTime.utc(2026, 8, 1)
    ..endAt = DateTime.utc(2026, 8, 3)
    ..bottleneckMinSamples = 3
    ..bottleneckRatioPct = 20
    ..status = CampResponseStatusEnum.ACTIVE,
);

void main() {
  testWidgets('ShoudPrefillNameAndDatesWhenBuilt', (tester) async {
    // arrange
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: CampInfoSection(camp: _camp())),
        ),
      ),
    );

    // act — no interaction, verify initial render only

    // assert
    expect(find.text('테스트 캠프'), findsOneWidget);
    expect(find.text('2026.08.01'), findsOneWidget);
    expect(find.text('2026.08.03'), findsOneWidget);
  });

  testWidgets('ShoudShowToastWhenSaveSucceeds', (tester) async {
    // arrange
    final camp = _camp();
    final updated = camp.rebuild((b) => b..name = '바뀐 이름');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          updateCampProvider(
            CampId('camp-1'),
            name: '테스트 캠프',
            startAt: camp.startAt,
            endAt: camp.endAt,
          ).overrideWith((_) async => updated),
        ],
        child: MaterialApp(home: Scaffold(body: CampInfoSection(camp: camp))),
      ),
    );

    // act
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();

    // assert
    expect(find.text('캠프 정보가 저장되었습니다.'), findsOneWidget);
  });

  testWidgets(
    'ShoudShowInlineErrorAndKeepPreviousValueWhenSaveFails',
    (tester) async {
      // arrange
      final camp = _camp();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            updateCampProvider(
              CampId('camp-1'),
              name: '테스트 캠프',
              startAt: camp.startAt,
              endAt: camp.endAt,
            ).overrideWith((_) async => throw Exception('이름이 중복됩니다')),
          ],
          child: MaterialApp(home: Scaffold(body: CampInfoSection(camp: camp))),
        ),
      );

      // act
      await tester.tap(find.text('저장'));
      await tester.pumpAndSettle();

      // assert
      expect(find.textContaining('이름이 중복됩니다'), findsOneWidget);
      expect(find.text('테스트 캠프'), findsOneWidget);
    },
  );
}
