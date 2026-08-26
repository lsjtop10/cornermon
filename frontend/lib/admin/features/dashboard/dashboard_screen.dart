import 'package:cornermon/admin/features/dashboard/_corner_group_section.dart';
import 'package:cornermon/admin/features/dashboard/_corner_status_pill.dart';
import 'package:cornermon/admin/widgets/connection_lost_provider.dart';
import 'package:cornermon/admin/features/dashboard/dashboard_actions.dart';
import 'package:cornermon/admin/features/dashboard/dashboard_entries.dart';
import 'package:cornermon/admin/features/dashboard/dashboard_state.dart';
import 'package:cornermon/admin/features/dashboard/_inline_pill_tabs.dart';
import 'package:cornermon/admin/features/dashboard/dashboard_track_grouping.dart';
import 'package:cornermon/admin/features/dashboard/track_pin_export_controller.dart';
import 'package:cornermon/admin/features/track_direct/track_direct_providers.dart';
import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/corner_track_providers.dart'
    hide deleteCorner;
import 'package:cornermon/shared/api/providers/report_providers.dart';
import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/dimensions.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';
import 'package:cornermon/shared/design_system/widgets/app_dropdown.dart';
import 'package:cornermon/shared/design_system/widgets/empty_state.dart';
import 'package:cornermon/shared/design_system/widgets/connection_banner.dart';
import 'package:cornermon/shared/design_system/widgets/pill_tab_bar.dart';
import 'package:cornermon/shared/design_system/widgets/responsive_context.dart';
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
    final connectionLost = ref.watch(connectionLostProvider('dashboard'));
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
            // (connection_lost_provider.dart 참고).
            ConnectionBanner(
              state: connectionLost
                  ? ConnectionBannerState.disconnected
                  : ConnectionBannerState.hidden,
            ),
            _SummaryBar(
              summary: summary,
              unreadDirectCount: unreadDirectCount,
              isActive: isActive,
            ),
            const SizedBox(height: AppSpacing.space6),
            _Toolbar(campId: id),
            const SizedBox(height: AppSpacing.space6),
            corners.when(
              loading: () => view == DashboardView.cards
                  ? const _CornerGridSkeleton()
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
                        // maxCrossAxisExtent(260)는 태블릿/PC 전제 값 — 스마트폰 콘텐츠
                        // 폭(~300px)에서는 260이 두 번 안 들어가는데도 2열을 강제해
                        // 카드 하나가 ~150px로 짓눌리고, 카드 내부는 이미 1줄+말줄임표로
                        // 고정돼 있어(위 CornerStatusCard 주석) 결과가 대부분 잘려
                        // 보였다(#241). 폭이 좁을 땐 1열로 펴서 각 카드가 거의 전체
                        // 폭을 쓴다.
                        gridDelegate: context.isPhoneWidth
                            ? const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 1,
                                mainAxisExtent: _cornerCardExtent,
                                crossAxisSpacing: AppSpacing.space3,
                                mainAxisSpacing: AppSpacing.space3,
                              )
                            : const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 260,
                                mainAxisExtent: _cornerCardExtent,
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
                    : _TrackListView(
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

class _SummaryBar extends StatelessWidget {
  const _SummaryBar({
    required this.summary,
    required this.unreadDirectCount,
    required this.isActive,
  });
  final AsyncValue<api.CampSummaryStats> summary;
  final int? unreadDirectCount;
  final bool isActive;

  @override
  Widget build(BuildContext context) => summary.when(
    loading: () => const LinearProgressIndicator(),
    error: (_, _) => const Text('요약을 불러오지 못했습니다'),
    data: (item) {
      final tiles = <({String label, String value, String? route})>[
        (
          label: '완주율',
          value: '${(item.completionRate ?? 0).round()}%',
          route: null,
        ),
        (
          label: '미완주 조',
          value:
              '${(item.totalGroups ?? 0) - (item.finishedGroupCount ?? 0)}',
          route: null,
        ),
        (
          label: '경과시간',
          value:
              '${(item.programDurationSeconds ?? 0) ~/ 3600}시간 ${((item.programDurationSeconds ?? 0) % 3600) ~/ 60}분',
          route: null,
        ),
        if (isActive)
          (
            label: '안읽은 다이렉트',
            value: '$unreadDirectCount',
            route: '/messages/direct',
          ),
      ];
      // 관리자 화면의 1차 타겟은 iPad 가로(§design-system.md 3.2)라 태블릿/PC 폭에서는
      // 4분할 Row를 유지한다 — Expanded는 구조적으로 오버플로하지 않는다. 스마트폰 폭은
      // 이전엔 "지원하되 최적화 대상 아님"으로 명시적으로 배제했었지만(§design-system.md
      // 3.2), 이슈 241로 그 전제가 바뀌어 4칸이 짓눌리는 폭에서는 2열로 접는다(#241).
      // 아래로 흐르는 만큼 본문 높이가 늘어나는 건 이 폭에서는 의도된 트레이드오프다.
      return LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= AppDimensions.phoneBreakpoint) {
            return Row(
              children: [
                for (var i = 0; i < tiles.length; i++) ...[
                  if (i > 0) const SizedBox(width: AppSpacing.space3),
                  Expanded(
                    child: _SummaryTile(
                      label: tiles[i].label,
                      value: tiles[i].value,
                      route: tiles[i].route,
                    ),
                  ),
                ],
              ],
            );
          }
          final tileWidth = (constraints.maxWidth - AppSpacing.space3) / 2;
          return Wrap(
            spacing: AppSpacing.space3,
            runSpacing: AppSpacing.space3,
            children: [
              for (final tile in tiles)
                SizedBox(
                  width: tileWidth,
                  child: _SummaryTile(
                    label: tile.label,
                    value: tile.value,
                    route: tile.route,
                    // 2열 폭(~150px)에서는 display(36px)로 "0시간 0분" 같은 값이
                    // 말줄임표로 잘렸다 — 한 단계 작은 title2로 낮춘다(#241).
                    compact: true,
                  ),
                ),
            ],
          );
        },
      );
    },
  );
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.value,
    this.route,
    this.compact = false,
  });

  final String label;
  final String value;
  final String? route;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.dark
        ? AppColors.dark
        : AppColors.light;
    // 탭 가능한 타일만 시각적으로 다르게 표시한다(§design-system.md 0-6 —
    // 히트박스와 시각 신호는 항상 일치해야 한다) — 나머지 정보성 타일과 똑같은
    // Card 모양이면서 실제로는 하나만 눌리는 상황을 피한다.
    final tappable = route != null;
    return Card(
      child: InkWell(
        onTap: tappable ? () => context.go(route!) : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space4,
            vertical: AppSpacing.space3,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    // compact(2열 폭)에서는 "안읽은 다이렉트"처럼 라벨이 2줄로
                    // 감싸이는 타일만 카드가 더 커져 같은 줄의 다른 타일과 높이가
                    // 어긋났다(#241) — 2줄 몫을 항상 예약해 1줄 라벨도 같은 높이로
                    // 맞춘다. 4분할(태블릿/PC)에서는 라벨이 늘 1줄에 들어가므로
                    // 예약이 불필요해 그대로 둔다.
                    child: SizedBox(
                      height: compact
                          ? AppTypography.label.fontSize! *
                                AppTypography.label.height! *
                                2
                          : null,
                      child: Text(
                        label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.label.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  if (tappable)
                    Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: colors.textSecondary,
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.space1),
              Text(
                value,
                // 4분할 Row의 좁은 타일 폭에서 "경과시간" 같은 긴 값이 display(36px)로
                // 줄바꿈되면 같은 Row의 다른 타일과 카드 높이가 어긋나므로 1줄로 고정한다.
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: (compact ? AppTypography.title2 : AppTypography.display)
                    .copyWith(color: colors.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _cornerFilterLabels = {
  CornerFilterChip.all: '전체',
  CornerFilterChip.busy: '진행중',
  CornerFilterChip.idle: '유휴',
  CornerFilterChip.inactive: '미가동',
  CornerFilterChip.bottleneckOnly: '병목만',
};

const _cornerSortLabels = {
  CornerSortKey.cornerNo: '코너번호순',
  CornerSortKey.name: '이름순',
  CornerSortKey.avgDeviation: '평균편차순',
};

/// 필터·정렬·뷰 전환·추가를 한 줄에 모은다 — 조 현황 화면(group_list_screen.dart)과
/// 정확히 같은 순서(필터 → 정렬 기준 → 정렬 방향 → 추가)와 같은 위젯 형태(정렬은
/// 라벨 있는 드롭다운 + 방향 토글 아이콘, 추가는 라벨 있는 툴바 버튼)를 쓴다 —
/// 예전엔 이 화면은 드롭다운, 조 현황은 아이콘 전용 팝업으로 서로 다른 형태였다
/// (critique frontend-lib-admin 2026-08-25 후속 반영).
class _Toolbar extends ConsumerWidget {
  const _Toolbar({required this.campId});
  final CampId campId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ascending = ref.watch(dashboardSortAscendingProvider);
    final view = ref.watch(dashboardViewProvider);
    return Wrap(
      spacing: AppSpacing.space3,
      runSpacing: AppSpacing.space2,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // 이 툴바는 필터·정렬·뷰 전환·추가가 한 Wrap 안에서 나란히 흘러야 해서,
        // 그 줄을 혼자 차지하는 공용 PillTabBar 대신 내용만큼만 차지하는
        // InlinePillTabs를 쓴다(_inline_pill_tabs.dart 참고 — 이 화면만의 레이아웃
        // 요구사항으로 다른 화면이 쓰는 공용 위젯을 바꾸지 않기 위함).
        InlinePillTabs(
          tabs: [
            for (final value in CornerFilterChip.values)
              PillTab(label: _cornerFilterLabels[value]!),
          ],
          selectedIndex: CornerFilterChip.values.indexOf(
            ref.watch(dashboardFilterProvider),
          ),
          onSelected: (index) => ref
              .read(dashboardFilterProvider.notifier)
              .select(CornerFilterChip.values[index]),
        ),
        AppDropdown<CornerSortKey>(
          value: ref.watch(dashboardSortKeyProvider),
          onChanged: (value) {
            if (value != null) {
              ref.read(dashboardSortKeyProvider.notifier).select(value);
            }
          },
          items: [
            for (final key in CornerSortKey.values)
              DropdownMenuItem(value: key, child: Text(_cornerSortLabels[key]!)),
          ],
        ),
        Tooltip(
          message: ascending ? '오름차순' : '내림차순',
          child: AppButton(
            variant: AppButtonVariant.iconOnly,
            size: AppButtonSize.compact,
            icon: ascending ? Icons.arrow_upward : Icons.arrow_downward,
            label: ascending ? '오름차순' : '내림차순',
            onPressed: () =>
                ref.read(dashboardSortAscendingProvider.notifier).toggle(),
          ),
        ),
        // 노션 스타일 뷰 전환 — 카드형/트랙별은 같은 필터·정렬 결과의 다른 렌더링일
        // 뿐이라 화면 이동이 아니라 이 토글 하나로 바뀐다. PENDING/ACTIVE 모두 항상
        // 같은 자리에 노출한다(예전엔 PENDING만 사이드바 '코너·트랙' 항목, ACTIVE만
        // 이 자리의 '트랙별 보기 →' 버튼으로 진입 방식 자체가 상태마다 달랐다).
        //
        // 구조적으로 "여러 옵션 중 하나 선택"이라는 점에서 왼쪽의 필터와 성격이
        // 같다 — 새 토글 컴포넌트를 만드는 대신 같은 InlinePillTabs를 재사용한다.
        // (칠해진 캡슐로 만든 첫 시도는 "선택=텍스트 색만 바뀜, 배경은 채우지 않는다"
        // 원칙과 충돌해 바로 옆 필터와 서로 다른 "선택됨" 문법이 됐었다.)
        InlinePillTabs(
          tabs: const [PillTab(label: '카드형'), PillTab(label: '트랙별')],
          selectedIndex: DashboardView.values.indexOf(view),
          onSelected: (index) => ref
              .read(dashboardViewProvider.notifier)
              .select(DashboardView.values[index]),
        ),
        AppButton(
          variant: AppButtonVariant.secondary,
          size: AppButtonSize.compact,
          icon: Icons.add,
          label: '코너 추가',
          onPressed: () => showAddCornerDialog(context, ref, campId),
        ),
      ],
    );
  }
}

/// "트랙별" 뷰 — 카드형과 같은 필터·정렬을 거친 [corners]를 트랙 단위로 펼쳐 보여주는
/// 순수 조회 렌더링이다. 코너/트랙 생성·삭제·수정은 카드형 뷰(코너)와 코너 상세
/// 화면(트랙)에 그대로 남아있다 — 이 뷰 자체에는 액션을 두지 않는다.
class _TrackListView extends ConsumerWidget {
  const _TrackListView({required this.campId, required this.corners});

  final CampId campId;
  final List<api.Corner> corners;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracks = ref.watch(trackListProvider(campId));
    return tracks.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.space6),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => SizedBox(
        height: 300,
        child: EmptyState(
          message: '트랙을 불러오지 못했습니다.\n$error',
          actionLabel: '재시도',
          onAction: () => ref.invalidate(trackListProvider(campId)),
        ),
      ),
      data: (items) {
        final active = items
            .where((track) => track.status == api.TrackStatus.ACTIVE)
            .toList();
        final groups = groupTracksByCorner(corners, active);
        return Column(
          children: [
            for (final group in groups) CornerGroupSection(group: group),
          ],
        );
      },
    );
  }
}

