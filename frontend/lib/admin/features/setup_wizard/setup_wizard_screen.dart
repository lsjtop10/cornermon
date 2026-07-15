import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cornermon/admin/features/setup_wizard/setup_wizard_provider.dart';
import 'package:cornermon/admin/features/setup_wizard/steps/camp_info_step.dart';
import 'package:cornermon/admin/features/setup_wizard/steps/corner_track_step.dart';
import 'package:cornermon/admin/features/setup_wizard/steps/review_step.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';

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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 840),
          child: Card(
            margin: const EdgeInsets.all(AppSpacing.space6),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.space6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('초기 설정', style: AppTypography.title1),
                  const SizedBox(height: AppSpacing.space4),
                  _StepIndicator(currentStep: step),
                  const SizedBox(height: AppSpacing.space6),
                  Flexible(child: SingleChildScrollView(child: content)),
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
  const _StepIndicator({required this.currentStep});
  final int currentStep;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (var index = 0; index < 3; index++) ...[
        Expanded(
          child: Column(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: index <= currentStep
                    ? Theme.of(context).colorScheme.primary
                    : null,
                child: Text('${index + 1}'),
              ),
              const SizedBox(height: AppSpacing.space1),
              Text(['캠프 정보', '코너·트랙', '검토'][index]),
            ],
          ),
        ),
        if (index < 2) const Expanded(child: Divider()),
      ],
    ],
  );
}
