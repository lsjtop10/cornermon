import 'package:cornermon/admin/widgets/track_row_actions.dart';
import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/corner_track_providers.dart';
import 'package:cornermon/shared/design_system/widgets/status_badge.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TrackTable extends ConsumerWidget {
  const TrackTable({required this.campId, required this.tracks, super.key});

  final CampId campId;
  final List<api.Track> tracks;

  @override
  Widget build(BuildContext context, WidgetRef ref) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: DataTable(
      columns: const [
        DataColumn(label: Text('트랙')),
        DataColumn(label: Text('상태')),
        DataColumn(label: Text('현재 조')),
        DataColumn(label: Text('PIN')),
        DataColumn(label: Text('액션')),
      ],
      rows: [
        for (final track in tracks)
          DataRow(
            cells: [
              DataCell(Text('${track.trackNo ?? '-'}번')),
              DataCell(
                StatusBadge(
                  status:
                      track.operationalStatus == api.TrackOperationalStatus.BUSY
                      ? TrackVisualStatus.busy
                      : TrackVisualStatus.idle,
                ),
              ),
              DataCell(Text(track.currentVisit?.groupId ?? '-')),
              const DataCell(Text('••••••')),
              DataCell(
                Builder(
                  builder: (buttonsContext) {
                    // 진행 중인 방문이 있는 트랙은 교체/삭제가 하드 블록 대상이다
                    // (deleteTrack/openReplaceTrackDialog가 실제로도 이 상태면 거부한다).
                    // §design-system.md 4.2가 처방한 대로 "누르고 나서 막기"가 아니라
                    // 버튼을 사전 비활성화 + 이유 툴팁으로 안내한다.
                    final isBusy =
                        track.operationalStatus ==
                        api.TrackOperationalStatus.BUSY;
                    return Wrap(
                      children: [
                        IconButton(
                          tooltip: 'PIN 보기',
                          onPressed: () =>
                              showTrackPinDialog(context, ref, track),
                          icon: const Icon(Icons.key_outlined),
                        ),
                        IconButton(
                          tooltip: 'PIN 재발급',
                          onPressed: () =>
                              regenerateTrackPin(context, ref, campId, track),
                          icon: const Icon(Icons.refresh),
                        ),
                        IconButton(
                          tooltip: isBusy
                              ? '진행 중인 방문이 완료된 후 다시 시도하세요'
                              : '트랙 교체',
                          onPressed: isBusy
                              ? null
                              : () async {
                                  final corners = await ref.read(
                                    cornerListProvider(campId).future,
                                  );
                                  if (!context.mounted) return;
                                  await openReplaceTrackDialog(
                                    context,
                                    ref,
                                    campId,
                                    track,
                                    corners
                                        .where(
                                          (corner) =>
                                              corner.id != track.cornerId,
                                        )
                                        .toList(),
                                    siblingActiveTrackCount: tracks.length,
                                  );
                                },
                          icon: const Icon(Icons.swap_horiz),
                        ),
                        IconButton(
                          tooltip: isBusy
                              ? '진행 중인 방문이 있어 삭제할 수 없습니다'
                              : '삭제',
                          onPressed: isBusy
                              ? null
                              : () => deleteTrack(
                                  context,
                                  ref,
                                  campId,
                                  track,
                                  siblingActiveTrackCount: tracks.length,
                                ),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
      ],
    ),
  );
}
