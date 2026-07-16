import 'package:cornermon/admin/features/device_manage/_device_registration_row.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

DeviceRegistrationResponse _reg() => DeviceRegistrationResponse(
  (b) => b
    ..id = '1'
    ..deviceName = '아이패드'
    ..status = DeviceRegistrationResponseStatusEnum.PENDING
    ..createdAt = DateTime(2026, 1, 1),
);

void main() {
  testWidgets(
    'ShouldApplyHighlightStyleWhenIsNewArrivalIsTrue',
    (tester) async {
      // arrange / act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: DeviceRegistrationRow(
                registration: _reg(),
                isNewArrival: true,
              ),
            ),
          ),
        ),
      );

      // assert
      final container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      expect(container.decoration, isNotNull);
    },
  );

  testWidgets(
    'ShouldNotApplyHighlightStyleWhenIsNewArrivalIsFalse',
    (tester) async {
      // arrange / act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: DeviceRegistrationRow(registration: _reg()),
            ),
          ),
        ),
      );

      // assert
      final container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      expect(container.decoration, isNull);
    },
  );
}
