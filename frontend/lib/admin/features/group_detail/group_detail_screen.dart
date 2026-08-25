import 'package:cornermon/admin/entities/group_ext.dart';
import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/corner_track_providers.dart';
import 'package:cornermon/shared/api/providers/group_providers.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'widgets/group_summary_header.dart';
import 'widgets/itinerary_status_list.dart';

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
          padding: const EdgeInsets.all(AppSpacing.space6),
          children: [
            GroupSummaryHeader(group: value),
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
            ItineraryStatusList(
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
                padding: EdgeInsets.all(AppSpacing.space6),
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
                  margin: const EdgeInsets.only(top: AppSpacing.space2),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowHeight: 48,
                      dataRowMinHeight: 48,
                      dataRowMaxHeight: 48,
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
