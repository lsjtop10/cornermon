import 'package:cornermon/shared/export/export_action_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ShoudOfferSaveAndShareWhenExportButtonIsPressed', (
    tester,
  ) async {
    // arrange
    ExportAction? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExportActionButton(
            label: 'PDF로 내보내기',
            icon: Icons.ios_share,
            onSelected: (action) => selected = action,
          ),
        ),
      ),
    );

    // act
    await tester.tap(find.text('PDF로 내보내기'));
    await tester.pumpAndSettle();

    // assert
    expect(find.text('기기에 저장'), findsOneWidget);
    expect(find.text('다른 앱으로 공유'), findsOneWidget);

    // act
    await tester.tap(find.text('기기에 저장'));
    await tester.pumpAndSettle();

    // assert
    expect(selected, ExportAction.saveToDevice);
  });

  testWidgets('ShoudNotSelectActionWhenExportMenuIsDismissed', (tester) async {
    // arrange
    ExportAction? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExportActionButton(
            label: 'PDF로 내보내기',
            icon: Icons.ios_share,
            onSelected: (action) => selected = action,
          ),
        ),
      ),
    );

    // act
    await tester.tap(find.text('PDF로 내보내기'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(8, 8));
    await tester.pumpAndSettle();

    // assert
    expect(selected, isNull);
  });
}
