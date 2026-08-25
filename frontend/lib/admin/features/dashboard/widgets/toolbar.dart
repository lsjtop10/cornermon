import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';
import 'package:cornermon/shared/design_system/widgets/app_dropdown.dart';
import 'package:cornermon/shared/design_system/widgets/pill_tab_bar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cornermon/admin/features/dashboard/actions/dashboard_actions.dart';
import 'package:cornermon/admin/features/dashboard/state/dashboard_state.dart';
import 'inline_pill_tabs.dart';

const _cornerFilterLabels = {
  CornerFilterChip.all: '전체',
  CornerFilterChip.busy: '진행중',
  CornerFilterChip.idle: '유휴',
  CornerFilterChip.inactive: '미가동',
  CornerFilterChip.bottleneckOnly: '병목만',
};

const _cornerSortLabels = {
  CornerSortKey.cornerNo: '코너번호순',
  CornerSortKey.name: '이름순',
  CornerSortKey.avgDeviation: '평균편차순',
};

/// 필터·정렬·뷰 전환·추가를 한 줄에 모은다 — 조 현황 화면(group_list_screen.dart)과
/// 정확히 같은 순서(필터 → 정렬 기준 → 정렬 방향 → 추가)와 같은 위젯 형태(정렬은
/// 라벨 있는 드롭다운 + 방향 토글 아이콘, 추가는 라벨 있는 툴바 버튼)를 쓴다 —
/// 예전엔 이 화면은 드롭다운, 조 현황은 아이콘 전용 팝업으로 서로 다른 형태였다
/// (critique frontend-lib-admin 2026-08-25 후속 반영).
class Toolbar extends ConsumerWidget {
  const Toolbar({required this.campId, super.key});
  final CampId campId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ascending = ref.watch(dashboardSortAscendingProvider);
    final view = ref.watch(dashboardViewProvider);
    return Wrap(
      spacing: AppSpacing.space3,
      runSpacing: AppSpacing.space2,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // 이 툴바는 필터·정렬·뷰 전환·추가가 한 Wrap 안에서 나란히 흘러야 해서,
        // 그 줄을 혼자 차지하는 공용 PillTabBar 대신 내용만큼만 차지하는
        // InlinePillTabs를 쓴다(widgets/inline_pill_tabs.dart 참고 — 이 화면만의 레이아웃
        // 요구사항으로 다른 화면이 쓰는 공용 위젯을 바꾸지 않기 위함).
        InlinePillTabs(
          tabs: [
            for (final value in CornerFilterChip.values)
              PillTab(label: _cornerFilterLabels[value]!),
          ],
          selectedIndex: CornerFilterChip.values.indexOf(
            ref.watch(dashboardFilterProvider),
          ),
          onSelected: (index) => ref
              .read(dashboardFilterProvider.notifier)
              .select(CornerFilterChip.values[index]),
        ),
        AppDropdown<CornerSortKey>(
          value: ref.watch(dashboardSortKeyProvider),
          onChanged: (value) {
            if (value != null) {
              ref.read(dashboardSortKeyProvider.notifier).select(value);
            }
          },
          items: [
            for (final key in CornerSortKey.values)
              DropdownMenuItem(value: key, child: Text(_cornerSortLabels[key]!)),
          ],
        ),
        Tooltip(
          message: ascending ? '오름차순' : '내림차순',
          child: AppButton(
            variant: AppButtonVariant.iconOnly,
            size: AppButtonSize.compact,
            icon: ascending ? Icons.arrow_upward : Icons.arrow_downward,
            label: ascending ? '오름차순' : '내림차순',
            onPressed: () =>
                ref.read(dashboardSortAscendingProvider.notifier).toggle(),
          ),
        ),
        // 노션 스타일 뷰 전환 — 카드형/트랙별은 같은 필터·정렬 결과의 다른 렌더링일
        // 뿐이라 화면 이동이 아니라 이 토글 하나로 바뀐다. PENDING/ACTIVE 모두 항상
        // 같은 자리에 노출한다(예전엔 PENDING만 사이드바 '코너·트랙' 항목, ACTIVE만
        // 이 자리의 '트랙별 보기 →' 버튼으로 진입 방식 자체가 상태마다 달랐다).
        //
        // 구조적으로 "여러 옵션 중 하나 선택"이라는 점에서 왼쪽의 필터와 성격이
        // 같다 — 새 토글 컴포넌트를 만드는 대신 같은 InlinePillTabs를 재사용한다.
        // (칠해진 캡슐로 만든 첫 시도는 "선택=텍스트 색만 바뀜, 배경은 채우지 않는다"
        // 원칙과 충돌해 바로 옆 필터와 서로 다른 "선택됨" 문법이 됐었다.)
        InlinePillTabs(
          tabs: const [PillTab(label: '카드형'), PillTab(label: '트랙별')],
          selectedIndex: DashboardView.values.indexOf(view),
          onSelected: (index) => ref
              .read(dashboardViewProvider.notifier)
              .select(DashboardView.values[index]),
        ),
        AppButton(
          variant: AppButtonVariant.secondary,
          size: AppButtonSize.compact,
          icon: Icons.add,
          label: '코너 추가',
          onPressed: () => showAddCornerDialog(context, ref, campId),
        ),
      ],
    );
  }
}
