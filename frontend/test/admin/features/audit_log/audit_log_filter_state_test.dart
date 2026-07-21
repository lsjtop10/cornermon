import 'package:cornermon/admin/features/audit_log/audit_log_filter_state.dart';
import 'package:cornermon/admin/features/audit_log/audit_log_known_actions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ShoudCountOnlyNonNullFieldsWhenComputingActiveCount', () {
    // arrange
    const empty = AuditLogFilter();
    const oneSet = AuditLogFilter(actor: 'admin1');
    const allSet = AuditLogFilter(
      actor: 'admin1',
      action: 'LOGIN_SUCCESS',
      result: 'failure',
    );

    // act / assert
    expect(empty.activeCount, 0);
    expect(oneSet.activeCount, 1);
    expect(allSet.activeCount, 3);
  });

  test('ShoudResetAllFieldsWhenClearIsCalled', () {
    // arrange
    const filter = AuditLogFilter(
      actor: 'admin1',
      action: 'LOGIN_SUCCESS',
      result: 'failure',
    );

    // act
    final cleared = filter.clear();

    // assert
    expect(cleared.actor, isNull);
    expect(cleared.action, isNull);
    expect(cleared.result, isNull);
    expect(cleared.activeCount, 0);
  });

  test('ShoudNormalizeBlankActorToNullWhenSetActorCalled', () {
    // arrange
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(auditLogFilterProvider.notifier);

    // act
    notifier.setActor('   ');

    // assert
    expect(container.read(auditLogFilterProvider).actor, isNull);
    expect(container.read(auditLogFilterProvider).activeCount, 0);
  });

  test('ShoudUpdateOnlyTargetedFieldWhenSetActionCalled', () {
    // arrange
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(auditLogFilterProvider.notifier);
    notifier.setActor('admin1');

    // act
    notifier.setAction('LOGIN_SUCCESS');

    // assert
    final filter = container.read(auditLogFilterProvider);
    expect(filter.actor, 'admin1');
    expect(filter.action, 'LOGIN_SUCCESS');
    expect(filter.activeCount, 2);
  });

  test('ShoudClearAllFieldsWhenClearAllCalled', () {
    // arrange
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(auditLogFilterProvider.notifier);
    notifier.setActor('admin1');
    notifier.setAction('LOGIN_SUCCESS');
    notifier.setResult('failure');

    // act
    notifier.clearAll();

    // assert
    final filter = container.read(auditLogFilterProvider);
    expect(filter.activeCount, 0);
  });

  test('ShoudAccumulateNewActionsWhenObserveCalledRepeatedly', () {
    // arrange
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(auditLogKnownActionsProvider.notifier);

    // act
    notifier.observe(['LOGIN_SUCCESS', 'LOGIN_FAILURE']);
    notifier.observe(['LOGIN_SUCCESS', 'CORNER_UPDATE']);

    // assert
    expect(
      container.read(auditLogKnownActionsProvider),
      containsAll(['LOGIN_SUCCESS', 'LOGIN_FAILURE', 'CORNER_UPDATE']),
    );
    expect(container.read(auditLogKnownActionsProvider).length, 3);
  });
}
