import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cornermon/facilitator/features/visit_summary/visit_summary_overlay.dart';
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/group_providers.dart';
import 'package:cornermon/shared/design_system/tokens/colors.dart';

import '../../test_utils/widget_test_helpers.dart';

Group _buildGroup({String id = 'group-1', String name = 'A조'}) {
  return Group(
    (b) => b
      ..id = id
      ..name = name
      ..status = GroupStatus.AT_CORNER
      ..isFinished = false,
  );
}

VisitSummary _buildVisit({
  String groupId = 'group-1',
  int? durationSeconds = 600,
  int? deviationSeconds = 0,
}) {
  return VisitSummary(
    (b) => b
      ..id = 'visit-1'
      ..groupId = groupId
      ..cornerId = 'corner-1'
      ..trackId = 'track-1'
      ..status = VisitStatus.COMPLETED
      ..startedAt = DateTime.utc(2026, 7, 11, 10, 0, 0)
      ..durationSeconds = durationSeconds
      ..deviationSeconds = deviationSeconds,
  );
}

/// 위젯이 남긴 3초 자동닫힘 타이머를 소진해 "pending timer" 테스트 실패를 막는다.
Future<void> _drainAutoDismissTimer(WidgetTester tester) =>
    tester.pump(const Duration(seconds: 3));

void main() {
  testWidgets('ShouldFormatDurationAsMinutesSeconds', (tester) async {
    // arrange
    final visit = _buildVisit(durationSeconds: 600, deviationSeconds: 0);
    final group = _buildGroup();

    // act
    await tester.pumpWidget(
      buildTestable(
        VisitSummaryOverlay(visit: visit, onDismiss: () {}),
        overrides: [groupDetailProvider(GroupId(visit.groupId)).overrideWith((ref) => group)],
      ),
    );
    await tester.pump(); // groupDetailProvider(FutureOr) 1틱 대기

    // assert
    expect(find.text('10:00'), findsOneWidget);

    await _drainAutoDismissTimer(tester);
  });

  testWidgets('ShouldShowAlertColorWhenDeviationPositive', (tester) async {
    // arrange
    final visit = _buildVisit(deviationSeconds: 45);
    final group = _buildGroup();

    // act
    await tester.pumpWidget(
      buildTestable(
        VisitSummaryOverlay(visit: visit, onDismiss: () {}),
        overrides: [groupDetailProvider(GroupId(visit.groupId)).overrideWith((ref) => group)],
      ),
    );
    await tester.pump();

    // assert
    final deviationText = tester.widget<Text>(find.text('+00:45'));
    expect(deviationText.style?.color, AppColors.light.statusAlert);

    await _drainAutoDismissTimer(tester);
  });

  testWidgets('ShouldShowIdleColorWhenDeviationZeroOrNegative', (tester) async {
    // arrange
    final zeroVisit = _buildVisit(deviationSeconds: 0);
    final group = _buildGroup();

    // act: 편차 0
    await tester.pumpWidget(
      buildTestable(
        VisitSummaryOverlay(visit: zeroVisit, onDismiss: () {}),
        overrides: [
          groupDetailProvider(GroupId(zeroVisit.groupId)).overrideWith((ref) => group),
        ],
      ),
    );
    await tester.pump();

    // assert: 편차 0 -> statusIdle
    final zeroDeviationText = tester.widget<Text>(find.text('+00:00'));
    expect(zeroDeviationText.style?.color, AppColors.light.statusIdle);
    await _drainAutoDismissTimer(tester);

    // act: 편차 음수
    final negativeVisit = _buildVisit(deviationSeconds: -30);
    await tester.pumpWidget(
      buildTestable(
        VisitSummaryOverlay(visit: negativeVisit, onDismiss: () {}),
        overrides: [
          groupDetailProvider(GroupId(negativeVisit.groupId)).overrideWith((ref) => group),
        ],
      ),
    );
    await tester.pump();

    // assert: 편차 음수 -> statusIdle
    final negativeDeviationText = tester.widget<Text>(find.text('-00:30'));
    expect(negativeDeviationText.style?.color, AppColors.light.statusIdle);
    await _drainAutoDismissTimer(tester);
  });

  testWidgets('ShouldAutoDismissAfterThreeSeconds', (tester) async {
    // arrange
    final visit = _buildVisit();
    final group = _buildGroup();
    var dismissCount = 0;

    // act
    await tester.pumpWidget(
      buildTestable(
        VisitSummaryOverlay(visit: visit, onDismiss: () => dismissCount++),
        overrides: [groupDetailProvider(GroupId(visit.groupId)).overrideWith((ref) => group)],
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));

    // assert
    expect(dismissCount, 1);
  });

  testWidgets(
    'ShouldNotDoubleCallOnDismissWhenManuallyDismissedBeforeTimerFires',
    (tester) async {
      // arrange
      final visit = _buildVisit();
      final group = _buildGroup();
      var dismissCount = 0;

      // act
      await tester.pumpWidget(
        buildTestable(
          VisitSummaryOverlay(visit: visit, onDismiss: () => dismissCount++),
          overrides: [groupDetailProvider(GroupId(visit.groupId)).overrideWith((ref) => group)],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1)); // 자동 타이머가 아직 안 끝난 시점
      await tester.tap(find.byIcon(Icons.close)); // 수동 닫기
      await tester.pump();
      await tester.pump(const Duration(seconds: 3)); // 원래 3초 시점을 지나도록 진행

      // assert
      expect(dismissCount, 1);
    },
  );
}
