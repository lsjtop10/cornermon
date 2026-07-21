import 'package:cornermon/admin/entities/group_ext.dart';
import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/group_providers.dart';
import 'package:cornermon/shared/api/providers/badge_providers.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';
import 'package:cornermon/shared/design_system/widgets/app_tag.dart';
import 'package:cornermon/shared/design_system/widgets/pill_tab_bar.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

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

  void _sortBy(GroupSortColumn column) => setState(() {
    _ascending = _sortColumn == column ? !_ascending : true;
    _sortColumn = column;
  });

  @override
  Widget build(BuildContext context) {
    final campId = ref.watch(selectedCampIdProvider);
    if (campId == null) return const SizedBox.shrink();
    final groups = ref.watch(groupListProvider(campId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('조 현황'),
        actions: [
          IconButton(
            tooltip: '조 등록',
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => _RegisterGroupDialog(campId: campId),
            ),
            icon: const Icon(Icons.person_add),
          ),
        ],
      ),
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: PillTabBar(
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
                    ),
                    Text(
                      '${visible.length}/${items.length}건',
                      style: AppTypography.caption,
                    ),
                    PopupMenuButton<GroupSortColumn>(
                      tooltip: '정렬',
                      icon: Icon(
                        _ascending
                            ? Icons.arrow_upward_outlined
                            : Icons.arrow_downward_outlined,
                      ),
                      onSelected: _sortBy,
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: GroupSortColumn.name,
                          child: Text('조 이름순'),
                        ),
                        PopupMenuItem(
                          value: GroupSortColumn.status,
                          child: Text('상태순'),
                        ),
                        PopupMenuItem(
                          value: GroupSortColumn.completedCount,
                          child: Text('완료 코너 수순'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
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
                                    child: _GroupStatusCard(
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

class _GroupStatusCard extends StatelessWidget {
  const _GroupStatusCard({required this.group, required this.onTap});

  final api.Group group;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    group.name ?? '이름 없는 조',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.title3.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                AppTag(
                  label: group.isFinished == true ? '완주' : '진행 중',
                  tone: group.isFinished == true
                      ? AppTagTone.success
                      : AppTagTone.warning,
                ),
              ],
            ),
            const Spacer(),
            Text(
              '완료 코너',
              style: AppTypography.caption.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.space1),
            Row(
              children: [
                Text(
                  group.completedCountLabel,
                  style: AppTypography.bodyEmphasis.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: AppSpacing.space3),
                Expanded(
                  child: LinearProgressIndicator(value: group.completionRate),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _RegisterGroupDialog extends ConsumerStatefulWidget {
  const _RegisterGroupDialog({required this.campId});
  final CampId campId;
  @override
  ConsumerState<_RegisterGroupDialog> createState() =>
      _RegisterGroupDialogState();
}

class _RegisterGroupDialogState extends ConsumerState<_RegisterGroupDialog> {
  final _name = TextEditingController();
  final _payload = TextEditingController();
  int _tab = 0;
  bool _busy = false;
  bool _scanned = false;
  @override
  void dispose() {
    _name.dispose();
    _payload.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty || _payload.text.trim().isEmpty) return;
    setState(() => _busy = true);
    try {
      await ref.read(
        scanRegisterBadgeProvider(
          _payload.text.trim(),
          _name.text.trim(),
        ).future,
      );
      ref.invalidate(groupListProvider(widget.campId));
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미 등록된 배지이거나 등록할 수 없습니다')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final badges = ref.watch(badgeListProvider);
    return AlertDialog(
      title: const Text('조 등록'),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('카메라 QR')),
                ButtonSegment(value: 1, label: Text('목록에서 선택')),
                ButtonSegment(value: 2, label: Text('직접 입력')),
              ],
              selected: {_tab},
              onSelectionChanged: (value) =>
                  setState(() => _tab = value.single),
            ),
            const SizedBox(height: 12),
            if (_tab == 0)
              SizedBox(
                height: 220,
                child: _scanned
                    ? Center(child: Text('QR 인식 완료: ${_payload.text}'))
                    : MobileScanner(
                        onDetect: (capture) {
                          if (!mounted || _scanned) return;
                          final token = capture.barcodes.firstOrNull?.rawValue;
                          if (token != null) {
                            setState(() {
                              _payload.text = token;
                              _scanned = true;
                            });
                          }
                        },
                      ),
              )
            else if (_tab == 1)
              SizedBox(
                height: 180,
                child: badges.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, _) => const Text('배지를 불러오지 못했습니다'),
                  data: (items) => ListView(
                    children: [
                      for (final badge in items.where(
                        (item) => item.status == api.BadgeStatus.UNASSIGNED,
                      ))
                        ListTile(
                          title: Text(badge.shortId ?? badge.id ?? '-'),
                          selected: _payload.text == badge.qrPayload,
                          onTap: () => setState(
                            () => _payload.text = badge.qrPayload ?? '',
                          ),
                        ),
                    ],
                  ),
                ),
              )
            else
              TextField(
                controller: _payload,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: '배지 ID',
                  hintText: 'QR 코드 아래 인쇄된 ID를 입력하세요',
                ),
              ),
            if (_payload.text.isNotEmpty)
              TextField(
                controller: _name,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(labelText: '조 이름'),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        AppButton(
          variant: AppButtonVariant.primary,
          size: AppButtonSize.compact,
          label: '등록 확정',
          onPressed:
              _busy || _payload.text.trim().isEmpty || _name.text.trim().isEmpty
              ? null
              : _submit,
        ),
      ],
    );
  }
}
