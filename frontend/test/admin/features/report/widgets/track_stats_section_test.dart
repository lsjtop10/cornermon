import 'package:cornermon/admin/features/report/widgets/track_stats_section.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

TrackStatsResponse _track(int trackNo) => TrackStatsResponse(
  (b) => b
    ..trackId = 't-$trackNo'
    ..trackNo = trackNo
    ..handledVisitCount = 12
    ..avgDeviationSeconds = 90
    ..manualVisitRatio = 25,
);

void main() {
  testWidgets(
    'ShoudShowEmptyStateWhenTrackStatsIsEmpty',
    (tester) async {
      // arrange
      const widget = TrackStatsSection(trackStats: []);

      // act
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: widget)));

      // assert
      expect(find.text('트랙 데이터가 없습니다'), findsOneWidget);
      expect(find.byType(DataTable), findsNothing);
    },
  );

  testWidgets(
    'ShoudRenderOneRowPerTrackWithFormattedDeviationAndRatioWhenTrackStatsExist',
    (tester) async {
      // arrange
      final widget = TrackStatsSection(trackStats: [_track(1), _track(2)]);

      // act
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

      // assert
      expect(find.text('1번 트랙'), findsOneWidget);
      expect(find.text('2번 트랙'), findsOneWidget);
      expect(find.text('+1:30'), findsNWidgets(2));
      expect(find.text('25%'), findsNWidgets(2));
    },
  );
}
