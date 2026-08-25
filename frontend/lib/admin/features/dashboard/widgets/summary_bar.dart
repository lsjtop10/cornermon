import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SummaryBar extends StatelessWidget {
  const SummaryBar({
    required this.summary,
    required this.unreadDirectCount,
    required this.isActive,
    super.key,
  });
  final AsyncValue<api.CampSummaryStats> summary;
  final int? unreadDirectCount;
  final bool isActive;

  @override
  Widget build(BuildContext context) => summary.when(
    loading: () => const LinearProgressIndicator(),
    error: (_, _) => const Text('요약을 불러오지 못했습니다'),
    data: (item) {
      final tiles = <({String label, String value, String? route})>[
        (
          label: '완주율',
          value: '${(item.completionRate ?? 0).round()}%',
          route: null,
        ),
        (
          label: '미완주 조',
          value:
              '${(item.totalGroups ?? 0) - (item.finishedGroupCount ?? 0)}',
          route: null,
        ),
        (
          label: '경과시간',
          value:
              '${(item.programDurationSeconds ?? 0) ~/ 3600}시간 ${((item.programDurationSeconds ?? 0) % 3600) ~/ 60}분',
          route: null,
        ),
        if (isActive)
          (
            label: '안읽은 다이렉트',
            value: '$unreadDirectCount',
            route: '/messages/direct',
          ),
      ];
      // 관리자 화면의 1차 타겟은 iPad 가로(§design-system.md 3.2)이므로 균등 분할
      // Row를 유지한다 — Expanded는 구조적으로 오버플로하지 않아 세로 모드(지원은
      // 하되 최적화 대상은 아님)에서도 안전하다. 2행으로 흘려보내는 Wrap은 오히려
      // 본문 높이를 예측 불가능하게 늘려 아래 코너 그리드/빈 상태를 밀어내므로
      // 채택하지 않는다.
      return Row(
        children: [
          for (var i = 0; i < tiles.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.space3),
            Expanded(
              child: _SummaryTile(
                label: tiles[i].label,
                value: tiles[i].value,
                route: tiles[i].route,
              ),
            ),
          ],
        ],
      );
    },
  );
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.label, required this.value, this.route});

  final String label;
  final String value;
  final String? route;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.dark
        ? AppColors.dark
        : AppColors.light;
    // 탭 가능한 타일만 시각적으로 다르게 표시한다(§design-system.md 0-6 —
    // 히트박스와 시각 신호는 항상 일치해야 한다) — 나머지 정보성 타일과 똑같은
    // Card 모양이면서 실제로는 하나만 눌리는 상황을 피한다.
    final tappable = route != null;
    return Card(
      child: InkWell(
        onTap: tappable ? () => context.go(route!) : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space4,
            vertical: AppSpacing.space3,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: AppTypography.label.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                  if (tappable)
                    Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: colors.textSecondary,
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.space1),
              Text(
                value,
                // 4분할 Row의 좁은 타일 폭에서 "경과시간" 같은 긴 값이 display(36px)로
                // 줄바꿈되면 같은 Row의 다른 타일과 카드 높이가 어긋나므로 1줄로 고정한다.
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.display.copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
