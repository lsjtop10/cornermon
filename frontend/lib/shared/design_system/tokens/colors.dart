import 'package:flutter/material.dart';

class AppColors {
  const AppColors({
    required this.bgCanvas,
    required this.bgSurface,
    required this.bgSurfaceRaised,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.brandPrimary,
    required this.brandPrimaryPressed,
    required this.statusIdle,
    required this.statusBusy,
    required this.statusAlert,
    required this.statusInactive,
    required this.quiet,
    required this.success,
    required this.warning,
    required this.danger,
    required this.info,
  });

  final Color bgCanvas;
  final Color bgSurface;
  final Color bgSurfaceRaised;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textDisabled;
  final Color brandPrimary;
  final Color brandPrimaryPressed;
  final Color statusIdle;
  final Color statusBusy;
  final Color statusAlert;
  final Color statusInactive;
  final Color quiet;
  final Color success;
  final Color warning;
  final Color danger;
  final Color info;

  static const light = AppColors(
    bgCanvas: Color(0xFFF5F6F8),
    bgSurface: Color(0xFFFFFFFF),
    bgSurfaceRaised: Color(0xFFFFFFFF),
    border: Color(0xFFE2E5EA),
    textPrimary: Color(0xFF14171C),
    textSecondary: Color(0xFF5B6370),
    textDisabled: Color(0xFFA6ADB8),
    brandPrimary: Color(0xFF2F6FED),
    brandPrimaryPressed: Color(0xFF1F53C2),
    statusIdle: Color(0xFF12A150),
    statusBusy: Color(0xFFE5A100),
    statusAlert: Color(0xFFD64545),
    statusInactive: Color(0xFF8A94A6),
    quiet: Color(0xFF23262B),
    success: Color(0xFF12A150),
    warning: Color(0xFFE5A100),
    danger: Color(0xFFD64545),
    info: Color(0xFF2F6FED),
  );

  static const dark = AppColors(
    bgCanvas: Color(0xFF0F1115),
    bgSurface: Color(0xFF1A1D23),
    bgSurfaceRaised: Color(0xFF22262E),
    border: Color(0xFF2E333D),
    textPrimary: Color(0xFFF2F3F5),
    textSecondary: Color(0xFF9AA2AF),
    textDisabled: Color(0xFF5C636E),
    brandPrimary: Color(0xFF5B8DF6),
    brandPrimaryPressed: Color(0xFF84A7F8),
    statusIdle: Color(0xFF3DD68C),
    statusBusy: Color(0xFFF2C14E),
    statusAlert: Color(0xFFF17070),
    statusInactive: Color(0xFF6B7280),
    quiet: Color(0xFF7A8290),
    success: Color(0xFF3DD68C),
    warning: Color(0xFFF2C14E),
    danger: Color(0xFFF17070),
    info: Color(0xFF5B8DF6),
  );
}
