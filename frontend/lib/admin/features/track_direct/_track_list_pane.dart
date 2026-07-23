import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/message_providers.dart';
import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:cornermon/shared/design_system/widgets/empty_state.dart';
import 'package:cornermon/shared/widgets/local_time_label.dart';
import 'track_direct_providers.dart';

class TrackListPane extends ConsumerWidget {
  const TrackListPane({required this.campId, super.key});

  final CampId campId;

  Future<void> _openThread(
    BuildContext context,
    WidgetRef ref,
    TrackId trackId,
  ) async {
    final readProvider = trackMessageListProvider(trackId, background: true);
    final container = ProviderScope.containerOf(context, listen: false);
    // 탭 직후에는 아직 ChatThreadPane이 provider를 watch하기 전일 수 있다. 임시 구독으로
    // 자동 dispose를 막아 읽음 처리 GET이 취소되지 않도록 한다.
    final subscription = container.listen(readProvider, (_, _) {});
    ref.read(selectedDirectTrackIdProvider.notifier).select(trackId);
    try {
      await container.read(readProvider.future);
      // 읽음 처리 응답은 스레드 provider에만 반영된다. 미리보기는 별도 family 인스턴스이므로
      // 서버의 최신 isRead 값을 다시 받아 배지를 즉시 제거한다.
      ref.invalidate(trackMessageListProvider(trackId, background: false));
      ref.invalidate(trackDirectSummariesProvider(campId));
    } finally {
      subscription.close();
    }
  }

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
                onTap: () => _openThread(
                  context,
                  ref,
                  TrackId(track.id ?? ''),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
