import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import '../client/api_client.dart';
import '../domain_aliases.dart';
import '../ids.dart';
import 'no_retry.dart';

part 'camp_providers.g.dart';

@riverpod
BResourceManagementAdminApi campApi(Ref ref) {
  final dio = ref.watch(apiClientProvider);
  return BResourceManagementAdminApi(dio, standardSerializers);
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

@Riverpod(retry: noRetry)
Future<Camp> createCamp(
  Ref ref,
  String name, {
  required DateTime startAt,
  required DateTime endAt,
}) async {
  final apiInstance = ref.watch(campApiProvider);
  final response = await apiInstance.campsPost(
    request: CreateCampRequest((b) => b
      ..name = name
      ..startAt = startAt.toUtc()
      ..endAt = endAt.toUtc()),
  );
  final data = response.data;
  if (data == null) {
    throw Exception('Camp creation response was empty');
  }
  return data;
}

// PATCH이지만 서버 400(예: 병목 기준 0 이하) 등 재시도해도 동일하게 실패하는 응답을
// 무한 재시도(§DEVELOPER_GUIDE.md 2.3, 컨테이너 기본 정책)로 감추지 않기 위해
// retry: noRetry를 명시한다 — A15 설정 화면의 인라인 에러 표시가 이 정책에 의존한다.
@Riverpod(retry: noRetry)
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
      b.startAt = startAt?.toUtc();
      b.endAt = endAt?.toUtc();
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
