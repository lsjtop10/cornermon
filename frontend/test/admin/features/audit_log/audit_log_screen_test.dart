import 'package:cornermon/admin/features/audit_log/audit_log_page_notifier.dart';
import 'package:cornermon/admin/features/audit_log/audit_log_screen.dart';
import 'package:cornermon/shared/api/domain_aliases.dart';
import 'package:cornermon/shared/api/providers/audit_log_providers.dart';
import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../test_utils/widget_test_helpers.dart';

AuditLog _log({
  required String id,
  String actor = 'admin1',
  String action = 'LOGIN_SUCCESS',
  String target = 'track-1',
  bool success = true,
}) => AuditLogResponse(
  (b) => b
    ..id = id
    ..actor = actor
    ..action = action
    ..target = target
    ..success = success
    ..occurredAt = DateTime.utc(2026, 7, 17, 10, 0, 0),
);

AuditLogPage _page(List<AuditLog> logs, {String? nextCursor}) =>
    AuditLogPageResponse(
      (b) => b
        ..logs.replace(logs)
        ..nextCursor = nextCursor,
    );

void main() {
  testWidgets('ShoudShowFiveColumnsAndLoadedCountWhenFirstPageLoads', (
    tester,
  ) async {
    // arrange
    await tester.pumpWidget(
      buildTestable(
        const AuditLogScreen(),
        overrides: [
          auditLogListProvider(
            limit: auditLogPageLimit,
            before: null,
            action: null,
            actor: null,
            result: null,
          ).overrideWith((ref) async => _page([_log(id: '1'), _log(id: '2')])),
        ],
      ),
    );
    await tester.pumpAndSettle();

    // act — no interaction, initial load only

    // assert
    expect(find.text('시각'), findsOneWidget);
    expect(find.text('행위자'), findsOneWidget);
    expect(find.text('행위 종류'), findsOneWidget);
    expect(find.text('대상'), findsOneWidget);
    expect(find.text('결과'), findsOneWidget);
    expect(find.text('현재까지 2건 로드됨'), findsOneWidget);
    expect(find.text('마지막 로그입니다.'), findsOneWidget);
  });

  testWidgets('ShoudShowDangerBorderAndFailureBadgeWhenRowIsFailure', (
    tester,
  ) async {
    // arrange
    await tester.pumpWidget(
      buildTestable(
        const AuditLogScreen(),
        overrides: [
          auditLogListProvider(
            limit: auditLogPageLimit,
            before: null,
            action: null,
            actor: null,
            result: null,
          ).overrideWith((ref) async => _page([_log(id: '1', success: false)])),
        ],
      ),
    );
    await tester.pumpAndSettle();

    // act — no interaction

    // assert
    expect(find.text('실패'), findsOneWidget);
    expect(find.text('✕'), findsOneWidget);
    final dangerBorderedRow = tester
        .widgetList<Container>(find.byType(Container))
        .where((container) {
          final decoration = container.decoration;
          if (decoration is! BoxDecoration) return false;
          final border = decoration.border;
          if (border is! Border) return false;
          return border.left.color == AppColors.light.danger &&
              border.left.width == 4;
        });
    expect(dangerBorderedRow, isNotEmpty);
  });

  testWidgets('ShoudRequeryWithActorFilterAfterDebounceWhenTypingActorField', (
    tester,
  ) async {
    // arrange
    await tester.pumpWidget(
      buildTestable(
        const AuditLogScreen(),
        overrides: [
          auditLogListProvider(
            limit: auditLogPageLimit,
            before: null,
            action: null,
            actor: null,
            result: null,
          ).overrideWith((ref) async => _page([_log(id: '1'), _log(id: '2')])),
          auditLogListProvider(
            limit: auditLogPageLimit,
            before: null,
            action: null,
            actor: 'admin9',
            result: null,
          ).overrideWith(
            (ref) async => _page([_log(id: '3', actor: 'admin9')]),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('현재까지 2건 로드됨'), findsOneWidget);

    // act
    await tester.enterText(find.byType(TextField), 'admin9');
    await tester.pump(const Duration(milliseconds: 100));
    // 디바운스(300ms) 전이라 아직 재조회되지 않아야 한다
    expect(find.text('현재까지 2건 로드됨'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();

    // assert
    expect(find.text('현재까지 1건 로드됨'), findsOneWidget);
  });

  testWidgets('ShoudShowActiveCountAndClearFiltersWhenResetButtonTapped', (
    tester,
  ) async {
    // arrange
    await tester.pumpWidget(
      buildTestable(
        const AuditLogScreen(),
        overrides: [
          auditLogListProvider(
            limit: auditLogPageLimit,
            before: null,
            action: null,
            actor: null,
            result: null,
          ).overrideWith((ref) async => _page([_log(id: '1')])),
          auditLogListProvider(
            limit: auditLogPageLimit,
            before: null,
            action: null,
            actor: null,
            result: 'failure',
          ).overrideWith((ref) async => _page([_log(id: '2', success: false)])),
        ],
      ),
    );
    await tester.pumpAndSettle();

    // act — 결과 드롭다운을 "실패"로 선택
    await tester.tap(find.byType(DropdownButton<String?>).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('실패').last);
    await tester.pumpAndSettle();

    // assert — 필터 초기화 버튼에 활성 개수(1)가 표시된다
    expect(find.text('필터 초기화 (1)'), findsOneWidget);

    // act — 필터 초기화
    await tester.tap(find.text('필터 초기화 (1)'));
    await tester.pumpAndSettle();

    // assert — 원래 목록으로 돌아가고 버튼 라벨도 초기화된다
    expect(find.text('필터 초기화'), findsOneWidget);
    expect(find.text('현재까지 1건 로드됨'), findsOneWidget);
  });

  testWidgets('ShoudAppendLogsAndIncreaseCountWhenLoadMoreTapped', (
    tester,
  ) async {
    // arrange
    await tester.pumpWidget(
      buildTestable(
        const AuditLogScreen(),
        overrides: [
          auditLogListProvider(
            limit: auditLogPageLimit,
            before: null,
            action: null,
            actor: null,
            result: null,
          ).overrideWith(
            (ref) async => _page([_log(id: '1')], nextCursor: 'cursor-2'),
          ),
          auditLogListProvider(
            limit: auditLogPageLimit,
            before: 'cursor-2',
            action: null,
            actor: null,
            result: null,
          ).overrideWith((ref) async => _page([_log(id: '2')])),
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('더 보기'), findsOneWidget);

    // act
    await tester.tap(find.text('더 보기'));
    await tester.pumpAndSettle();

    // assert
    expect(find.text('현재까지 2건 로드됨'), findsOneWidget);
    expect(find.text('마지막 로그입니다.'), findsOneWidget);
    expect(find.text('더 보기'), findsNothing);
  });
}
