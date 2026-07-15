import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import '../client/api_client.dart';
import '../domain_aliases.dart';
import '../ids.dart';

part 'camp_providers.g.dart';

@riverpod
BResourceManagementAdminApi campApi(Ref ref) {
  final dio = ref.watch(apiClientProvider);
  return BResourceManagementAdminApi(dio, serializers);
}

@riverpod
Future<List<Camp>> campList(Ref ref) async {
  final apiInstance = ref.watch(campApiProvider);
  final response = await apiInstance.campsGet();
  return response.data?.toList() ?? [];
}

@riverpod
Future<Camp> campDetail(Ref ref, CampId id) async {
  final apiInstance = ref.watch(campApiProvider);
  final response = await apiInstance.campsIdGet(id: id.value);
  final data = response.data;
  if (data == null) {
    throw Exception('Camp not found');
  }
  return data;
}

@riverpod
Future<Camp> createCamp(Ref ref, String name) async {
  final apiInstance = ref.watch(campApiProvider);
  final response = await apiInstance.campsPost(
    request: CreateCampRequest((b) => b..name = name),
  );
  final data = response.data;
  if (data == null) {
    throw Exception('Camp creation response was empty');
  }
  return data;
}

@riverpod
Future<Camp> updateCamp(
  Ref ref,
  CampId id, {
  String? name,
  int? bottleneckMinSamples,
  int? bottleneckRatioPct,
  DateTime? startAt,
  DateTime? endAt,
}) async {
  final apiInstance = ref.watch(campApiProvider);
  final response = await apiInstance.campsIdPatch(
    id: id.value,
    request: UpdateCampRequest((b) {
      b.name = name;
      b.bottleneckMinSamples = bottleneckMinSamples;
      b.bottleneckRatioPct = bottleneckRatioPct;
      b.startAt = startAt;
      b.endAt = endAt;
    }),
  );
  final data = response.data;
  if (data == null) {
    throw Exception('Camp update response was empty');
  }
  return data;
}

@riverpod
Future<Camp> startCamp(Ref ref, CampId id) async {
  final apiInstance = ref.watch(campApiProvider);
  final response = await apiInstance.campsIdStartPost(id: id.value);
  final data = response.data;
  if (data == null) {
    throw Exception('Camp start response was empty');
  }
  return data;
}

@riverpod
Future<Camp> endCamp(Ref ref, CampId id) async {
  final apiInstance = ref.watch(campApiProvider);
  final response = await apiInstance.campsIdEndPost(id: id.value);
  final data = response.data;
  if (data == null) {
    throw Exception('Camp end response was empty');
  }
  return data;
}
