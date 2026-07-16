import 'package:cornermon/facilitator/widgets/double_tap_confirm_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('ShoudCompleteVisitWhenScanStartsAndEndIsConfirmedTwice', (
    tester,
  ) async {
    // arrange
    await tester.pumpWidget(const MaterialApp(home: _VisitFlowHarness()));

    // act
    await tester.tap(find.text('스캔 시작'));
    await tester.pump();
    await tester.tap(find.text('종료 확인'));
    await tester.pump();
    await tester.tap(find.text('다시 탭해 확인'));
    await tester.pump();

    // assert
    expect(find.text('방문 완료 요약'), findsOneWidget);
  });
}

class _VisitFlowHarness extends StatefulWidget {
  const _VisitFlowHarness();

  @override
  State<_VisitFlowHarness> createState() => _VisitFlowHarnessState();
}

class _VisitFlowHarnessState extends State<_VisitFlowHarness> {
  var _visitStarted = false;
  var _visitComplete = false;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: _visitComplete
          ? const Text('방문 완료 요약')
          : _visitStarted
          ? DoubleTapConfirmButton(
              label: '종료 확인',
              armedLabel: '다시 탭해 확인',
              onConfirmed: () => setState(() => _visitComplete = true),
            )
          : FilledButton(
              onPressed: () => setState(() => _visitStarted = true),
              child: const Text('스캔 시작'),
            ),
    ),
  );
}
