import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import '../domain_aliases.dart';
import 'camp_providers.dart';

part 'badge_providers.g.dart';

@riverpod
Future<List<Badge>> badgeList(Ref ref) async {
  final apiInstance = ref.watch(campApiProvider);
  final response = await apiInstance.badgesGet();
  return response.data?.toList() ?? [];
}

@riverpod
Future<List<Badge>> bulkGenerateBadges(Ref ref, int count) async {
  final apiInstance = ref.watch(campApiProvider);
  final response = await apiInstance.badgesBulkGeneratePost(
    request: BulkGenerateBadgesRequest((b) => b..count = count),
  );
  return response.data?.toList() ?? [];
}

@riverpod
Future<List<Badge>> exportUnassignedBadges(Ref ref) async {
  final apiInstance = ref.watch(campApiProvider);
  final response = await apiInstance.badgesExportGet();
  return response.data?.badges?.toList() ?? [];
}

@riverpod
Future<Badge> registerBadge(Ref ref, String badgeId, String groupId) async {
  final apiInstance = ref.watch(campApiProvider);
  final response = await apiInstance.badgesIdRegisterPost(
    id: badgeId,
    request: AssignBadgeRequest((b) => b..groupId = groupId),
  );
  final data = response.data;
  if (data == null) {
    throw Exception('Badge register response was empty');
  }
  return data;
}

@riverpod
Future<Group> scanRegisterBadge(Ref ref, String qrPayload, String groupName) async {
  final apiInstance = ref.watch(campApiProvider);
  final response = await apiInstance.badgesScanRegisterPost(
    request: ScanAssignBadgeRequest(
      (b) => b
        ..qrPayload = qrPayload
        ..groupName = groupName,
    ),
  );
  final data = response.data;
  if (data == null) {
    throw Exception('Badge scan-register response was empty');
  }
  return data;
}
