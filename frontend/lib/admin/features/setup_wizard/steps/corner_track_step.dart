import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cornermon/admin/features/setup_wizard/setup_wizard_provider.dart';
import 'package:cornermon/admin/features/setup_wizard/setup_wizard_state.dart';
import 'package:cornermon/admin/features/setup_wizard/setup_wizard_templates.dart';
import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
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

  void _reparse() {
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
    final colors = Theme.of(context).brightness == Brightness.dark
        ? AppColors.dark
        : AppColors.light;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '코너 목록 (한 줄에 하나씩)',
                style: AppTypography.bodyEmphasis,
              ),
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
        const SizedBox(height: AppSpacing.space3),
        TextField(
          controller: _pasteController,
          maxLines: 5,
          onChanged: (_) => _reparse(),
          decoration: const InputDecoration(hintText: '성경 퀴즈\n보드게임 마스터\n...'),
        ),
        const SizedBox(height: AppSpacing.space3),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _minutesController,
                keyboardType: TextInputType.number,
                onChanged: (_) => _reparse(),
                decoration: const InputDecoration(labelText: '기본 목표시간(분)'),
              ),
            ),
            const SizedBox(width: AppSpacing.space3),
            Expanded(
              child: TextField(
                controller: _trackController,
                keyboardType: TextInputType.number,
                onChanged: (_) => _reparse(),
                decoration: const InputDecoration(labelText: '코너당 기본 트랙 수'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space3),
        Text(
          '코너별로 다르게 조정하고 싶으면 아래 목록에서 개별 수정하세요. 트랙마다 PIN은 자동 발급됩니다.',
          style: AppTypography.caption.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.space3),
        SizedBox(
          height: 220,
          child: state.corners.isEmpty
              ? const Center(child: Text('붙여넣거나 예시 템플릿을 사용하세요'))
              : ListView.builder(
                  itemCount: state.corners.length,
                  itemBuilder: (context, index) =>
                      _CornerRow(index: index, row: state.corners[index]),
                ),
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
