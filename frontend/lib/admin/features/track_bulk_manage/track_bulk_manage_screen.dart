import 'package:cornermon/admin/session/admin_session_provider.dart';
import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/corner_track_providers.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';
import 'package:cornermon/shared/design_system/widgets/app_dropdown.dart';
import 'package:cornermon/shared/design_system/widgets/connection_banner.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '_corner_group_section.dart';
import '_track_bulk_manage_connection_state.dart';
import 'track_bulk_manage_grouping.dart';
import 'track_csv_export.dart';

enum _SortKey { corner, trackNo, status }

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
  _SortKey _sortKey = _SortKey.corner;
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
          AppButton(
            variant: AppButtonVariant.primary,
            size: AppButtonSize.compact,
            label: '적용',
            onPressed: () =>
                Navigator.pop(context, int.tryParse(controller.text)),
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
          AppButton(
            variant: AppButtonVariant.destructive,
            size: AppButtonSize.compact,
            label: '삭제',
            onPressed: () => Navigator.pop(context, true),
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

  List<CornerTrackGroup> _sortedGroups(
    List<api.Corner> cornerItems,
    List<api.Track> visible,
  ) {
    final groups = [
      for (final group in groupTracksByCorner(cornerItems, visible))
        CornerTrackGroup(
          corner: group.corner,
          tracks: [...group.tracks]..sort((left, right) {
            final compare = switch (_sortKey) {
              _SortKey.trackNo => (left.trackNo ?? 0).compareTo(
                right.trackNo ?? 0,
              ),
              _SortKey.status => (left.operationalStatus?.name ?? '')
                  .compareTo(right.operationalStatus?.name ?? ''),
              _SortKey.corner => (left.trackNo ?? 0).compareTo(
                right.trackNo ?? 0,
              ),
            };
            return _ascending ? compare : -compare;
          }),
        ),
    ];
    if (_sortKey == _SortKey.corner) {
      groups.sort((left, right) {
        final compare = (left.corner.name ?? left.corner.id ?? '').compareTo(
          right.corner.name ?? right.corner.id ?? '',
        );
        return _ascending ? compare : -compare;
      });
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final campId = ref.watch(selectedCampIdProvider);
    if (campId == null) return const SizedBox.shrink();
    final session = ref.watch(adminSessionProvider);
    final selectedCamp = ref.watch(selectedCampProvider).asData?.value;
    final tracks = ref.watch(trackListProvider(campId));
    final corners = ref.watch(cornerListProvider(campId));
    final connectionLost = ref.watch(trackBulkManageConnectionLostProvider);
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
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: AppButton(
              variant: AppButtonVariant.secondary,
              size: AppButtonSize.compact,
              icon: Icons.download_outlined,
              label: '전체 PIN 내보내기',
              onPressed: () => _exportCsv(
                campId,
                session is AdminSessionAuthenticated ? session.adminId : '관리자',
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          ConnectionBanner(
            state: connectionLost
                ? ConnectionBannerState.disconnected
                : ConnectionBannerState.hidden,
          ),
          Expanded(
            child: corners.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) =>
                  Center(child: Text('코너를 불러오지 못했습니다.\n$error')),
              data: (cornerItems) => tracks.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (error, _) =>
                    Center(child: Text('트랙을 불러오지 못했습니다.\n$error')),
                data: (items) {
                  final visible = items
                      .where(
                        (track) =>
                            track.status == api.TrackStatus.ACTIVE &&
                            (_filter == null ||
                                track.operationalStatus == _filter),
                      )
                      .toList();
                  final groups = _sortedGroups(cornerItems, visible);
                  final selected = items
                      .where((track) => _selectedIds.contains(track.id))
                      .toList();
                  final blocked = selected.any(
                    (track) =>
                        track.operationalStatus ==
                        api.TrackOperationalStatus.BUSY,
                  );
                  final allSelected =
                      visible.isNotEmpty &&
                      visible.every(
                        (track) => _selectedIds.contains(track.id),
                      );
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: allSelected,
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
                            const Text('전체 선택'),
                            const SizedBox(width: 16),
                            AppDropdown<api.TrackOperationalStatus?>(
                              value: _filter,
                              hint: '전체 상태',
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
                              onChanged: (value) =>
                                  setState(() => _filter = value),
                            ),
                            const SizedBox(width: 8),
                            AppDropdown<_SortKey>(
                              value: _sortKey,
                              items: const [
                                DropdownMenuItem(
                                  value: _SortKey.corner,
                                  child: Text('코너순'),
                                ),
                                DropdownMenuItem(
                                  value: _SortKey.trackNo,
                                  child: Text('트랙번호순'),
                                ),
                                DropdownMenuItem(
                                  value: _SortKey.status,
                                  child: Text('상태순'),
                                ),
                              ],
                              onChanged: (value) => setState(
                                () => _sortKey = value ?? _SortKey.corner,
                              ),
                            ),
                            IconButton(
                              tooltip: _ascending ? '오름차순' : '내림차순',
                              icon: Icon(
                                _ascending
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                              ),
                              onPressed: () =>
                                  setState(() => _ascending = !_ascending),
                            ),
                            const SizedBox(width: 8),
                            Text('${_selectedIds.length}개 선택됨'),
                            const Spacer(),
                            if (blocked)
                              const Text('진행 중인 방문이 있어 삭제할 수 없습니다'),
                            const SizedBox(width: 8),
                            AppButton(
                              variant: AppButtonVariant.secondary,
                              size: AppButtonSize.compact,
                              label: '목표시간 변경',
                              onPressed: _selectedIds.isEmpty
                                  ? null
                                  : () => _applyTargetTime(campId, selected),
                            ),
                            const SizedBox(width: 8),
                            AppButton(
                              variant: AppButtonVariant.destructive,
                              size: AppButtonSize.compact,
                              label: '선택 삭제',
                              disabledReason: blocked
                                  ? '진행 중인 방문이 있어 삭제할 수 없습니다'
                                  : null,
                              onPressed: _selectedIds.isEmpty || blocked
                                  ? null
                                  : () => _delete(campId, selected),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_exports.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text('최근 내보내기: ${_exports.first}'),
                            ),
                          ),
                        Expanded(
                          child: ListView(
                            children: [
                              for (final group in groups)
                                CornerGroupSection(
                                  campId: campId,
                                  group: group,
                                  selectedIds: _selectedIds,
                                  onSelectTrack: (trackId, isSelected) =>
                                      setState(() {
                                        if (isSelected) {
                                          _selectedIds.add(trackId);
                                        } else {
                                          _selectedIds.remove(trackId);
                                        }
                                      }),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
