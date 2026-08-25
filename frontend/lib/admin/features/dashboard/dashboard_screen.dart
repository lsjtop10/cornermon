import 'package:cornermon/admin/features/dashboard/state/dashboard_connection_state.dart';
import 'package:cornermon/admin/features/dashboard/actions/dashboard_actions.dart';
import 'package:cornermon/admin/features/dashboard/state/dashboard_entries.dart';
import 'package:cornermon/admin/features/dashboard/state/dashboard_state.dart';
import 'package:cornermon/admin/features/dashboard/actions/track_pin_export_actions.dart';
import 'package:cornermon/admin/features/dashboard/widgets/corner_grid_skeleton.dart';
import 'package:cornermon/admin/features/dashboard/widgets/corner_status_card.dart';
import 'package:cornermon/admin/features/dashboard/widgets/summary_bar.dart';
import 'package:cornermon/admin/features/dashboard/widgets/toolbar.dart';
import 'package:cornermon/admin/features/dashboard/widgets/track_list_view.dart';
import 'package:cornermon/admin/features/track_direct/state/track_direct_state.dart';
import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/api/providers/corner_track_providers.dart'
    hide deleteCorner;
import 'package:cornermon/shared/api/providers/report_providers.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/widgets/empty_state.dart';
import 'package:cornermon/shared/design_system/widgets/connection_banner.dart';
import 'package:cornermon/shared/export/export_action_menu.dart';
import 'package:cornermon/shared/export/export_file.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final dashboardPinExportButtonKey = GlobalKey();

