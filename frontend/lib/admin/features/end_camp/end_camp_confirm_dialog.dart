import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cornermon/admin/features/end_camp/end_camp_controller.dart';
import 'package:cornermon/admin/widgets/admin_scaffold_messenger_key.dart';
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/report_providers.dart';
import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';

class EndCampConfirmDialog extends ConsumerStatefulWidget {
  const EndCampConfirmDialog({required this.campId, super.key});

  final CampId campId;

  @override
  ConsumerState<EndCampConfirmDialog> createState() =>
      _EndCampConfirmDialogState();
}

class _EndCampConfirmDialogState extends ConsumerState<EndCampConfirmDialog> {
  bool _submitting = false;
  String? _error;

  Future<void> _confirm() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(endCampControllerProvider.notifier).confirm();
      final result = ref.read(endCampControllerProvider);
      if (result.hasError) throw result.error!;
      final reportGenerationFailed = ref
          .read(endCampControllerProvider.notifier)
          .lastReportGenerationFailed;
      if (mounted) {
        Navigator.pop(context);
        context.go('/camps');
        if (reportGenerationFailed) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            adminScaffoldMessengerKey.currentState?.showSnackBar(
              const SnackBar(
                content: Text('리포트 자동 생성에 실패했습니다 — 리포트 화면에서 다시 생성할 수 있습니다'),
              ),
            );
          });
        }
      }
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.dark
        ? AppColors.dark
        : AppColors.light;
    final summary = ref.watch(liveSummaryProvider(widget.campId));
    return AlertDialog(
      backgroundColor: colors.bgSurfaceRaised,
      constraints: const BoxConstraints(minWidth: 480, maxWidth: 640),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: colors.warning, size: 28),
          const SizedBox(width: AppSpacing.space3),
          Expanded(
            child: Text(
              '코너학습을 종료할까요?',
              style: AppTypography.title3.copyWith(color: colors.textPrimary),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '종료 즉시 모든 진행자 세션이 로그아웃되며, 이후 데이터를 수정할 수 없습니다.',
            style: AppTypography.body.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.space3),
          summary.when(
            data: (stats) {
              final finished = stats.finishedGroupCount ?? 0;
              final total = stats.totalGroups ?? 0;
              final partial = (total - finished) < 0 ? 0 : total - finished;
              return Text(
                '완주 $finished조 / 부분완주 $partial조',
                style: AppTypography.body.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              );
            },
            loading: () => const SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            error: (_, _) => Text(
              '완주/부분완주 요약을 불러올 수 없습니다',
              style: AppTypography.caption.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.space3),
              child: Semantics(
                liveRegion: true,
                child: Text(
                  _error!,
                  style: AppTypography.caption.copyWith(color: colors.danger),
                ),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        AppButton(
          variant: AppButtonVariant.destructive,
          size: AppButtonSize.compact,
          label: _submitting ? '종료 처리 중…' : '종료 선언',
          onPressed: _submitting ? null : _confirm,
        ),
      ],
    );
  }
}
