import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import '../client/api_client.dart';
import '../ids.dart';
import 'camp_providers.dart';

part 'group_providers.g.dart';

@riverpod
CVisitScanFlowApi visitScanFlowApi(Ref ref) {
  final dio = ref.watch(apiClientProvider);
  return CVisitScanFlowApi(dio, serializers);
}

@riverpod
Future<List<Group>> groupList(
  Ref ref, {
  String? filter,
  String? sort,
  String? order,
}) async {
  final apiInstance = ref.watch(campApiProvider);
  final response = await apiInstance.groupsGet(
    filter: filter,
    sort: sort,
    order: order,
  );
  return response.data?.groups?.toList() ?? [];
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
  final apiInstance = ref.watch(visitScanFlowApiProvider);
  final response = await apiInstance.groupsIdVisitsGet(id: id.value);
  return response.data?.visits?.toList() ?? [];
}
