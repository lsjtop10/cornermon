import 'package:cornermon/shared/design_system/widgets/app_button.dart';
import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:flutter/material.dart';

enum ExportAction { saveToDevice, shareWithApp }

/// 내보내기 방식을 명시적으로 선택하게 하는 공통 UI.
///
/// 선택 메뉴는 트리거 바로 아래에 표시한다. 이후 시스템 저장 선택기와 공유
/// 시트는 각 플랫폼이 정한 위치에 표시되지만, 앱 안의 첫 선택은 항상 버튼
/// 근처에서 시작하게 한다.
class ExportActionButton extends StatelessWidget {
  const ExportActionButton({
    required this.label,
    required this.icon,
    required this.onSelected,
    this.busy = false,
    super.key,
  });

  final String label;
  final IconData icon;
  final ValueChanged<ExportAction> onSelected;
  final bool busy;

  @override
  Widget build(BuildContext context) => Builder(
    builder: (buttonContext) => AppButton(
      variant: AppButtonVariant.secondary,
      size: AppButtonSize.compact,
      icon: icon,
      label: label,
      onPressed: busy
          ? null
          : () async {
              final action = await showExportActionMenu(buttonContext);
              if (action != null) onSelected(action);
            },
    ),
  );
}

/// [context]의 render box를 기준으로 메뉴를 열어 앱 내 선택 동선을 고정한다.
Future<ExportAction?> showExportActionMenu(BuildContext context) {
  final anchor = context.findRenderObject()! as RenderBox;
  final overlay =
      Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final colors = isDark ? AppColors.dark : AppColors.light;
  final anchorRect = Rect.fromPoints(
    anchor.localToGlobal(Offset.zero, ancestor: overlay),
    anchor.localToGlobal(
      anchor.size.bottomRight(Offset.zero),
      ancestor: overlay,
    ),
  );

  return showMenu<ExportAction>(
    context: context,
    position: RelativeRect.fromRect(
      Rect.fromLTWH(anchorRect.left, anchorRect.bottom, anchorRect.width, 0),
      Offset.zero & overlay.size,
    ),
    color: colors.bgSurfaceRaised,
    surfaceTintColor: Colors.transparent,
    elevation: isDark ? 0 : 4,
    shadowColor: isDark
        ? Colors.transparent
        : Colors.black.withValues(alpha: .16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: colors.border),
    ),
    menuPadding: const EdgeInsets.symmetric(vertical: 4),
    constraints: const BoxConstraints.tightFor(width: 264),
    items: const [
      PopupMenuItem(
        value: ExportAction.saveToDevice,
        height: 68,
        padding: EdgeInsets.zero,
        child: _ExportActionMenuItem(
          icon: Icons.save_alt_outlined,
          title: '기기에 저장',
          subtitle: '저장 위치를 선택합니다',
        ),
      ),
      PopupMenuItem(
        value: ExportAction.shareWithApp,
        height: 68,
        padding: EdgeInsets.zero,
        child: _ExportActionMenuItem(
          icon: Icons.share_outlined,
          title: '다른 앱으로 공유',
          subtitle: '시스템 공유 시트를 엽니다',
        ),
      ),
    ],
  );
}

class _ExportActionMenuItem extends StatelessWidget {
  const _ExportActionMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyEmphasis.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.caption.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
