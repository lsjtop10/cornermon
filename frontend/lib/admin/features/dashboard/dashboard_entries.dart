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
List<CornerDashboardEntry> sortEntries(
  List<CornerDashboardEntry> entries,
  CornerSortOption option,
) {
  final result = [...entries];
  int number(CornerDashboardEntry value) =>
      int.tryParse(
        RegExp(r'\d+').firstMatch(value.corner.name ?? '')?.group(0) ?? '',
      ) ??
      1 << 30;
  result.sort((a, b) {
    if (a.inactive != b.inactive) return a.inactive ? 1 : -1;
    return switch (option) {
      CornerSortOption.cornerNo => number(a).compareTo(number(b)),
      CornerSortOption.name => (a.corner.name ?? '').compareTo(
        b.corner.name ?? '',
      ),
      CornerSortOption.avgDeviationDesc =>
        (b.avgDeviationSeconds ?? double.negativeInfinity).compareTo(
          a.avgDeviationSeconds ?? double.negativeInfinity,
        ),
      CornerSortOption.avgDeviationAsc =>
        (a.avgDeviationSeconds ?? double.infinity).compareTo(
          b.avgDeviationSeconds ?? double.infinity,
        ),
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
