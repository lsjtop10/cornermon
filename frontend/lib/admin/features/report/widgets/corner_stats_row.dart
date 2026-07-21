import 'package:flutter/material.dart';

import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/util/duration_format.dart';

/// 코너별 탭 1행. `DataTable`은 `DataRow`를 직접 받는 API라 plan(10_a12_report.md §2.6)의
/// `StatelessWidget` 시그니처 대신 `DataRow`를 반환하는 순수 함수로 구현한다(기존 화면
/// `group_list_screen.dart`/`badge_precreate_screen.dart`의 `DataTable` 관례와 일관).
///
/// 컬럼: 코너명 / 완료 조 수("N/전체") / 평균 소요시간(편차) / 편차>0 비율.
///
/// **편차>0 비율**: `CornerStatsResponse.overDeviationRatio`(0~1, nullable) — issue #117로
/// 백엔드에 추가되어 PR #120(커밋 9c5cbdc)으로 이미 merge된 필드다. null이면(코너 데이터
/// 없음 등) "-", 아니면 `(ratio * 100).round()}%`로 렌더링한다. 더 이상 "-" 고정 표시가
/// 아니다(10_a12_report.md §0.1/§2.6의 예전 "확인 필요" 서술은 해소됨 — 문서에도 반영함).
DataRow buildCornerStatsRow({
  required api.CornerStats stats,
  required num? avgDeviationSeconds,
  required int? targetMinutes,
  required int? totalGroups,
}) {
  final completed = stats.completedVisitCount ?? 0;
  final completedLabel = totalGroups == null
      ? '$completed'
      : '$completed/$totalGroups';

  final durationLabel = (avgDeviationSeconds != null && targetMinutes != null)
      ? formatDurationWithDeviation(
          targetMinutes * 60 + avgDeviationSeconds.round(),
          avgDeviationSeconds,
        )
      : '-';

  final ratio = stats.overDeviationRatio;
  final ratioLabel = ratio == null ? '-' : '${(ratio * 100).round()}%';

  return DataRow(
    cells: [
      DataCell(Text(stats.cornerName ?? '코너')),
      DataCell(Text(completedLabel)),
      DataCell(Text(durationLabel)),
      DataCell(Text(ratioLabel)),
    ],
  );
}
