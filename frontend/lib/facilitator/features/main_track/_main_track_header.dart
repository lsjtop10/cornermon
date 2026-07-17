import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/visit_providers.dart';
import 'package:cornermon/shared/api/sse/track_event_stream.dart';
import 'package:cornermon/facilitator/session/facilitator_broadcast_provider.dart';
import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';
import 'package:cornermon/shared/design_system/widgets/connection_banner.dart';
import 'package:cornermon/shared/design_system/widgets/status_badge.dart';

/// B2 헤더 — 상태뱃지 + 공지/다이렉트 아이콘(안읽음 뱃지 포함) + 연결배너.
class MainTrackHeader extends ConsumerWidget {
  const MainTrackHeader({required this.trackId, super.key});

  final TrackId trackId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBusy = ref
        .watch(currentVisitProvider(trackId))
        .maybeWhen(data: (visit) => visit != null, orElse: () => false);

    final unreadBroadcastCount = ref
        .watch(facilitatorBroadcastMessageListProvider)
        .maybeWhen(
          data: (messages) => messages.where((m) => m.readAt == null).length,
          orElse: () => 0,
        );

    // trackEvents 연결상태 매핑은 Phase 01의 TrackConnection이 이미 구현해뒀다(같은 파일,
    // trackEventsProvider를 build() 안 ref.listen으로 감싼 동일한 패턴) — 여기서 다시 만들지 않는다.
    final connectionBannerState = switch (ref.watch(
      trackConnectionProvider(trackId),
    )) {
      TrackConnectionState.connected => ConnectionBannerState.hidden,
      TrackConnectionState.reconnecting => ConnectionBannerState.reconnecting,
      TrackConnectionState.disconnected => ConnectionBannerState.disconnected,
    };

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space4,
            vertical: AppSpacing.space3,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatusBadge(
                status: isBusy
                    ? TrackVisualStatus.busy
                    : TrackVisualStatus.idle,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _IconWithBadge(
                    icon: Icons.campaign_outlined,
                    count: unreadBroadcastCount,
                    onPressed: () => context.go('/main/broadcast'),
                  ),
                  AppButton(
                    variant: AppButtonVariant.iconOnly,
                    size: AppButtonSize.comfortable,
                    label: '다이렉트 메시지',
                    icon: Icons.chat_bubble_outline,
                    onPressed: () => context.go('/main/direct'),
                  ),
                ],
              ),
            ],
          ),
        ),
        ConnectionBanner(state: connectionBannerState),
      ],
    );
  }
}

class _IconWithBadge extends StatelessWidget {
  const _IconWithBadge({
    required this.icon,
    required this.count,
    required this.onPressed,
  });

  final IconData icon;
  final int count;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        AppButton(
          variant: AppButtonVariant.iconOnly,
          size: AppButtonSize.comfortable,
          label: '공지',
          icon: icon,
          onPressed: onPressed,
        ),
        if (count > 0)
          Positioned(
            right: 2.0,
            top: 2.0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 5.0,
                vertical: 1.0,
              ),
              constraints: const BoxConstraints(minWidth: 16.0),
              decoration: BoxDecoration(
                color: colors.danger,
                borderRadius: BorderRadius.circular(100.0),
              ),
              child: Text(
                count > 99 ? '99+' : '$count',
                style: AppTypography.label.copyWith(
                  color: colors.bgSurface,
                  fontSize: 10.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
