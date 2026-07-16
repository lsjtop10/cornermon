import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/admin/widgets/message_tab_bar.dart';
import 'package:cornermon/shared/design_system/widgets/empty_state.dart';
import '_broadcast_history_list.dart';
import '_broadcast_receipt_grid.dart';
import '_new_broadcast_modal.dart';
import 'broadcast_selection_provider.dart';

class BroadcastScreen extends ConsumerWidget {
  const BroadcastScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campId = ref.watch(selectedCampIdProvider);
    if (campId == null) {
      return const Scaffold(body: EmptyState(message: '선택된 캠프가 없습니다'));
    }
    final selectedId = ref.watch(selectedBroadcastIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('메시지'),
        actions: [
          IconButton(
            tooltip: '새 공지 작성',
            icon: const Icon(Icons.add_comment_outlined),
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => NewBroadcastModal(campId: campId),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const MessageTabBar(current: MessageTab.broadcast),
          const Divider(height: 1),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: BroadcastHistoryList(campId: campId),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  flex: 3,
                  child: BroadcastReceiptGrid(messageId: selectedId),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
