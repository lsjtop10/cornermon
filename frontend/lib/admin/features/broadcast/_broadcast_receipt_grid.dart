import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/message_providers.dart';
import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:cornermon/shared/design_system/widgets/empty_state.dart';

class BroadcastReceiptGrid extends ConsumerWidget {
  const BroadcastReceiptGrid({required this.messageId, super.key});

  final MessageId? messageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;

    if (messageId == null) {
      return const EmptyState(message: '공지를 선택하세요');
    }

    final receipts = ref.watch(broadcastReceiptsProvider(messageId!));

    return receipts.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('읽음 현황을 불러오지 못했습니다.\n$error')),
      data: (items) {
        if (items.isEmpty) {
          return const EmptyState(message: '발송 시점에 ACTIVE인 트랙이 없었습니다');
        }
        final readCount = items.where((r) => r.isRead == true).length;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.space4),
              child: Text(
                '$readCount / 전체 ${items.length}개 트랙 읽음',
                style: AppTypography.bodyEmphasis.copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space4,
                ),
                gridDelegate:
                    const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 180,
                      mainAxisSpacing: AppSpacing.space2,
                      crossAxisSpacing: AppSpacing.space2,
                      childAspectRatio: 1.6,
                    ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final receipt = items[index];
                  final isRead = receipt.isRead == true;
                  final bg = isRead
                      ? colors.success.withValues(alpha: isDark ? .2 : .12)
                      : colors.danger.withValues(alpha: isDark ? .2 : .12);
                  final fg = isRead ? colors.success : colors.danger;
                  return Container(
                    padding: const EdgeInsets.all(AppSpacing.space2),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${receipt.trackNo ?? '-'}번 트랙',
                          style: AppTypography.bodyEmphasis.copyWith(color: fg),
                        ),
                        Text(
                          receipt.cornerName ?? '',
                          style: AppTypography.caption.copyWith(color: fg),
                        ),
                        Icon(
                          isRead ? Icons.check_circle : Icons.circle_outlined,
                          color: fg,
                          size: 16,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
