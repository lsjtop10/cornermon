import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// 앱 전역에서 재사용하는 필 모양 탭 — Material [TabBar]의 밑줄 인디케이터 대신
/// 선택된 탭의 텍스트 색만 브랜드색으로 바꾸는 가벼운 스타일로 통일한다
/// (메시지 공지/다이렉트, 기기 관리 등에서 공통으로 쓴다).
class PillTab {
  const PillTab({required this.label, this.badgeCount});
  final String label;
  final int? badgeCount;
}

class PillTabBar extends StatelessWidget {
  const PillTabBar({
    required this.tabs,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final List<PillTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.space4,
      vertical: AppSpacing.space2,
    ),
    child: Row(
      children: [
        for (var i = 0; i < tabs.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.space2),
          _PillTabButton(
            tab: tabs[i],
            selected: i == selectedIndex,
            onTap: () => onSelected(i),
          ),
        ],
      ],
    ),
  );
}

class _PillTabButton extends StatelessWidget {
  const _PillTabButton({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final PillTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space3,
          vertical: AppSpacing.space2,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tab.label,
              style: AppTypography.bodyEmphasis.copyWith(
                color: selected ? colors.brandPrimary : colors.textSecondary,
              ),
            ),
            if (tab.badgeCount != null && tab.badgeCount! > 0) ...[
              const SizedBox(width: AppSpacing.space1),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: colors.danger,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  tab.badgeCount! > 9 ? '9+' : '${tab.badgeCount}',
                  style: AppTypography.caption.copyWith(
                    color: colors.bgSurface,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
