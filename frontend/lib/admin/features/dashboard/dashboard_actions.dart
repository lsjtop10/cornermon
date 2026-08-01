import 'package:cornermon/admin/features/dashboard/dashboard_entries.dart';
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/corner_track_providers.dart';
import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';
import 'package:cornermon/shared/design_system/widgets/confirm_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> showAddCornerDialog(
  BuildContext context,
  WidgetRef ref,
  CampId campId,
) async {
  final nameController = TextEditingController();
  final minutesController = TextEditingController(text: '10');
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final colors = isDark ? AppColors.dark : AppColors.light;
      return AlertDialog(
        title: Text(
          '코너 추가',
          style: AppTypography.title3.copyWith(color: colors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: const InputDecoration(labelText: '코너 이름'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: minutesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '목표시간(분)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          AppButton(
            variant: AppButtonVariant.primary,
            size: AppButtonSize.compact,
            label: '추가',
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      );
    },
  );
  if (confirmed != true) return;
  final name = nameController.text.trim();
  final minutes = int.tryParse(minutesController.text) ?? 10;
  if (name.isEmpty) return;
  await ref.read(createCornerProvider(campId, name, minutes).future);
  ref.invalidate(cornerListProvider(campId));
}

Future<void> deleteCorner(
  BuildContext context,
  WidgetRef ref,
  CampId campId,
  CornerDashboardEntry entry,
) async {
  if (entry.hasBusyTrack) {
    await showConfirmModal(
      context,
      kind: ConfirmModalKind.hardBlock,
      title: '작업할 수 없습니다',
      body: '진행 중인 방문이 있어 삭제할 수 없습니다',
    );
    return;
  }
  final confirmed = await showConfirmModal(
    context,
    kind: ConfirmModalKind.softConfirm,
    title: '코너 "${entry.corner.name ?? entry.corner.id}"를 삭제하시겠습니까?',
    body: '연결된 트랙과 방문 기록도 함께 삭제됩니다.',
  );
  if (!confirmed) return;
  try {
    await ref.read(deleteCornerProvider(CornerId(entry.corner.id!)).future);
    ref.invalidate(cornerListProvider(campId));
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('코너 삭제에 실패했습니다. 잠시 후 다시 시도해주세요.')),
      );
    }
  }
}
