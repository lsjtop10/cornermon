import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/corner_track_providers.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/widgets/empty_state.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cornermon/admin/features/dashboard/state/dashboard_track_grouping.dart';
import 'corner_group_section.dart';

/// "트랙별" 뷰 — 카드형과 같은 필터·정렬을 거친 [corners]를 트랙 단위로 펼쳐 보여주는
/// 순수 조회 렌더링이다. 코너/트랙 생성·삭제·수정은 카드형 뷰(코너)와 코너 상세
/// 화면(트랙)에 그대로 남아있다 — 이 뷰 자체에는 액션을 두지 않는다.
class TrackListView extends ConsumerWidget {
  const TrackListView({required this.campId, required this.corners, super.key});

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