class CornerStatusCard extends StatelessWidget {
  const CornerStatusCard({
    required this.entry,
    required this.onTap,
    this.onCreateTrack,
    this.onDelete,
    super.key,
  });

  final CornerDashboardEntry entry;
  final VoidCallback onTap;
  final VoidCallback? onCreateTrack;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.dark
        ? AppColors.dark
        : AppColors.light;
    final presentation = cornerStatusPresentation(entry.corner.status, colors);
    final metric = entry.corner.cornerMetric;
    final List<api.TrackSummary> tracks =
        entry.corner.activeTracks?.toList() ?? [];
    final busyTrackCount = tracks
        .where((track) => track.operationalStatus?.name == 'BUSY')
        .length;
    final subtitle = formatCornerCardSubtitle(
      avgDurationSeconds: metric?.avgDurationSeconds ?? 0,
      sampleCount: metric?.sampleCount ?? 0,
      avgDeviationSeconds: entry.avgDeviationSeconds,
    );
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: ValueKey('corner-card-${entry.corner.id}'),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                width: 4,
                color: entry.corner.isBottleneck ?? false
                    ? colors.statusAlert
                    : presentation.color,
              ),
            ),
          ),
          padding: const EdgeInsets.all(AppSpacing.space3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      entry.corner.name ?? '코너',
                      // 코너 이름은 관리자가 자유 입력하는 값이라 길이가 보장되지 않는다 —
                      // 이 카드는 고정 높이(mainAxisExtent: 242)라 줄바꿈을 허용하면
                      // 하단 내용(트랙 생성 버튼 등)이 Card의 clip에 잘려나간다.
                      // "스캔(훑어보기)" 원칙(§design-system.md 0-1)에도 축약이 더 맞다.
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyEmphasis.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  if (entry.corner.isBottleneck ?? false)
                    CornerStatusPill(
                      color: colors.statusAlert,
                      icon: '▲',
                      label: '병목',
                    ),
                  if (onDelete != null)
                    IconButton(
                      // 진행 중인 방문이 있으면 deleteCorner()가 실제로도 하드 블록한다 —
                      // §design-system.md 4.2가 처방한 대로 "누르고 나서 막기"가 아니라
                      // 버튼을 사전 비활성화 + 이유 툴팁으로 안내한다.
                      tooltip: entry.hasBusyTrack
                          ? '진행 중인 방문이 있어 삭제할 수 없습니다'
                          : '코너 삭제',
                      iconSize: 18,
                      // 시각적으로는 컴팩트하게 유지하되, 탭 영역은 이 앱의 컴팩트 밀도
                      // 컨트롤 표준(AppDimensions.iconButtonCompact, 44pt — §design-system.md
                      // 7-3의 관리자 최소 터치 타겟)과 맞춘다.
                      constraints: const BoxConstraints(
                        minWidth: AppDimensions.iconButtonCompact,
                        minHeight: AppDimensions.iconButtonCompact,
                      ),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      onPressed: entry.hasBusyTrack ? null : onDelete,
                      icon: Icon(
                        Icons.delete_outline,
                        color: entry.hasBusyTrack
                            ? colors.textDisabled
                            : colors.textSecondary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.space2),
              CornerStatusPill(
                color: presentation.color,
                icon: presentation.icon,
                label: presentation.label,
              ),
              const SizedBox(height: AppSpacing.space1),
              // 예전엔 두 정보를 " · "로 이어붙인 문자열 하나였다 — 좁은 카드
              // 폭에서 그 문자열 자체가 말줄임표로 잘렸다(#241 후속: "라벨을 왜
              // 한 줄에 다 이어붙이냐"는 지적). 서로 다른 사실이니 애초에 별개
              // 라벨로 나눠서 한 줄에 나란히 둔다 — 각 라벨 자체는 항상 짧아서
              // 줄바꿈이 필요 없다.
              _CornerCardStatRow(
                // "N트랙 중 M 진행중"보다 group_detail_screen.dart의 진행률
                // 표기(§design-system.md 진행률 "완료/전체")와 같은 "M/N" 축약이
                // 더 간결하다.
                primary: '진행중 $busyTrackCount/${tracks.length}트랙',
                secondary: '목표 ${entry.corner.targetMinutes ?? 0}분',
                color: colors.textSecondary,
                secondaryColor: colors.statusLimited,
              ),
              _CornerCardStatRow(
                primary: subtitle.duration,
                secondary: subtitle.sampleCount,
                color: entry.corner.isBottleneck ?? false
                    ? colors.statusAlert
                    : colors.textSecondary,
                bold: true,
              ),
              if (entry.inactive && onCreateTrack != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.space2,
                        vertical: AppSpacing.space1,
                      ),
                    ),
                    onPressed: onCreateTrack,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('트랙 생성'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 코너 카드 하단의 짧은 통계 라벨 한 쌍을 한 줄에 나란히 둔다(#241 후속) — 왼쪽
/// 라벨(길이가 트랙 수에 따라 늘어날 수 있음)만 Expanded로 여유를 흡수하고,
/// 오른쪽 라벨(항상 짧음)은 축약 없이 그대로 보여준다.
class _CornerCardStatRow extends StatelessWidget {
  const _CornerCardStatRow({
    required this.primary,
    required this.secondary,
    required this.color,
    this.secondaryColor,
    this.bold = false,
  });

  final String primary;
  final String secondary;
  final Color color;
  // 목표시간(관리자가 정한 제약값)처럼 오른쪽 라벨만 다른 시멘틱을 가질 때만 지정한다
  // — 지정 안 하면 왼쪽과 같은 [color].
  final Color? secondaryColor;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = AppTypography.caption.copyWith(
      color: color,
      fontWeight: bold ? FontWeight.w700 : null,
    );
    return Row(
      children: [
        Expanded(
          child: Text(
            primary,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        ),
        const SizedBox(width: AppSpacing.space2),
        Text(secondary, style: style.copyWith(color: secondaryColor ?? color)),
      ],
    );
  }
}

// 카드 헤더 행의 삭제 아이콘 버튼이 컴팩트 컨트롤 표준(AppDimensions.iconButtonCompact,
// 44pt)만큼 높이를 차지하므로 220pt 기준값 + 그 여유분(22pt)을 더한다 — 실제 카드
// (CornerStatusCard)·로딩 스켈레톤(_CornerGridSkeleton)이 반드시 같은 값을 쓰도록
// 한 곳에 둔다.
const double _cornerCardExtent = 242;

class _CornerGridSkeleton extends StatelessWidget {
  const _CornerGridSkeleton();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.dark
        ? AppColors.dark
        : AppColors.light;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      // 로딩 완료 후 카드 그리드와 동일 높이/열 수(레이아웃 점프 방지).
      gridDelegate: context.isPhoneWidth
          ? const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              mainAxisExtent: _cornerCardExtent,
              crossAxisSpacing: AppSpacing.space3,
              mainAxisSpacing: AppSpacing.space3,
            )
          : const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 260,
              mainAxisExtent: _cornerCardExtent,
              crossAxisSpacing: AppSpacing.space3,
              mainAxisSpacing: AppSpacing.space3,
            ),
      itemCount: 10,
      itemBuilder: (context, index) => Container(
        decoration: BoxDecoration(
          color: colors.textDisabled.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
