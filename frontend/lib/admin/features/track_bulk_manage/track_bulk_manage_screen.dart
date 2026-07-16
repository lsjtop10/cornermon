import 'package:cornermon/admin/session/admin_session_provider.dart';
import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/corner_track_providers.dart';
import 'package:cornermon/shared/design_system/widgets/status_badge.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import 'track_csv_export.dart';

class TrackBulkManageScreen extends ConsumerStatefulWidget {
  const TrackBulkManageScreen({super.key});
  @override
  ConsumerState<TrackBulkManageScreen> createState() =>
      _TrackBulkManageScreenState();
}

class _TrackBulkManageScreenState extends ConsumerState<TrackBulkManageScreen> {
  final _selectedIds = <String>{};
  final _exports = <String>[];
  api.TrackOperationalStatus? _filter;
  int _sortColumn = 1;
  bool _ascending = true;

  Future<void> _exportCsv(CampId campId, String adminId) async {
    final response = await ref.read(exportAllTracksCsvProvider(campId).future);
    final bytes = buildTrackPinCsvBytes(
      response.tracks ?? const <api.TrackPin>[],
    );
    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(Uint8List.fromList(bytes), mimeType: 'text/csv'),
        ],
        fileNameOverrides: ['track-pins.csv'],
        subject: '트랙 PIN 목록',
      ),
    );
    if (mounted) {
      setState(() => _exports.insert(0, '전체 PIN CSV · 방금 전 · $adminId'));
    }
  }

  Future<void> _applyTargetTime(CampId campId, List<api.Track> selected) async {
    final controller = TextEditingController();
    final minutes = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('목표시간 일괄 변경'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '목표시간(분)',
            helperText: '선택한 트랙이 속한 코너에 적용됩니다.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(context, int.tryParse(controller.text)),
            child: const Text('적용'),
          ),
        ],
      ),
    );
    if (minutes == null || minutes < 1) return;
    final cornerIds = selected
        .map((track) => track.cornerId)
        .whereType<String>()
        .toSet();
    await ref.read(
      bulkUpdateCornersProvider([
        for (final cornerId in cornerIds)
          CornerUpdateInput(id: cornerId, targetMinutes: minutes),
      ]).future,
    );
    ref.invalidate(cornerListProvider(campId));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${cornerIds.length}개 코너의 목표시간이 변경되었습니다')),
      );
    }
  }

  Future<void> _delete(CampId campId, List<api.Track> tracks) async {
    if (tracks.any(
      (track) => track.operationalStatus == api.TrackOperationalStatus.BUSY,
    )) {
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('선택한 트랙을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await ref.read(
      bulkDeleteTracksProvider([
        for (final track in tracks) TrackId(track.id!),
      ]).future,
    );
    setState(_selectedIds.clear);
    ref.invalidate(trackListProvider(campId));
  }

  @override
  Widget build(BuildContext context) {
    final campId = ref.watch(selectedCampIdProvider);
    if (campId == null) return const SizedBox.shrink();
    final session = ref.watch(adminSessionProvider);
    final selectedCamp = ref.watch(selectedCampProvider).asData?.value;
    final tracks = ref.watch(trackListProvider(campId));
    final corners = ref.watch(cornerListProvider(campId));
    return Scaffold(
      appBar: AppBar(
        leading: selectedCamp?.status == api.CampStatus.ACTIVE
            ? IconButton(
                onPressed: () => context.go('/dashboard'),
                icon: const Icon(Icons.arrow_back),
              )
            : null,
        title: const Text('코너·트랙 관리'),
        actions: [
          IconButton(
            tooltip: '전체 PIN CSV 다운로드',
            onPressed: () => _exportCsv(
              campId,
              session is AdminSessionAuthenticated ? session.adminId : '관리자',
            ),
            icon: const Icon(Icons.download),
          ),
        ],
      ),
      body: tracks.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('트랙을 불러오지 못했습니다.\n$error')),
        data: (items) {
          final cornerNames = corners.asData?.value == null
              ? const <String, String>{}
              : {
                  for (final corner in corners.asData!.value)
                    corner.id!: corner.name ?? corner.id!,
                };
          final visible =
              items
                  .where(
                    (track) =>
                        track.status == api.TrackStatus.ACTIVE &&
                        (_filter == null || track.operationalStatus == _filter),
                  )
                  .toList()
                ..sort((left, right) {
                  final compare = switch (_sortColumn) {
                    1 =>
                      (cornerNames[left.cornerId] ?? left.cornerId ?? '')
                          .compareTo(
                            cornerNames[right.cornerId] ?? right.cornerId ?? '',
                          ),
                    2 => (left.trackNo ?? 0).compareTo(right.trackNo ?? 0),
                    _ => (left.operationalStatus?.name ?? '').compareTo(
                      right.operationalStatus?.name ?? '',
                    ),
                  };
                  return _ascending ? compare : -compare;
                });
          final selected = items
              .where((track) => _selectedIds.contains(track.id))
              .toList();
          final blocked = selected.any(
            (track) =>
                track.operationalStatus == api.TrackOperationalStatus.BUSY,
          );
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    DropdownButton<api.TrackOperationalStatus?>(
                      value: _filter,
                      hint: const Text('전체 상태'),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('전체')),
                        DropdownMenuItem(
                          value: api.TrackOperationalStatus.IDLE,
                          child: Text('IDLE만'),
                        ),
                        DropdownMenuItem(
                          value: api.TrackOperationalStatus.BUSY,
                          child: Text('BUSY만'),
                        ),
                      ],
                      onChanged: (value) => setState(() => _filter = value),
                    ),
                    const SizedBox(width: 16),
                    Text('${_selectedIds.length}개 선택됨'),
                    const Spacer(),
                    if (blocked) const Text('진행 중인 방문이 있어 삭제할 수 없습니다'),
                    const SizedBox(width: 8),
                    FilledButton.tonal(
                      onPressed: _selectedIds.isEmpty
                          ? null
                          : () => _applyTargetTime(campId, selected),
                      child: const Text('목표시간 변경'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.tonal(
                      onPressed: _selectedIds.isEmpty || blocked
                          ? null
                          : () => _delete(campId, selected),
                      child: const Text('선택 삭제'),
                    ),
                  ],
                ),
              ),
              if (_exports.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('최근 내보내기: ${_exports.first}'),
                  ),
                ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    sortColumnIndex: _sortColumn,
                    sortAscending: _ascending,
                    columns: [
                      DataColumn(
                        label: Checkbox(
                          value:
                              visible.isNotEmpty &&
                              visible.every(
                                (track) => _selectedIds.contains(track.id),
                              ),
                          tristate: true,
                          onChanged: (checked) => setState(() {
                            if (checked == true) {
                              _selectedIds.addAll(
                                visible.map((track) => track.id!).toSet(),
                              );
                            } else {
                              _selectedIds.removeAll(
                                visible.map((track) => track.id),
                              );
                            }
                          }),
                        ),
                      ),
                      DataColumn(
                        label: const Text('코너'),
                        onSort: (index, ascending) => setState(() {
                          _sortColumn = index;
                          _ascending = ascending;
                        }),
                      ),
                      DataColumn(
                        label: const Text('트랙'),
                        numeric: true,
                        onSort: (index, ascending) => setState(() {
                          _sortColumn = index;
                          _ascending = ascending;
                        }),
                      ),
                      DataColumn(
                        label: const Text('상태'),
                        onSort: (index, ascending) => setState(() {
                          _sortColumn = index;
                          _ascending = ascending;
                        }),
                      ),
                      const DataColumn(label: Text('PIN')),
                    ],
                    rows: [
                      for (final track in visible)
                        DataRow(
                          selected: _selectedIds.contains(track.id),
                          onSelectChanged: (checked) => setState(() {
                            if (checked == true) {
                              _selectedIds.add(track.id!);
                            } else {
                              _selectedIds.remove(track.id);
                            }
                          }),
                          cells: [
                            DataCell(
                              Checkbox(
                                value: _selectedIds.contains(track.id),
                                onChanged: null,
                              ),
                            ),
                            DataCell(
                              Text(
                                cornerNames[track.cornerId] ??
                                    track.cornerId ??
                                    '-',
                              ),
                            ),
                            DataCell(Text('${track.trackNo ?? '-'}번')),
                            DataCell(
                              StatusBadge(
                                status:
                                    track.operationalStatus ==
                                        api.TrackOperationalStatus.BUSY
                                    ? TrackVisualStatus.busy
                                    : TrackVisualStatus.idle,
                                label:
                                    track.operationalStatus ==
                                        api.TrackOperationalStatus.BUSY
                                    ? 'BUSY'
                                    : 'IDLE',
                              ),
                            ),
                            const DataCell(Text('••••••')),
                          ],
                        ),
                    ],
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
