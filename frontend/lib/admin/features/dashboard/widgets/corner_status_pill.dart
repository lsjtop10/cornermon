import 'package:material_ui/material_ui.dart';

import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';

/// 코너 카드(§design-system.md 1.2-b·4.1)의 3색 집계 상태 — 카드형 뷰(코너 카드)와
/// 트랙별 뷰(코너별 그룹 헤더)가 반드시 같은 매핑을 쓰도록 한 곳에 둔다. 이전엔 두
/// 화면이 각자 이 switch를 따로 들고 있어서(코너 상세 화면도 마찬가지) 한쪽만 고치면
/// 어긋날 위험이 있었다.
({Color color, String icon, String label}) cornerStatusPresentation(
  api.CornerOperationalStatus? status,
  AppColors colors,
) => switch (status) {
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

/// §design-system.md 4.3의 캡슐형 상태 뱃지 — 배경은 상태색 12%(다크 20%) 틴트,
/// 텍스트/아이콘은 상태색 그대로.
class CornerStatusPill extends StatelessWidget {
  const CornerStatusPill({
    required this.color,
    required this.icon,
    required this.label,
    super.key,
  });

  final Color color;
  final String icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final opacity = Theme.of(context).brightness == Brightness.dark ? .20 : .12;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space2,
        vertical: AppSpacing.space1,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        '$icon  $label',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(color: color),
      ),
    );
  }
}
