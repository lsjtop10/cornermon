import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cornermon/admin/features/setup_wizard/setup_wizard_provider.dart';
import 'package:cornermon/admin/features/setup_wizard/setup_wizard_state.dart';
import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';

class ReviewStep extends ConsumerWidget {
  const ReviewStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(setupWizardProvider);
    final colors = Theme.of(context).brightness == Brightness.dark
        ? AppColors.dark
        : AppColors.light;
    final tracks = state.corners.fold<int>(
      0,
      (total, row) => total + row.trackCount,
    );
    final hasFailures = state.corners.any(
      (row) => row.status == SetupWizardCornerStatus.failed,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('캠프: ${state.campName}'),
        Text('기간: ${_dateRange(state.startAt, state.endAt)}'),
        Text('코너 ${state.corners.length}개 · 트랙 총 $tracks개'),
        if (state.submitError != null) ...[
          const SizedBox(height: AppSpacing.space3),
          Container(
            padding: const EdgeInsets.all(AppSpacing.space3),
            color: colors.danger.withValues(alpha: .1),
            child: Text(
              state.submitError!,
              style: TextStyle(color: colors.danger),
            ),
          ),
        ],
        if (state.isSubmitting || hasFailures) ...[
          const SizedBox(height: AppSpacing.space4),
          const Text('생성 상태'),
          Expanded(
            child: ListView(
              children: [
                for (final row in state.corners)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(row.name),
                    subtitle: row.errorMessage == null
                        ? null
                        : Text(row.errorMessage!),
                    trailing: _StatusLabel(status: row.status),
                  ),
              ],
            ),
          ),
        ] else
          const Spacer(),
        const Divider(),
        const SizedBox(height: AppSpacing.space3),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppButton(
              variant: AppButtonVariant.secondary,
              label: '이전',
              onPressed: state.isSubmitting
                  ? null
                  : () => ref.read(setupWizardProvider.notifier).goToStep(1),
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                AppButton(
                  variant: AppButtonVariant.primary,
                  label: hasFailures ? '실패한 코너 재시도' : '설정 완료 → 코너·트랙 준비로',
                  onPressed: state.isSubmitting
                      ? null
                      : () async {
                          final completed = await ref
                              .read(setupWizardProvider.notifier)
                              .submit();
                          if (completed && context.mounted) {
                            context.go('/corner-track-manage');
                          }
                        },
                ),
                if (state.isSubmitting)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _StatusLabel extends StatelessWidget {
  const _StatusLabel({required this.status});
  final SetupWizardCornerStatus status;

  @override
  Widget build(BuildContext context) => Text(switch (status) {
    SetupWizardCornerStatus.pending => '대기',
    SetupWizardCornerStatus.creating => '생성 중',
    SetupWizardCornerStatus.created => '완료',
    SetupWizardCornerStatus.failed => '실패',
  });
}

String _dateRange(DateTime? start, DateTime? end) {
  String format(DateTime? value) => value == null
      ? '미지정'
      : '${value.year}.${value.month.toString().padLeft(2, '0')}.${value.day.toString().padLeft(2, '0')}';
  return '${format(start)} ~ ${format(end)}';
}
