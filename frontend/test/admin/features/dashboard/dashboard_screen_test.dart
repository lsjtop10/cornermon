import 'package:cornermon/admin/features/dashboard/dashboard_screen.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:flutter_test/flutter_test.dart';

CornerResponse _corner(
  String id,
  String name,
  CornerResponseStatusEnum status, {
  bool bottleneck = false,
}) => CornerResponse(
  (b) => b
    ..id = id
    ..name = name
    ..status = status
    ..isBottleneck = bottleneck,
);

void main() {
  group('Dashboard entries', () {
    test('ShoudSortNumericallyWhenCornerNamesContainNumbers', () {
      // arrange
      final entries = buildDashboardEntries([
        _corner('10', '코너 10', CornerResponseStatusEnum.BUSY),
        _corner('2', '코너 2', CornerResponseStatusEnum.BUSY),
        _corner('1', '코너 1', CornerResponseStatusEnum.BUSY),
      ], []);
      // act
      final sorted = sortEntries(entries, CornerSortOption.cornerNo);
      // assert
      expect(sorted.map((entry) => entry.corner.id), ['1', '2', '10']);
    });

    test('ShoudPlaceInactiveLastWhenSortingByDeviation', () {
      // arrange
      final entries = [
        CornerDashboardEntry(
          _corner('inactive', '코너 1', CornerResponseStatusEnum.INACTIVE),
          avgDeviationSeconds: 99,
        ),
        CornerDashboardEntry(
          _corner('busy', '코너 2', CornerResponseStatusEnum.BUSY),
          avgDeviationSeconds: 1,
        ),
      ];
      // act / assert
      expect(
        sortEntries(entries, CornerSortOption.avgDeviationDesc).last.corner.id,
        'inactive',
      );
      expect(
        sortEntries(entries, CornerSortOption.avgDeviationAsc).last.corner.id,
        'inactive',
      );
    });

    test('ShoudFilterOnlyBottlenecksWhenBottleneckFilterSelected', () {
      // arrange
      final entries = buildDashboardEntries([
        _corner('yes', '코너 1', CornerResponseStatusEnum.BUSY, bottleneck: true),
        _corner('no', '코너 2', CornerResponseStatusEnum.BUSY),
      ], []);
      // act / assert
      expect(
        filterEntries(
          entries,
          CornerFilterChip.bottleneckOnly,
        ).single.corner.id,
        'yes',
      );
    });

    test('ShoudOmitDeviationWhenNoRankingExists', () {
      // arrange / act / assert
      expect(
        formatCornerCardSubtitle(avgDurationSeconds: 640, sampleCount: 10),
        '평균 10:40 · 최근 10건',
      );
    });
  });
}
