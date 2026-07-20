import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cornermon/shared/api/domain_aliases.dart';
import 'package:cornermon/shared/api/providers/audit_log_providers.dart';

import 'audit_log_filter_state.dart';
import 'audit_log_known_actions.dart';

/// 서버 기본값과 동일한 페이지 크기 — plan §0 `limit`(기본 50).
const auditLogPageLimit = 50;

/// 커서 누적 상태 — plan §2.3. "더 보기"를 누를 때마다 다음 페이지를 이전 누적
/// 결과에 append한다. 서버가 전체 건수를 안 주므로 [totalLoaded]는 "현재까지 로드된
/// 건수"일 뿐 "전체 건수"가 아니다(화면 문구도 그렇게 표기한다).
class AuditLogPageState {
  const AuditLogPageState({
    required this.logs,
    required this.nextCursor,
    required this.totalLoaded,
  });

  final List<AuditLog> logs;
  final String? nextCursor;
  final int totalLoaded;
}

/// "더 보기" 로딩 중에는 이미 누적된 [AuditLogPageState.logs]를 화면에서 지우지 않는다
/// (state를 AsyncLoading으로 바꾸면 테이블이 통째로 스켈레톤으로 바뀐다) — 대신 별도
/// bool provider로 "더 보기" 버튼 자체의 스피너 상태만 노출한다.
final auditLogLoadMoreBusyProvider =
    NotifierProvider<AuditLogLoadMoreBusy, bool>(AuditLogLoadMoreBusy.new);

class AuditLogLoadMoreBusy extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) => state = value;
}

final auditLogPageNotifierProvider =
    AsyncNotifierProvider<AuditLogPageNotifier, AuditLogPageState>(
      AuditLogPageNotifier.new,
    );

class AuditLogPageNotifier extends AsyncNotifier<AuditLogPageState> {
  @override
  Future<AuditLogPageState> build() async {
    // 필터가 바뀌면 이 build()가 다시 실행되어 자동으로 처음부터(before: null) 재조회된다.
    final filter = ref.watch(auditLogFilterProvider);
    return _fetch(filter: filter, before: null, previous: const []);
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.nextCursor == null) return;
    if (ref.read(auditLogLoadMoreBusyProvider)) return;

    final busy = ref.read(auditLogLoadMoreBusyProvider.notifier);
    busy.set(true);
    try {
      final filter = ref.read(auditLogFilterProvider);
      final next = await _fetch(
        filter: filter,
        before: current.nextCursor,
        previous: current.logs,
      );
      state = AsyncData(next);
    } finally {
      busy.set(false);
    }
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<AuditLogPageState> _fetch({
    required AuditLogFilter filter,
    required String? before,
    required List<AuditLog> previous,
  }) async {
    final page = await ref.read(
      auditLogListProvider(
        limit: auditLogPageLimit,
        before: before,
        action: filter.action,
        actor: filter.actor,
        result: filter.result,
      ).future,
    );
    final logs = page.logs?.toList() ?? const <AuditLog>[];
    ref
        .read(auditLogKnownActionsProvider.notifier)
        .observe(logs.map((log) => log.action?.name).whereType<String>());
    final combined = [...previous, ...logs];
    return AuditLogPageState(
      logs: combined,
      nextCursor: page.nextCursor,
      totalLoaded: combined.length,
    );
  }
}
