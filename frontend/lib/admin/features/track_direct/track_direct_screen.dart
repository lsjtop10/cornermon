import 'package:collection/collection.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/admin/widgets/adaptive_master_detail.dart';
import 'package:cornermon/admin/widgets/message_tab_bar.dart';
import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/design_system/widgets/empty_state.dart';
import 'package:cornermon/shared/design_system/widgets/responsive_context.dart';
import 'package:cornermon/admin/features/track_direct/_chat_thread_pane.dart';
import 'package:cornermon/admin/features/track_direct/_track_list_pane.dart';
import 'package:cornermon/admin/features/track_direct/track_direct_providers.dart';

class TrackDirectScreen extends ConsumerWidget {
  // trackId는 라우트 파라미터(admin_router.dart의 `/messages/direct/:trackId`)로
  // 들어온다 — 선택 상태의 유일한 소스라, 태블릿(분할 표시)과 스마트폰(상세 화면
  // 전환) 둘 다 이 값 하나로만 그린다(#241).
  const TrackDirectScreen({this.trackId, super.key});

  final TrackId? trackId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campId = ref.watch(selectedCampIdProvider);
    if (campId == null) {
      return const Scaffold(body: EmptyState(message: '선택된 캠프가 없습니다'));
    }
    final summaries = ref.watch(trackDirectSummariesProvider(campId));

    final selectedSummary = summaries.maybeWhen(
      skipLoadingOnReload: true,
      data: (items) =>
          items.firstWhereOrNull((s) => s.track.id == trackId?.value),
      orElse: () => null,
    );
    final isPhoneDetail = context.isPhoneWidth && trackId != null;

    return Scaffold(
      appBar: AppBar(
        leading: isPhoneDetail
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/messages/direct'),
              )
            : null,
        title: Text(
          isPhoneDetail && selectedSummary != null
              ? '${selectedSummary.cornerName} · '
                    '${selectedSummary.track.trackNo ?? '-'}번 트랙'
              : '메시지',
        ),
      ),
      body: Column(
        children: [
          if (!isPhoneDetail) ...[
            const MessageTabBar(current: MessageTab.direct),
            const Divider(height: 1),
          ],
          Expanded(
            child: AdaptiveMasterDetail(
              showDetailOnPhone: trackId != null,
              listPane: TrackListPane(
                campId: campId,
                selectedTrackId: trackId,
                onSelect: (id) => context.go('/messages/direct/${id.value}'),
              ),
              detailPane: trackId == null
                  ? const EmptyState(message: '트랙을 선택하세요')
                  : ChatThreadPane(
                      campId: campId,
                      trackId: trackId!,
                      trackDeleted:
                          selectedSummary?.track.status ==
                          api.TrackStatus.DELETED,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
