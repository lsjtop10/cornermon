import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import '../ids.dart';
import 'camp_providers.dart';

part 'corner_track_providers.g.dart';

@riverpod
Future<List<Corner>> cornerList(CornerListRef ref) async {
  final apiInstance = ref.watch(campApiProvider);
  final response = await apiInstance.cornersGet();
  return response.data?.corners?.toList() ?? [];
}

@riverpod
Future<Corner> cornerDetail(CornerDetailRef ref, CornerId id) async {
  final list = await ref.watch(cornerListProvider.future);
  return list.firstWhere(
    (c) => c.id == id.value,
    orElse: () => throw Exception('Corner not found'),
  );
}

@riverpod
Future<List<Track>> trackList(TrackListRef ref) async {
  final apiInstance = ref.watch(campApiProvider);
  final response = await apiInstance.tracksGet();
  return response.data?.tracks?.toList() ?? [];
}
