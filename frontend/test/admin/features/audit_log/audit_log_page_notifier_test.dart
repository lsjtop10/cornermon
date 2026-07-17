import 'package:cornermon/admin/features/audit_log/audit_log_filter_state.dart';
import 'package:cornermon/admin/features/audit_log/audit_log_known_actions.dart';
import 'package:cornermon/admin/features/audit_log/audit_log_page_notifier.dart';
import 'package:cornermon/shared/api/domain_aliases.dart';
import 'package:cornermon/shared/api/providers/audit_log_providers.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

AuditLog _log({
  required String id,
  String actor = 'admin1',
  String action = 'LOGIN_SUCCESS',
  bool success = true,
}) => AuditLogResponse(
  (b) => b
    ..id = id
    ..actor = actor
    ..action = action
    ..target = 'track-1'
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
  test('ShoudLoadFirstPageWithNullCursorWhenBuilt', () async {
    // arrange
    final container = ProviderContainer(
      overrides: [
        auditLogListProvider(
          limit: auditLogPageLimit,
          before: null,
          action: null,
          actor: null,
          result: null,
        ).overrideWith((ref) async => _page([_log(id: '1'), _log(id: '2')])),
      ],
    );
    addTearDown(container.dispose);

    // act
    final state = await container.read(auditLogPageNotifierProvider.future);

    // assert
    expect(state.logs.length, 2);
    expect(state.totalLoaded, 2);
    expect(state.nextCursor, isNull);
  });

  test('ShoudAppendNextPageWhenLoadMoreCalled', () async {
    // arrange
    final container = ProviderContainer(
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
    );
    addTearDown(container.dispose);
    await container.read(auditLogPageNotifierProvider.future);

    // act
    await container.read(auditLogPageNotifierProvider.notifier).loadMore();

    // assert
    final state = container.read(auditLogPageNotifierProvider).value!;
    expect(state.logs.map((l) => l.id), ['1', '2']);
    expect(state.totalLoaded, 2);
    expect(state.nextCursor, isNull);
  });

  test(
    'ShoudResetAccumulationAndRefetchFromScratchWhenFilterChanges',
    () async {
      // arrange
      final container = ProviderContainer(
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
            actor: 'admin2',
            result: null,
          ).overrideWith(
            (ref) async => _page([_log(id: '3', actor: 'admin2')]),
          ),
        ],
      );
      addTearDown(container.dispose);
      await container.read(auditLogPageNotifierProvider.future);
      expect(
        container.read(auditLogPageNotifierProvider).value!.totalLoaded,
        2,
      );

      // act — 필터 변경(actor)으로 build()가 재실행되어 처음부터(before: null) 다시 조회된다
      container.read(auditLogFilterProvider.notifier).setActor('admin2');
      final state = await container.read(auditLogPageNotifierProvider.future);

      // assert
      expect(state.logs.map((l) => l.id), ['3']);
      expect(state.totalLoaded, 1);
    },
  );

  test('ShoudObserveActionValuesFromLoadedLogsIntoKnownActions', () async {
    // arrange
    final container = ProviderContainer(
      overrides: [
        auditLogListProvider(
          limit: auditLogPageLimit,
          before: null,
          action: null,
          actor: null,
          result: null,
        ).overrideWith(
          (ref) async => _page([
            _log(id: '1', action: 'LOGIN_SUCCESS'),
            _log(id: '2', action: 'CORNER_UPDATE'),
          ]),
        ),
      ],
    );
    addTearDown(container.dispose);

    // act
    await container.read(auditLogPageNotifierProvider.future);

    // assert
    expect(
      container.read(auditLogKnownActionsProvider),
      containsAll(['LOGIN_SUCCESS', 'CORNER_UPDATE']),
    );
  });
}
