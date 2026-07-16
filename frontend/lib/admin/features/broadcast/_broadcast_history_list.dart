import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cornermon/admin/entities/message_ext.dart';
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/message_providers.dart';
import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:cornermon/shared/design_system/widgets/empty_state.dart';
import 'package:cornermon/shared/widgets/local_time_label.dart';
import 'broadcast_selection_provider.dart';

class BroadcastHistoryList extends ConsumerWidget {
  const BroadcastHistoryList({required this.campId, super.key});

  final CampId campId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;
    final messages = ref.watch(broadcastMessageListProvider(campId));
    final selectedId = ref.watch(selectedBroadcastIdProvider);

    return messages.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('공지 이력을 불러오지 못했습니다.\n$error')),
      data: (items) {
        if (items.isEmpty) {
          return const EmptyState(
            message: '아직 발송한 공지가 없습니다',
            icon: Icons.campaign_outlined,
          );
        }
        final sorted = items.newestFirst;
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(broadcastMessageListProvider(campId));
            await ref.read(broadcastMessageListProvider(campId).future);
          },
          child: ListView.separated(
            itemCount: sorted.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final message = sorted[index];
              final isSelected = selectedId?.value == message.id;
              return ListTile(
                selected: isSelected,
                selectedTileColor: colors.brandPrimary.withValues(alpha: .08),
                title: Text(
                  message.content ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body.copyWith(color: colors.textPrimary),
                ),
                subtitle: message.sentAt != null
                    ? LocalTimeLabel(dateTime: message.sentAt!)
                    : null,
                onTap: () => ref
                    .read(selectedBroadcastIdProvider.notifier)
                    .select(MessageId(message.id ?? '')),
              );
            },
          ),
        );
      },
    );
  }
}
