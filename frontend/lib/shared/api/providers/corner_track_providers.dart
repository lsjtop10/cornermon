import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import '../domain_aliases.dart';
import '../ids.dart';
import 'camp_providers.dart';
import 'no_retry.dart';

part 'corner_track_providers.g.dart';

class CornerUpdateInput {
  const CornerUpdateInput({required this.id, this.name, this.targetMinutes});
  final String id;
  final String? name;
  final int? targetMinutes;
}

@riverpod
Future<List<Corner>> cornerList(Ref ref, CampId campId) async {
  final apiInstance = ref.watch(campApiProvider);
  final response = await apiInstance.campsCampIdCornersGet(campId: campId.value);
  return response.data?.toList() ?? [];
}

@riverpod
Future<Corner> cornerDetail(Ref ref, CornerId id) async {
  final apiInstance = ref.watch(campApiProvider);
  final response = await apiInstance.cornersIdGet(id: id.value);
  final data = response.data;
  if (data == null) {
    throw Exception('Corner not found');
  }
  return data;
}

@Riverpod(retry: noRetry)
Future<Corner> createCorner(Ref ref, CampId campId, String name, int targetMinutes) async {
  final apiInstance = ref.watch(campApiProvider);
  final response = await apiInstance.cornersPost(
    request: CreateCornerRequest(
      (b) => b
        ..campId = campId.value
        ..name = name
        ..targetMinutes = targetMinutes,
    ),
  );
  final data = response.data;
  if (data == null) {
    throw Exception('Corner creation response was empty');
  }
  return data;
}

@riverpod
Future<List<Corner>> bulkUpdateCorners(Ref ref, List<CornerUpdateInput> updates) async {
  final apiInstance = ref.watch(campApiProvider);
  final response = await apiInstance.cornersBulkUpdatePut(
    request: BulkUpdateCornersRequest(
      (b) => b.corners.addAll(
        updates.map(
          (u) => BulkUpdateCornersRequestCornersInner(
            (cb) => cb
              ..id = u.id
              ..name = u.name
              ..targetMinutes = u.targetMinutes,
          ),
        ),
      ),
    ),
  );
  return response.data?.toList() ?? [];
}

@riverpod
Future<void> deleteCorner(Ref ref, CornerId id) async {
  final apiInstance = ref.watch(campApiProvider);
  await apiInstance.cornersIdDelete(id: id.value);
}

@riverpod
Future<List<Track>> trackList(Ref ref, CampId campId) async {
  final apiInstance = ref.watch(campApiProvider);
  final response = await apiInstance.campsCampIdTracksGet(campId: campId.value);
  return response.data?.toList() ?? [];
}

@riverpod
Future<List<Track>> cornerTrackList(Ref ref, CornerId cornerId) async {
  final apiInstance = ref.watch(campApiProvider);
  final response = await apiInstance.cornersCornerIdTracksGet(cornerId: cornerId.value);
  return response.data?.toList() ?? [];
}

@Riverpod(retry: noRetry)
Future<List<TrackPin>> createTracksForCorner(Ref ref, CampId campId, CornerId cornerId, int count) async {
  final apiInstance = ref.watch(campApiProvider);
  final response = await apiInstance.tracksPost(
    request: CreateTracksRequest(
      (b) => b
        ..campId = campId.value
        ..cornerId = cornerId.value
        ..count = count,
    ),
  );
  return response.data?.toList() ?? [];
}

@riverpod
Future<void> bulkDeleteTracks(Ref ref, List<TrackId> trackIds) async {
  final apiInstance = ref.watch(campApiProvider);
  await apiInstance.tracksBulkDeleteDelete(
    request: BulkDeleteTracksRequest(
      (b) => b.trackIds.addAll(trackIds.map((t) => t.value)),
    ),
  );
}

@riverpod
Future<TrackPin> replaceTrack(Ref ref, TrackId id, CornerId newCornerId) async {
  final apiInstance = ref.watch(campApiProvider);
  final response = await apiInstance.tracksIdReplacePut(
    id: id.value,
    request: ReplaceTrackRequest((b) => b..newCornerId = newCornerId.value),
  );
  final data = response.data;
  if (data == null) {
    throw Exception('Track replace response was empty');
  }
  return data;
}

@riverpod
Future<TrackPin> regeneratePin(Ref ref, TrackId id) async {
  final apiInstance = ref.watch(campApiProvider);
  final response = await apiInstance.tracksIdRegeneratePinPost(id: id.value);
  final data = response.data;
  if (data == null) {
    throw Exception('Regenerate PIN response was empty');
  }
  return data;
}

@riverpod
Future<ExportTracksResponse> exportAllTracksCsv(Ref ref, CampId campId) async {
  final apiInstance = ref.watch(campApiProvider);
  final response = await apiInstance.tracksExportGet(campId: campId.value);
  final data = response.data;
  if (data == null) {
    throw Exception('Track export response was empty');
  }
  return data;
}

@riverpod
Future<TrackPin> exportTrackPdf(Ref ref, TrackId id) async {
  final apiInstance = ref.watch(campApiProvider);
  final response = await apiInstance.tracksIdExportGet(id: id.value);
  final data = response.data;
  if (data == null) {
    throw Exception('Track PIN export response was empty');
  }
  return data;
}
