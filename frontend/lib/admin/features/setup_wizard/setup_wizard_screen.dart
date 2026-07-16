import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cornermon/admin/features/setup_wizard/setup_wizard_provider.dart';
import 'package:cornermon/admin/features/setup_wizard/setup_wizard_state.dart';
import 'package:cornermon/admin/features/setup_wizard/steps/camp_info_step.dart';
import 'package:cornermon/admin/features/setup_wizard/steps/corner_track_step.dart';
import 'package:cornermon/admin/features/setup_wizard/steps/review_step.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';

class SetupWizardScreen extends ConsumerWidget {
  const SetupWizardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(setupWizardProvider);
    final colors = Theme.of(context).brightness == Brightness.dark
        ? AppColors.dark
        : AppColors.light;
    final content = switch (state.step) {
      0 => const CampInfoStep(),
      1 => const CornerTrackStep(),
      _ => const ReviewStep(),
    };
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/camps'),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.space6),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '코너학습 초기 설정',
                    textAlign: TextAlign.center,
                    style: AppTypography.title1,
                  ),
                  const SizedBox(height: AppSpacing.space1),
                  Text(
                    '캠프 정보와 코너·트랙을 한 번에 준비합니다',
                    textAlign: TextAlign.center,
                    style: AppTypography.caption.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space5),
                  _StepIndicator(currentStep: state.step, colors: colors),
                  const SizedBox(height: AppSpacing.space4),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.space5),
                      child: content,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  _WizardFooter(state: state),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.currentStep, required this.colors});
  final int currentStep;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    const labels = ['캠프 정보', '코너·트랙', '검토'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var index = 0; index < labels.length; index++) ...[
          _StepPill(
            number: index + 1,
            label: labels[index],
            state: index < currentStep
                ? _StepState.complete
                : index == currentStep
                ? _StepState.current
                : _StepState.upcoming,
            colors: colors,
          ),
          if (index < labels.length - 1)
            Container(
              width: 20,
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.space1),
              color: colors.border,
            ),
        ],
      ],
    );
  }
}

enum _StepState { complete, current, upcoming }

class _StepPill extends StatelessWidget {
  const _StepPill({
    required this.number,
    required this.label,
    required this.state,
    required this.colors,
  });

  final int number;
  final String label;
  final _StepState state;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final (background, foreground, numBackground) = switch (state) {
      _StepState.complete => (
        colors.brandPrimary.withValues(alpha: .1),
        colors.brandPrimary,
        colors.success,
      ),
      _StepState.current => (
        colors.brandPrimary.withValues(alpha: .1),
        colors.brandPrimary,
        colors.brandPrimary,
      ),
      _StepState.upcoming => (
        colors.bgCanvas,
        colors.textDisabled,
        colors.border,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 18,
            height: 18,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: numBackground,
              shape: BoxShape.circle,
            ),
            child: state == _StepState.complete
                ? Icon(Icons.check, size: 12, color: colors.bgSurface)
                : Text(
                    '$number',
                    style: AppTypography.label.copyWith(
                      fontSize: 10.5,
                      color: colors.bgSurface,
                    ),
                  ),
          ),
          const SizedBox(width: AppSpacing.space1),
          Text(label, style: AppTypography.label.copyWith(color: foreground)),
        ],
      ),
    );
  }
}

class _WizardFooter extends ConsumerWidget {
  const _WizardFooter({required this.state});
  final SetupWizardState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(setupWizardProvider.notifier);
    final hasFailures = state.corners.any(
      (row) => row.status == SetupWizardCornerStatus.failed,
    );

    final VoidCallback? onPrev = switch (state.step) {
      2 => state.isSubmitting ? null : () => notifier.goToStep(1),
      _ => () => notifier.goToStep(0),
    };

    final String nextLabel = switch (state.step) {
      2 => hasFailures ? '실패한 코너 재시도' : '설정 완료 → 코너·트랙 준비로',
      _ => '다음',
    };

    VoidCallback? onNext;
    switch (state.step) {
      case 0:
        final valid =
            state.campName.trim().isNotEmpty &&
            state.startAt != null &&
            state.endAt != null;
        onNext = valid ? () => notifier.goToStep(1) : null;
      case 1:
        onNext = () {
          if (state.corners.isEmpty) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('코너를 1개 이상 추가하세요')));
            return;
          }
          notifier.goToStep(2);
        };
      default:
        onNext = state.isSubmitting
            ? null
            : () async {
                final completed = await notifier.submit();
                if (completed && context.mounted) {
                  context.go('/corner-track-manage');
                }
              };
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Visibility(
          visible: state.step != 0,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          child: AppButton(
            variant: AppButtonVariant.secondary,
            label: '이전',
            onPressed: onPrev,
          ),
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            AppButton(
              variant: AppButtonVariant.primary,
              label: nextLabel,
              onPressed: onNext,
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
    );
  }
}
