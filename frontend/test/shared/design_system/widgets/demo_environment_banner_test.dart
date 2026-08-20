import 'package:cornermon/shared/design_system/widgets/demo_environment_banner.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('ShouldRenderNothingWhenNotVisible', (tester) async {
    // arrange
    await tester.pumpWidget(
      _app(DemoEnvironmentBanner(visible: false, onExitDemo: () {})),
    );

    // act
    // (고정값이라 별도 상호작용 없음)

    // assert
    expect(find.text('데모 환경 — 탭하여 운영으로 전환'), findsNothing);
  });

  testWidgets('ShouldCallOnExitDemoWhenTappedWhileVisible', (tester) async {
    // arrange
    var exited = false;
    await tester.pumpWidget(
      _app(
        DemoEnvironmentBanner(visible: true, onExitDemo: () => exited = true),
      ),
    );

    // act
    expect(find.text('데모 환경 — 탭하여 운영으로 전환'), findsOneWidget);
    await tester.tap(find.byType(DemoEnvironmentBanner));
    await tester.pump();

    // assert
    expect(exited, isTrue);
  });
}
