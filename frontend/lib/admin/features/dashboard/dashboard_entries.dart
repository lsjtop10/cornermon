import 'package:cornermon/admin/features/dashboard/dashboard_state.dart';
import 'package:cornermon/shared/api/domain_aliases.dart' as api;

class CornerDashboardEntry {
  const CornerDashboardEntry(this.corner, {this.avgDeviationSeconds});
  final api.Corner corner;
  final num? avgDeviationSeconds;
  bool get inactive => corner.status == api.CornerOperationalStatus.INACTIVE;
  bool get hasBusyTrack => (corner.activeTracks?.toList() ?? const []).any(
    (track) => track.operationalStatus?.name == 'BUSY',
  );
}

List<CornerDashboardEntry> buildDashboardEntries(
  List<api.Corner> corners,
  Iterable<api.BottleneckRanking> ranking,
) {
  final deviations = {
    for (final item in ranking) item.cornerId: item.avgDeviationSeconds,
  };
  return [
    for (final corner in corners)
      CornerDashboardEntry(corner, avgDeviationSeconds: deviations[corner.id]),
  ];
}

List<CornerDashboardEntry> filterEntries(
  List<CornerDashboardEntry> entries,
  CornerFilterChip filter,
) => entries
    .where(
      (entry) => switch (filter) {
        CornerFilterChip.all => true,
        CornerFilterChip.busy =>
          entry.corner.status == api.CornerOperationalStatus.BUSY,
        CornerFilterChip.idle =>
          entry.corner.status == api.CornerOperationalStatus.IDLE,
        CornerFilterChip.inactive => entry.inactive,
        CornerFilterChip.bottleneckOnly => entry.corner.isBottleneck ?? false,
      },
    )
    .toList();
/// [key]가 가리키는 기준으로, [ascending]이 가리키는 방향으로 정렬한다 — 조 현황
/// 화면의 정렬 컨트롤(기준 드롭다운 + 방향 토글 버튼 분리)과 같은 형태를 공유한다
/// (critique frontend-lib-admin 2026-08-25 후속 — 화면마다 다른 정렬 위젯이 섞여
/// 있던 것을 하나의 패턴으로 통일).
List<CornerDashboardEntry> sortEntries(
  List<CornerDashboardEntry> entries,
  CornerSortKey key,
  bool ascending,
) {
  final result = [...entries];
  int number(CornerDashboardEntry value) =>
      int.tryParse(
        RegExp(r'\d+').firstMatch(value.corner.name ?? '')?.group(0) ?? '',
      ) ??
      1 << 30;
  int ordered(int compare) => ascending ? compare : -compare;
  int compareDeviation(CornerDashboardEntry a, CornerDashboardEntry b) {
    final av = a.avgDeviationSeconds;
    final bv = b.avgDeviationSeconds;
    if (av == null && bv == null) return 0;
    // 편차 데이터가 없는 코너는 정렬 방향과 무관하게 항상 맨 뒤로 보낸다.
    if (av == null) return 1;
    if (bv == null) return -1;
    return ascending ? av.compareTo(bv) : bv.compareTo(av);
  }
  result.sort((a, b) {
    if (a.inactive != b.inactive) return a.inactive ? 1 : -1;
    return switch (key) {
      CornerSortKey.cornerNo => ordered(number(a).compareTo(number(b))),
      CornerSortKey.name =>
        ordered((a.corner.name ?? '').compareTo(b.corner.name ?? '')),
      CornerSortKey.avgDeviation => compareDeviation(a, b),
    };
  });
  return result;
}

String formatCornerCardSubtitle({
  required int avgDurationSeconds,
  required int sampleCount,
  num? avgDeviationSeconds,
}) {
  String duration(num seconds) =>
      '${seconds ~/ 60}:${(seconds % 60).round().toString().padLeft(2, '0')}';
  final deviation = avgDeviationSeconds == null
      ? ''
      : ' (${avgDeviationSeconds >= 0 ? '+' : '-'}${duration(avgDeviationSeconds.abs())})';
  return '평균 ${duration(avgDurationSeconds)}$deviation · 최근 $sampleCount건';
}
