import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/typography.dart';

enum AppTagTone { neutral, success, warning }

class AppTag extends StatelessWidget {
  const AppTag({
    required this.label,
    this.tone = AppTagTone.neutral,
    super.key,
  });

  final String label;
  final AppTagTone tone;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;
    final color = switch (tone) {
      AppTagTone.neutral => colors.textSecondary,
      AppTagTone.success => colors.success,
      AppTagTone.warning => colors.warning,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? .20 : .12),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(label, style: AppTypography.label.copyWith(color: color)),
    );
  }
}
