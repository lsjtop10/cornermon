import 'package:material_ui/material_ui.dart';

import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/widgets/empty_state.dart';
import 'corner_stats_row.dart';

/// 코너마다 1행. 평균 소요시간과 평균 편차는 `report.cornerStats`의 정식 필드로 렌더링한다.
class ReportCornerStatsTab extends StatelessWidget {
  const ReportCornerStatsTab({required this.report, super.key});
  final api.CampReport report;

  @override
  Widget build(BuildContext context) {
    final stats = report.cornerStats ?? const <api.CornerStats>[];
    final totalGroups = report.summary?.totalGroups;

    if (stats.isEmpty) {
      return const EmptyState(
        message: '코너 데이터가 없습니다',
        icon: Icons.account_tree_outlined,
      );
    }

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.space4),
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        child: SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              // §design-system.md 4.5 관리자 테이블 행 높이(48pt) — 기본 DataTable
              // 행 높이(52pt)보다 조밀하게 맞춘다.
              headingRowHeight: 48,
              dataRowMinHeight: 48,
              dataRowMaxHeight: 48,
              columns: const [
                DataColumn(label: Text('코너')),
                DataColumn(label: Text('완료 조 수')),
                DataColumn(label: Text('평균 소요시간(편차)')),
                DataColumn(label: Text('편차>0 비율')),
              ],
              rows: [
                for (final stat in stats)
                  buildCornerStatsRow(
                    stats: stat,
                    totalGroups: totalGroups,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
