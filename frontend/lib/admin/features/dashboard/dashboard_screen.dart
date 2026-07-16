import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/api/providers/corner_track_providers.dart';
import 'package:cornermon/shared/api/providers/report_providers.dart';
import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/widgets/empty_state.dart';
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
    return Scaffold(
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
            _SummaryBar(summary: summary),
            const SizedBox(height: 20),
            _Controls(),
            const SizedBox(height: 12),
            _Filters(),
            const SizedBox(height: 16),
            corners.when(
              loading: () => const SizedBox(
                height: 400,
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
                  ref.watch(dashboardSortProvider),
                );
                if (visible.isEmpty) {
                  return const SizedBox(
                    height: 300,
                    child: EmptyState(
                      message: '조건에 맞는 코너가 없습니다',
                      icon: Icons.filter_alt_off,
                    ),
                  );
                }
                return GridView.count(
                  crossAxisCount: MediaQuery.sizeOf(context).width > 1100
                      ? 4
                      : 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.35,
                  children: [
                    for (final entry in visible)
                      CornerStatusCard(
                        entry: entry,
                        onTap: () => context.go('/corners/${entry.corner.id}'),
                      ),
                  ],
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
  const _SummaryBar({required this.summary});
  final AsyncValue<api.CampSummaryStats> summary;

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
        ('안읽은 다이렉트', '-'),
      ];
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (final tile in tiles)
            SizedBox(
              width: 160,
              child: Card(
                child: InkWell(
                  onTap: tile.$1 == '안읽은 다이렉트'
                      ? () => context.go('/messages/direct')
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tile.$1),
                        Text(
                          tile.$2,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    },
  );
}

class _Controls extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) => Wrap(
    spacing: 12,
    runSpacing: 8,
    children: [
      DropdownButton<CornerSortOption>(
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
      OutlinedButton(
        onPressed: () => context.go('/corner-track-manage'),
        child: const Text('트랙 일괄 관리 →'),
      ),
      FilledButton(
        onPressed: () => context.go('/messages/broadcast'),
        child: const Text('공지 발송'),
      ),
    ],
  );
}

class _Filters extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const labels = {
      CornerFilterChip.all: '전체',
      CornerFilterChip.busy: 'BUSY',
      CornerFilterChip.idle: 'IDLE',
      CornerFilterChip.inactive: '미가동',
      CornerFilterChip.bottleneckOnly: '병목만',
    };
    final selected = ref.watch(dashboardFilterProvider);
    return Wrap(
      spacing: 8,
      children: [
        for (final value in CornerFilterChip.values)
          FilterChip(
            label: Text(labels[value]!),
            selected: selected == value,
            onSelected: (_) =>
                ref.read(dashboardFilterProvider.notifier).select(value),
          ),
      ],
    );
  }
}

class CornerStatusCard extends StatelessWidget {
  const CornerStatusCard({required this.entry, required this.onTap, super.key});
  final CornerDashboardEntry entry;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.dark
        ? AppColors.dark
        : AppColors.light;
    final status = entry.corner.status;
    final color = status == api.CornerOperationalStatus.BUSY
        ? colors.statusIdle
        : status == api.CornerOperationalStatus.IDLE
        ? colors.quiet
        : colors.statusInactive;
    final metric = entry.corner.cornerMetric;
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                width: 4,
                color: entry.corner.isBottleneck ?? false
                    ? colors.statusAlert
                    : Colors.transparent,
              ),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.corner.name ?? '코너',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              Chip(
                avatar: Icon(Icons.circle, size: 12, color: color),
                label: Text(status?.name ?? '미가동'),
              ),
              Text('목표 ${entry.corner.targetMinutes ?? 0}분'),
              Text(
                formatCornerCardSubtitle(
                  avgDurationSeconds: metric?.avgDurationSeconds ?? 0,
                  sampleCount: metric?.sampleCount ?? 0,
                  avgDeviationSeconds: entry.avgDeviationSeconds,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
