import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cornermon/admin/features/setup_wizard/setup_wizard_provider.dart';
import 'package:cornermon/admin/features/setup_wizard/setup_wizard_state.dart';
import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';

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
        Text('설정 내용을 확인하세요', style: AppTypography.bodyEmphasis),
        const SizedBox(height: AppSpacing.space2),
        _SummaryRow(
          label: '캠프',
          value: state.campName.isEmpty ? '(이름 없음)' : state.campName,
          colors: colors,
        ),
        _SummaryRow(
          label: '기간',
          value: _dateRange(state.startAt, state.endAt),
          colors: colors,
        ),
        _SummaryRow(
          label: '코너 수',
          value: '${state.corners.length}개',
          colors: colors,
        ),
        _SummaryRow(
          label: '생성될 트랙 수',
          value: '총 $tracks개 (PIN 자동 발급)',
          colors: colors,
          showDivider: false,
        ),
        const SizedBox(height: AppSpacing.space3),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space3,
            vertical: AppSpacing.space2,
          ),
          decoration: BoxDecoration(
            color: colors.brandPrimary.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            '완료 즉시 "준비 중" 상태로 캠프 목록에 추가되며, 곧장 코너·트랙 준비 화면으로 이동합니다. '
            '트랙 PIN은 지금 바로 발급되지만, "코너학습 시작"을 확정하기 전까지는 로그인이 열리지 않습니다.',
            style: AppTypography.caption.copyWith(color: colors.brandPrimary),
          ),
        ),
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
          Text('생성 상태', style: AppTypography.bodyEmphasis),
          SizedBox(
            height: 180,
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
        ],
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.colors,
    this.showDivider = true,
  });

  final String label;
  final String value;
  final AppColors colors;
  final bool showDivider;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.space2),
    decoration: showDivider
        ? BoxDecoration(
            border: Border(bottom: BorderSide(color: colors.border)),
          )
        : null,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(color: colors.textSecondary),
        ),
        Text(value, style: AppTypography.bodyEmphasis),
      ],
    ),
  );
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
