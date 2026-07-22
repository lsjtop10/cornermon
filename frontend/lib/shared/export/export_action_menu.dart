import 'package:cornermon/shared/design_system/widgets/app_button.dart';
import 'package:flutter/material.dart';

enum ExportAction { saveToDevice, shareWithApp }

/// 내보내기 방식을 명시적으로 선택하게 하는 공통 UI.
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
  Widget build(BuildContext context) => AppButton(
    variant: AppButtonVariant.secondary,
    size: AppButtonSize.compact,
    icon: icon,
    label: label,
    onPressed: busy
        ? null
        : () async {
            final action = await showExportActionMenu(context);
            if (action != null) onSelected(action);
          },
  );
}

Future<ExportAction?> showExportActionMenu(BuildContext context) =>
    showModalBottomSheet<ExportAction>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.save_alt_outlined),
              title: const Text('기기에 저장'),
              subtitle: const Text('저장 위치를 선택합니다'),
              onTap: () =>
                  Navigator.pop(sheetContext, ExportAction.saveToDevice),
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('다른 앱으로 공유'),
              subtitle: const Text('시스템 공유 시트를 엽니다'),
              onTap: () =>
                  Navigator.pop(sheetContext, ExportAction.shareWithApp),
            ),
          ],
        ),
      ),
    );
