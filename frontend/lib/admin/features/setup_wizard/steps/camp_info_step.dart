import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cornermon/admin/features/setup_wizard/setup_wizard_provider.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';

class CampInfoStep extends ConsumerStatefulWidget {
  const CampInfoStep({super.key});

  @override
  ConsumerState<CampInfoStep> createState() => _CampInfoStepState();
}

class _CampInfoStepState extends ConsumerState<CampInfoStep> {
  late final TextEditingController _nameController;
  DateTime? _startAt;
  DateTime? _endAt;

  @override
  void initState() {
    super.initState();
    final state = ref.read(setupWizardProvider);
    _nameController = TextEditingController(text: state.campName);
    _startAt = state.startAt;
    _endAt = state.endAt;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(bool isStart) async {
    final current = isStart ? _startAt : _endAt;
    final selected = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (selected != null) {
      setState(() => isStart ? _startAt = selected : _endAt = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final valid =
        _nameController.text.trim().isNotEmpty &&
        _startAt != null &&
        _endAt != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('캠프 정보를 입력하세요.'),
        const SizedBox(height: AppSpacing.space4),
        TextField(
          controller: _nameController,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(labelText: '캠프 이름'),
        ),
        const SizedBox(height: AppSpacing.space3),
        Wrap(
          spacing: AppSpacing.space3,
          runSpacing: AppSpacing.space2,
          children: [
            OutlinedButton(
              onPressed: () => _selectDate(true),
              child: Text(
                _startAt == null ? '시작일 선택' : '시작일 ${_date(_startAt!)}',
              ),
            ),
            OutlinedButton(
              onPressed: () => _selectDate(false),
              child: Text(
                _endAt == null ? '종료일 선택' : '종료일 ${_date(_endAt!)}',
              ),
            ),
          ],
        ),
        const Spacer(),
        const Divider(),
        const SizedBox(height: AppSpacing.space3),
        Align(
          alignment: Alignment.centerRight,
          child: AppButton(
            variant: AppButtonVariant.primary,
            label: '다음',
            disabledReason: '캠프 이름과 시작일·종료일을 입력하면 다음 단계로 이동할 수 있습니다.',
            onPressed: valid
                ? () {
                    ref
                        .read(setupWizardProvider.notifier)
                        .setCampInfo(_nameController.text, _startAt, _endAt);
                    ref.read(setupWizardProvider.notifier).goToStep(1);
                  }
                : null,
          ),
        ),
      ],
    );
  }
}

String _date(DateTime value) =>
    '${value.year}.${value.month.toString().padLeft(2, '0')}.${value.day.toString().padLeft(2, '0')}';
