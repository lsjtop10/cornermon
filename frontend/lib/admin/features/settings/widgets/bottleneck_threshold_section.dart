import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cornermon/admin/features/settings/update_camp_controller.dart';
import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';

/// A15 설정 — 병목 판정 기준(최소 표본, 목표시간 대비 편차 비율) 수정 섹션.
/// scenarios.md Feature 2-f: 0 이하 값은 서버 호출 자체를 클라이언트에서 차단한다.
/// 저장은 `UpdateCampController`를 통해 수행하며 성공 시
/// `selectedCampSnapshotProvider`가 직접 갱신된다 — 대시보드(A1)로 이동하면
/// 그 시점의 GET이 새 기준을 반영한 `isBottleneck`을 내려주므로 별도 무효화가 필요 없다
/// (plan §4.2 마지막 주석 참고).
class BottleneckThresholdSection extends ConsumerStatefulWidget {
  const BottleneckThresholdSection({required this.camp, super.key});

  final api.Camp camp;

  @override
  ConsumerState<BottleneckThresholdSection> createState() =>
      _BottleneckThresholdSectionState();
}

class _BottleneckThresholdSectionState
    extends ConsumerState<BottleneckThresholdSection> {
  late final TextEditingController _minSamplesController;
  late final TextEditingController _ratioPctController;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _minSamplesController = TextEditingController(
      text: widget.camp.bottleneckMinSamples?.toString() ?? '',
    );
    _ratioPctController = TextEditingController(
      text: widget.camp.bottleneckRatioPct?.toString() ?? '',
    );
    _minSamplesController.addListener(_onFieldChanged);
    _ratioPctController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() => setState(() {});

  @override
  void dispose() {
    _minSamplesController.removeListener(_onFieldChanged);
    _ratioPctController.removeListener(_onFieldChanged);
    _minSamplesController.dispose();
    _ratioPctController.dispose();
    super.dispose();
  }

  int? get _minSamples => int.tryParse(_minSamplesController.text);
  int? get _ratioPct => int.tryParse(_ratioPctController.text);

  bool get _minSamplesValid => _minSamples != null && _minSamples! > 0;
  bool get _ratioPctValid => _ratioPct != null && _ratioPct! > 0;

  bool get _canSave => _minSamplesValid && _ratioPctValid && !_saving;

  Future<void> _save() async {
    final id = widget.camp.id;
    if (id == null || !_canSave) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(updateCampControllerProvider.notifier)
          .save(
            CampId(id),
            bottleneckMinSamples: _minSamples,
            bottleneckRatioPct: _ratioPct,
          );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('병목 판정 기준이 저장되었습니다.')));
      }
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
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
            '병목 판정 기준',
            style: AppTypography.title3.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.space2),
          Text(
            '설정한 최소 표본 건수 이상 처리된 코너 중, 목표시간 대비 편차가 이 비율을 넘으면 병목으로 표시합니다.',
            style: AppTypography.caption.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.space4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _minSamplesController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: '최소 표본 건수',
                    errorText: _minSamplesValid ? null : '1 이상의 정수를 입력하세요',
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.space3),
              Expanded(
                child: TextField(
                  controller: _ratioPctController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: '목표시간 대비 편차 비율(%)',
                    errorText: _ratioPctValid ? null : '1 이상의 정수를 입력하세요',
                  ),
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
              onPressed: _canSave ? _save : null,
              disabledReason: _saving
                  ? null
                  : '최소 표본 건수와 편차 비율은 1 이상의 정수여야 합니다.',
            ),
          ),
        ],
      ),
    );
  }
}
