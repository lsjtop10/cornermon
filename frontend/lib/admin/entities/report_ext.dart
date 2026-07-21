import '../../shared/api/domain_aliases.dart' as api;

/// 10_a12_report.md §0.3 — 조별 탭 파생 로직.
extension AdminCampReportX on api.CampReport {
  /// 코너별 unvisitedGroups를 뒤집어 groupId → 미완료 코너명 목록 맵을 만든다.
  /// O(코너 수 × 코너당 미방문 조 수) — 캠프 규모(코너 10, 조 20)에서 무시할 수준.
  Map<String, List<String>> get unvisitedCornerNamesByGroupId {
    final map = <String, List<String>>{};
    final Iterable<api.CornerStats> stats =
        cornerStats ?? const <api.CornerStats>[];
    for (final corner in stats) {
      final Iterable<api.UnvisitedGroup> unvisited =
          corner.unvisitedGroups ?? const <api.UnvisitedGroup>[];
      for (final g in unvisited) {
        final groupId = g.groupId;
        final cornerName = corner.cornerName;
        if (groupId == null || cornerName == null) continue;
        map.putIfAbsent(groupId, () => []).add(cornerName);
      }
    }
    return map;
  }
}

extension AdminGroupStatsX on api.GroupStats {
  /// completedCount가 전체 코너 수(report.cornerStats.length)와 같으면 완주로 간주.
  bool isFinishedIn(api.CampReport report) =>
      (completedCount ?? 0) >= (report.cornerStats?.length ?? 0);

  List<String> unvisitedCornerNamesIn(api.CampReport report) =>
      report.unvisitedCornerNamesByGroupId[groupId] ?? const [];
}
