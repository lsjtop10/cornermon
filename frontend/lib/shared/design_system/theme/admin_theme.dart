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
      brightness: colors == AppColors.light
          ? Brightness.light
          : Brightness.dark,
      scaffoldBackgroundColor: colors.bgCanvas,
      colorScheme: ColorScheme(
        brightness: colors == AppColors.light
            ? Brightness.light
            : Brightness.dark,
        primary: colors.brandPrimary,
        onPrimary: colors.bgSurface,
        secondary: colors.textSecondary,
        onSecondary: colors.bgSurface,
        error: colors.danger,
        onError: colors.bgSurface,
        surface: colors.bgSurface,
        onSurface: colors.textPrimary,
      ),
      dividerTheme: DividerThemeData(color: colors.border, thickness: 1.0),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(44, 44),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          disabledBackgroundColor: colors.bgSurface,
          disabledForegroundColor: colors.textDisabled,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.textPrimary,
          side: BorderSide(color: colors.border),
          minimumSize: const Size(44, 44),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          disabledForegroundColor: colors.textDisabled,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(44, 44),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.textPrimary,
          minimumSize: const Size(44, 44),
          disabledForegroundColor: colors.textDisabled,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colors.bgSurface,
        selectedLabelTextStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ).copyWith(color: colors.brandPrimary),
        unselectedLabelTextStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ).copyWith(color: colors.textSecondary),
        selectedIconTheme: IconThemeData(color: colors.brandPrimary, size: 20),
        unselectedIconTheme: IconThemeData(
          color: colors.textSecondary,
          size: 20,
        ),
        indicatorColor: colors.brandPrimary.withValues(alpha: .12),
      ),
      cardTheme: CardThemeData(
        color: colors.bgSurface,
        elevation: colors == AppColors.light ? 1 : 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colors.border),
        ),
      ),
      dataTableTheme: DataTableThemeData(
        headingTextStyle: AppTypography.label.copyWith(
          color: colors.textDisabled,
        ),
        dataTextStyle: AppTypography.body.copyWith(color: colors.textPrimary),
        dividerThickness: 1,
        headingRowColor: WidgetStatePropertyAll(colors.bgSurface),
        dataRowMinHeight: 48,
        dataRowMaxHeight: 48,
        horizontalMargin: 16,
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.display.copyWith(color: colors.textPrimary),
        titleLarge: AppTypography.title1.copyWith(color: colors.textPrimary),
        titleMedium: AppTypography.title2.copyWith(color: colors.textPrimary),
        titleSmall: AppTypography.title3.copyWith(color: colors.textPrimary),
        bodyLarge: AppTypography.body.copyWith(color: colors.textPrimary),
        bodyMedium: AppTypography.bodyEmphasis.copyWith(
          color: colors.textPrimary,
        ),
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
      dialogTheme: DialogThemeData(
        backgroundColor: colors.bgSurfaceRaised,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
