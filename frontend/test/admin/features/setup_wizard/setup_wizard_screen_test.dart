import 'package:cornermon/admin/features/setup_wizard/setup_wizard_provider.dart';
import 'package:cornermon/admin/features/setup_wizard/setup_wizard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget app(ProviderContainer container) => UncontrolledProviderScope(
    container: container,
    child: const MaterialApp(home: SetupWizardScreen()),
  );

  testWidgets('requires a camp name before advancing', (tester) async {
    await tester.pumpWidget(app(ProviderContainer()));
    final next = find.widgetWithText(OutlinedButton, '다음');
    expect(tester.widget<OutlinedButton>(next).onPressed, isNull);
  });

  testWidgets('applies the example corners and renders their preview', (
    tester,
  ) async {
    final container = ProviderContainer();
    await tester.pumpWidget(app(container));
    await tester.enterText(find.byType(TextField).first, '테스트 캠프');
    await tester.pump();
    container
        .read(setupWizardProvider.notifier)
        .setCampInfo('테스트 캠프', DateTime(2026, 8, 1), DateTime(2026, 8, 3));
    container.read(setupWizardProvider.notifier).goToStep(1);
    await tester.pumpAndSettle();
    await tester.tap(find.text('예시 10개로 빠르게 시작'));
    await tester.pumpAndSettle();

    expect(find.byType(TextFormField), findsAtLeastNWidgets(1));
  });
}
