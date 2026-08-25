import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:material_ui/material_ui.dart';

class CornerGridSkeleton extends StatelessWidget {
  const CornerGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.dark
        ? AppColors.dark
        : AppColors.light;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 260,
        mainAxisExtent: 242, // 로딩 완료 후 카드 그리드와 동일 높이(레이아웃 점프 방지)
        crossAxisSpacing: AppSpacing.space3,
        mainAxisSpacing: AppSpacing.space3,
      ),
      itemCount: 10,
      itemBuilder: (context, index) => Container(
        decoration: BoxDecoration(
          color: colors.textDisabled.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
