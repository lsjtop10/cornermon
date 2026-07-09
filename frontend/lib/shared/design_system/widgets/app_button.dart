import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/typography.dart';

enum AppButtonVariant { primary, secondary, destructive, iconOnly }

class AppButton extends StatelessWidget {
  const AppButton({
    required this.variant,
    required this.label,
    required this.onPressed,
    this.icon,
    super.key,
  });

  final AppButtonVariant variant;
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;

    if (variant == AppButtonVariant.iconOnly) {
      return SizedBox(
        width: 48.0,
        height: 48.0,
        child: IconButton(
          icon: Icon(icon, color: onPressed != null ? colors.brandPrimary : colors.textDisabled),
          onPressed: onPressed,
          style: IconButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      );
    }

    Color bgColor;
    Color textColor;
    BorderSide borderSide = BorderSide.none;

    final isEnabled = onPressed != null;

    if (!isEnabled) {
      bgColor = isDark ? const Color(0xFF2E333D) : const Color(0xFFE2E5EA);
      textColor = colors.textDisabled;
    } else {
      switch (variant) {
        case AppButtonVariant.primary:
          bgColor = colors.brandPrimary;
          textColor = colors.bgSurface;
          break;
        case AppButtonVariant.secondary:
          bgColor = Colors.transparent;
          textColor = colors.brandPrimary;
          borderSide = BorderSide(color: colors.brandPrimary, width: 1.0);
          break;
        case AppButtonVariant.destructive:
          bgColor = colors.danger;
          textColor = colors.bgSurface;
          break;
        default:
          bgColor = colors.brandPrimary;
          textColor = colors.bgSurface;
      }
    }

    final buttonContent = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20.0, color: textColor),
          const SizedBox(width: 8.0),
        ],
        Text(
          label,
          style: AppTypography.bodyEmphasis.copyWith(color: textColor),
        ),
      ],
    );

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: bgColor,
        side: borderSide,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      ),
      child: buttonContent,
    );
  }
}
