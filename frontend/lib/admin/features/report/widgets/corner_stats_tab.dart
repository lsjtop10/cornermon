import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/api/providers/corner_track_providers.dart';
import 'package:cornermon/shared/design_system/widgets/empty_state.dart';
import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'corner_stats_row.dart';

/// 코너마다 1행. `cornerListProvider(campId)`를 조인해 §0.2 역산에 필요한 `targetMinutes`를
/// 가져온다 — 로딩 중엔 이 컬럼만 값이 비고("-") 나머지 컬럼(완료 조 수, 편차>0 비율)은
/// `report.cornerStats`만으로 이미 렌더링 가능하므로 전체 탭을 막지 않는다.
class ReportCornerStatsTab extends ConsumerWidget {
  const ReportCornerStatsTab({required this.report, super.key});
  final api.CampReport report;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campId = ref.watch(selectedCampIdProvider);
    final cornersAsync = campId == null
        ? const AsyncValue<List<api.Corner>>.data(<api.Corner>[])
        : ref.watch(cornerListProvider(campId));
    final targetMinutesByCornerId = cornersAsync.maybeWhen(
      data: (items) => {for (final c in items) c.id: c.targetMinutes},
      orElse: () => const <String?, int?>{},
    );
    final deviationByCornerId = {
      for (final b
          in report.summary?.bottleneckRanking ??
              const <api.BottleneckRanking>[])
        b.cornerId: b.avgDeviationSeconds,
    };
    final stats = report.cornerStats ?? const <api.CornerStats>[];
    final totalGroups = report.summary?.totalGroups;

    if (stats.isEmpty) {
      return const EmptyState(
        message: '코너 데이터가 없습니다',
        icon: Icons.account_tree_outlined,
      );
    }

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
                DataColumn(label: Text('코너')),
                DataColumn(label: Text('완료 조 수')),
                DataColumn(label: Text('평균 소요시간(편차)')),
                DataColumn(label: Text('편차>0 비율')),
              ],
              rows: [
                for (final stat in stats)
                  buildCornerStatsRow(
                    stats: stat,
                    avgDeviationSeconds: deviationByCornerId[stat.cornerId],
                    targetMinutes: targetMinutesByCornerId[stat.cornerId],
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
