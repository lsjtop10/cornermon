import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cornermon/shared/api/dio_error.dart';
import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/corner_track_providers.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';
import 'package:cornermon/shared/design_system/widgets/confirm_modal.dart';
import 'package:cornermon/shared/design_system/widgets/status_badge.dart';

import '_track_bulk_manage_connection_state.dart';
import 'track_bulk_manage_grouping.dart';

/// 코너 1개 + 그 코너에 속한 트랙 목록을 보여주는 그룹 섹션. 트랙이 하나도 없는
/// 코너(중복 생성으로 남은 좀비 코너)도 그대로 노출해 관리자가 삭제할 수 있게 한다.
class CornerGroupSection extends ConsumerStatefulWidget {
  const CornerGroupSection({
    required this.campId,
    required this.group,
    required this.selectedIds,
    required this.onSelectTrack,
    super.key,
  });

  final CampId campId;
  final CornerTrackGroup group;
  final Set<String> selectedIds;
  final void Function(String trackId, bool selected) onSelectTrack;

  @override
  ConsumerState<CornerGroupSection> createState() =>
      _CornerGroupSectionState();
}

class _CornerGroupSectionState extends ConsumerState<CornerGroupSection> {
  bool _isBusy = false;

  Future<void> _deleteCorner() async {
    final corner = widget.group.corner;
    final confirmed = await showConfirmModal(
      context,
      kind: ConfirmModalKind.softConfirm,
      title: '코너 "${corner.name ?? corner.id}"를 삭제하시겠습니까?',
      body: '트랙이 연결되지 않은 코너만 삭제할 수 있습니다.',
    );
    if (!mounted || !confirmed || _isBusy) return;
    setState(() => _isBusy = true);
    try {
      final provider = deleteCornerProvider(CornerId(corner.id!));
      final container = ProviderScope.containerOf(context, listen: false);
      final sub = container.listen(provider, (_, _) {});
      await container.read(provider.future).whenComplete(sub.close);
      ref.invalidate(cornerListProvider(widget.campId));
      ref.read(trackBulkManageConnectionLostProvider.notifier).set(false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('코너가 삭제되었습니다')));
      }
    } on DioException catch (error, stackTrace) {
      debugPrint(
        '[track_bulk_manage] delete corner failed: type=${error.type} '
        'statusCode=${error.response?.statusCode} '
        'body=${error.response?.data}\n$stackTrace',
      );
      if (isConnectionLost(error)) {
        ref.read(trackBulkManageConnectionLostProvider.notifier).set(true);
      } else {
        _showSnackBar('코너 삭제에 실패했습니다. 잠시 후 다시 시도해주세요.');
      }
    } catch (error, stackTrace) {
      debugPrint('[track_bulk_manage] delete corner failed: $error\n$stackTrace');
      _showSnackBar('코너 삭제에 실패했습니다. 잠시 후 다시 시도해주세요.');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final group = widget.group;
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    group.corner.name ?? group.corner.id ?? '코너',
                    style: AppTypography.bodyEmphasis,
                  ),
                ),
                Text('트랙 ${group.tracks.length}개'),
                const SizedBox(width: 12),
                AppButton(
                  variant: AppButtonVariant.destructive,
                  size: AppButtonSize.compact,
                  label: '코너 삭제',
                  disabledReason: group.canDelete
                      ? null
                      : '연결된 트랙이 있어 삭제할 수 없습니다',
                  onPressed: group.canDelete && !_isBusy ? _deleteCorner : null,
                ),
              ],
            ),
            if (group.tracks.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('연결된 트랙이 없습니다'),
              )
            else
              DataTable(
                columns: const [
                  DataColumn(label: Text('')),
                  DataColumn(label: Text('트랙'), numeric: true),
                  DataColumn(label: Text('상태')),
                  DataColumn(label: Text('PIN')),
                ],
                rows: [
                  for (final track in group.tracks)
                    DataRow(
                      selected: widget.selectedIds.contains(track.id),
                      onSelectChanged: (checked) =>
                          widget.onSelectTrack(track.id!, checked ?? false),
                      cells: [
                        DataCell(
                          Checkbox(
                            value: widget.selectedIds.contains(track.id),
                            onChanged: null,
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
          ],
        ),
      ),
    );
  }
}
