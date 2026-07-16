import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cornermon/admin/features/setup_wizard/setup_wizard_provider.dart';
import 'package:cornermon/admin/features/setup_wizard/setup_wizard_state.dart';
import 'package:cornermon/admin/features/setup_wizard/setup_wizard_templates.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';

class CornerTrackStep extends ConsumerStatefulWidget {
  const CornerTrackStep({super.key});

  @override
  ConsumerState<CornerTrackStep> createState() => _CornerTrackStepState();
}

class _CornerTrackStepState extends ConsumerState<CornerTrackStep> {
  final _pasteController = TextEditingController();
  final _minutesController = TextEditingController(text: '10');
  final _trackController = TextEditingController(text: '1');

  @override
  void dispose() {
    _pasteController.dispose();
    _minutesController.dispose();
    _trackController.dispose();
    super.dispose();
  }

  void _apply() {
    final notifier = ref.read(setupWizardProvider.notifier);
    notifier.setDefaults(
      targetMinutes: int.tryParse(_minutesController.text),
      trackCountPerCorner: int.tryParse(_trackController.text),
    );
    notifier.parseCornerNames(_pasteController.text);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(setupWizardProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('코너 이름을 줄바꿈으로 입력하세요.'),
        const SizedBox(height: AppSpacing.space3),
        TextField(
          controller: _pasteController,
          maxLines: 3,
          decoration: const InputDecoration(hintText: '1코너\n2코너'),
        ),
        const SizedBox(height: AppSpacing.space3),
        Wrap(
          spacing: AppSpacing.space3,
          runSpacing: AppSpacing.space2,
          children: [
            SizedBox(
              width: 140,
              child: TextField(
                controller: _minutesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '기본 목표 시간(분)'),
              ),
            ),
            SizedBox(
              width: 140,
              child: TextField(
                controller: _trackController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '코너당 트랙 수'),
              ),
            ),
            AppButton(
              variant: AppButtonVariant.secondary,
              label: '입력 적용',
              onPressed: _apply,
            ),
            AppButton(
              variant: AppButtonVariant.secondary,
              label: '예시 10개로 빠르게 시작',
              onPressed: () {
                _pasteController.text = kSetupWizardExampleCornerNames.join(
                  '\n',
                );
                ref.read(setupWizardProvider.notifier).applyExampleTemplate();
              },
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space4),
        Expanded(
          child: state.corners.isEmpty
              ? const Center(child: Text('붙여넣거나 예시 템플릿을 사용하세요'))
              : ListView.builder(
                  padding: const EdgeInsets.only(top: AppSpacing.space2),
                  itemCount: state.corners.length,
                  itemBuilder: (context, index) =>
                      _CornerRow(index: index, row: state.corners[index]),
                ),
        ),
        const Divider(),
        const SizedBox(height: AppSpacing.space3),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppButton(
              variant: AppButtonVariant.secondary,
              label: '이전',
              onPressed: () =>
                  ref.read(setupWizardProvider.notifier).goToStep(0),
            ),
            AppButton(
              variant: AppButtonVariant.primary,
              label: '다음',
              onPressed: () => ref
                  .read(setupWizardProvider.notifier)
                  .tryAdvanceFromCornerStep(),
            ),
          ],
        ),
      ],
    );
  }
}

class _CornerRow extends ConsumerWidget {
  const _CornerRow({required this.index, required this.row});
  final int index;
  final SetupWizardCornerRow row;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.space2),
    child: Row(
      children: [
        Expanded(
          flex: 3,
          child: TextFormField(
            initialValue: row.name,
            onChanged: (value) => ref
                .read(setupWizardProvider.notifier)
                .updateCornerRow(index, name: value),
            decoration: const InputDecoration(labelText: '코너 이름'),
          ),
        ),
        const SizedBox(width: AppSpacing.space2),
        Expanded(
          child: TextFormField(
            initialValue: '${row.targetMinutes}',
            keyboardType: TextInputType.number,
            onChanged: (value) => ref
                .read(setupWizardProvider.notifier)
                .updateCornerRow(index, targetMinutes: int.tryParse(value)),
            decoration: const InputDecoration(labelText: '분'),
          ),
        ),
        const SizedBox(width: AppSpacing.space2),
        Expanded(
          child: TextFormField(
            initialValue: '${row.trackCount}',
            keyboardType: TextInputType.number,
            onChanged: (value) => ref
                .read(setupWizardProvider.notifier)
                .updateCornerRow(index, trackCount: int.tryParse(value)),
            decoration: const InputDecoration(labelText: '트랙'),
          ),
        ),
        IconButton(
          onPressed: () =>
              ref.read(setupWizardProvider.notifier).removeCornerRow(index),
          icon: const Icon(Icons.delete_outline),
          tooltip: '삭제',
        ),
      ],
    ),
  );
}
