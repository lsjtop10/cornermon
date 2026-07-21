import 'package:flutter/material.dart';

import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:cornermon/shared/design_system/widgets/empty_state.dart';
import 'package:cornermon/shared/util/duration_format.dart';

/// 병목 랭킹 상위 3개만 표시한다. 서버가 이미 정렬해 주는지 확인되지 않아(§2.5.1) 호출부
/// (`summary_tab.dart`)가 `avgDeviationSeconds` 내림차순으로 방어적으로 재정렬한 뒤 넘겨준다
/// — 이 위젯은 정렬을 신뢰하고 `take(3)`만 한다.
class BottleneckTop3 extends StatelessWidget {
  const BottleneckTop3({required this.ranking, super.key});
  final List<api.BottleneckRanking> ranking;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.dark
        ? AppColors.dark
        : AppColors.light;
    final top3 = ranking.take(3).toList();
    if (top3.isEmpty) {
      return const EmptyState(message: '병목 코너가 없습니다', icon: Icons.check_circle_outline);
    }
    return Column(
      children: [
        for (var i = 0; i < top3.length; i++)
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: colors.brandPrimary.withValues(alpha: .12),
                foregroundColor: colors.brandPrimary,
                child: Text('${i + 1}', style: AppTypography.bodyEmphasis),
              ),
              title: Text(top3[i].cornerName ?? '코너'),
              trailing: Text(
                formatSignedMmSs(top3[i].avgDeviationSeconds ?? 0),
                style: AppTypography.bodyEmphasis.copyWith(
                  color: colors.statusAlert,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
