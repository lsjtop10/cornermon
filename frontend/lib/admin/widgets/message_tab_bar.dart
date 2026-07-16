import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cornermon/admin/features/track_direct/track_direct_providers.dart';
import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';

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

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space4,
        vertical: AppSpacing.space2,
      ),
      child: Row(
        children: [
          _TabButton(
            label: '공지',
            selected: current == MessageTab.broadcast,
            onTap: () => context.go('/messages/broadcast'),
          ),
          const SizedBox(width: AppSpacing.space2),
          _TabButton(
            label: '다이렉트',
            selected: current == MessageTab.direct,
            badgeCount: campId == null ? null : unreadTotal,
            onTap: () => context.go('/messages/direct'),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
    this.badgeCount,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space3,
          vertical: AppSpacing.space2,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTypography.bodyEmphasis.copyWith(
                color: selected ? colors.brandPrimary : colors.textSecondary,
              ),
            ),
            if (badgeCount != null && badgeCount! > 0) ...[
              const SizedBox(width: AppSpacing.space1),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: colors.danger,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  badgeCount! > 9 ? '9+' : '$badgeCount',
                  style: AppTypography.caption.copyWith(color: colors.bgSurface),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
