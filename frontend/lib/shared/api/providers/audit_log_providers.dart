import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import '../client/api_client.dart';

part 'audit_log_providers.g.dart';

@riverpod
GAuditLogsApi auditLogApi(AuditLogApiRef ref) {
  final dio = ref.watch(apiClientProvider);
  return GAuditLogsApi(dio, serializers);
}

@riverpod
Future<AuditLogsGet200Response> auditLogList(
  AuditLogListRef ref, {
  int? limit,
  DateTime? before,
  String? action,
  String? actor,
}) async {
  final apiInstance = ref.watch(auditLogApiProvider);
  final response = await apiInstance.auditLogsGet(
    limit: limit,
    before: before,
    action: action,
    actor: actor,
  );
  final data = response.data;
  if (data == null) {
    throw Exception('Audit logs not found');
  }
  return data;
}
