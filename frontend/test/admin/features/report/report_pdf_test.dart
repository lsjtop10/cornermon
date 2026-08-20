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
        ])
        ..trackStats.replace([
          TrackStatsResponse(
            (t) => t
              ..trackId = 't-1'
              ..trackNo = 1
              ..handledVisitCount = 12
              ..avgDeviationSeconds = 90
              ..manualVisitRatio = 25,
          ),
        ])
        ..timeline.replace(
          TimelineStatsResponse(
            (tl) => tl.buckets.replace([
              TimelineBucketResponse(
                (bucket) => bucket
                  ..bucketStart = DateTime.utc(2026, 8, 19, 9)
                  ..inProgressCount = 3
                  ..cumulativeCompleted = 5,
              ),
            ]),
          ),
        )
        ..operationalStats.replace(
          OperationalStatsResponse(
            (o) => o
              ..pinLoginSuccessCount = 10
              ..pinLoginFailureCount = 2
              ..deviceRequestCount = 5
              ..deviceApprovedCount = 4
              ..deviceRejectedCount = 1
              ..deviceRevokedCount = 0
              ..adminOperationCounts.replace([
                AdminOperationCountResponse(
                  (a) => a
                    ..adminId = 'admin-1'
                    ..adminName = '관리자A'
                    ..count = 7,
                ),
              ])
              ..trackDirectMessageCounts.replace([
                TrackMessageCountResponse(
                  (t) => t
                    ..trackId = 'track-1'
                    ..trackLabel = '1번 트랙'
                    ..count = 3,
                ),
              ])
              ..announcementReadStats.replace([
                AnnouncementReadStatResponse(
                  (a) => a
                    ..announcementId = 'ann-1'
                    ..announcementContent = '공지 내용'
                    ..readCount = 8
                    ..totalRecipients = 10,
                ),
              ]),
          ),
        ),
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
