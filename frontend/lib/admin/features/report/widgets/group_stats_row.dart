import 'package:flutter/material.dart';

import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/design_system/widgets/app_tag.dart';
import 'package:cornermon/shared/util/duration_format.dart';

/// 조별 탭 1행. `corner_stats_row.dart`와 동일한 이유로 `DataRow`를 반환하는 순수 함수로
/// 구현한다(plan 10_a12_report.md §2.7의 `StatelessWidget` 대신 — `DataTable` API 제약).
///
/// 컬럼: 조명 / 완주 여부 / 완료 코너 수("N/전체") / 총 활동시간 / 미완료 코너 목록.
DataRow buildGroupStatsRow({
  required api.GroupStats stats,
  required bool isFinished,
  required List<String> unvisitedCornerNames,
  required int? totalCorners,
}) {
  final completed = stats.completedCount ?? 0;
  final completedLabel = totalCorners == null
      ? '$completed'
      : '$completed/$totalCorners';
  final durationLabel = formatMmSs(stats.totalDurationSeconds ?? 0);
  final unvisitedLabel = isFinished || unvisitedCornerNames.isEmpty
      ? '-'
      : unvisitedCornerNames.join(', ');

  return DataRow(
    cells: [
      DataCell(Text(stats.groupName ?? '조')),
      DataCell(
        AppTag(
          label: isFinished ? '완주' : '미완주',
          tone: isFinished ? AppTagTone.success : AppTagTone.neutral,
        ),
      ),
      DataCell(Text(completedLabel)),
      DataCell(Text(durationLabel)),
      DataCell(Text(unvisitedLabel)),
    ],
  );
}
