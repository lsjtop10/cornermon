import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/admin/widgets/adaptive_master_detail.dart';
import 'package:cornermon/admin/widgets/message_tab_bar.dart';
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/design_system/widgets/empty_state.dart';
import 'package:cornermon/shared/design_system/widgets/responsive_context.dart';
import '_broadcast_history_list.dart';
import '_broadcast_receipt_grid.dart';
import '_new_broadcast_modal.dart';

class BroadcastScreen extends ConsumerWidget {
  // messageId는 라우트 파라미터(admin_router.dart의 `/messages/broadcast/:messageId`)로
  // 들어온다 — track_direct_screen.dart와 동일한 이유로 provider 대신 이 값 하나가
  // 선택 상태의 소스다(#241).
  const BroadcastScreen({this.messageId, super.key});

  final MessageId? messageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campId = ref.watch(selectedCampIdProvider);
    if (campId == null) {
      return const Scaffold(body: EmptyState(message: '선택된 캠프가 없습니다'));
    }
    final isPhoneDetail = context.isPhoneWidth && messageId != null;

    return Scaffold(
      appBar: AppBar(
        leading: isPhoneDetail
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/messages/broadcast'),
              )
            : null,
        title: const Text('메시지'),
        actions: isPhoneDetail
            ? null
            : [
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
          if (!isPhoneDetail) ...[
            const MessageTabBar(current: MessageTab.broadcast),
            const Divider(height: 1),
          ],
          Expanded(
            child: AdaptiveMasterDetail(
              showDetailOnPhone: messageId != null,
              listPane: BroadcastHistoryList(
                campId: campId,
                selectedId: messageId,
                onSelect: (id) =>
                    context.go('/messages/broadcast/${id.value}'),
              ),
              detailPane: BroadcastReceiptGrid(messageId: messageId),
            ),
          ),
        ],
      ),
    );
  }
}
