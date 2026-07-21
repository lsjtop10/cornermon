import 'package:cornermon/admin/features/report/report_pdf.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ShoudCreatePdfBytesWhenReportIsProvided', () async {
    // arrange
    final report = CampReportResponse(
      (b) => b
        ..campId = 'camp-1'
        ..summary.replace(
          CampSummaryStatsResponse(
            (s) => s
              ..completionRate = 50
              ..avgDeviationSeconds = 90
              ..manualVisitRatio = 10,
          ),
        )
        ..cornerStats.replace([
          CornerStatsResponse(
            (c) => c
              ..cornerId = 'c-1'
              ..cornerName = '코너 1'
              ..completedVisitCount = 5
              ..overDeviationRatio = 0.4,
          ),
        ])
        ..groupStats.replace([
          GroupStatsResponse(
            (g) => g
              ..groupId = 'g-1'
              ..groupName = '1조'
              ..completedCount = 3
              ..totalDurationSeconds = 5400,
          ),
        ]),
    );

    // act
    final bytes = await buildReportPdf(report);

    // assert
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  });

  test('ShoudCreatePdfBytesWhenSummaryAndStatsAreEmpty', () async {
    // arrange
    final report = CampReportResponse((b) => b..campId = 'camp-1');

    // act
    final bytes = await buildReportPdf(report);

    // assert
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  });
}
