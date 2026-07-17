import 'package:cornermon/admin/features/track_direct/track_direct_providers.dart';
import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/api/providers/corner_track_providers.dart';
import 'package:cornermon/shared/api/providers/report_providers.dart';
import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';
import 'package:cornermon/shared/design_system/widgets/app_dropdown.dart';
import 'package:cornermon/shared/design_system/widgets/empty_state.dart';
import 'package:cornermon/shared/design_system/widgets/connection_banner.dart';
import 'package:cornermon/shared/design_system/widgets/pill_tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum CornerSortOption { cornerNo, name, avgDeviationDesc, avgDeviationAsc }

enum CornerFilterChip { all, busy, idle, inactive, bottleneckOnly }

final dashboardSortProvider = NotifierProvider<DashboardSort, CornerSortOption>(
  DashboardSort.new,
);

class DashboardSort extends Notifier<CornerSortOption> {
  @override
  CornerSortOption build() => CornerSortOption.cornerNo;
  void select(CornerSortOption value) => state = value;
}

final dashboardFilterProvider =
    NotifierProvider<DashboardFilter, CornerFilterChip>(DashboardFilter.new);

class DashboardFilter extends Notifier<CornerFilterChip> {
  @override
  CornerFilterChip build() => CornerFilterChip.all;
  void select(CornerFilterChip value) => state = value;
}

class CornerDashboardEntry {
  const CornerDashboardEntry(this.corner, {this.avgDeviationSeconds});
  final api.Corner corner;
  final num? avgDeviationSeconds;
  bool get inactive => corner.status == api.CornerOperationalStatus.INACTIVE;
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

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ref.watch(selectedCampIdProvider);
    if (id == null) {
      return const Scaffold(body: EmptyState(message: '선택된 캠프가 없습니다'));
    }
    final corners = ref.watch(cornerListProvider(id));
    final summary = ref.watch(liveSummaryProvider(id));
    final selectedCamp = ref.watch(selectedCampProvider).asData?.value;
    final isActive = selectedCamp?.status == api.CampStatus.ACTIVE;
    final directSummaries = isActive
        ? ref.watch(trackDirectSummariesProvider(id))
        : null;
    final unreadDirectCount = directSummaries?.maybeWhen(
      data: (items) => items.fold<int>(0, (sum, s) => sum + s.unreadCount),
      orElse: () => 0,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('대시보드')),
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
          padding: const EdgeInsets.all(24),
          children: [
            const ConnectionBanner(state: ConnectionBannerState.hidden),
            _SummaryBar(
              summary: summary,
              unreadDirectCount: unreadDirectCount,
              isActive: isActive,
            ),
            const SizedBox(height: 20),
            _Controls(isActive: isActive),
            const SizedBox(height: 12),
            _Filters(),
            const SizedBox(height: 16),
            corners.when(
              loading: () => const _CornerGridSkeleton(),
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
                  ref.watch(dashboardSortProvider),
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
                      actionLabel: noCorners ? '코너·트랙 관리' : null,
                      onAction: noCorners
                          ? () => context.go('/corner-track-manage')
                          : null,
                    ),
                  );
                }
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 260,
                        mainAxisExtent: 220,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                  itemCount: visible.length,
                  itemBuilder: (context, index) {
                    final entry = visible[index];
                    return CornerStatusCard(
                      entry: entry,
                      onTap: () =>
                          context.go('/dashboard/corners/${entry.corner.id}'),
                      onCreateTrack: entry.inactive
                          ? () => context.go('/corner-track-manage')
                          : null,
                    );
                  },
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
      final tiles = [
        ('완주율', '${((item.completionRate ?? 0) * 100).round()}%'),
        (
          '진행중 조',
          '${(item.totalGroups ?? 0) - (item.finishedGroupCount ?? 0)}',
        ),
        (
          '경과시간',
          '${(item.programDurationSeconds ?? 0) ~/ 3600}시간 ${((item.programDurationSeconds ?? 0) % 3600) ~/ 60}분',
        ),
        if (isActive) ('안읽은 다이렉트', '$unreadDirectCount'),
      ];
      final colors = Theme.of(context).brightness == Brightness.dark
          ? AppColors.dark
          : AppColors.light;
      return Row(
        children: [
          for (var i = 0; i < tiles.length; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            Expanded(
              child: Card(
                child: InkWell(
                  onTap: tiles[i].$1 == '안읽은 다이렉트'
                      ? () => context.go('/messages/direct')
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tiles[i].$1,
                          style: AppTypography.label.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tiles[i].$2,
                          style: AppTypography.display.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      );
    },
  );
}

class _Controls extends ConsumerWidget {
  const _Controls({required this.isActive});
  final bool isActive;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      AppDropdown<CornerSortOption>(
        value: ref.watch(dashboardSortProvider),
        onChanged: (value) {
          if (value != null) {
            ref.read(dashboardSortProvider.notifier).select(value);
          }
        },
        items: const [
          DropdownMenuItem(
            value: CornerSortOption.cornerNo,
            child: Text('코너번호순'),
          ),
          DropdownMenuItem(value: CornerSortOption.name, child: Text('이름순')),
          DropdownMenuItem(
            value: CornerSortOption.avgDeviationDesc,
            child: Text('평균편차 높은순'),
          ),
          DropdownMenuItem(
            value: CornerSortOption.avgDeviationAsc,
            child: Text('평균편차 낮은순'),
          ),
        ],
      ),
      Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          AppButton(
            variant: AppButtonVariant.secondary,
            label: '트랙 일괄 관리 →',
            onPressed: () => context.go('/corner-track-manage'),
          ),
          if (isActive)
            AppButton(
              variant: AppButtonVariant.primary,
              label: '공지 발송',
              onPressed: () => context.go('/messages/broadcast'),
            ),
        ],
      ),
    ],
  );
}

