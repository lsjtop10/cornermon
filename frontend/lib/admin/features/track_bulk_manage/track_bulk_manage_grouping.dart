import 'package:cornermon/shared/api/domain_aliases.dart' as api;

/// 코너 1개 + 그 코너에 속한 트랙 목록. 화면 그룹핑 전용, provider 레이어에는 두지 않는다.
class CornerTrackGroup {
  const CornerTrackGroup({required this.corner, required this.tracks});
  final api.Corner corner;
  final List<api.Track> tracks;

  /// 코너 삭제는 DB에서 트랙·방문 기록까지 `ON DELETE CASCADE`로 함께 제거되므로
  /// 트랙이 있어도 막지 않는다. 다만 진행 중인 방문(BUSY 트랙)이 있는 채로 지우면
  /// 현장에서 스캔 중인 진행자의 세션이 끊기므로 그 경우에만 막는다.
  bool get canDelete =>
      tracks.every((track) => track.operationalStatus != api.TrackOperationalStatus.BUSY);
}

/// 코너 목록과 트랙 목록을 코너 기준으로 묶는다. 트랙이 하나도 없는 코너도 반드시 그룹으로
/// 포함해야 한다 — 트랙 없는 좀비 코너를 화면에 노출하는 것이 이 그룹핑의 목적이다.
List<CornerTrackGroup> groupTracksByCorner(
  List<api.Corner> corners,
  List<api.Track> tracks,
) {
  final tracksByCornerId = <String, List<api.Track>>{};
  for (final track in tracks) {
    final cornerId = track.cornerId;
    if (cornerId == null) continue;
    tracksByCornerId.putIfAbsent(cornerId, () => []).add(track);
  }
  return [
    for (final corner in corners)
      CornerTrackGroup(
        corner: corner,
        tracks: tracksByCornerId[corner.id] ?? const [],
      ),
  ];
}
