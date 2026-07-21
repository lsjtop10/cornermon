import 'package:flutter/material.dart';

import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/design_system/widgets/empty_state.dart';
import 'package:cornermon/admin/entities/report_ext.dart';
import 'group_stats_row.dart';

/// 조마다 1행. §0.3의 `unvisitedCornerNamesByGroupId`를 build 시작부에서 한 번만 계산해
/// 각 행에 전달한다(행마다 다시 순회하지 않도록).
class ReportGroupStatsTab extends StatelessWidget {
  const ReportGroupStatsTab({required this.report, super.key});
  final api.CampReport report;

  @override
  Widget build(BuildContext context) {
    final groups = report.groupStats ?? const <api.GroupStats>[];
    if (groups.isEmpty) {
      return const EmptyState(
        message: '조 데이터가 없습니다',
        icon: Icons.groups_outlined,
      );
    }
    final unvisitedByGroupId = report.unvisitedCornerNamesByGroupId;
    final totalCorners = report.cornerStats?.length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        child: SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('조')),
                DataColumn(label: Text('완주 여부')),
                DataColumn(label: Text('완료 코너 수')),
                DataColumn(label: Text('총 활동시간')),
                DataColumn(label: Text('미완료 코너 목록')),
              ],
              rows: [
                for (final stat in groups)
                  buildGroupStatsRow(
                    stats: stat,
                    isFinished: stat.isFinishedIn(report),
                    unvisitedCornerNames:
                        unvisitedByGroupId[stat.groupId] ?? const [],
                    totalCorners: totalCorners,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
