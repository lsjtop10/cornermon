import 'package:cornermon/admin/features/setup_wizard/setup_wizard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget app() =>
      const ProviderScope(child: MaterialApp(home: SetupWizardScreen()));

  testWidgets('requires a camp name before advancing', (tester) async {
    await tester.pumpWidget(app());
    final next = find.widgetWithText(OutlinedButton, '다음');
    expect(tester.widget<OutlinedButton>(next).onPressed, isNull);
  });

  testWidgets('applies the example corners and renders their preview', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.enterText(find.byType(TextField).first, '테스트 캠프');
    await tester.pump();
    await tester.tap(find.widgetWithText(OutlinedButton, '다음'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('예시 10개로 빠르게 시작'));
    await tester.pump();

    expect(find.text('1코너'), findsAtLeastNWidgets(1));
    expect(find.text('10코너'), findsAtLeastNWidgets(1));
  });
}
