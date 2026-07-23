import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/admin/widgets/message_tab_bar.dart';
import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/design_system/widgets/empty_state.dart';
import '_chat_thread_pane.dart';
import '_track_list_pane.dart';
import 'track_direct_providers.dart';

class TrackDirectScreen extends ConsumerWidget {
  const TrackDirectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campId = ref.watch(selectedCampIdProvider);
    if (campId == null) {
      return const Scaffold(body: EmptyState(message: '선택된 캠프가 없습니다'));
    }
    final selectedTrackId = ref.watch(selectedDirectTrackIdProvider);
    final summaries = ref.watch(trackDirectSummariesProvider(campId));

    final selectedSummary = summaries.maybeWhen(
      skipLoadingOnReload: true,
      data: (items) =>
          items.firstWhereOrNull((s) => s.track.id == selectedTrackId?.value),
      orElse: () => null,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('메시지')),
      body: Column(
        children: [
          const MessageTabBar(current: MessageTab.direct),
          const Divider(height: 1),
          Expanded(
            child: Row(
              children: [
                Expanded(flex: 2, child: TrackListPane(campId: campId)),
                const VerticalDivider(width: 1),
                Expanded(
                  flex: 3,
                  child: selectedTrackId == null
                      ? const EmptyState(message: '트랙을 선택하세요')
                      : ChatThreadPane(
                          campId: campId,
                          trackId: selectedTrackId,
                          trackDeleted:
                              selectedSummary?.track.status ==
                              api.TrackStatus.DELETED,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
