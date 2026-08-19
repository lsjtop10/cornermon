import 'package:material_ui/material_ui.dart';

import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/util/duration_format.dart';

/// 트랙별 탭 1행. `corner_stats_row.dart`와 동일하게 `DataTable`이 `DataRow`를 직접 받는
/// API라 `DataRow`를 반환하는 순수 함수로 구현한다(이 코드베이스의 `DataTable` 관례).
///
/// 컬럼: 트랙 / 처리 건수 / 평균편차 / 수동 처리 비율.
///
/// **수동 처리 비율 스케일**: `backend/internal/infrastructure/web/report_handler.go`의
/// `mapReport` 트랙 순회 블록(코드 리딩, backend 수정 아님)을 확인한 결과
/// `manualVisitRatio := ManualCount / CompletedCount * 100`으로 이미 0~100 퍼센트
/// 스케일이다(`CampSummaryStatsResponse.manualVisitRatio`와 동일 규칙) — 추가 `×100` 금지.
DataRow buildTrackStatsRow(api.TrackStats stats) {
  final trackNo = stats.trackNo;
  final trackLabel = trackNo == null ? '트랙' : '$trackNo번 트랙';
  final handled = stats.handledVisitCount ?? 0;
  final avgDeviationSeconds = stats.avgDeviationSeconds ?? 0;
  final manualRatioPct = (stats.manualVisitRatio ?? 0).round();

  return DataRow(
    cells: [
      DataCell(Text(trackLabel)),
      DataCell(Text('$handled')),
      DataCell(Text(formatSignedMmSs(avgDeviationSeconds))),
      DataCell(Text('$manualRatioPct%')),
    ],
  );
}
