import 'package:material_ui/material_ui.dart';

import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:cornermon/shared/design_system/widgets/pill_tab_bar.dart';

/// `PillTabBar`(shared/design_system/widgets/pill_tab_bar.dart)와 같은 필 모양
/// 탭 스타일이지만, 그 화면 전체 폭을 혼자 차지하지 않고 내용만큼만 차지한다
/// (`Row`가 `mainAxisSize.min`) — 대시보드 툴바처럼 필터·정렬·뷰 전환·추가 버튼이
/// 한 `Wrap` 안에서 나란히 흘러야 하는 자리 전용이다.
///
/// `PillTabBar` 자체를 고치지 않는 이유: 그 위젯은 조 현황·메시지 등 다른 화면에서
/// "그 줄을 혼자 쓰는 필터 바"로 이미 쓰이고 있다 — 이 화면 하나의 레이아웃
/// 요구사항 때문에 공용 위젯의 기본 동작을 바꾸면 그 화면들의 검증되지 않은
/// 변경이 된다. 필요한 화면이 늘어나면 그때 `shared/design_system/widgets`로
/// 승격을 고려한다.
class InlinePillTabs extends StatelessWidget {
  const InlinePillTabs({
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
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < tabs.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.space2),
          _InlinePillTabButton(
            tab: tabs[i],
            selected: i == selectedIndex,
            onTap: () => onSelected(i),
          ),
        ],
      ],
    ),
  );
}

class _InlinePillTabButton extends StatelessWidget {
  const _InlinePillTabButton({
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
