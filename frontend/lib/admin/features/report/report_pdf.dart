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
  final trackStats = report.trackStats?.toList() ?? const <api.TrackStats>[];
  final timelineBuckets = report.timeline?.buckets?.toList() ?? const <api.TimelineBucket>[];
  final operational = report.operationalStats;
  final adminOps =
      operational?.adminOperationCounts?.toList() ?? const <api.AdminOperationCount>[];
  final trackMessages =
      operational?.trackDirectMessageCounts?.toList() ?? const <api.TrackMessageCount>[];
  final announcementReads =
      operational?.announcementReadStats?.toList() ?? const <api.AnnouncementReadStat>[];

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
        pw.SizedBox(height: 16),
        pw.Header(level: 1, text: '트랙별'),
        pw.TableHelper.fromTextArray(
          headers: const ['트랙', '처리 건수', '평균편차', '수동 처리 비율'],
          data: [
            for (final track in trackStats)
              [
                track.trackNo == null ? '트랙' : '${track.trackNo}번 트랙',
                '${track.handledVisitCount ?? 0}',
                formatSignedMmSs(track.avgDeviationSeconds ?? 0),
                '${(track.manualVisitRatio ?? 0).round()}%',
              ],
          ],
        ),
        pw.SizedBox(height: 16),
        // fl_chart는 위젯 렌더링 전용이라 pdf 패키지 문서에는 쓸 수 없다 — 버킷별 표로 대체
        // (analytics-model.md §1.5, 화면의 TimelineSection과 데이터 소스는 동일).
        pw.Header(level: 1, text: '시간대별 처리량 추이'),
        pw.TableHelper.fromTextArray(
          headers: const ['시각', '진행중 방문 수', '누적 완료 방문 수'],
          data: [
            for (final bucket in timelineBuckets)
              [
                _formatHhMm(bucket.bucketStart),
                '${bucket.inProgressCount ?? 0}',
                '${bucket.cumulativeCompleted ?? 0}',
              ],
          ],
        ),
        pw.SizedBox(height: 16),
        pw.Header(level: 1, text: '운영/보안 지표'),
        // exceptionApprovalCount는 기능 삭제로 항상 0이 오는 필드라 화면과 동일하게 PDF에도
        // 노출하지 않는다(§0, 사용자 결정).
        pw.Text(
          'PIN 로그인 성공/실패: ${operational?.pinLoginSuccessCount ?? 0} / '
          '${operational?.pinLoginFailureCount ?? 0}',
        ),
        pw.Text(
          '기기 등록 요청/승인/거절/회수: ${operational?.deviceRequestCount ?? 0} / '
          '${operational?.deviceApprovedCount ?? 0} / '
          '${operational?.deviceRejectedCount ?? 0} / '
          '${operational?.deviceRevokedCount ?? 0}',
        ),
        if (adminOps.isNotEmpty) ...[
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headers: const ['관리자', '조작 횟수'],
            data: [
              for (final op in adminOps) [op.adminName ?? '관리자', '${op.count ?? 0}건'],
            ],
          ),
        ],
        if (trackMessages.isNotEmpty) ...[
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headers: const ['트랙', '다이렉트 메시지 발신 횟수'],
            data: [
              for (final msg in trackMessages)
                [msg.trackLabel ?? '트랙', '${msg.count ?? 0}건'],
            ],
          ),
        ],
        if (announcementReads.isNotEmpty) ...[
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headers: const ['공지', '읽음/전체'],
            data: [
              for (final read in announcementReads)
                [
                  read.announcementContent ?? '공지',
                  '${read.readCount ?? 0}/${read.totalRecipients ?? 0}',
                ],
            ],
          ),
        ],
      ],
    ),
  );
  return document.save();
}

String _formatHhMm(DateTime? utc) {
  if (utc == null) return '-';
  final local = utc.toLocal();
  return '${local.hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')}';
}
