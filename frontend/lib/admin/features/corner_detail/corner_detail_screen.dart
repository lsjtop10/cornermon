import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/admin/widgets/track_row_actions.dart';
import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/corner_track_providers.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';
import 'package:cornermon/shared/design_system/widgets/empty_state.dart';
import 'package:cornermon/shared/design_system/widgets/confirm_modal.dart';
import 'package:cornermon/shared/design_system/widgets/status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// A2. 선택한 코너의 규칙과 ACTIVE 트랙을 관리한다.
class CornerDetailScreen extends ConsumerWidget {
  const CornerDetailScreen({required this.cornerId, super.key});

  final CornerId cornerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campId = ref.watch(selectedCampIdProvider);
    if (campId == null) return const SizedBox.shrink();
    final corner = ref.watch(cornerDetailProvider(cornerId));
    final tracks = ref.watch(trackListProvider(campId));
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/dashboard'),
          icon: const Icon(Icons.arrow_back),
          tooltip: '대시보드로 돌아가기',
        ),
        title: const Text('코너 상세'),
      ),
      body: corner.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('코너를 불러오지 못했습니다.\n$error')),
        data: (value) => tracks.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('트랙을 불러오지 못했습니다.\n$error')),
          data: (items) => _CornerBody(
            campId: campId,
            corner: value,
            tracks: items
                .where(
                  (track) =>
                      track.cornerId == value.id &&
                      track.status == api.TrackStatus.ACTIVE,
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _CornerBody extends ConsumerWidget {
  const _CornerBody({
    required this.campId,
    required this.corner,
    required this.tracks,
  });

  final CampId campId;
  final api.Corner corner;
  final List<api.Track> tracks;

  Future<void> _addTrack(WidgetRef ref) async {
    await ref.read(
      createTracksForCornerProvider(campId, CornerId(corner.id!), 1).future,
    );
    ref.invalidate(trackListProvider(campId));
  }

  Future<void> _saveCorner(
    BuildContext context,
    WidgetRef ref,
    String name,
    int targetMinutes,
  ) async {
    await ref.read(
      bulkUpdateCornersProvider([
        CornerUpdateInput(
          id: corner.id!,
          name: name,
          targetMinutes: targetMinutes,
        ),
      ]).future,
    );
    ref.invalidate(cornerDetailProvider(CornerId(corner.id!)));
    ref.invalidate(cornerListProvider(campId));
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('저장되었습니다')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      _CornerEditor(
        corner: corner,
        onSave: (name, minutes) => _saveCorner(context, ref, name, minutes),
      ),
      const SizedBox(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('트랙', style: Theme.of(context).textTheme.titleLarge),
          AppButton(
            variant: AppButtonVariant.primary,
            size: AppButtonSize.compact,
            icon: Icons.add,
            label: '트랙 추가',
            onPressed: () => _addTrack(ref),
          ),
        ],
      ),
      const SizedBox(height: 12),
      if (tracks.isEmpty)
        SizedBox(
          height: 220,
          child: EmptyState(
            message: '이 코너에는 트랙이 없습니다',
            icon: Icons.devices_other_outlined,
            actionLabel: '트랙 추가',
            onAction: () => _addTrack(ref),
          ),
        )
      else
        _TrackTable(campId: campId, tracks: tracks),
    ],
  );
}

class _CornerEditor extends StatefulWidget {
  const _CornerEditor({required this.corner, required this.onSave});

  final api.Corner corner;
  final Future<void> Function(String name, int minutes) onSave;

  @override
  State<_CornerEditor> createState() => _CornerEditorState();
}

class _CornerEditorState extends State<_CornerEditor> {
  late final _name = TextEditingController(text: widget.corner.name ?? '');
  late final _minutes = TextEditingController(
    text: '${widget.corner.targetMinutes ?? 0}',
  );

  @override
  void dispose() {
    _name.dispose();
    _minutes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: '코너 이름'),
          ),
          TextField(
            controller: _minutes,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: '목표시간(분)'),
          ),
          const SizedBox(height: 12),
          AppButton(
            variant: AppButtonVariant.primary,
            size: AppButtonSize.compact,
            label: '변경 저장',
            onPressed: () async {
              final minutes = int.tryParse(_minutes.text);
              if (minutes == null || minutes < 1) return;
              final confirmed = await _confirm(
                context,
                '${widget.corner.targetMinutes ?? 0}분 → $minutes분으로 변경합니다',
              );
              if (confirmed) await widget.onSave(_name.text.trim(), minutes);
            },
          ),
        ],
      ),
    ),
  );
}

class _TrackTable extends ConsumerWidget {
  const _TrackTable({required this.campId, required this.tracks});

  final CampId campId;
  final List<api.Track> tracks;

  @override
  Widget build(BuildContext context, WidgetRef ref) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: DataTable(
      columns: const [
        DataColumn(label: Text('트랙')),
        DataColumn(label: Text('상태')),
        DataColumn(label: Text('현재 조')),
        DataColumn(label: Text('PIN')),
        DataColumn(label: Text('액션')),
      ],
      rows: [
        for (final track in tracks)
          DataRow(
            cells: [
              DataCell(Text('${track.trackNo ?? '-'}번')),
              DataCell(
                StatusBadge(
                  status:
                      track.operationalStatus == api.TrackOperationalStatus.BUSY
                      ? TrackVisualStatus.busy
                      : TrackVisualStatus.idle,
                ),
              ),
              DataCell(Text(track.currentVisit?.groupId ?? '-')),
              const DataCell(Text('••••••')),
              DataCell(
                Wrap(
                  children: [
                    IconButton(
                      tooltip: 'PIN 보기',
                      onPressed: () => showTrackPinDialog(context, ref, track),
                      icon: const Icon(Icons.key_outlined),
                    ),
                    IconButton(
                      tooltip: 'PIN 재발급',
                      onPressed: () =>
                          regenerateTrackPin(context, ref, campId, track),
                      icon: const Icon(Icons.refresh),
                    ),
                    IconButton(
                      tooltip: '트랙 교체',
                      onPressed: () async {
                        final corners = await ref.read(
                          cornerListProvider(campId).future,
                        );
                        if (!context.mounted) return;
                        await openReplaceTrackDialog(
                          context,
                          ref,
                          campId,
                          track,
                          corners
                              .where((corner) => corner.id != track.cornerId)
                              .toList(),
                          siblingActiveTrackCount: tracks.length,
                        );
                      },
                      icon: const Icon(Icons.swap_horiz),
                    ),
                    IconButton(
                      tooltip: '삭제',
                      onPressed: () => deleteTrack(
                        context,
                        ref,
                        campId,
                        track,
                        siblingActiveTrackCount: tracks.length,
                      ),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    ),
  );
}

Future<bool> _confirm(BuildContext context, String message) => showConfirmModal(
  context,
  kind: ConfirmModalKind.softConfirm,
  title: message,
);