const _cornerFilterLabels = {
  CornerFilterChip.all: '전체',
  CornerFilterChip.busy: '진행중',
  CornerFilterChip.idle: '유휴',
  CornerFilterChip.inactive: '미가동',
  CornerFilterChip.bottleneckOnly: '병목만',
};

class _Filters extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(dashboardFilterProvider);
    return PillTabBar(
      tabs: [
        for (final value in CornerFilterChip.values)
          PillTab(label: _cornerFilterLabels[value]!),
      ],
      selectedIndex: CornerFilterChip.values.indexOf(selected),
      onSelected: (index) => ref
          .read(dashboardFilterProvider.notifier)
          .select(CornerFilterChip.values[index]),
    );
  }
}

class CornerStatusCard extends StatelessWidget {
  const CornerStatusCard({
    required this.entry,
    required this.onTap,
    this.onCreateTrack,
    super.key,
  });

  final CornerDashboardEntry entry;
  final VoidCallback onTap;
  final VoidCallback? onCreateTrack;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.dark
        ? AppColors.dark
        : AppColors.light;
    final status = entry.corner.status;
    final presentation = switch (status) {
      api.CornerOperationalStatus.BUSY => (
        color: colors.statusIdle,
        icon: '●',
        label: '정상',
      ),
      api.CornerOperationalStatus.IDLE => (
        color: colors.quiet,
        icon: '○',
        label: '유휴',
      ),
      _ => (color: colors.statusInactive, icon: '✕', label: '미가동'),
    };
    final metric = entry.corner.cornerMetric;
    final List<api.TrackSummary> tracks =
        entry.corner.activeTracks?.toList() ?? [];
    final busyTrackCount = tracks
        .where((track) => track.operationalStatus?.name == 'BUSY')
        .length;
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
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
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
                      style: AppTypography.bodyEmphasis.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  if (entry.corner.isBottleneck ?? false)
                    _CornerStatusPill(
                      color: colors.statusAlert,
                      icon: '▲',
                      label: '병목',
                    ),
                ],
              ),
              const SizedBox(height: 8),
              _CornerStatusPill(
                color: presentation.color,
                icon: presentation.icon,
                label: presentation.label,
              ),
              const SizedBox(height: 4),
              Text(
                '활성 ${tracks.length}트랙 중 $busyTrackCount 진행중 · 목표 ${entry.corner.targetMinutes ?? 0}분',
                style: AppTypography.caption.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              Text(
                formatCornerCardSubtitle(
                  avgDurationSeconds: metric?.avgDurationSeconds ?? 0,
                  sampleCount: metric?.sampleCount ?? 0,
                  avgDeviationSeconds: entry.avgDeviationSeconds,
                ),
                style: AppTypography.caption.copyWith(
                  color: entry.corner.isBottleneck ?? false
                      ? colors.statusAlert
                      : colors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (entry.inactive && onCreateTrack != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
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
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 260,
        mainAxisExtent: 220,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
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

class _CornerStatusPill extends StatelessWidget {
  const _CornerStatusPill({
    required this.color,
    required this.icon,
    required this.label,
  });

  final Color color;
  final String icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final opacity = Theme.of(context).brightness == Brightness.dark ? .20 : .12;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        '$icon  $label',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(color: color),
      ),
    );
  }
}
