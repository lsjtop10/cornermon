import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import '../domain_aliases.dart';
import '../ids.dart';
import 'group_providers.dart';

part 'visit_providers.g.dart';

@riverpod
Future<VisitSummary?> currentVisit(Ref ref, TrackId trackId) async {
  final apiInstance = ref.watch(visitScanFlowApiProvider);
  final response = await apiInstance.tracksTrackIdVisitsCurrentGet(trackId: trackId.value);
  return response.data;
}

@riverpod
class VisitActions extends _$VisitActions {
  @override
  void build(TrackId trackId) {}

  /// POST /tracks/{trackId}/visits/start — qrToken 브랜치
  Future<VisitSummary> startByQr(String qrToken) async {
    final apiInstance = ref.read(visitScanFlowApiProvider);
    final response = await apiInstance.tracksTrackIdVisitsStartPost(
      trackId: trackId.value,
      request: VisitStartRequest((b) => b..qrToken = qrToken),
    );
    final data = response.data;
    if (data == null) {
      throw Exception('방문 시작 응답이 올바르지 않습니다.');
    }
    return data;
  }

  /// POST /tracks/{trackId}/visits/start — groupId+method:MANUAL 브랜치
  Future<VisitSummary> startManual(GroupId groupId) async {
    final apiInstance = ref.read(visitScanFlowApiProvider);
    final response = await apiInstance.tracksTrackIdVisitsStartPost(
      trackId: trackId.value,
      request: VisitStartRequest(
        (b) => b
          ..groupId = groupId.value
          ..method = VisitStartRequestMethodEnum.MANUAL,
      ),
    );
    final data = response.data;
    if (data == null) {
      throw Exception('방문 시작 응답이 올바르지 않습니다.');
    }
    return data;
  }

  /// POST /tracks/{trackId}/visits/current/end — 바디 없음
  Future<VisitSummary> endCurrent() async {
    final apiInstance = ref.read(visitScanFlowApiProvider);
    final response = await apiInstance.tracksTrackIdVisitsCurrentEndPost(trackId: trackId.value);
    final data = response.data;
    if (data == null) {
      throw Exception('방문 종료 응답이 올바르지 않습니다.');
    }
    return data;
  }
}
