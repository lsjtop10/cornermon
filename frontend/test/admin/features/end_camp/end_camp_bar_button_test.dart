import 'dart:async';

import 'package:cornermon/admin/features/end_camp/end_camp_bar_button.dart';
import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/admin/widgets/admin_scaffold.dart';
import 'package:cornermon/admin/widgets/admin_scaffold_messenger_key.dart';
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/camp_providers.dart';
import 'package:cornermon/shared/api/providers/report_providers.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _SelectedCampId extends SelectedCampId {
  _SelectedCampId(this._id);
  final CampId? _id;

  @override
  CampId? build() => _id;
}

CampResponse _camp(CampResponseStatusEnum status) => CampResponse(
  (b) => b
    ..id = 'camp-1'
    ..name = '테스트 캠프'
    ..status = status,
);

CampSummaryStatsResponse _summary({
  required int finishedGroupCount,
  required int totalGroups,
}) => CampSummaryStatsResponse(
  (b) => b
    ..finishedGroupCount = finishedGroupCount
    ..totalGroups = totalGroups,
);

CampReportResponse _report() => CampReportResponse((b) => b..campId = 'camp-1');

void main() {
  final campId = CampId('camp-1');

  testWidgets('ShoudShowEndButtonWhenAdminScaffoldIsOperating', (tester) async {
    // arrange
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const AdminScaffold(body: Text('body')),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          selectedCampIdProvider.overrideWith(() => _SelectedCampId(campId)),
          selectedCampProvider.overrideWith(
            (ref) async => _camp(CampResponseStatusEnum.ACTIVE),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    // assert
    expect(find.text('코너학습 종료'), findsOneWidget);
  });

  testWidgets('ShoudHideEndButtonWhenAdminScaffoldIsPreparing', (tester) async {
    // arrange
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const AdminScaffold(body: Text('body')),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          selectedCampIdProvider.overrideWith(() => _SelectedCampId(campId)),
          selectedCampProvider.overrideWith(
            (ref) async => _camp(CampResponseStatusEnum.PENDING),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    // assert
    expect(find.text('코너학습 종료'), findsNothing);
  });

  testWidgets('ShoudHideEndButtonWhenAdminScaffoldIsReportOnly', (
    tester,
  ) async {
    // arrange
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const AdminScaffold(body: Text('body')),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          selectedCampIdProvider.overrideWith(() => _SelectedCampId(campId)),
          selectedCampProvider.overrideWith(
            (ref) async => _camp(CampResponseStatusEnum.ENDED),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    // assert
    expect(find.text('코너학습 종료'), findsNothing);
  });

  testWidgets('ShoudShowLiveSummaryWhenConfirmDialogOpened', (tester) async {
    // arrange
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          selectedCampIdProvider.overrideWith(() => _SelectedCampId(campId)),
          selectedCampProvider.overrideWith(
            (ref) async => _camp(CampResponseStatusEnum.ACTIVE),
          ),
          liveSummaryProvider(campId).overrideWith(
            (ref) async => _summary(finishedGroupCount: 4, totalGroups: 10),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: EndCampBarButton())),
      ),
    );
    await tester.pumpAndSettle();

    // act
    await tester.tap(find.text('코너학습 종료'));
    await tester.pumpAndSettle();

    // assert
    expect(find.text('코너학습을 종료할까요?'), findsOneWidget);
    expect(find.text('완주 4조 / 부분완주 6조'), findsOneWidget);
  });

  testWidgets('ShoudShowDialogAndNotEndCampWhenCancelTapped', (tester) async {
    // arrange
    var endCalls = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          selectedCampIdProvider.overrideWith(() => _SelectedCampId(campId)),
          selectedCampProvider.overrideWith(
            (ref) async => _camp(CampResponseStatusEnum.ACTIVE),
          ),
          liveSummaryProvider(campId).overrideWith(
            (ref) async => _summary(finishedGroupCount: 0, totalGroups: 0),
          ),
          endCampProvider(campId).overrideWith((ref) async {
            endCalls++;
            return _camp(CampResponseStatusEnum.ENDED);
          }),
        ],
        child: const MaterialApp(home: Scaffold(body: EndCampBarButton())),
      ),
    );
    await tester.pumpAndSettle();

    // act
    await tester.tap(find.text('코너학습 종료'));
    await tester.pumpAndSettle();
    expect(find.text('코너학습을 종료할까요?'), findsOneWidget);
    await tester.tap(find.text('취소'));
    await tester.pumpAndSettle();

    // assert
    expect(endCalls, 0);
    expect(find.text('코너학습을 종료할까요?'), findsNothing);
  });

  testWidgets('ShoudDisableDialogActionsWhenEndConfirmIsSubmitting', (
    tester,
  ) async {
    // arrange
    final completer = Completer<CampResponse>();
    var endCalls = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          selectedCampIdProvider.overrideWith(() => _SelectedCampId(campId)),
          selectedCampProvider.overrideWith(
            (ref) async => _camp(CampResponseStatusEnum.ACTIVE),
          ),
          liveSummaryProvider(campId).overrideWith(
            (ref) async => _summary(finishedGroupCount: 0, totalGroups: 0),
          ),
          endCampProvider(campId).overrideWith((ref) {
            endCalls++;
            return completer.future;
          }),
        ],
        child: const MaterialApp(home: Scaffold(body: EndCampBarButton())),
      ),
    );
    await tester.pumpAndSettle();

    // act
    await tester.tap(find.text('코너학습 종료'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('종료 선언'));
    await tester.pump();

    // assert
    expect(endCalls, 1);
    expect(find.text('종료 처리 중…'), findsOneWidget);
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, '취소'))
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widget<AppButton>(find.widgetWithText(AppButton, '종료 처리 중…'))
          .onPressed,
      isNull,
    );

    completer.complete(_camp(CampResponseStatusEnum.ENDED));
    await tester.pumpAndSettle();
  });

  testWidgets('ShoudKeepDialogOpenAndShowServerMessageWhenEndFails', (
    tester,
  ) async {
    // arrange
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          selectedCampIdProvider.overrideWith(() => _SelectedCampId(campId)),
          selectedCampProvider.overrideWith(
            (ref) async => _camp(CampResponseStatusEnum.ACTIVE),
          ),
          liveSummaryProvider(campId).overrideWith(
            (ref) async => _summary(finishedGroupCount: 0, totalGroups: 0),
          ),
          endCampProvider(
            campId,
          ).overrideWith((ref) async => throw Exception('이미 종료된 캠프')),
        ],
        child: const MaterialApp(home: Scaffold(body: EndCampBarButton())),
      ),
    );
    await tester.pumpAndSettle();

    // act
    await tester.tap(find.text('코너학습 종료'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('종료 선언'));
    for (var i = 0; i < 60; i++) {
      await tester.pump(const Duration(seconds: 1));
    }

    // assert
    expect(find.text('코너학습을 종료할까요?'), findsOneWidget);
    expect(find.textContaining('이미 종료된 캠프'), findsOneWidget);
  });

  testWidgets(
    'ShoudNavigateToCampsAndShowWarningSnackbarWhenReportGenerationFailsButEndSucceeds',
    (tester) async {
      // arrange
      final router = GoRouter(
        initialLocation: '/dashboard',
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (_, _) => const Scaffold(body: EndCampBarButton()),
          ),
          GoRoute(
            path: '/camps',
            builder: (_, _) => const Scaffold(body: Text('캠프 목록')),
          ),
        ],
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            selectedCampIdProvider.overrideWith(() => _SelectedCampId(campId)),
            selectedCampProvider.overrideWith(
              (ref) async => _camp(CampResponseStatusEnum.ACTIVE),
            ),
            liveSummaryProvider(campId).overrideWith(
              (ref) async => _summary(finishedGroupCount: 2, totalGroups: 5),
            ),
            endCampProvider(
              campId,
            ).overrideWith((ref) async => _camp(CampResponseStatusEnum.ENDED)),
            generateReportProvider(
              campId,
            ).overrideWith((ref) async => throw Exception('리포트 생성 실패')),
          ],
          child: MaterialApp.router(
            scaffoldMessengerKey: adminScaffoldMessengerKey,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // act
      await tester.tap(find.text('코너학습 종료'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('종료 선언'));
      await tester.pumpAndSettle();

      // assert
      expect(find.text('캠프 목록'), findsOneWidget);
      expect(find.textContaining('리포트 자동 생성에 실패했습니다'), findsOneWidget);
    },
  );

  testWidgets(
    'ShoudNavigateToCampsWithoutSnackbarWhenEndAndReportBothSucceed',
    (tester) async {
      // arrange
      final router = GoRouter(
        initialLocation: '/dashboard',
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (_, _) => const Scaffold(body: EndCampBarButton()),
          ),
          GoRoute(
            path: '/camps',
            builder: (_, _) => const Scaffold(body: Text('캠프 목록')),
          ),
        ],
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            selectedCampIdProvider.overrideWith(() => _SelectedCampId(campId)),
            selectedCampProvider.overrideWith(
              (ref) async => _camp(CampResponseStatusEnum.ACTIVE),
            ),
            liveSummaryProvider(campId).overrideWith(
              (ref) async => _summary(finishedGroupCount: 5, totalGroups: 5),
            ),
            endCampProvider(
              campId,
            ).overrideWith((ref) async => _camp(CampResponseStatusEnum.ENDED)),
            generateReportProvider(
              campId,
            ).overrideWith((ref) async => _report()),
          ],
          child: MaterialApp.router(
            scaffoldMessengerKey: adminScaffoldMessengerKey,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // act
      await tester.tap(find.text('코너학습 종료'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('종료 선언'));
      await tester.pumpAndSettle();

      // assert
      expect(find.text('캠프 목록'), findsOneWidget);
      expect(find.textContaining('리포트 자동 생성에 실패했습니다'), findsNothing);
    },
  );
}
