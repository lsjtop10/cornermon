import 'package:fl_chart/fl_chart.dart';
import 'package:material_ui/material_ui.dart';

import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:cornermon/shared/design_system/widgets/empty_state.dart';

/// 요약 탭 하위 섹션 — 5분 버킷 진행중 방문 수(선) + 누적 완료 방문 수(선), 두 시리즈를
/// 하나의 `LineChart`로 그린다(analytics-model.md §1.5). X축은 버킷 인덱스를 그대로 쓰고
/// `getTitlesWidget`에서 `bucketStart`(UTC)를 로컬 "HH:mm"으로 되돌려 붙인다 — `intl` 의존성이
/// 없는 프로젝트라 수동 포맷.
class TimelineSection extends StatelessWidget {
  const TimelineSection({required this.timeline, super.key});
  final api.TimelineStats timeline;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.dark
        ? AppColors.dark
        : AppColors.light;
    final buckets = timeline.buckets?.toList() ?? const <api.TimelineBucket>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '시간대별 처리량 추이',
          style: AppTypography.title3.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: 12),
        if (buckets.isEmpty)
          const EmptyState(message: '타임라인 데이터가 없습니다', icon: Icons.show_chart)
        else
          _TimelineChart(buckets: buckets, colors: colors),
      ],
    );
  }
}

class _TimelineChart extends StatelessWidget {
  const _TimelineChart({required this.buckets, required this.colors});
  final List<api.TimelineBucket> buckets;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final inProgressSpots = <FlSpot>[
      for (var i = 0; i < buckets.length; i++)
        FlSpot(i.toDouble(), (buckets[i].inProgressCount ?? 0).toDouble()),
    ];
    final cumulativeSpots = <FlSpot>[
      for (var i = 0; i < buckets.length; i++)
        FlSpot(i.toDouble(), (buckets[i].cumulativeCompleted ?? 0).toDouble()),
    ];
    // 라벨이 겹치지 않도록 최대 6개만 보이도록 간격을 둔다.
    final labelStep = (buckets.length / 6).ceil().clamp(1, buckets.length);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Legend(colors: colors),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true, drawVerticalLine: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (value, meta) => Text(
                          value.round().toString(),
                          style: AppTypography.caption.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: labelStep.toDouble(),
                        getTitlesWidget: (value, meta) {
                          final index = value.round();
                          if (index < 0 || index >= buckets.length) {
                            return const SizedBox.shrink();
                          }
                          final start = buckets[index].bucketStart?.toLocal();
                          final label = start == null
                              ? ''
                              : '${start.hour.toString().padLeft(2, '0')}:'
                                    '${start.minute.toString().padLeft(2, '0')}';
                          return Text(
                            label,
                            style: AppTypography.caption.copyWith(
                              color: colors.textSecondary,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: inProgressSpots,
                      isCurved: false,
                      color: colors.brandPrimary,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: cumulativeSpots,
                      isCurved: false,
                      color: colors.statusAlert,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.colors});
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _LegendItem(color: colors.brandPrimary, label: '진행중 방문 수'),
        const SizedBox(width: 16),
        _LegendItem(color: colors.statusAlert, label: '누적 완료 방문 수'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.dark
        ? AppColors.dark
        : AppColors.light;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTypography.caption.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }
}
