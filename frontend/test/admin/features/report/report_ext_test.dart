import 'package:cornermon/admin/entities/report_ext.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:flutter_test/flutter_test.dart';

UnvisitedGroupResponse _unvisited(String groupId) =>
    UnvisitedGroupResponse((b) => b..groupId = groupId);

CornerStatsResponse _cornerStats(
  String cornerId,
  String cornerName, {
  List<String> unvisitedGroupIds = const [],
}) => CornerStatsResponse(
  (b) => b
    ..cornerId = cornerId
    ..cornerName = cornerName
    ..unvisitedGroups.replace(unvisitedGroupIds.map(_unvisited)),
);

GroupStatsResponse _groupStats(String groupId, {required int completedCount}) =>
    GroupStatsResponse(
      (b) => b
        ..groupId = groupId
        ..completedCount = completedCount,
    );

CampReportResponse _report({
  required List<CornerStatsResponse> cornerStats,
}) => CampReportResponse((b) => b..cornerStats.replace(cornerStats));

void main() {
  group('AdminCampReportX.unvisitedCornerNamesByGroupId', () {
    test(
      'ShoudBuildReverseMappingWhenThreeCornersAndTwoGroupsExist',
      () {
        // arrange — 코너 3개(A, B, C), 조 2개(g1, g2). g1은 A/C를 방문 못함, g2는 B만 방문 못함.
        final report = _report(
          cornerStats: [
            _cornerStats('c-a', '코너 A', unvisitedGroupIds: ['g1']),
            _cornerStats('c-b', '코너 B', unvisitedGroupIds: ['g2']),
            _cornerStats('c-c', '코너 C', unvisitedGroupIds: ['g1']),
          ],
        );

        // act
        final map = report.unvisitedCornerNamesByGroupId;

        // assert
        expect(map['g1'], ['코너 A', '코너 C']);
        expect(map['g2'], ['코너 B']);
      },
    );

    test('ShoudReturnEmptyMapWhenNoCornerHasUnvisitedGroups', () {
      // arrange
      final report = _report(
        cornerStats: [_cornerStats('c-a', '코너 A')],
      );

      // act
      final map = report.unvisitedCornerNamesByGroupId;

      // assert
      expect(map, isEmpty);
    });
  });

  group('AdminGroupStatsX', () {
    test('ShoudBeFinishedWhenCompletedCountEqualsTotalCornerCount', () {
      // arrange
      final report = _report(
        cornerStats: [
          _cornerStats('c-a', '코너 A'),
          _cornerStats('c-b', '코너 B'),
        ],
      );
      final group = _groupStats('g1', completedCount: 2);

      // act / assert
      expect(group.isFinishedIn(report), isTrue);
    });

    test('ShoudNotBeFinishedWhenCompletedCountIsLessThanTotalCornerCount', () {
      // arrange
      final report = _report(
        cornerStats: [
          _cornerStats('c-a', '코너 A'),
          _cornerStats('c-b', '코너 B'),
        ],
      );
      final group = _groupStats('g1', completedCount: 1);

      // act / assert
      expect(group.isFinishedIn(report), isFalse);
    });

    test('ShoudReturnUnvisitedCornerNamesForGroupWhenPartiallyFinished', () {
      // arrange
      final report = _report(
        cornerStats: [
          _cornerStats('c-a', '코너 A', unvisitedGroupIds: ['g1']),
          _cornerStats('c-b', '코너 B'),
        ],
      );
      final group = _groupStats('g1', completedCount: 1);

      // act / assert
      expect(group.unvisitedCornerNamesIn(report), ['코너 A']);
    });
  });
}
