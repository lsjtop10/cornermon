import 'package:cornermon/admin/features/settings/widgets/bottleneck_threshold_section.dart';
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
    ..bottleneckMinSamples = 3
    ..bottleneckRatioPct = 20
    ..status = CampResponseStatusEnum.ACTIVE,
);

void main() {
  testWidgets(
    'ShoudDisableSaveAndNotCallServerWhenMinSamplesIsZero',
    (tester) async {
      // arrange
      var calls = 0;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            updateCampProvider(
              CampId('camp-1'),
              bottleneckMinSamples: 0,
              bottleneckRatioPct: 20,
            ).overrideWith((_) async {
              calls++;
              return _camp();
            }),
          ],
          child: MaterialApp(
            home: Scaffold(body: BottleneckThresholdSection(camp: _camp())),
          ),
        ),
      );

      // act
      await tester.enterText(
        find.widgetWithText(TextField, '최소 표본 건수'),
        '0',
      );
      await tester.pump();
      await tester.tap(find.text('저장'));
      await tester.pump();

      // assert
      expect(calls, 0);
      expect(find.text('1 이상의 정수를 입력하세요'), findsOneWidget);
    },
  );

  testWidgets(
    'ShoudDisableSaveAndNotCallServerWhenRatioPctIsNegative',
    (tester) async {
      // arrange
      var calls = 0;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            updateCampProvider(
              CampId('camp-1'),
              bottleneckMinSamples: 3,
              bottleneckRatioPct: -5,
            ).overrideWith((_) async {
              calls++;
              return _camp();
            }),
          ],
          child: MaterialApp(
            home: Scaffold(body: BottleneckThresholdSection(camp: _camp())),
          ),
        ),
      );

      // act
      await tester.enterText(
        find.widgetWithText(TextField, '목표시간 대비 편차 비율(%)'),
        '-5',
      );
      await tester.pump();
      await tester.tap(find.text('저장'));
      await tester.pump();

      // assert
      expect(calls, 0);
      expect(find.text('1 이상의 정수를 입력하세요'), findsOneWidget);
    },
  );

  testWidgets(
    'ShoudShowToastWhenValidValuesSaved',
    (tester) async {
      // arrange
      final camp = _camp();
      final updated = camp.rebuild(
        (b) => b
          ..bottleneckMinSamples = 5
          ..bottleneckRatioPct = 30,
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            updateCampProvider(
              CampId('camp-1'),
              bottleneckMinSamples: 5,
              bottleneckRatioPct: 30,
            ).overrideWith((_) async => updated),
          ],
          child: MaterialApp(
            home: Scaffold(body: BottleneckThresholdSection(camp: camp)),
          ),
        ),
      );

      // act
      await tester.enterText(
        find.widgetWithText(TextField, '최소 표본 건수'),
        '5',
      );
      await tester.enterText(
        find.widgetWithText(TextField, '목표시간 대비 편차 비율(%)'),
        '30',
      );
      await tester.pump();
      await tester.tap(find.text('저장'));
      await tester.pumpAndSettle();

      // assert
      expect(find.text('병목 판정 기준이 저장되었습니다.'), findsOneWidget);
    },
  );
}
