import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:cornermon/shared/design_system/widgets/empty_state.dart';
import 'package:cornermon/shared/widgets/local_time_label.dart';
import 'track_direct_providers.dart';

class TrackListPane extends ConsumerWidget {
  const TrackListPane({required this.campId, super.key});

  final CampId campId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;
    final summaries = ref.watch(trackDirectSummariesProvider(campId));
    final selected = ref.watch(selectedDirectTrackIdProvider);

    return summaries.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('트랙 목록을 불러오지 못했습니다.\n$error')),
      data: (items) {
        if (items.isEmpty) {
          return const EmptyState(message: '아직 생성된 트랙이 없습니다');
        }
        return ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final summary = items[index];
            final track = summary.track;
            final isDeleted = track.status == api.TrackStatus.DELETED;
            final isSelected = selected?.value == track.id;
            return Opacity(
              opacity: isDeleted ? 0.5 : 1.0,
              child: ListTile(
                selected: isSelected,
                selectedTileColor: colors.brandPrimary.withValues(alpha: .08),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${summary.cornerName} · ${track.trackNo ?? '-'}번 트랙',
                        style: AppTypography.bodyEmphasis.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    if (isDeleted)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colors.textDisabled.withValues(alpha: .2),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          '삭제됨',
                          style: AppTypography.caption.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
                subtitle: Row(
                  children: [
                    Expanded(
                      child: Text(
                        summary.lastMessage?.content ?? '대화 없음',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                    if (summary.lastMessage?.sentAt != null)
                      LocalTimeLabel(dateTime: summary.lastMessage!.sentAt!),
                  ],
                ),
                trailing: summary.unreadCount > 0
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colors.danger,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          '${summary.unreadCount}',
                          style: AppTypography.caption.copyWith(
                            color: colors.bgSurface,
                          ),
                        ),
                      )
                    : null,
                onTap: () => ref
                    .read(selectedDirectTrackIdProvider.notifier)
                    .select(TrackId(track.id ?? '')),
              ),
            );
          },
        );
      },
    );
  }
}
