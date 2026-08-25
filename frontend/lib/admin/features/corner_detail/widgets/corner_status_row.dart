import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:material_ui/material_ui.dart';

/// 대시보드(A1)의 코너 카드와 동일한 3색 판정을 재사용한다: 트랙 일부만 가동 중이어도
/// 색으로는 구분하지 않고 "정상"(초록)으로 묶는다 — 여러 트랙을 하나로 요약할 때만
/// 적용되는 §design-system.md 1.2-b 규칙이라, 트랙 단위 상태에 쓰는 [StatusBadge](일부
/// 진행중이면 amber 'BUSY')를 그대로 재사용하면 안 된다.
class CornerStatusRow extends StatelessWidget {
  const CornerStatusRow({required this.status, super.key});

  final api.CornerOperationalStatus? status;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.dark
        ? AppColors.dark
        : AppColors.light;
    final presentation = switch (status) {
      api.CornerOperationalStatus.BUSY => (
        color: colors.statusIdle,
        icon: '●',
        label: '정상',
      ),
      api.CornerOperationalStatus.IDLE => (
        color: colors.quiet,
        icon: '○',
        label: '유휴',
      ),
      _ => (color: colors.statusInactive, icon: '✕', label: '미가동'),
    };
    final opacity = Theme.of(context).brightness == Brightness.dark
        ? .20
        : .12;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '현재 상태',
          style: AppTypography.label.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(width: AppSpacing.space2),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space2,
            vertical: AppSpacing.space1,
          ),
          decoration: BoxDecoration(
            color: presentation.color.withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            '${presentation.icon}  ${presentation.label}',
            style: AppTypography.label.copyWith(color: presentation.color),
          ),
        ),
      ],
    );
  }
}
