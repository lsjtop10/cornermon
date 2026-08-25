import 'package:material_ui/material_ui.dart';

import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:cornermon/shared/design_system/widgets/empty_state.dart';
import 'track_stats_row.dart';

/// 요약 탭 하위 섹션 — 트랙마다 1행(analytics-model.md §1.3). `corner_stats_tab.dart`와
/// 동일한 `Card` + `DataTable` 레이아웃을 재사용해 요약 탭 안에서도 일관된 표 스타일을 유지한다.
class TrackStatsSection extends StatelessWidget {
  const TrackStatsSection({required this.trackStats, super.key});
  final List<api.TrackStats> trackStats;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.dark
        ? AppColors.dark
        : AppColors.light;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '트랙별 통계',
          style: AppTypography.title3.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.space3),
        if (trackStats.isEmpty)
          const EmptyState(message: '트랙 데이터가 없습니다', icon: Icons.route_outlined)
        else
          Card(
            clipBehavior: Clip.antiAlias,
            margin: EdgeInsets.zero,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 48,
                dataRowMinHeight: 48,
                dataRowMaxHeight: 48,
                columns: const [
                  DataColumn(label: Text('트랙')),
                  DataColumn(label: Text('처리 건수')),
                  DataColumn(label: Text('평균편차')),
                  DataColumn(label: Text('수동 처리 비율')),
                ],
                rows: [for (final stats in trackStats) buildTrackStatsRow(stats)],
              ),
            ),
          ),
      ],
    );
  }
}
