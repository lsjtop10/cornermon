import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A13 감사 로그 필터 상태 — plan §2.3.
/// actor(부분 일치)/action(정확 일치)/result("success"|"failure") 세 축만 있다.
class AuditLogFilter {
  const AuditLogFilter({this.actor, this.action, this.result});

  final String? actor;
  final String? action;
  final String? result; // "success" | "failure" | null(전체)

  /// "필터 초기화 (N)" 버튼 라벨용 — null이 아닌(빈 문자열도 제외) 필터 개수.
  int get activeCount =>
      [actor, action, result].where((v) => v != null && v.isNotEmpty).length;

  AuditLogFilter clear() => const AuditLogFilter();

  AuditLogFilter copyWith({
    String? actor,
    bool clearActor = false,
    String? action,
    bool clearAction = false,
    String? result,
    bool clearResult = false,
  }) => AuditLogFilter(
    actor: clearActor ? null : (actor ?? this.actor),
    action: clearAction ? null : (action ?? this.action),
    result: clearResult ? null : (result ?? this.result),
  );
}

final auditLogFilterProvider =
    NotifierProvider<AuditLogFilterNotifier, AuditLogFilter>(
      AuditLogFilterNotifier.new,
    );

class AuditLogFilterNotifier extends Notifier<AuditLogFilter> {
  @override
  AuditLogFilter build() => const AuditLogFilter();

  void setActor(String? value) {
    final normalized = _normalize(value);
    state = state.copyWith(actor: normalized, clearActor: normalized == null);
  }

  void setAction(String? value) {
    final normalized = _normalize(value);
    state = state.copyWith(action: normalized, clearAction: normalized == null);
  }

  void setResult(String? value) {
    final normalized = _normalize(value);
    state = state.copyWith(result: normalized, clearResult: normalized == null);
  }

  void clearAll() => state = state.clear();

  String? _normalize(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
