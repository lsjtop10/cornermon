import 'package:test/test.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';

// tests for CampSummaryStats
void main() {
  final instance = CampSummaryStatsBuilder();
  // TODO add properties to the builder and call build()

  group(CampSummaryStats, () {
    // int totalGroups
    test('to test the property `totalGroups`', () async {
      // TODO
    });

    // int finishedGroupCount
    test('to test the property `finishedGroupCount`', () async {
      // TODO
    });

    // 완주율 (0.0 ~ 1.0)
    // double completionRate
    test('to test the property `completionRate`', () async {
      // TODO
    });

    // int totalVisits
    test('to test the property `totalVisits`', () async {
      // TODO
    });

    // 방문 완료율 (완료 방문 수 / 이론상 최대 200)
    // double visitCompletionRate
    test('to test the property `visitCompletionRate`', () async {
      // TODO
    });

    // int programDurationSeconds
    test('to test the property `programDurationSeconds`', () async {
      // TODO
    });

    // double avgDeviationSeconds
    test('to test the property `avgDeviationSeconds`', () async {
      // TODO
    });

    // double manualVisitRatio
    test('to test the property `manualVisitRatio`', () async {
      // TODO
    });

    // int ruleOverrideCount
    test('to test the property `ruleOverrideCount`', () async {
      // TODO
    });

    // int trackOperationCount
    test('to test the property `trackOperationCount`', () async {
      // TODO
    });

    // int exceptionApprovalCount
    test('to test the property `exceptionApprovalCount`', () async {
      // TODO
    });

    // 코너를 평균편차 기준 내림차순 정렬한 병목 랭킹
    // BuiltList<CampSummaryStatsBottleneckRankingInner> bottleneckRanking
    test('to test the property `bottleneckRanking`', () async {
      // TODO
    });

  });
}
