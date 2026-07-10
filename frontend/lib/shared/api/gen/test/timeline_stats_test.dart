import 'package:test/test.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';

// tests for TimelineStats
void main() {
  final instance = TimelineStatsBuilder();
  // TODO add properties to the builder and call build()

  group(TimelineStats, () {
    // 시계열 버킷 크기 (분)
    // int bucketMinutes (default value: 5)
    test('to test the property `bucketMinutes`', () async {
      // TODO
    });

    // BuiltList<TimelineStatsInProgressCountsInner> inProgressCounts
    test('to test the property `inProgressCounts`', () async {
      // TODO
    });

    // BuiltList<TimelineStatsInProgressCountsInner> cumulativeCompletedCounts
    test('to test the property `cumulativeCompletedCounts`', () async {
      // TODO
    });

  });
}
