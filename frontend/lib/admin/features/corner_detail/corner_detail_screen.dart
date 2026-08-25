import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/corner_track_providers.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'widgets/corner_body.dart';

/// A2. 선택한 코너의 규칙과 ACTIVE 트랙을 관리한다.
class CornerDetailScreen extends ConsumerWidget {
  const CornerDetailScreen({required this.cornerId, super.key});

  final CornerId cornerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campId = ref.watch(selectedCampIdProvider);
    if (campId == null) return const SizedBox.shrink();
    final corner = ref.watch(cornerDetailProvider(cornerId));
    final tracks = ref.watch(trackListProvider(campId));
    // 대시보드의 카드형/트랙별 뷰 어느 쪽에서 들어와도 같은 화면(/dashboard)의 다른
    // 렌더링일 뿐이라 돌아갈 곳은 항상 하나다 — 뷰 선택 상태(dashboardViewProvider)는
    // provider에 남아있으므로 복귀 시 원래 보던 뷰 그대로 돌아간다.
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/dashboard'),
          icon: const Icon(Icons.arrow_back),
          tooltip: '대시보드로 돌아가기',
        ),
        title: const Text('코너 상세'),
      ),
      body: corner.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('코너를 불러오지 못했습니다.\n$error')),
        data: (value) => tracks.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('트랙을 불러오지 못했습니다.\n$error')),
          data: (items) => CornerBody(
            campId: campId,
            corner: value,
            tracks: items
                .where(
                  (track) =>
                      track.cornerId == value.id &&
                      track.status == api.TrackStatus.ACTIVE,
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
