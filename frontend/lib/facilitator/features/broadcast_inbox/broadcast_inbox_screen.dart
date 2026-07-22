import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cornermon/shared/api/domain_aliases.dart';
import 'package:cornermon/shared/api/providers/message_providers.dart';
import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:cornermon/shared/design_system/widgets/empty_state.dart';
import 'package:cornermon/facilitator/session/facilitator_broadcast_provider.dart';
import 'package:cornermon/facilitator/session/track_session_provider.dart';
import 'package:cornermon/shared/widgets/local_time_label.dart';

/// B6 공지함 — 진입 시 안읽은 공지를 자동 읽음 처리한다(screen-spec-facilitator.md B6).
class BroadcastInboxScreen extends ConsumerStatefulWidget {
  const BroadcastInboxScreen({super.key});

  @override
  ConsumerState<BroadcastInboxScreen> createState() =>
      _BroadcastInboxScreenState();
}

class _BroadcastInboxScreenState extends ConsumerState<BroadcastInboxScreen> {
  final Set<String> _expandedIds = {};
  // 세션 내에서 이미 읽음 처리 API를 호출한 메시지 id — provider 재빌드 시 중복 호출 방지.
  final Set<String> _readRequestedIds = {};

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;

    // 목록이 갱신될 때마다(리빌드 포함) 안읽음 항목을 잡아낸다.
    ref.listen(facilitatorBroadcastMessageListProvider, (previous, next) {
      final messages = next.value;
      if (messages != null) {
        unawaited(_markUnreadAsRead(messages));
      }
    });

    final messagesAsync = ref.watch(facilitatorBroadcastMessageListProvider);

    return Scaffold(
      backgroundColor: colors.bgCanvas,
      appBar: AppBar(title: const Text('공지함')),
      body: messagesAsync.when(
        data: (messages) {
          // 최초 로드 시점(ref.listen은 이후 변경에만 반응하므로)에도 안읽음 항목을 잡아낸다.
          unawaited(_markUnreadAsRead(messages));

          if (messages.isEmpty) {
            return const EmptyState(message: '아직 도착한 공지가 없습니다');
          }

          // API가 순서를 보장하지 않으므로 화면에서 최신순으로 정렬한다.
          final sorted = [...messages]
            ..sort((a, b) => b.sentAt!.compareTo(a.sentAt!));

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.space4),
            itemCount: sorted.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: AppSpacing.space3),
            itemBuilder: (context, index) {
              final message = sorted[index];
              final unread = message.readAt == null;
              final expanded = _expandedIds.contains(message.id!);

              return _BroadcastMessageTile(
                message: message,
                unread: unread,
                expanded: expanded,
                colors: colors,
                onTap: () => setState(() {
                  if (expanded) {
                    _expandedIds.remove(message.id!);
                  } else {
                    _expandedIds.add(message.id!);
                  }
                }),
              );
            },
          );
        },
        error: (error, stackTrace) => Center(
          child: Text(
            '공지를 불러오지 못했습니다',
            style: AppTypography.body.copyWith(color: colors.danger),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Future<void> _markUnreadAsRead(List<Message> messages) async {
    final targets = messages
        .where((m) => m.readAt == null && !_readRequestedIds.contains(m.id))
        .toList();
    if (targets.isEmpty) return;

    _readRequestedIds.addAll(targets.map((m) => m.id!));

    try {
      final api = ref.read(messageApiProvider);
      await Future.wait(
        targets.map((m) => api.messagesBroadcastIdReadPost(id: m.id!)),
      );

      if (!mounted) return;
      // facade provider만 invalidate하면 내부 family의 HTTP 결과는 캐시된 채다.
      // 개별 호출이 모두 끝난 뒤 실제 목록 provider를 한 번만 무효화한다.
      final campId = facilitatorBroadcastCampId(
        ref.read(trackSessionProvider),
      );
      if (campId != null) {
        ref.invalidate(broadcastMessageListProvider(campId));
      }
    } catch (error, stackTrace) {
      _readRequestedIds.removeAll(targets.map((m) => m.id!));
      debugPrint('broadcast read request failed: $error\n$stackTrace');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('공지 읽음 처리에 실패했습니다')));
    }
  }
}

class _BroadcastMessageTile extends StatelessWidget {
  const _BroadcastMessageTile({
    required this.message,
    required this.unread,
    required this.expanded,
    required this.colors,
    required this.onTap,
  });

  final Message message;
  final bool unread;
  final bool expanded;
  final AppColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final contentStyle =
        (unread ? AppTypography.bodyEmphasis : AppTypography.body).copyWith(
          color: colors.textPrimary,
          fontWeight: unread ? FontWeight.bold : null,
        );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: colors.bgSurface,
          borderRadius: BorderRadius.circular(8.0),
          border: Border(
            left: BorderSide(
              color: unread ? colors.info : Colors.transparent,
              width: 3.0,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space4,
          vertical: AppSpacing.space3,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content ?? '',
              style: contentStyle,
              maxLines: expanded ? null : 2,
              overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.space1),
            DefaultTextStyle.merge(
              style: AppTypography.caption.copyWith(
                color: colors.textSecondary,
              ),
              child: LocalTimeLabel(dateTime: message.sentAt!),
            ),
          ],
        ),
      ),
    );
  }
}
