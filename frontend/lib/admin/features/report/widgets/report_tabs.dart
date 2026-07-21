import 'package:flutter/material.dart';

import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/design_system/widgets/pill_tab_bar.dart';
import 'package:cornermon/admin/features/report/report_export_button.dart';
import 'corner_stats_tab.dart';
import 'group_stats_tab.dart';
import 'summary_tab.dart';

/// 3탭(요약/코너별/조별) — 이 프로젝트의 실제 관례(`message_tab_bar.dart`, `group_list_screen.dart`
/// 등)를 따라 `PillTabBar` + 로컬 `selectedIndex` 상태로 구현한다(plan의 `TabController` 대신,
/// 10_a12_report.md §2.4의 디자인 일관성 요구사항 반영).
class ReportTabs extends StatefulWidget {
  const ReportTabs({required this.report, super.key});
  final api.CampReport report;

  @override
  State<ReportTabs> createState() => _ReportTabsState();
}

class _ReportTabsState extends State<ReportTabs> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final summary = widget.report.summary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: PillTabBar(
                selectedIndex: _selectedIndex,
                tabs: const [
                  PillTab(label: '요약'),
                  PillTab(label: '코너별'),
                  PillTab(label: '조별'),
                ],
                onSelected: (index) =>
                    setState(() => _selectedIndex = index),
              ),
            ),
            // 탭 전환과 무관하게 항상 보이는 고정 PDF 내보내기 버튼(screen-spec "탭 우측
            // PDF로 내보내기" 문구).
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: ReportExportButton(report: widget.report),
            ),
          ],
        ),
        const Divider(height: 1),
        Expanded(
          child: switch (_selectedIndex) {
            0 => summary == null
                ? const Center(child: Text('요약 데이터가 없습니다'))
                : ReportSummaryTab(summary: summary),
            1 => ReportCornerStatsTab(report: widget.report),
            _ => ReportGroupStatsTab(report: widget.report),
          },
        ),
      ],
    );
  }
}
