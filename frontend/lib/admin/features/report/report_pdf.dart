import 'dart:typed_data';

import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/util/duration_format.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// `CampReport`를 받아 3개 섹션(요약/코너별/조별)을 담은 PDF 바이트를 만드는 순수 함수.
/// `badge_sticker_pdf.dart`(`buildBadgeStickerPdf`)와 동일한 관례 — 공유 다이얼로그 호출은
/// 호출부(`ReportExportController`) 책임이고 이 함수는 바이트 생성만 한다.
/// `Printing.layoutPdf`는 쓰지 않는다(iPad에서 직접 인쇄하지 않는다는 결정, 04 §3.4와 동일).
Future<Uint8List> buildReportPdf(api.CampReport report) async {
  final document = pw.Document();
  final summary = report.summary;
  final cornerStats = report.cornerStats ?? const <api.CornerStats>[];
  final groupStats = report.groupStats ?? const <api.GroupStats>[];

  document.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (_) => [
        pw.Header(level: 0, text: '캠프 리포트'),
        if (summary != null) ...[
          pw.Text('완주율: ${(summary.completionRate ?? 0).round()}%'),
          pw.Text(
            '평균편차: ${formatSignedMmSs(summary.avgDeviationSeconds ?? 0)}',
          ),
          pw.Text('수동 처리 비율: ${(summary.manualVisitRatio ?? 0).round()}%'),
        ],
        pw.SizedBox(height: 16),
        pw.Header(level: 1, text: '코너별'),
        pw.TableHelper.fromTextArray(
          headers: const ['코너', '완료 조 수', '편차>0 비율'],
          data: [
            for (final corner in cornerStats)
              [
                corner.cornerName ?? '코너',
                '${corner.completedVisitCount ?? 0}',
                corner.overDeviationRatio == null
                    ? '-'
                    : '${(corner.overDeviationRatio! * 100).round()}%',
              ],
          ],
        ),
        pw.SizedBox(height: 16),
        pw.Header(level: 1, text: '조별'),
        pw.TableHelper.fromTextArray(
          headers: const ['조', '완료 코너 수', '총 활동시간'],
          data: [
            for (final group in groupStats)
              [
                group.groupName ?? '조',
                '${group.completedCount ?? 0}',
                formatMmSs(group.totalDurationSeconds ?? 0),
              ],
          ],
        ),
      ],
    ),
  );
  return document.save();
}
