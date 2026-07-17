import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/typography.dart';
import 'app_button.dart';

enum ConfirmModalKind { hardBlock, softConfirm, singleAckOnly }

Future<bool> showConfirmModal(
  BuildContext context, {
  required ConfirmModalKind kind,
  required String title,
  String? body,
  AppButtonSize buttonSize = AppButtonSize.compact,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible:
        kind != ConfirmModalKind.hardBlock, // 하드 블록은 바깥 탭으로 닫기 불가능
    builder: (BuildContext context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final colors = isDark ? AppColors.dark : AppColors.light;

      IconData icon;
      Color iconColor;
      List<Widget> actions = [];

      switch (kind) {
        case ConfirmModalKind.hardBlock:
          icon = Icons.error_outline;
          iconColor = colors.danger;
          actions = [
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                '확인',
                style: AppTypography.bodyEmphasis.copyWith(
                  color: colors.brandPrimary,
                ),
              ),
            ),
          ];
          break;
        case ConfirmModalKind.softConfirm:
          icon = Icons.warning_amber_rounded;
          iconColor = colors.warning;
          actions = [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                '취소',
                style: AppTypography.body.copyWith(color: colors.textSecondary),
              ),
            ),
            AppButton(
              variant: AppButtonVariant.destructive,
              size: buttonSize,
              label: '진행',
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ];
          break;
        case ConfirmModalKind.singleAckOnly:
          icon = Icons.info_outline;
          iconColor = colors.info;
          actions = [
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                '확인',
                style: AppTypography.bodyEmphasis.copyWith(
                  color: colors.brandPrimary,
                ),
              ),
            ),
          ];
          break;
      }

      return AlertDialog(
        backgroundColor: colors.bgSurfaceRaised,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        title: Row(
          children: [
            Icon(icon, color: iconColor, size: 28.0),
            const SizedBox(width: 12.0),
            Expanded(
              child: Text(
                title,
                style: AppTypography.title3.copyWith(color: colors.textPrimary),
              ),
            ),
          ],
        ),
        content: body != null
            ? Text(
                body,
                style: AppTypography.body.copyWith(color: colors.textSecondary),
              )
            : null,
        actions: actions,
      );
    },
  );

  return result ?? (kind == ConfirmModalKind.softConfirm ? false : true);
}
