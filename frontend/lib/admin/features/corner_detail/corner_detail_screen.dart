import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/corner_track_providers.dart';
import 'package:cornermon/shared/design_system/widgets/empty_state.dart';
import 'package:cornermon/shared/design_system/widgets/confirm_modal.dart';
import 'package:cornermon/shared/design_system/widgets/status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';

import 'track_pin_pdf.dart';

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
          FilledButton.icon(
            onPressed: () => _addTrack(ref),
            icon: const Icon(Icons.add),
            label: const Text('트랙 추가'),
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
          FilledButton(
            onPressed: () async {
              final minutes = int.tryParse(_minutes.text);
              if (minutes == null || minutes < 1) return;
              final confirmed = await _confirm(
                context,
                '${widget.corner.targetMinutes ?? 0}분 → $minutes분으로 변경합니다',
              );
              if (confirmed) await widget.onSave(_name.text.trim(), minutes);
            },
            child: const Text('변경 저장'),
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

  Future<void> _showPin(
    BuildContext context,
    WidgetRef ref,
    api.Track track,
  ) async {
    final result = await ref.read(
      exportTrackPdfProvider(TrackId(track.id!)).future,
    );
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('${track.trackNo ?? '-'}번 트랙 PIN'),
        content: SelectableText(
          result.pin ?? '-',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          TextButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: result.pin ?? ''));
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('PIN을 복사했습니다')));
              }
            },
            icon: const Icon(Icons.copy),
            label: const Text('복사'),
          ),
          TextButton.icon(
            onPressed: () async {
              final bytes = await buildTrackPinPdf(
                trackNo: '${track.trackNo ?? '-'}',
                pin: result.pin ?? '-',
              );
              await Printing.sharePdf(
                bytes: bytes,
                filename: 'track-${track.trackNo ?? 'pin'}-pin.pdf',
              );
            },
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: const Text('PDF 내보내기'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    api.Track track,
  ) async {
    if (track.operationalStatus == api.TrackOperationalStatus.BUSY) {
      await _showHardBlock(context, '진행 중인 방문이 있어 삭제할 수 없습니다');
      return;
    }
    if (tracks.length == 1 &&
        !await _confirm(context, '이 코너를 서비스할 트랙이 없어집니다. 계속하시겠습니까?')) {
      return;
    }
    await ref.read(bulkDeleteTracksProvider([TrackId(track.id!)]).future);
    ref.invalidate(trackListProvider(campId));
  }

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
                      onPressed: () => _showPin(context, ref, track),
                      icon: const Icon(Icons.key_outlined),
                    ),
                    IconButton(
                      tooltip: 'PIN 재발급',
                      onPressed: () async {
                        final confirmed = await showConfirmModal(
                          context,
                          kind: ConfirmModalKind.softConfirm,
                          title: 'PIN을 재발급하면 접속 중인 세션이 즉시 종료됩니다. 계속하시겠습니까?',
                        );
                        if (!confirmed) return;
                        await ref.read(
                          regeneratePinProvider(TrackId(track.id!)).future,
                        );
                        ref.invalidate(trackListProvider(campId));
                      },
                      icon: const Icon(Icons.refresh),
                    ),
                    IconButton(
                      tooltip: '트랙 교체',
                      onPressed: () => _openReplace(context, ref, track),
                      icon: const Icon(Icons.swap_horiz),
                    ),
                    IconButton(
                      tooltip: '삭제',
                      onPressed: () => _delete(context, ref, track),
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

  Future<void> _openReplace(
    BuildContext context,
    WidgetRef ref,
    api.Track track,
  ) async {
    if (track.operationalStatus == api.TrackOperationalStatus.BUSY) {
      await showConfirmModal(
        context,
        kind: ConfirmModalKind.hardBlock,
        title: '진행 중인 방문이 완료된 후 다시 시도하세요',
      );
      return;
    }
    final corners = await ref.read(cornerListProvider(campId).future);
    if (!context.mounted) return;
    final replacement = await showDialog<api.Corner>(
      context: context,
      builder: (_) => _ReplaceTrackDialog(
        track: track,
        corners: corners
            .where((corner) => corner.id != track.cornerId)
            .toList(),
      ),
    );
    if (replacement == null || !context.mounted) return;
    if (tracks.length == 1 &&
        !await showConfirmModal(
          context,
          kind: ConfirmModalKind.softConfirm,
          title: '이 코너를 서비스할 트랙이 없어집니다. 계속하시겠습니까?',
        )) {
      return;
    }
    try {
      final result = await ref.read(
        replaceTrackProvider(
          TrackId(track.id!),
          CornerId(replacement.id!),
        ).future,
      );
      ref.invalidate(trackListProvider(campId));
      ref.invalidate(cornerListProvider(campId));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('교체되었습니다. 새 PIN: ${result.pin ?? '-'}')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        await showConfirmModal(
          context,
          kind: ConfirmModalKind.hardBlock,
          title: '진행 중인 방문이 완료된 후 다시 시도하세요',
        );
      }
    }
  }
}

class _ReplaceTrackDialog extends StatefulWidget {
  const _ReplaceTrackDialog({required this.track, required this.corners});
  final api.Track track;
  final List<api.Corner> corners;
  @override
  State<_ReplaceTrackDialog> createState() => _ReplaceTrackDialogState();
}

class _ReplaceTrackDialogState extends State<_ReplaceTrackDialog> {
  api.Corner? _corner;
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('트랙 교체'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${widget.track.trackNo ?? '-'}번 트랙을 새 코너로 이동합니다.'),
        const SizedBox(height: 12),
        DropdownButtonFormField<api.Corner>(
          initialValue: _corner,
          decoration: const InputDecoration(labelText: '신규 코너'),
          items: [
            for (final corner in widget.corners)
              DropdownMenuItem(
                value: corner,
                child: Text(corner.name ?? corner.id ?? '-'),
              ),
          ],
          onChanged: (value) => setState(() => _corner = value),
        ),
        const SizedBox(height: 12),
        const Text('PIN 카드 재인쇄가 필요합니다. 접속 중인 기기가 있다면 자동 재인증됩니다.'),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('취소'),
      ),
      FilledButton(
        onPressed: _corner == null
            ? null
            : () => Navigator.pop(context, _corner),
        child: const Text('교체 실행'),
      ),
    ],
  );
}

Future<bool> _confirm(BuildContext context, String message) => showConfirmModal(
  context,
  kind: ConfirmModalKind.softConfirm,
  title: message,
);

Future<void> _showHardBlock(BuildContext context, String message) async {
  await showConfirmModal(
    context,
    kind: ConfirmModalKind.hardBlock,
    title: '작업할 수 없습니다',
    body: message,
  );
}
