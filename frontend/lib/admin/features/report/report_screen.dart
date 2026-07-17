import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'report_view_provider.dart';
import 'widgets/report_empty_state.dart';
import 'widgets/report_tabs.dart';

/// A12 — 코너학습 종료 후 사후 분석 리포트. 진입 경로 2가지(§screen-spec-admin.md A12):
/// ① 진행 중 캠프의 운영 사이드바 "리포트" 클릭(미생성 → empty state), ② 캠프 목록에서
/// 종료된 캠프 클릭(리포트 전용 축소 사이드바로 곧장 실데이터 3탭).
class ReportScreen extends ConsumerWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campId = ref.watch(selectedCampIdProvider);
    // 라우터 가드(admin_router.dart)가 campId == null이면 이미 /camps로 보냈을 것 — 방어적 처리.
    if (campId == null) return const SizedBox.shrink();

    final reportAsync = ref.watch(reportViewProvider(campId));

    return Scaffold(
      appBar: AppBar(title: const Text('리포트')),
      body: reportAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('리포트를 불러오지 못했습니다.\n$error')),
        data: (state) => switch (state) {
          ReportViewNotGenerated() => const ReportEmptyState(),
          ReportViewReady(:final report) => ReportTabs(report: report),
        },
      ),
    );
  }
}
