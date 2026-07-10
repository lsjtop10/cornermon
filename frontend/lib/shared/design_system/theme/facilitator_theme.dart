import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/typography.dart';

class FacilitatorTheme {
  static ThemeData get lightTheme {
    return _buildTheme(AppColors.light);
  }

  static ThemeData get darkTheme {
    return _buildTheme(AppColors.dark);
  }

  static ThemeData _buildTheme(AppColors colors) {
    return ThemeData(
      useMaterial3: true,
      brightness: colors == AppColors.light ? Brightness.light : Brightness.dark,
      scaffoldBackgroundColor: colors.bgCanvas,
      colorScheme: ColorScheme(
        brightness: colors == AppColors.light ? Brightness.light : Brightness.dark,
        primary: colors.brandPrimary,
        onPrimary: colors.bgSurface,
        secondary: colors.textSecondary,
        onSecondary: colors.bgSurface,
        error: colors.danger,
        onError: colors.bgSurface,
        surface: colors.bgSurface,
        onSurface: colors.textPrimary,
      ),
      dividerTheme: DividerThemeData(
        color: colors.border,
        thickness: 1.0,
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.display.copyWith(color: colors.textPrimary),
        titleLarge: AppTypography.title1.copyWith(color: colors.textPrimary),
        titleMedium: AppTypography.title2.copyWith(color: colors.textPrimary),
        titleSmall: AppTypography.title3.copyWith(color: colors.textPrimary),
        bodyLarge: AppTypography.body.copyWith(color: colors.textPrimary),
        bodyMedium: AppTypography.bodyEmphasis.copyWith(color: colors.textPrimary),
        bodySmall: AppTypography.caption.copyWith(color: colors.textSecondary),
        labelLarge: AppTypography.label.copyWith(color: colors.textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(56.0), // 프라이머리 버튼 56dp 높이
          backgroundColor: colors.brandPrimary,
          foregroundColor: colors.bgSurface,
          elevation: 0.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16.0),
        ),
      ),
    );
  }
}
