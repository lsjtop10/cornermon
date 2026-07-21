import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 행위 종류(action) 드롭다운 옵션 소스 — plan §2.4.
///
/// `GET /audit-logs`에는 가능한 action enum 값을 내려주는 별도 API가 없다(issue #118,
/// 아직 미해결). 임시방편으로 지금까지 로드된 로그들의 action 값 집합을 옵션으로 쓰고,
/// 페이지가 더 로드되거나 필터가 바뀌어 새 값이 나타나면 점진적으로 추가한다. 필터 변경으로
/// [AuditLogPageNotifier]의 누적이 초기화돼도 이 목록 자체는 비우지 않는다 — 그래야
/// "이전에 본 적 있는 action"이 드롭다운에서 사라지지 않는다.
final auditLogKnownActionsProvider =
    NotifierProvider<AuditLogKnownActionsNotifier, List<String>>(
      AuditLogKnownActionsNotifier.new,
    );

class AuditLogKnownActionsNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => const [];

  void observe(Iterable<String> actions) {
    final next = {...state, ...actions.where((a) => a.isNotEmpty)};
    if (next.length == state.length) return; // 새 값 없음
    state = next.toList()..sort();
  }
}
