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

/// 코너 1개 + 그 코너에 속한 트랙 목록을 트리뷰처럼 접었다 펼 수 있는 항목으로
/// 보여준다. 코너 삭제는 트랙·방문 기록까지 DB CASCADE로 함께 제거되므로 트랙이
/// 있어도 막지 않는다 — 진행 중인 방문(BUSY 트랙)이 있을 때만 막는다
/// (`CornerTrackGroup.canDelete` 참고).
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
      body: '연결된 트랙과 방문 기록도 함께 삭제됩니다.',
    );
    if (!mounted || !confirmed || _isBusy) return;
    setState(() => _isBusy = true);
    try {
      final provider = deleteCornerProvider(CornerId(corner.id!));
      final container = ProviderScope.containerOf(context, listen: false);
      final sub = container.listen(provider, (_, _) {});
      await container.read(provider.future).whenComplete(sub.close);
      ref.invalidate(cornerListProvider(widget.campId));
      ref.invalidate(trackListProvider(widget.campId));
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
    return ExpansionTile(
      initiallyExpanded: true,
      title: Row(
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
                : '진행 중인 방문이 있어 삭제할 수 없습니다',
            onPressed: group.canDelete && !_isBusy ? _deleteCorner : null,
          ),
        ],
      ),
      children: [
        if (group.tracks.isEmpty)
          const Padding(
            padding: EdgeInsets.only(left: 16, bottom: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('연결된 트랙이 없습니다'),
            ),
          )
        else
          for (final track in group.tracks)
            ListTile(
              leading: Checkbox(
                value: widget.selectedIds.contains(track.id),
                onChanged: (checked) =>
                    widget.onSelectTrack(track.id!, checked ?? false),
              ),
              title: Text('${track.trackNo ?? '-'}번'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                  const SizedBox(width: 12),
                  const Text('••••••'),
                ],
              ),
              onTap: () =>
                  widget.onSelectTrack(
                    track.id!,
                    !widget.selectedIds.contains(track.id),
                  ),
            ),
      ],
    );
  }
}
