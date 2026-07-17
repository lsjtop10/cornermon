import 'dart:async';

import 'package:cornermon/admin/features/start_camp/start_camp_button.dart';
import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/admin/widgets/admin_scaffold.dart';
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/camp_providers.dart';
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

void main() {
  testWidgets('ShoudHideStartButtonWhenAdminScaffoldIsOperating', (
    tester,
  ) async {
    // arrange
    final campId = CampId('camp-1');
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
    expect(find.text('코너학습 시작'), findsNothing);
  });

  testWidgets('ShoudShowDialogAndNotStartCampWhenCancelTapped', (tester) async {
    // arrange
    final campId = CampId('camp-1');
    var calls = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          selectedCampIdProvider.overrideWith(() => _SelectedCampId(campId)),
          startCampProvider(campId).overrideWith((ref) async {
            calls++;
            return _camp(CampResponseStatusEnum.ACTIVE);
          }),
        ],
        child: const MaterialApp(home: Scaffold(body: StartCampButton())),
      ),
    );

    // act
    await tester.tap(find.text('코너학습 시작'));
    await tester.pumpAndSettle();
    expect(find.text('코너학습을 시작할까요?'), findsOneWidget);
    await tester.tap(find.text('취소'));
    await tester.pumpAndSettle();

    // assert
    expect(calls, 0);
    expect(find.text('코너학습을 시작할까요?'), findsNothing);
  });

  testWidgets('ShoudDisableDialogActionsWhenStartConfirmIsSubmitting', (
    tester,
  ) async {
    // arrange
    final campId = CampId('camp-1');
    final completer = Completer<CampResponse>();
    var calls = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          selectedCampIdProvider.overrideWith(() => _SelectedCampId(campId)),
          startCampProvider(campId).overrideWith((ref) {
            calls++;
            return completer.future;
          }),
        ],
        child: const MaterialApp(home: Scaffold(body: StartCampButton())),
      ),
    );

    // act
    await tester.tap(find.text('코너학습 시작'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('시작 확정'));
    await tester.pump();

    // assert
    expect(calls, 1);
    expect(find.text('시작 확정 중…'), findsOneWidget);
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, '취소'))
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widget<AppButton>(find.widgetWithText(AppButton, '시작 확정 중…'))
          .onPressed,
      isNull,
    );

    completer.complete(_camp(CampResponseStatusEnum.ACTIVE));
    await tester.pumpAndSettle();
  });

  testWidgets('ShoudKeepDialogOpenAndShowServerMessageWhenStartFails', (
    tester,
  ) async {
    // arrange
    final campId = CampId('camp-1');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          selectedCampIdProvider.overrideWith(() => _SelectedCampId(campId)),
          startCampProvider(
            campId,
          ).overrideWith((ref) async => throw Exception('조건 미충족')),
        ],
        child: const MaterialApp(home: Scaffold(body: StartCampButton())),
      ),
    );

    // act
    await tester.tap(find.text('코너학습 시작'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('시작 확정'));
    for (var i = 0; i < 60; i++) {
      await tester.pump(const Duration(seconds: 1));
    }

    // assert
    expect(find.text('코너학습을 시작할까요?'), findsOneWidget);
    expect(find.textContaining('조건 미충족'), findsOneWidget);
  });
}
