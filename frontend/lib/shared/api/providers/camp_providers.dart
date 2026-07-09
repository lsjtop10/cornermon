import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import '../client/api_client.dart';
import '../ids.dart';

part 'camp_providers.g.dart';

@riverpod
BCampCornerTrackApi campApi(CampApiRef ref) {
  final dio = ref.watch(apiClientProvider);
  return BCampCornerTrackApi(dio, serializers);
}

@riverpod
Future<List<Camp>> campList(CampListRef ref, {CampStatus? status}) async {
  final apiInstance = ref.watch(campApiProvider);
  final response = await apiInstance.campsGet(status: status);
  return response.data?.camps?.toList() ?? [];
}

@riverpod
Future<Camp> campDetail(CampDetailRef ref, CampId id) async {
  final apiInstance = ref.watch(campApiProvider);
  final response = await apiInstance.campsIdGet(id: id.value);
  final data = response.data;
  if (data == null) {
    throw Exception('Camp not found');
  }
  return data;
}
