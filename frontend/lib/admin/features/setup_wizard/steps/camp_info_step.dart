import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cornermon/admin/features/setup_wizard/setup_wizard_provider.dart';
import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';

class CampInfoStep extends ConsumerStatefulWidget {
  const CampInfoStep({super.key});

  @override
  ConsumerState<CampInfoStep> createState() => _CampInfoStepState();
}

class _CampInfoStepState extends ConsumerState<CampInfoStep> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: ref.read(setupWizardProvider).campName,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _updateInfo({DateTime? startAt, DateTime? endAt}) {
    final state = ref.read(setupWizardProvider);
    ref
        .read(setupWizardProvider.notifier)
        .setCampInfo(
          _nameController.text,
          startAt ?? state.startAt,
          endAt ?? state.endAt,
        );
  }

  Future<void> _selectDate(bool isStart) async {
    final state = ref.read(setupWizardProvider);
    final current = isStart ? state.startAt : state.endAt;
    final selected = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (selected == null) return;
    _updateInfo(
      startAt: isStart ? selected : null,
      endAt: isStart ? null : selected,
    );
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
        TextField(
          controller: _nameController,
          onChanged: (_) => _updateInfo(),
          decoration: const InputDecoration(labelText: '캠프 이름'),
        ),
        const SizedBox(height: AppSpacing.space3),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _DateField(
                label: '시작일',
                value: state.startAt,
                onTap: () => _selectDate(true),
              ),
            ),
            const SizedBox(width: AppSpacing.space3),
            Expanded(
              child: _DateField(
                label: '종료일',
                value: state.endAt,
                onTap: () => _selectDate(false),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space3),
        Text(
          '코너학습 프로그램은 이 캠프 기간 중 정확히 1회 운영됩니다.',
          style: AppTypography.caption.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.label, required this.value, this.onTap});
  final String label;
  final DateTime? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: InputDecorator(
      decoration: InputDecoration(labelText: label),
      child: Text(value == null ? '선택' : _date(value!)),
    ),
  );
}

String _date(DateTime value) =>
    '${value.year}.${value.month.toString().padLeft(2, '0')}.${value.day.toString().padLeft(2, '0')}';
