import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cornermon/admin/features/settings/update_camp_controller.dart';
import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';
import 'package:cornermon/shared/design_system/widgets/korean_date_picker.dart';

/// A15 설정 — 캠프 이름/기간 수정 섹션.
/// 저장은 `UpdateCampController`(`update_camp_controller.dart`)를 통해 수행하며,
/// 성공 시 `selectedCampSnapshotProvider`가 직접 갱신되어 재조회 없이
/// 사이드바 캠프명 등 다른 화면에 즉시 반영된다(`start_camp_controller.dart`와 동일 패턴).
class CampInfoSection extends ConsumerStatefulWidget {
  const CampInfoSection({required this.camp, super.key});

  final api.Camp camp;

  @override
  ConsumerState<CampInfoSection> createState() => _CampInfoSectionState();
}

class _CampInfoSectionState extends ConsumerState<CampInfoSection> {
  late final TextEditingController _nameController;
  DateTime? _startAt;
  DateTime? _endAt;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.camp.name ?? '');
    _startAt = widget.camp.startAt;
    _endAt = widget.camp.endAt;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(bool isStart) async {
    final selected = await showKoreanDatePicker(
      context: context,
      initialDate: isStart ? _startAt : _endAt,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (selected == null) return;
    setState(() {
      if (isStart) {
        _startAt = selected;
      } else {
        _endAt = selected;
      }
    });
  }

  Future<void> _save() async {
    final id = widget.camp.id;
    if (id == null || _saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(updateCampControllerProvider.notifier)
          .save(CampId(id), name: _nameController.text, startAt: _startAt, endAt: _endAt);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('캠프 정보가 저장되었습니다.')));
      }
    } catch (error, stackTrace) {
      final message = describeUpdateCampError(error, stackTrace);
      if (mounted) setState(() => _error = message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.dark
        ? AppColors.dark
        : AppColors.light;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space5),
      decoration: BoxDecoration(
        color: colors.bgSurface,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '캠프 정보',
            style: AppTypography.title3.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.space4),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: '캠프 이름'),
          ),
          const SizedBox(height: AppSpacing.space3),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _DateField(
                  label: '시작일',
                  value: _startAt,
                  onTap: () => _selectDate(true),
                ),
              ),
              const SizedBox(width: AppSpacing.space3),
              Expanded(
                child: _DateField(
                  label: '종료일',
                  value: _endAt,
                  onTap: () => _selectDate(false),
                ),
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.space3),
            Semantics(
              liveRegion: true,
              child: Text(
                _error!,
                style: AppTypography.caption.copyWith(color: colors.danger),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.space4),
          Align(
            alignment: Alignment.centerRight,
            child: AppButton(
              variant: AppButtonVariant.primary,
              size: AppButtonSize.compact,
              label: _saving ? '저장 중…' : '저장',
              onPressed: _saving ? null : _save,
            ),
          ),
        ],
      ),
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
      child: Text(value == null ? '선택' : _formatDate(value!)),
    ),
  );
}

String _formatDate(DateTime value) =>
    '${value.year}.${value.month.toString().padLeft(2, '0')}.${value.day.toString().padLeft(2, '0')}';
