import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/typography.dart';
import 'app_button.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.message,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.actionButtonSize = AppButtonSize.compact,
    super.key,
  });

  final String message;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// actionLabel/onAction이 있을 때만 쓰인다. 현재 호출부가 모두 관리자 화면이라
  /// compact가 기본값 — 진행자 화면에서 쓰게 되면 comfortable을 명시적으로 넘긴다.
  final AppButtonSize actionButtonSize;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 64.0, color: colors.textDisabled),
              const SizedBox(height: 16.0),
            ],
            Text(
              message,
              style: AppTypography.body.copyWith(color: colors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24.0),
              AppButton(
                variant: AppButtonVariant.primary,
                size: actionButtonSize,
                label: actionLabel!,
                onPressed: onAction!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
