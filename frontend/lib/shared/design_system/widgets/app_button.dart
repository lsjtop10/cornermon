import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/dimensions.dart';

enum AppButtonVariant { primary, secondary, destructive, iconOnly }

/// 밀도 축 — 플랫폼이 아니라 컨트롤의 크기감을 나타낸다.
/// compact: 관리자(데스크톱/태블릿) 실측값. comfortable: 진행자(스마트폰) 실측값.
enum AppButtonSize { compact, comfortable }

/// hug: 글자 길이만큼(기본값) · fill: 부모 폭 100% · fixed: [AppButton.fixedWidth]로 고정.
enum AppButtonWidth { hug, fill, fixed }

class _ButtonMetrics {
  const _ButtonMetrics({
    required this.height,
    required this.radius,
    required this.textStyle,
    required this.paddingHorizontal,
    required this.iconSize,
    required this.iconGap,
    required this.iconSquare,
  });

  final double height;
  final double radius;
  final TextStyle textStyle;
  final double paddingHorizontal;
  final double iconSize;
  final double iconGap;
  final double iconSquare;

  static const compact = _ButtonMetrics(
    height: AppDimensions.controlHeightCompact,
    radius: AppDimensions.controlRadiusCompact,
    textStyle: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
    paddingHorizontal: 14.0,
    iconSize: 16.0,
    iconGap: 6.0,
    iconSquare: AppDimensions.iconButtonCompact,
  );

  static const comfortable = _ButtonMetrics(
    height: AppDimensions.controlHeightComfortable,
    radius: AppDimensions.controlRadiusComfortable,
    textStyle: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
    paddingHorizontal: 24.0,
    iconSize: 20.0,
    iconGap: 8.0,
    iconSquare: AppDimensions.iconButtonComfortable,
  );

  static _ButtonMetrics of(AppButtonSize size) => switch (size) {
    AppButtonSize.compact => compact,
    AppButtonSize.comfortable => comfortable,
  };
}

class AppButton extends StatelessWidget {
  const AppButton({
    required this.variant,
    required this.size,
    required this.label,
    required this.onPressed,
    this.width = AppButtonWidth.hug,
    this.fixedWidth,
    this.icon,
    this.disabledReason,
    super.key,
  }) : assert(
         width != AppButtonWidth.fixed || fixedWidth != null,
         'AppButtonWidth.fixed requires fixedWidth to be set.',
       );

  final AppButtonVariant variant;
  final AppButtonSize size;
  final AppButtonWidth width;
  final double? fixedWidth;
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final String? disabledReason;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;
    final metrics = _ButtonMetrics.of(size);

    if (variant == AppButtonVariant.iconOnly) {
      final button = SizedBox(
        width: metrics.iconSquare,
        height: metrics.iconSquare,
        child: IconButton(
          icon: Icon(
            icon,
            color: onPressed != null
                ? colors.brandPrimary
                : colors.textDisabled,
          ),
          onPressed: onPressed,
          style: IconButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(metrics.radius),
            ),
          ),
        ),
      );
      return _withDisabledReason(button);
    }

    Color bgColor;
    Color textColor;
    BorderSide borderSide = BorderSide.none;

    final isEnabled = onPressed != null;

    if (!isEnabled) {
      bgColor = Colors.transparent;
      textColor = colors.textDisabled;
      borderSide = BorderSide(color: colors.border);
    } else {
      switch (variant) {
        case AppButtonVariant.primary:
          bgColor = colors.brandPrimary;
          textColor = colors.bgSurface;
          break;
        case AppButtonVariant.secondary:
          bgColor = Colors.transparent;
          textColor = colors.textPrimary;
          borderSide = BorderSide(color: colors.border, width: 1.0);
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
          Icon(icon, size: metrics.iconSize, color: textColor),
          SizedBox(width: metrics.iconGap),
        ],
        Text(label, style: metrics.textStyle.copyWith(color: textColor)),
      ],
    );

    final button = SizedBox(
      height: metrics.height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: bgColor,
          side: borderSide,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(metrics.radius),
          ),
          padding: EdgeInsets.symmetric(horizontal: metrics.paddingHorizontal),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: buttonContent,
      ),
    );

    return _withDisabledReason(_applyWidth(button));
  }

  Widget _applyWidth(Widget button) {
    switch (width) {
      case AppButtonWidth.hug:
        return button;
      case AppButtonWidth.fill:
        return SizedBox(width: double.infinity, child: button);
      case AppButtonWidth.fixed:
        return SizedBox(width: fixedWidth, child: button);
    }
  }

  Widget _withDisabledReason(Widget button) {
    if (onPressed != null || disabledReason == null) return button;
    return Tooltip(message: disabledReason!, child: button);
  }
}
