import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cornermon/admin/features/setup_wizard/setup_wizard_provider.dart';
import 'package:cornermon/admin/features/setup_wizard/steps/camp_info_step.dart';
import 'package:cornermon/admin/features/setup_wizard/steps/corner_track_step.dart';
import 'package:cornermon/admin/features/setup_wizard/steps/review_step.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:cornermon/shared/design_system/tokens/colors.dart';

class SetupWizardScreen extends ConsumerWidget {
  const SetupWizardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final step = ref.watch(setupWizardProvider.select((value) => value.step));
    final content = switch (step) {
      0 => const CampInfoStep(),
      1 => const CornerTrackStep(),
      _ => const ReviewStep(),
    };
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 840),
              child: Card(
                margin: const EdgeInsets.all(AppSpacing.space6),
                child: SizedBox(
                  height: (constraints.maxHeight - AppSpacing.space12).clamp(
                    520.0,
                    720.0,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.space6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('초기 설정', style: AppTypography.title1),
                        const SizedBox(height: AppSpacing.space4),
                        _StepIndicator(currentStep: step),
                        const SizedBox(height: AppSpacing.space6),
                        Expanded(child: content),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.currentStep});
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.dark
        ? AppColors.dark
        : AppColors.light;
    const labels = ['캠프 정보', '코너·트랙', '검토'];
    return Row(
      children: [
        for (var index = 0; index < labels.length; index++) ...[
          Expanded(
            child: _StepPill(
              label: labels[index],
              state: index < currentStep
                  ? _StepState.complete
                  : index == currentStep
                  ? _StepState.current
                  : _StepState.upcoming,
              colors: colors,
            ),
          ),
          if (index < labels.length - 1)
            const SizedBox(width: AppSpacing.space2),
        ],
      ],
    );
  }
}

enum _StepState { complete, current, upcoming }

class _StepPill extends StatelessWidget {
  const _StepPill({
    required this.label,
    required this.state,
    required this.colors,
  });

  final String label;
  final _StepState state;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final (background, foreground, icon) = switch (state) {
      _StepState.complete => (colors.success, colors.bgSurface, Icons.check),
      _StepState.current => (colors.brandPrimary, colors.bgSurface, null),
      _StepState.upcoming => (colors.bgSurface, colors.textSecondary, null),
    };
    return Container(
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        border: Border.all(
          color: state == _StepState.upcoming ? colors.border : background,
        ),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: foreground),
            const SizedBox(width: AppSpacing.space1),
          ],
          Text(label, style: AppTypography.label.copyWith(color: foreground)),
        ],
      ),
    );
  }
}
