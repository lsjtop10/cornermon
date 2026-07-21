import 'package:cornermon/admin/entities/group_ext.dart';
import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/corner_track_providers.dart';
import 'package:cornermon/shared/api/providers/group_providers.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:cornermon/shared/design_system/widgets/app_tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class GroupDetailScreen extends ConsumerWidget {
  const GroupDetailScreen({required this.groupId, super.key});
  final GroupId groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final group = ref.watch(groupDetailProvider(groupId));
    final visits = ref.watch(groupVisitsProvider(groupId));
    final campId = ref.watch(selectedCampIdProvider);
    final corners = campId == null
        ? null
        : ref.watch(cornerListProvider(campId));
    final tracks = campId == null ? null : ref.watch(trackListProvider(campId));
    final cornerNames = {
      for (final corner in corners?.asData?.value ?? const <api.Corner>[])
        if (corner.id != null) corner.id!: corner.name ?? corner.id!,
    };
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/groups'),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('조 상세'),
      ),
      body: group.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('조를 불러오지 못했습니다.\n$error')),
        data: (value) => ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _GroupSummaryHeader(group: value),
            const SizedBox(height: AppSpacing.space6),
            Text(
              '순회 진행률',
              style: AppTypography.title2.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.space2),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.space4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('완료 코너'),
                        Text(
                          value.completedCountLabel,
                          style: AppTypography.bodyEmphasis.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.space3),
                    LinearProgressIndicator(value: value.completionRate),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.space5),
            Text(
              '코너 방문 현황',
              style: AppTypography.title2.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.space2),
            _ItineraryStatusList(
              itinerary: value.itinerary ?? const <api.CornerProgress>[],
              cornerNames: cornerNames,
            ),
            const SizedBox(height: AppSpacing.space6),
            Text(
              '방문 이력',
              style: AppTypography.title2.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            visits.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => Text('방문 이력을 불러오지 못했습니다.\n$error'),
              data: (items) {
                final trackNumbers = {
                  for (final track
                      in tracks?.asData?.value ?? const <api.Track>[])
                    track.id!: track.trackNo,
                };
                final sorted = [...items]
                  ..sort(
                    (a, b) => (a.startedAt ?? DateTime(0)).compareTo(
                      b.startedAt ?? DateTime(0),
                    ),
                  );
                return Card(
                  clipBehavior: Clip.antiAlias,
                  margin: const EdgeInsets.only(top: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('코너')),
                        DataColumn(label: Text('트랙')),
                        DataColumn(label: Text('시작')),
                        DataColumn(label: Text('종료')),
                        DataColumn(label: Text('소요시간')),
                        DataColumn(label: Text('편차')),
                        DataColumn(label: Text('입력')),
                      ],
                      rows: [
                        for (final visit in sorted)
                          DataRow(
                            cells: [
                              DataCell(
                                Text(cornerNames[visit.cornerId] ?? '-'),
                              ),
                              DataCell(
                                Text(
                                  trackNumbers[visit.trackId] == null
                                      ? '-'
                                      : '트랙 ${trackNumbers[visit.trackId]}',
                                ),
                              ),
                              DataCell(Text(_time(visit.startedAt))),
                              DataCell(Text(_time(visit.endedAt))),
                              DataCell(Text(_duration(visit.durationSeconds))),
                              DataCell(
                                Text(_deviation(visit.deviationSeconds)),
                              ),
                              DataCell(Text(visit.inputMethod?.name ?? '-')),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupSummaryHeader extends StatelessWidget {
  const _GroupSummaryHeader({required this.group});

  final api.Group group;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          group.name ?? '이름 없는 조',
          style: AppTypography.title2.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      AppTag(
        label: group.isFinished == true ? '완주' : '진행 중',
        tone: group.isFinished == true
            ? AppTagTone.success
            : AppTagTone.warning,
      ),
    ],
  );
}

class _ItineraryStatusList extends StatelessWidget {
  const _ItineraryStatusList({
    required this.itinerary,
    required this.cornerNames,
  });

  final Iterable<api.CornerProgress> itinerary;
  final Map<String, String> cornerNames;

  @override
  Widget build(BuildContext context) {
    final items = itinerary.toList();
    if (items.isEmpty) {
      return const Card(
        child: ListTile(
          leading: Icon(Icons.route_outlined),
          title: Text('순회표가 아직 없습니다'),
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _itineraryColumnCount(constraints.maxWidth),
          mainAxisSpacing: AppSpacing.space2,
          crossAxisSpacing: AppSpacing.space2,
          childAspectRatio: 2.0,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) => _ItineraryStatusCard(
          progress: items[index],
          cornerName: cornerNames[items[index].cornerId],
        ),
      ),
    );
  }
}

int _itineraryColumnCount(double width) {
  if (width >= 800) return 5;
  if (width >= 600) return 4;
  if (width >= 400) return 3;
  return 2;
}

class _ItineraryStatusCard extends StatelessWidget {
  const _ItineraryStatusCard({
    required this.progress,
    required this.cornerName,
  });

  final api.CornerProgress progress;
  final String? cornerName;

  @override
  Widget build(BuildContext context) {
    final presentation = switch (progress.status) {
      api.VisitStatusPerCorner.COMPLETED => (
        label: '완료',
        tone: AppTagTone.success,
      ),
      api.VisitStatusPerCorner.IN_PROGRESS => (
        label: '방문 중',
        tone: AppTagTone.warning,
      ),
      _ => (label: '미방문', tone: AppTagTone.neutral),
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space3,
          vertical: AppSpacing.space2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              cornerName ??
                  progress.cornerName ??
                  progress.cornerId ??
                  '이름 없는 코너',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodyEmphasis.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.space1),
            AppTag(label: presentation.label, tone: presentation.tone),
          ],
        ),
      ),
    );
  }
}

String _time(DateTime? value) => value == null
    ? '-'
    : '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
String _duration(int? seconds) => seconds == null
    ? '-'
    : '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
String _deviation(int? seconds) {
  if (seconds == null) return '-';
  final prefix = seconds > 0
      ? '+'
      : seconds < 0
      ? '-'
      : '';
  return '$prefix${_duration(seconds.abs())}';
}
