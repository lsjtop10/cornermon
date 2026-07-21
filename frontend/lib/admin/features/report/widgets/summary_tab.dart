import 'package:flutter/material.dart';

import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:cornermon/shared/util/duration_format.dart';
import 'bottleneck_top3.dart';

/// 캠프 레벨 요약 카드 그리드(완주율/평균편차/수동 처리 비율) + 코너별 병목 랭킹 Top3.
///
/// §2.5.1 확인 필요 사항 실측 결과(`backend/internal/infrastructure/web/report_handler.go`의
/// `mapSummary` 함수를 직접 확인 — 코드 읽기이며 backend 수정 아님): `completionRate`는
/// `FinishedGroups / TotalGroups * 100`으로 **이미 0~100 스케일의 퍼센트 값**이다(조 단위
/// 완주율 — analytics-model.md §1.1 "전체 완주율"과 대응). `visitCompletionRate`는 별개로
/// `CompletedVisits / TotalVisits * 100`(방문 단위)이라 이 카드가 요구하는 값이 아니다.
/// `manualVisitRatio`도 동일하게 이미 0~100 퍼센트다. **`CornerStatsResponse.overDeviationRatio`
/// (0~1 비율)와 스케일이 다르므로 혼동해서 다시 ×100 하지 않는다** — 이미 병합된
/// `dashboard_screen.dart`의 `_SummaryBar`가 `completionRate`에 ×100을 한 번 더 하고 있는데,
/// 이는 A1 범위의 기존 이슈이며 이 작업(A12)의 범위가 아니라 여기서 고치지 않는다.
/// `completionRate`가 없을 때만 `finishedGroupCount/totalGroups`를 직접 계산해 퍼센트로
/// 변환한 값으로 폴백한다(둘 다 없으면 0%).
class ReportSummaryTab extends StatelessWidget {
  const ReportSummaryTab({required this.summary, super.key});
  final api.CampSummaryStats summary;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.dark
        ? AppColors.dark
        : AppColors.light;
    final finished = summary.finishedGroupCount ?? 0;
    final total = summary.totalGroups ?? 0;
    final fallbackCompletionRatePct = total == 0 ? 0.0 : finished / total * 100;
    final completionRatePct =
        (summary.completionRate ?? fallbackCompletionRatePct).round();
    final manualRatioPct = (summary.manualVisitRatio ?? 0).round();
    final ranking = [
      ...(summary.bottleneckRanking ?? const <api.BottleneckRanking>[]),
    ]..sort(
      (a, b) => (b.avgDeviationSeconds ?? 0).compareTo(
        a.avgDeviationSeconds ?? 0,
      ),
    );

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryCard(label: '완주율', value: '$completionRatePct%'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                label: '평균편차',
                value: formatSignedMmSs(summary.avgDeviationSeconds ?? 0),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(label: '수동 처리 비율', value: '$manualRatioPct%'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          '코너별 병목 랭킹 Top3',
          style: AppTypography.title3.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: 12),
        BottleneckTop3(ranking: ranking),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.dark
        ? AppColors.dark
        : AppColors.light;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.label.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: AppTypography.display.copyWith(color: colors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
