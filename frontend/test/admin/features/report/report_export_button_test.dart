import 'dart:async';

import 'package:cornermon/admin/features/report/report_export_button.dart';
import 'package:cornermon/admin/features/report/report_export_controller.dart';
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/report_providers.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ShoudDisableButtonAndShowSpinnerWhileExportIsInProgress', (
    tester,
  ) async {
    // arrange — exportReport가 completer로 대기하는 동안 상태를 관찰한다.
    final completer = Completer<CampReportResponse>();
    final report = CampReportResponse((b) => b..campId = 'camp-1');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          exportReportProvider(
            CampId('camp-1'),
          ).overrideWith((ref) => completer.future),
          reportPdfShareProvider.overrideWithValue(
            ({required bytes, required filename}) async => true,
          ),
        ],
        child: MaterialApp(
          home: Scaffold(body: ReportExportButton(report: report)),
        ),
      ),
    );

    // act — 버튼 탭.
    await tester.tap(find.byType(AppButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다른 앱으로 공유'));
    await tester.pump();

    // assert — 대기 중엔 버튼이 비활성화되고 스피너가 겹쳐 보인다.
    expect(tester.widget<AppButton>(find.byType(AppButton)).onPressed, isNull);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // cleanup
    completer.complete(report);
    await tester.pumpAndSettle();
  });
}
