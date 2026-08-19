import 'package:cornermon/admin/features/report/widgets/timeline_section.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

TimelineBucketResponse _bucket(int minutesFromEpoch, {required int inProgress, required int cumulative}) =>
    TimelineBucketResponse(
      (b) => b
        ..bucketStart = DateTime.utc(2026, 8, 19).add(Duration(minutes: minutesFromEpoch))
        ..inProgressCount = inProgress
        ..cumulativeCompleted = cumulative,
    );

void main() {
  testWidgets(
    'ShoudShowEmptyStateWhenBucketsIsEmpty',
    (tester) async {
      // arrange
      final widget = TimelineSection(timeline: TimelineStatsResponse((b) => b));

      // act
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

      // assert
      expect(find.text('타임라인 데이터가 없습니다'), findsOneWidget);
      expect(find.byType(LineChart), findsNothing);
    },
  );

  testWidgets(
    'ShoudRenderLineChartWithoutCrashingWhenBucketsExist',
    (tester) async {
      // arrange
      final widget = TimelineSection(
        timeline: TimelineStatsResponse(
          (b) => b.buckets.replace([
            _bucket(0, inProgress: 2, cumulative: 0),
            _bucket(5, inProgress: 4, cumulative: 2),
            _bucket(10, inProgress: 3, cumulative: 5),
          ]),
        ),
      );

      // act
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

      // assert
      expect(find.byType(LineChart), findsOneWidget);
      expect(find.text('진행중 방문 수'), findsOneWidget);
      expect(find.text('누적 완료 방문 수'), findsOneWidget);
    },
  );
}
