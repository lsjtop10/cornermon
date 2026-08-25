import 'package:material_ui/material_ui.dart';

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

class PillTabBar extends StatefulWidget {
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
  State<PillTabBar> createState() => _PillTabBarState();
}

class _PillTabBarState extends State<PillTabBar> {
  // Scrollbar가 PrimaryScrollController에 자동으로 붙는 건 최상위 세로 스크롤
  // 전용이다 — 이 가로 스크롤은 화면 안에 중첩된 채로 쓰여서 자동 연결이 안 되고
  // "ScrollController has no ScrollPosition attached"로 즉시 죽는다(위젯 테스트로
  // 확인, #241). Scrollbar와 SingleChildScrollView가 같은 컨트롤러를 명시적으로
  // 공유하게 한다.
  final _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Align(
    // SingleChildScrollView는 내용 폭만큼만 차지해서(Row였던 이전과 달리
    // 더는 자체적으로 폭을 채우지 않는다), crossAxisAlignment.center인
    // 부모 Column 아래에서는 가운데로 밀려 보이는 회귀가 났다 — 항상
    // 왼쪽에 붙도록 명시한다.
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space4,
        vertical: AppSpacing.space2,
      ),
      // 탭 라벨 합이 화면 폭을 넘으면(스마트폰 폭 + 긴 라벨) Row가 그대로
      // RenderFlex 오버플로를 냈다 — 가로 스크롤로 감싸 넘칠 때만 스크롤되게
      // 한다(#241). 다 들어갈 땐 기존과 동일하게 내용 폭만큼만 차지한다.
      // Scrollbar는 스크롤할 내용이 없으면(다 들어가는 폭) 스스로 아무것도 그리지
      // 않으므로, 넘칠 때만 "더 있다"는 티가 나는 걸 조건 분기 없이 얻는다.
      child: Scrollbar(
        controller: _controller,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _controller,
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (var i = 0; i < widget.tabs.length; i++) ...[
                if (i > 0) const SizedBox(width: AppSpacing.space2),
                _PillTabButton(
                  tab: widget.tabs[i],
                  selected: i == widget.selectedIndex,
                  onTap: () => widget.onSelected(i),
                ),
              ],
            ],
          ),
        ),
      ),
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
