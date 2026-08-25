import 'package:cornermon/admin/entities/group_ext.dart';
import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/shared/api/providers/group_providers.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';
import 'package:cornermon/shared/design_system/widgets/app_dropdown.dart';
import 'package:cornermon/shared/design_system/widgets/pill_tab_bar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'widgets/group_status_card.dart';
import 'widgets/register_group_dialog.dart';

enum GroupStatusFilter { all, finished, partial }

enum GroupSortColumn { name, status, completedCount }

class GroupListScreen extends ConsumerStatefulWidget {
  const GroupListScreen({super.key});
  @override
  ConsumerState<GroupListScreen> createState() => _GroupListScreenState();
}

class _GroupListScreenState extends ConsumerState<GroupListScreen> {
  GroupStatusFilter _filter = GroupStatusFilter.all;
  GroupSortColumn _sortColumn = GroupSortColumn.name;
  bool _ascending = true;

  @override
  Widget build(BuildContext context) {
    final campId = ref.watch(selectedCampIdProvider);
    if (campId == null) return const SizedBox.shrink();
    final groups = ref.watch(groupListProvider(campId));
    return Scaffold(
      appBar: AppBar(title: const Text('조 현황')),
      body: groups.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('조를 불러오지 못했습니다.\n$error')),
        data: (items) {
          final visible =
              items
                  .where(
                    (group) => switch (_filter) {
                      GroupStatusFilter.all => true,
                      GroupStatusFilter.finished => group.isFinished == true,
                      GroupStatusFilter.partial => group.isFinished != true,
                    },
                  )
                  .toList()
                ..sort((left, right) {
                  final compare = switch (_sortColumn) {
                    GroupSortColumn.name => (left.name ?? '').compareTo(
                      right.name ?? '',
                    ),
                    GroupSortColumn.status =>
                      (left.isFinished == true ? 1 : 0).compareTo(
                        right.isFinished == true ? 1 : 0,
                      ),
                    GroupSortColumn.completedCount =>
                      left.completedCount.compareTo(right.completedCount),
                  };
                  return _ascending ? compare : -compare;
                });
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.space4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 대시보드 툴바(dashboard/widgets/toolbar.dart의 Toolbar)와 같은 순서·형태로
                // 맞춘다 — 필터 → 정렬 기준(라벨 있는 드롭다운) → 정렬 방향(아이콘
                // 토글) → 추가(라벨 있는 버튼). 예전엔 정렬이 아이콘 전용 팝업메뉴라
                // 대시보드의 드롭다운과 서로 다른 형태였다(critique frontend-lib-admin
                // 2026-08-25 후속 반영).
                Wrap(
                  spacing: AppSpacing.space3,
                  runSpacing: AppSpacing.space2,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    PillTabBar(
                      selectedIndex: GroupStatusFilter.values.indexOf(
                        _filter,
                      ),
                      tabs: [
                        for (final filter in GroupStatusFilter.values)
                          PillTab(
                            label: switch (filter) {
                              GroupStatusFilter.all => '전체',
                              GroupStatusFilter.finished => '완주',
                              GroupStatusFilter.partial => '부분완주',
                            },
                          ),
                      ],
                      onSelected: (index) => setState(
                        () => _filter = GroupStatusFilter.values[index],
                      ),
                    ),
                    Text(
                      '${visible.length}/${items.length}건',
                      style: AppTypography.caption,
                    ),
                    AppDropdown<GroupSortColumn>(
                      value: _sortColumn,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _sortColumn = value);
                        }
                      },
                      items: const [
                        DropdownMenuItem(
                          value: GroupSortColumn.name,
                          child: Text('조 이름순'),
                        ),
                        DropdownMenuItem(
                          value: GroupSortColumn.status,
                          child: Text('상태순'),
                        ),
                        DropdownMenuItem(
                          value: GroupSortColumn.completedCount,
                          child: Text('완료 코너 수순'),
                        ),
                      ],
                    ),
                    Tooltip(
                      message: _ascending ? '오름차순' : '내림차순',
                      child: AppButton(
                        variant: AppButtonVariant.iconOnly,
                        size: AppButtonSize.compact,
                        icon: _ascending
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        label: _ascending ? '오름차순' : '내림차순',
                        onPressed: () =>
                            setState(() => _ascending = !_ascending),
                      ),
                    ),
                    // 코너 대시보드의 "코너 추가"와 같은 패턴(툴바의 라벨 있는 버튼)으로
                    // 통일한다 — 이전엔 AppBar 아이콘 전용 버튼이라 같은 사이드바 안
                    // 형제 화면인데도 "새 레코드 만들기" 발견성이 서로 달랐다.
                    AppButton(
                      variant: AppButtonVariant.secondary,
                      size: AppButtonSize.compact,
                      icon: Icons.add,
                      label: '조 등록',
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (_) => RegisterGroupDialog(campId: campId),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space3),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async =>
                        ref.refresh(groupListProvider(campId).future),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final cardWidth = constraints.maxWidth < 300
                            ? constraints.maxWidth
                            : 300.0;
                        return SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Wrap(
                              spacing: AppSpacing.space4,
                              runSpacing: AppSpacing.space4,
                              children: [
                                for (final group in visible)
                                  SizedBox(
                                    width: cardWidth,
                                    height: 144,
                                    child: GroupStatusCard(
                                      group: group,
                                      onTap: () =>
                                          context.go('/groups/${group.id}'),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
