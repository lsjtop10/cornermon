import 'package:cornermon/admin/features/report/widgets/operational_stats_section.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'ShoudRenderCountCardsAndSkipEmptyListSubsectionsWhenListsAreEmpty',
    (tester) async {
      // arrange
      final widget = OperationalStatsSection(
        stats: OperationalStatsResponse(
          (b) => b
            ..pinLoginSuccessCount = 10
            ..pinLoginFailureCount = 2
            ..deviceRequestCount = 5
            ..deviceApprovedCount = 4
            ..deviceRejectedCount = 1
            ..deviceRevokedCount = 0,
        ),
      );

      // act
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

      // assert
      expect(find.text('10 / 2'), findsOneWidget);
      expect(find.text('4 / 1'), findsOneWidget);
      expect(find.text('관리자별 조작 횟수'), findsNothing);
      expect(find.text('트랙별 다이렉트 메시지 발신 횟수'), findsNothing);
      expect(find.text('공지별 읽음 도달률'), findsNothing);
    },
  );

  testWidgets(
    'ShoudRenderSubsectionRowsWhenListsAreNonEmpty',
    (tester) async {
      // arrange
      final widget = OperationalStatsSection(
        stats: OperationalStatsResponse(
          (b) => b
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
      );

      // act
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

      // assert
      expect(find.text('관리자A'), findsOneWidget);
      expect(find.text('7건'), findsOneWidget);
      expect(find.text('1번 트랙'), findsOneWidget);
      expect(find.text('3건'), findsOneWidget);
      expect(find.text('공지 내용'), findsOneWidget);
      expect(find.text('8/10'), findsOneWidget);
    },
  );

  testWidgets(
    'ShoudNotShowExceptionApprovalCountAnywhereOnScreen',
    (tester) async {
      // arrange — exceptionApprovalCount는 OperationalStatsResponse에 아예 없는 필드다
      // (CampSummaryStatsResponse 소속). 이 섹션이 그 필드를 참조/노출하지 않는지 문구로 확인.
      final widget = OperationalStatsSection(stats: OperationalStatsResponse((b) => b));

      // act
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

      // assert
      expect(find.textContaining('예외'), findsNothing);
    },
  );
}