/// A1. 캠프 하나의 코너·트랙 현황을 보여주는 대시보드 — PENDING/ACTIVE 모두 사이드바
/// '대시보드' 항목 하나가 유일한 진입점이다. 카드형(코너 그리드)과 트랙별(코너 안에
/// 트랙을 펼친 목록)은 별도 화면이 아니라 [DashboardView] 하나로 전환되는, 같은
/// 필터·정렬 결과의 다른 렌더링일 뿐이다(노션의 뷰 전환과 동일한 발상) — 예전엔
/// '코너·트랙'이라는 별도 사이드바 항목(PENDING)과 '트랙별 보기 →' 버튼(ACTIVE)으로
/// 진입 경로 자체가 상태마다 달라 일관성이 없었다.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ref.watch(selectedCampIdProvider);
    if (id == null) {
      return const Scaffold(body: EmptyState(message: '선택된 캠프가 없습니다'));
    }
    final connectionLost = ref.watch(dashboardConnectionLostProvider);
    final view = ref.watch(dashboardViewProvider);
    final corners = ref.watch(cornerListProvider(id));
    final summary = ref.watch(liveSummaryProvider(id));
    final selectedCamp = ref.watch(selectedCampProvider).asData?.value;
    final exportState = ref.watch(trackPinExportControllerProvider);
    final isActive = selectedCamp?.status == api.CampStatus.ACTIVE;
    final directSummaries = isActive
        ? ref.watch(trackDirectSummariesProvider(id))
        : null;
    final unreadDirectCount = directSummaries?.maybeWhen(
      skipLoadingOnReload: true,
      data: (items) => items.fold<int>(0, (sum, s) => sum + s.unreadCount),
      orElse: () => 0,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('대시보드'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.space3),
            child: ExportActionButton(
              key: dashboardPinExportButtonKey,
              icon: Icons.download_outlined,
              label: '전체 PIN 내보내기',
              busy: exportState.isLoading,
              onSelected: (action) async {
                final buttonBox =
                    dashboardPinExportButtonKey.currentContext
                            ?.findRenderObject()
                        as RenderBox?;
                final sharePositionOrigin =
                    buttonBox != null && buttonBox.hasSize
                    ? buttonBox.localToGlobal(Offset.zero) & buttonBox.size
                    : null;
                final controller = ref.read(
                  trackPinExportControllerProvider.notifier,
                );
                final saveResult = action == ExportAction.saveToDevice
                    ? await controller.exportAndSave(id)
                    : null;
                if (action == ExportAction.shareWithApp) {
                  await controller.exportAndShare(
                    id,
                    sharePositionOrigin: sharePositionOrigin,
                  );
                }
                if (!context.mounted) return;
                final result = ref.read(trackPinExportControllerProvider);
                if (action == ExportAction.saveToDevice &&
                    saveResult == ExportSaveResult.cancelled &&
                    !result.hasError) {
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      result.hasError
                          ? 'PIN 엑셀 내보내기 실패: ${result.error}'
                          : action == ExportAction.saveToDevice
                          ? 'PIN 엑셀을 저장했습니다'
                          : 'PIN 엑셀을 내보냈습니다',
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(cornerListProvider(id));
          ref.invalidate(liveSummaryProvider(id));
          await Future.wait([
            ref.read(cornerListProvider(id).future),
            ref.read(liveSummaryProvider(id).future),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.space6),
          children: [
            // 앱 전역 SSE 연결배너(admin/app.dart)와 별개로, 이 배너는 코너 추가/삭제가
            // 커넥션 유실로 실패했을 때만 뜬다 — device_manage_screen.dart와 동일한 패턴
            // (state/dashboard_connection_state.dart 참고).
            ConnectionBanner(
              state: connectionLost
                  ? ConnectionBannerState.disconnected
                  : ConnectionBannerState.hidden,
            ),
            SummaryBar(
              summary: summary,
              unreadDirectCount: unreadDirectCount,
              isActive: isActive,
            ),
            const SizedBox(height: AppSpacing.space6),
            Toolbar(campId: id),
            const SizedBox(height: AppSpacing.space6),
            corners.when(
              loading: () => view == DashboardView.cards
                  ? const CornerGridSkeleton()
                  : const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: AppSpacing.space6,
                      ),
                      child: Center(child: CircularProgressIndicator()),
                    ),
              error: (error, _) => SizedBox(
                height: 300,
                child: EmptyState(
                  message: '코너를 불러오지 못했습니다.\n$error',
                  actionLabel: '재시도',
                  onAction: () => ref.invalidate(cornerListProvider(id)),
                ),
              ),
              data: (items) {
                final Iterable<api.BottleneckRanking> ranking = summary.when(
                  data: (value) => value.bottleneckRanking ?? [],
                  loading: () => [],
                  error: (_, _) => [],
                );
                final entries = buildDashboardEntries(items, ranking);
                final visible = sortEntries(
                  filterEntries(entries, ref.watch(dashboardFilterProvider)),
                  ref.watch(dashboardSortKeyProvider),
                  ref.watch(dashboardSortAscendingProvider),
                );
                if (visible.isEmpty) {
                  final noCorners = items.isEmpty;
                  return SizedBox(
                    height: 300,
                    child: EmptyState(
                      message: noCorners
                          ? '아직 생성된 코너가 없습니다'
                          : '조건에 맞는 코너가 없습니다',
                      icon: noCorners
                          ? Icons.account_tree_outlined
                          : Icons.filter_alt_off,
                      actionLabel: noCorners ? '코너 추가' : null,
                      onAction: noCorners
                          ? () => showAddCornerDialog(context, ref, id)
                          : null,
                    ),
                  );
                }
                return view == DashboardView.cards
                    ? GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 260,
                              // 카드 헤더 행의 삭제 아이콘 버튼이 컴팩트 컨트롤 표준
                              // (AppDimensions.iconButtonCompact, 44pt)만큼 높이를
                              // 차지하므로 220pt 기준값 + 그 여유분(22pt)을 더한다.
                              mainAxisExtent: 242,
                              crossAxisSpacing: AppSpacing.space3,
                              mainAxisSpacing: AppSpacing.space3,
                            ),
                        itemCount: visible.length,
                        itemBuilder: (context, index) {
                          final entry = visible[index];
                          return CornerStatusCard(
                            entry: entry,
                            onTap: () => context.go(
                              '/dashboard/corners/${entry.corner.id}',
                            ),
                            onCreateTrack: entry.inactive
                                ? () => context.go(
                                    '/dashboard/corners/${entry.corner.id}',
                                  )
                                : null,
                            onDelete: () =>
                                deleteCorner(context, ref, id, entry),
                          );
                        },
                      )
                    : TrackListView(
                        campId: id,
                        corners: [for (final entry in visible) entry.corner],
                      );
              },
            ),
          ],
        ),
      ),
    );
  }
}
