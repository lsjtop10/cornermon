import 'dart:async';

import 'package:cornermon/admin/features/report/report_screen.dart';
import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/report_providers.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _SelectedCampId extends SelectedCampId {
  _SelectedCampId(this._id);
  final CampId? _id;

  @override
  CampId? build() => _id;
}

CampResponse _camp(CampResponseStatusEnum status, String id) => CampResponse(
  (b) => b
    ..id = id
    ..name = '테스트 캠프'
    ..status = status,
);

UnvisitedGroupResponse _unvisited(String groupId, String groupName) =>
    UnvisitedGroupResponse(
      (b) => b
        ..groupId = groupId
        ..groupName = groupName,
    );

CampReportResponse _report() => CampReportResponse(
  (b) => b
    ..campId = 'camp-1'
    ..summary.replace(
      CampSummaryStatsResponse(
        (s) => s
          ..totalGroups = 2
          ..finishedGroupCount = 1
          ..completionRate = 50
          ..avgDeviationSeconds = 90
          ..manualVisitRatio = 20
          ..bottleneckRanking.replace([
            BottleneckRankingResponse(
              (r) => r
                ..cornerId = 'c-a'
                ..cornerName = '코너 A'
                ..avgDeviationSeconds = 150,
            ),
            BottleneckRankingResponse(
              (r) => r
                ..cornerId = 'c-b'
                ..cornerName = '코너 B'
                ..avgDeviationSeconds = -30,
            ),
            BottleneckRankingResponse(
              (r) => r
                ..cornerId = 'c-x'
                ..cornerName = '코너 X'
                ..avgDeviationSeconds = 500,
            ),
            BottleneckRankingResponse(
              (r) => r
                ..cornerId = 'c-y'
                ..cornerName = '코너 Y'
                ..avgDeviationSeconds = 400,
            ),
          ]),
      ),
    )
    ..cornerStats.replace([
      CornerStatsResponse(
        (c) => c
          ..cornerId = 'c-a'
          ..cornerName = '코너 A'
          ..completedVisitCount = 5
          ..avgDurationSeconds = 720
          ..avgDeviationSeconds = 120
          ..overDeviationRatio = 0.4
          ..unvisitedGroups.replace([_unvisited('g2', '2조')]),
      ),
      CornerStatsResponse(
        (c) => c
          ..cornerId = 'c-b'
          ..cornerName = '코너 B'
          ..completedVisitCount = 2,
          ..avgDurationSeconds = 1170
          ..avgDeviationSeconds = -30,
      ),
    ])
    ..groupStats.replace([
      GroupStatsResponse(
        (g) => g
          ..groupId = 'g1'
          ..groupName = '1조'
          ..completedCount = 2
          ..totalDurationSeconds = 3600,
      ),
      GroupStatsResponse(
        (g) => g
          ..groupId = 'g2'
          ..groupName = '2조'
          ..completedCount = 1
          ..totalDurationSeconds = 1800,
      ),
    ]),
);

Future<void> _pump(
  WidgetTester tester, {
  required CampId campId,
  required CampResponseStatusEnum campStatus,
  FutureOr<CampReportResponse> Function(Ref ref)? currentReport,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        selectedCampIdProvider.overrideWith(() => _SelectedCampId(campId)),
        selectedCampProvider.overrideWith(
          (ref) async => _camp(campStatus, campId.value),
        ),
        if (currentReport != null)
          currentReportProvider(campId).overrideWith(currentReport),
      ],
      child: const MaterialApp(home: ReportScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'ShoudNotCallCurrentReportAndShowEmptyStateWhenCampIsActive',
    (tester) async {
      // arrange
      var calls = 0;
      final campId = CampId('camp-1');

      // act
      await _pump(
        tester,
        campId: campId,
        campStatus: CampResponseStatusEnum.ACTIVE,
        currentReport: (ref) async {
          calls++;
          return _report();
        },
      );

      // assert
      expect(calls, 0);
      expect(find.text('코너학습 종료 후 이용 가능'), findsOneWidget);
      expect(find.text('요약'), findsNothing);
    },
  );

  testWidgets(
    'ShoudCallCurrentReportOnceAndRenderThreeTabsWhenCampIsEnded',
    (tester) async {
      // arrange
      var calls = 0;
      final campId = CampId('camp-1');

      // act
      await _pump(
        tester,
        campId: campId,
        campStatus: CampResponseStatusEnum.ENDED,
        currentReport: (ref) async {
          calls++;
          return _report();
        },
      );

      // assert
      expect(calls, 1);
      expect(find.text('요약'), findsOneWidget);
      expect(find.text('코너별'), findsOneWidget);
      expect(find.text('조별'), findsOneWidget);
      // 요약 탭이 기본으로 보인다.
      expect(find.text('완주율'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
    },
  );

  testWidgets(
    'ShoudFallBackToEmptyStateWithoutErrorSnackbarWhenCurrentReportThrows',
    (tester) async {
      // arrange
      final campId = CampId('camp-1');

      // act
      await _pump(
        tester,
        campId: campId,
        campStatus: CampResponseStatusEnum.ENDED,
        currentReport: (ref) async => throw Exception('404'),
      );

      // assert
      expect(find.text('코너학습 종료 후 이용 가능'), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
    },
  );

  testWidgets(
    'ShoudShowTop3BottleneckCornersSortedDescendingWhenSummaryTabIsShown',
    (tester) async {
      // arrange
      final campId = CampId('camp-1');

      // act
      await _pump(
        tester,
        campId: campId,
        campStatus: CampResponseStatusEnum.ENDED,
        currentReport: (ref) async => _report(),
      );

      // assert — 상위 3개(500, 400, 150)만 보이고 4번째(-30)는 보이지 않는다.
      expect(find.text('코너 X'), findsOneWidget);
      expect(find.text('코너 Y'), findsOneWidget);
      expect(find.text('코너 A'), findsOneWidget);
      expect(find.text('코너 B'), findsNothing);
    },
  );

  testWidgets(
    'ShoudRenderRealOverDeviationRatioAndDashWhenValueIsNullOnCornerTab',
    (tester) async {
      // arrange
      final campId = CampId('camp-1');
      await _pump(
        tester,
        campId: campId,
        campStatus: CampResponseStatusEnum.ENDED,
        currentReport: (ref) async => _report(),
      );

      // act — 코너별 탭으로 전환.
      await tester.tap(find.text('코너별'));
      await tester.pumpAndSettle();

      // assert — c-a는 overDeviationRatio=0.4 → "40%", c-b는 null → "-".
      expect(find.text('40%'), findsOneWidget);
      expect(find.text('-'), findsOneWidget);
      // bottleneckRanking과 무관하게 코너 통계의 정식 평균값을 렌더링한다.
      expect(find.text('12:00 (+2:00)'), findsOneWidget);
    },
  );

  testWidgets(
    'ShoudShowFinishedBadgeAndUnvisitedCornerNamesOnGroupTab',
    (tester) async {
      // arrange
      final campId = CampId('camp-1');
      await _pump(
        tester,
        campId: campId,
        campStatus: CampResponseStatusEnum.ENDED,
        currentReport: (ref) async => _report(),
      );

      // act — 조별 탭으로 전환.
      await tester.tap(find.text('조별'));
      await tester.pumpAndSettle();

      // assert — g1(completedCount 2 == cornerStats.length 2)은 완주, g2는 미완주 + 미완료 코너 목록.
      expect(find.text('완주'), findsOneWidget);
      expect(find.text('미완주'), findsOneWidget);
      expect(find.text('코너 A'), findsOneWidget);
    },
  );
}
