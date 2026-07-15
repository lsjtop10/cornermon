import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import '../client/api_client.dart';
import '../domain_aliases.dart';
import '../ids.dart';
import 'camp_providers.dart';

part 'group_providers.g.dart';

@riverpod
CVisitScanFlowApi visitScanFlowApi(Ref ref) {
  final dio = ref.watch(apiClientProvider);
  return CVisitScanFlowApi(dio, serializers);
}

@riverpod
Future<List<Group>> groupList(Ref ref, CampId campId) async {
  final apiInstance = ref.watch(campApiProvider);
  final response = await apiInstance.campsCampIdGroupsGet(campId: campId.value);
  return response.data?.toList() ?? [];
}

@riverpod
Future<Group> groupDetail(Ref ref, GroupId id) async {
  final apiInstance = ref.watch(campApiProvider);
  final response = await apiInstance.groupsIdGet(id: id.value);
  final data = response.data;
  if (data == null) {
    throw Exception('Group not found');
  }
  return data;
}

@riverpod
Future<List<VisitSummary>> groupVisits(Ref ref, GroupId id) async {
  final apiInstance = ref.watch(campApiProvider);
  final response = await apiInstance.groupsIdVisitsGet(id: id.value);
  return response.data?.toList() ?? [];
}

@riverpod
Future<List<Group>> trackScopedGroups(Ref ref, TrackId trackId) async {
  final apiInstance = ref.watch(visitScanFlowApiProvider);
  final response = await apiInstance.tracksTrackIdGroupsGet(trackId: trackId.value);
  return response.data?.toList() ?? [];
}
