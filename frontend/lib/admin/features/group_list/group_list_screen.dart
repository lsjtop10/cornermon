import 'package:cornermon/admin/entities/group_ext.dart';
import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/group_providers.dart';
import 'package:cornermon/shared/api/providers/badge_providers.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';
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
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: PillTabBar(
                      selectedIndex: GroupStatusFilter.values.indexOf(_filter),
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
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Text(
                      '${visible.length}/${items.length}건',
                      style: AppTypography.caption,
                    ),
                  ),
                ],
              ),
              const Divider(height: 1),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async =>
                      ref.refresh(groupListProvider(campId).future),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      margin: EdgeInsets.zero,
                      child: SingleChildScrollView(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            sortColumnIndex: _sortColumn.index,
                            sortAscending: _ascending,
                            columns: [
                              DataColumn(
                                label: const Text('조'),
                                onSort: (_, _) => _sortBy(GroupSortColumn.name),
                              ),
                              DataColumn(
                                label: const Text('상태'),
                                onSort: (_, _) =>
                                    _sortBy(GroupSortColumn.status),
                              ),
                              DataColumn(
                                label: const Text('완료 코너 수'),
                                numeric: true,
                                onSort: (_, _) =>
                                    _sortBy(GroupSortColumn.completedCount),
                              ),
                            ],
                            rows: [
                              for (final group in visible)
                                DataRow(
                                  onSelectChanged: (_) =>
                                      context.go('/groups/${group.id}'),
                                  cells: [
                                    DataCell(Text(group.name ?? '이름 없는 조')),
                                    DataCell(
                                      Text(
                                        group.isFinished == true
                                            ? '완주'
                                            : '부분완주',
                                      ),
                                    ),
                                    DataCell(Text(group.completedCountLabel)),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
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
            else
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
          onPressed: _busy || _payload.text.isEmpty || _name.text.isEmpty
              ? null
              : _submit,
        ),
      ],
    );
  }
}
