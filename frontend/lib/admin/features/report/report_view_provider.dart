import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/report_providers.dart';
import 'package:cornermon/admin/session/selected_camp_provider.dart';

part 'report_view_provider.g.dart';

/// 10_a12_report.md §2.3 — 리포트 미생성 상태를 provider 레벨에서 흡수한다.
sealed class ReportViewState {
  const ReportViewState();
}

class ReportViewNotGenerated extends ReportViewState {
  const ReportViewNotGenerated();
}

class ReportViewReady extends ReportViewState {
  const ReportViewReady(this.report);
  final api.CampReport report;
}

/// ACTIVE/PENDING 캠프(진행 중)는 `currentReport` 호출 자체를 시도하지 않고 곧장
/// [ReportViewNotGenerated]를 반환한다 — 캠프 status는 [selectedCampProvider]에서 이미
/// 알고 있으므로 "404를 기다렸다 판단"하지 않는다(§screen-spec "코너학습 진행 중(리포트
/// 미생성)" 문구와 정확히 대응, analytics-model.md §2 "캠프 종료 시점에만 배치 계산").
/// ENDED 캠프인 경우에만 `currentReport(campId)`를 호출하며, 실패(404 등 어떤 예외든)해도
/// [ReportViewNotGenerated]로 방어적으로 폴백한다 — API 계약에 미생성 시 응답이 명시돼
/// 있지 않기 때문(§0.1, PR #120으로 해소된 overDeviationRatio 갭과는 별개 사항).
@riverpod
Future<ReportViewState> reportView(Ref ref, CampId campId) async {
  final camp = await ref.watch(selectedCampProvider.future);
  if (camp?.status != api.CampStatus.ENDED) {
    return const ReportViewNotGenerated();
  }
  try {
    final report = await ref.watch(currentReportProvider(campId).future);
    return ReportViewReady(report);
  } catch (_) {
    return const ReportViewNotGenerated();
  }
}
