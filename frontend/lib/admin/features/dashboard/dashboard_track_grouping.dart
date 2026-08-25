import 'package:cornermon/shared/api/domain_aliases.dart' as api;

/// 코너 1개 + 그 코너에 속한 트랙 목록. 화면 그룹핑 전용, provider 레이어에는 두지 않는다.
class CornerTrackGroup {
  const CornerTrackGroup({required this.corner, required this.tracks});
  final api.Corner corner;
  final List<api.Track> tracks;
}

/// 코너 목록과 트랙 목록을 코너 기준으로 묶는다. 트랙이 하나도 없는 코너도 반드시 그룹으로
/// 포함해야 한다 — 트랙 없는 좀비 코너를 화면에 노출하는 것이 이 그룹핑의 목적이다.
/// [corners]는 이미 대시보드 필터·정렬을 거친 목록을 그대로 받는다 — 카드형/트랙별 뷰가
/// 같은 필터·정렬 결과를 공유하기 위함(둘은 같은 데이터의 다른 렌더링일 뿐이다).
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
        // 트랙별 뷰는 자체 정렬 컨트롤을 두지 않는다(카드형과 동일한 코너 정렬만 공유) —
        // 코너 안에서는 트랙 번호 순으로 고정해 항상 예측 가능하게 한다.
        tracks: [...tracksByCornerId[corner.id] ?? const []]
          ..sort((a, b) => (a.trackNo ?? 0).compareTo(b.trackNo ?? 0)),
      ),
  ];
}
