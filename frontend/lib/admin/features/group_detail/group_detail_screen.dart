import 'package:cornermon/admin/entities/group_ext.dart';
import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/corner_track_providers.dart';
import 'package:cornermon/shared/api/providers/group_providers.dart';
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
            Text(
              value.name ?? '이름 없는 조',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              value.isFinished == true
                  ? '완주 · ${value.completedCountLabel}'
                  : '진행 중 · ${value.completedCountLabel}',
            ),
            const SizedBox(height: 20),
            Text('순회표', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final progress
                    in value.itinerary ?? const <api.CornerProgress>[])
                  _ProgressCell(progress: progress),
              ],
            ),
            const SizedBox(height: 24),
            Text('방문 이력', style: Theme.of(context).textTheme.titleLarge),
            visits.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => Text('방문 이력을 불러오지 못했습니다.\n$error'),
              data: (items) {
                final cornerNames = {
                  for (final corner
                      in corners?.asData?.value ?? const <api.Corner>[])
                    corner.id!: corner.name ?? corner.id!,
                };
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

class _ProgressCell extends StatelessWidget {
  const _ProgressCell({required this.progress});
  final api.CornerProgress progress;
  @override
  Widget build(BuildContext context) {
    final status = progress.status;
    final icon = switch (status) {
      api.VisitStatusPerCorner.COMPLETED => Icons.check_circle,
      api.VisitStatusPerCorner.IN_PROGRESS => Icons.timelapse,
      _ => Icons.radio_button_unchecked,
    };
    return SizedBox(
      width: 112,
      child: Chip(
        avatar: Icon(icon),
        label: Text(progress.cornerName ?? progress.cornerId ?? '-'),
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
