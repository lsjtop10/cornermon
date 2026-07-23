import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/export/export_action_menu.dart';
import 'package:cornermon/shared/export/export_file.dart';
import 'report_export_controller.dart';

/// 탭 우측 고정 PDF 내보내기 버튼. `campId`는 `selectedCampIdProvider`를 다시 watch하지
/// 않고 `report.campId`를 그대로 쓴다(이미 응답 안에 있음, §0 확인됨).
class ReportExportButton extends ConsumerWidget {
  const ReportExportButton({required this.report, super.key});
  final api.CampReport report;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exportState = ref.watch(reportExportControllerProvider);
    final busy = exportState.isLoading;

    Future<void> onSelected(ExportAction action) async {
      final campId = CampId(report.campId ?? '');
      final controller = ref.read(reportExportControllerProvider.notifier);
      final saveResult = action == ExportAction.saveToDevice
          ? await controller.exportAndSave(campId)
          : null;
      if (action == ExportAction.shareWithApp) {
        await controller.exportAndShare(campId);
      }
      if (!context.mounted) return;
      final result = ref.read(reportExportControllerProvider);
      if (action == ExportAction.saveToDevice &&
          saveResult == ExportSaveResult.cancelled &&
          !result.hasError) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.hasError
                ? 'PDF 내보내기 실패: ${result.error}'
                : action == ExportAction.saveToDevice
                ? 'PDF를 저장했습니다'
                : 'PDF를 내보냈습니다',
          ),
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        ExportActionButton(
          icon: Icons.ios_share,
          label: 'PDF로 내보내기',
          busy: busy,
          onSelected: onSelected,
        ),
        if (busy)
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
      ],
    );
  }
}
