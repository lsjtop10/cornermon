import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/report_providers.dart';
import 'package:cornermon/shared/export/export_file.dart';
import 'report_pdf.dart';

typedef SharePdf =
    Future<bool> Function({required Uint8List bytes, required String filename});

/// `badge_controllers.dart`의 `badgePdfShareProvider`와 동일한 관례 — 테스트에서
/// `Printing.sharePdf`를 mock으로 override할 수 있게 provider로 감싼다.
final reportPdfShareProvider = Provider<SharePdf>((ref) => Printing.sharePdf);

final reportExportControllerProvider =
    AsyncNotifierProvider<ReportExportController, void>(
      ReportExportController.new,
    );

class ReportExportController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {} // idle

  /// `exportReport(campId)` → `api.CampReport` → `buildReportPdf()` → `Printing.sharePdf`.
  /// 명세대로 `exportReport` 엔드포인트를 호출한다(화면에 이미 로드된 report를 재사용하지
  /// 않음 — 10_a12_report.md §2.9 참고, 두 응답이 다를 경우의 리스크를 피하기 위함).
  Future<void> exportAndShare(CampId campId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final report = await ref.read(exportReportProvider(campId).future);
      final bytes = await buildReportPdf(report);
      await ref.read(reportPdfShareProvider)(
        bytes: bytes,
        filename:
            'cornermon-report-${campId.value}-${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
    });
  }

  /// PDF를 생성한 뒤 사용자가 선택한 기기 위치에 저장한다.
  Future<ExportSaveResult?> exportAndSave(CampId campId) async {
    state = const AsyncLoading();
    ExportSaveResult? result;
    state = await AsyncValue.guard(() async {
      final report = await ref.read(exportReportProvider(campId).future);
      final bytes = await buildReportPdf(report);
      result = await ref.read(saveExportFileProvider)(
        ExportFile.pdf(
          name:
              'cornermon-report-${campId.value}-${DateTime.now().millisecondsSinceEpoch}',
          bytes: bytes,
        ),
      );
    });
    return result;
  }
}
