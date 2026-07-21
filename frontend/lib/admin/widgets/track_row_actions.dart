import 'package:cornermon/admin/features/corner_detail/track_pin_pdf.dart';
import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/corner_track_providers.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';
import 'package:cornermon/shared/design_system/widgets/confirm_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

/// 트랙 1개에 대한 PIN 보기/재발급/교체/삭제 액션. 코너 상세(A2)와 코너·트랙 관리
/// 화면이 동일한 액션 세트를 공유하므로 여기 한 곳에 둔다.

Future<void> showTrackPinDialog(
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

Future<void> regenerateTrackPin(
  BuildContext context,
  WidgetRef ref,
  CampId campId,
  api.Track track,
) async {
  final confirmed = await showConfirmModal(
    context,
    kind: ConfirmModalKind.softConfirm,
    title: 'PIN을 재발급하면 접속 중인 세션이 즉시 종료됩니다. 계속하시겠습니까?',
  );
  if (!confirmed) return;
  await ref.read(regeneratePinProvider(TrackId(track.id!)).future);
  ref.invalidate(trackListProvider(campId));
}

/// [siblingActiveTrackCount]는 이 트랙이 속한 코너의 ACTIVE 트랙 총 개수(자기 자신
/// 포함)다 — 마지막 하나를 지우면 코너가 무트랙 상태가 된다는 경고 판단에 쓰인다.
Future<void> deleteTrack(
  BuildContext context,
  WidgetRef ref,
  CampId campId,
  api.Track track, {
  required int siblingActiveTrackCount,
}) async {
  if (track.operationalStatus == api.TrackOperationalStatus.BUSY) {
    await showConfirmModal(
      context,
      kind: ConfirmModalKind.hardBlock,
      title: '작업할 수 없습니다',
      body: '진행 중인 방문이 있어 삭제할 수 없습니다',
    );
    return;
  }
  if (siblingActiveTrackCount == 1 &&
      !await showConfirmModal(
        context,
        kind: ConfirmModalKind.softConfirm,
        title: '이 코너를 서비스할 트랙이 없어집니다. 계속하시겠습니까?',
      )) {
    return;
  }
  await ref.read(bulkDeleteTracksProvider([TrackId(track.id!)]).future);
  ref.invalidate(trackListProvider(campId));
}

Future<void> openReplaceTrackDialog(
  BuildContext context,
  WidgetRef ref,
  CampId campId,
  api.Track track,
  List<api.Corner> otherCorners, {
  required int siblingActiveTrackCount,
}) async {
  if (track.operationalStatus == api.TrackOperationalStatus.BUSY) {
    await showConfirmModal(
      context,
      kind: ConfirmModalKind.hardBlock,
      title: '진행 중인 방문이 완료된 후 다시 시도하세요',
    );
    return;
  }
  final replacement = await showDialog<api.Corner>(
    context: context,
    builder: (_) => ReplaceTrackDialog(track: track, corners: otherCorners),
  );
  if (replacement == null || !context.mounted) return;
  if (siblingActiveTrackCount == 1 &&
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

class ReplaceTrackDialog extends StatefulWidget {
  const ReplaceTrackDialog({
    required this.track,
    required this.corners,
    super.key,
  });

  final api.Track track;
  final List<api.Corner> corners;

  @override
  State<ReplaceTrackDialog> createState() => _ReplaceTrackDialogState();
}

class _ReplaceTrackDialogState extends State<ReplaceTrackDialog> {
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
      AppButton(
        variant: AppButtonVariant.primary,
        size: AppButtonSize.compact,
        label: '교체 실행',
        onPressed: _corner == null
            ? null
            : () => Navigator.pop(context, _corner),
      ),
    ],
  );
}
