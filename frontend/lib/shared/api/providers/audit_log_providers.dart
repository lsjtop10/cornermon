import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import '../client/api_client.dart';
import '../domain_aliases.dart';

part 'audit_log_providers.g.dart';

@riverpod
GAuditLogsApi auditLogApi(Ref ref) {
  final dio = ref.watch(apiClientProvider);
  return GAuditLogsApi(dio, standardSerializers);
}

@riverpod
Future<AuditLogPage> auditLogList(
  Ref ref, {
  int? limit,
  String? before, // 이전 응답의 불투명 nextCursor 문자열 — DateTime 아님
  String? action,
  String? actor,
  String? result, // "success" | "failure"
}) async {
  final apiInstance = ref.watch(auditLogApiProvider);
  final response = await apiInstance.auditLogsGet(
    limit: limit,
    before: before,
    action: action,
    actor: actor,
    result: result,
  );
  final data = response.data;
  if (data == null) {
    throw Exception('Audit logs not found');
  }
  return data;
}
