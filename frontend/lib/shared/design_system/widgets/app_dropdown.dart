import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/typography.dart';

/// 툴바에 얹는 정렬/필터용 드롭다운 — design-system.md §4.5-b "드롭다운 정렬"
/// 규칙을 따르는 공용 컴포넌트. 화면마다 제각각 스타일 없는 [DropdownButton]을
/// 직접 쓰지 않고 이 컴포넌트로 통일한다.
class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
    super.key,
  });

  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(8),
        color: colors.bgSurface,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          hint: hint == null
              ? null
              : Text(
                  hint!,
                  style: AppTypography.body.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
          isDense: true,
          style: AppTypography.body.copyWith(color: colors.textPrimary),
          icon: Icon(Icons.expand_more, size: 18, color: colors.textSecondary),
          dropdownColor: colors.bgSurfaceRaised,
        ),
      ),
    );
  }
}
