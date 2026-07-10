import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/typography.dart';

class AdminTheme {
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
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.bgSurface,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: colors.border),
          borderRadius: BorderRadius.circular(8.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colors.border),
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colors.brandPrimary, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }
}
