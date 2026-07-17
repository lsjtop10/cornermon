import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cornermon/admin/features/track_direct/track_direct_providers.dart';
import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/shared/design_system/widgets/pill_tab_bar.dart';

enum MessageTab { broadcast, direct }

class MessageTabBar extends ConsumerWidget {
  const MessageTabBar({required this.current, super.key});

  final MessageTab current;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campId = ref.watch(selectedCampIdProvider);

    int unreadTotal = 0;
    if (campId != null) {
      final summaries = ref.watch(trackDirectSummariesProvider(campId));
      unreadTotal = summaries.maybeWhen(
        data: (items) => items.fold<int>(0, (sum, s) => sum + s.unreadCount),
        orElse: () => 0,
      );
    }

    return PillTabBar(
      selectedIndex: current == MessageTab.broadcast ? 0 : 1,
      tabs: [
        const PillTab(label: '공지'),
        PillTab(label: '다이렉트', badgeCount: campId == null ? null : unreadTotal),
      ],
      onSelected: (index) =>
          context.go(index == 0 ? '/messages/broadcast' : '/messages/direct'),
    );
  }
}
