import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cornermon/admin/entities/message_ext.dart';
import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/message_providers.dart';
import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';
import 'package:cornermon/shared/design_system/widgets/empty_state.dart';
import 'package:cornermon/shared/widgets/local_time_label.dart';
import 'track_direct_providers.dart';

class ChatThreadPane extends ConsumerStatefulWidget {
  const ChatThreadPane({
    required this.campId,
    required this.trackId,
    required this.trackDeleted,
    super.key,
  });

  final CampId campId;
  final TrackId trackId;
  final bool trackDeleted;

  @override
  ConsumerState<ChatThreadPane> createState() => _ChatThreadPaneState();
}

class _ChatThreadPaneState extends ConsumerState<ChatThreadPane> {
  final _input = TextEditingController();
  final _messageListController = ScrollController();
  bool _scrollToBottomAfterListUpdate = false;

  @override
  void dispose() {
    _input.dispose();
    _messageListController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ChatThreadPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trackId.value != widget.trackId.value) {
      _markRead();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _markRead());
  }

  void _markRead() {
    // 스레드를 실제로 여는 시점이므로 background: true로 호출해 읽음 처리한다.
    ref.read(
      trackMessageListProvider(widget.trackId, background: true).future,
    );
  }

  void _scrollToBottom() {
    if (!_messageListController.hasClients) return;

    final maxScrollExtent = _messageListController.position.maxScrollExtent;
    _messageListController.animateTo(
      maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
    // lazy ListView는 첫 레이아웃 뒤에도 콘텐츠 추정치를 보정할 수 있다. 다음 두 프레임에
    // 마지막 위치를 다시 맞춰, 새 항목이 화면 밖에 남지 않게 한다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_messageListController.hasClients) return;
      _messageListController.jumpTo(
        _messageListController.position.maxScrollExtent,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_messageListController.hasClients) return;
        _messageListController.jumpTo(
          _messageListController.position.maxScrollExtent,
        );
      });
    });
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    _input.clear();
    await ref.read(sendDirectMessageProvider(widget.trackId, text).future);
    ref.invalidate(trackMessageListProvider(widget.trackId, background: true));
    ref.invalidate(trackDirectSummariesProvider(widget.campId));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;
    final messages = ref.watch(
      trackMessageListProvider(widget.trackId, background: true),
    );

    ref.listen(trackMessageListProvider(widget.trackId, background: true), (
      previous,
      next,
    ) {
      if (next.hasValue) {
        ref.invalidate(trackDirectSummariesProvider(widget.campId));
      }
      if (next.hasValue && !next.isLoading) {
        // provider 알림은 ListView의 새 itemCount 레이아웃보다 먼저 온다. 이 플래그는
        // data 분기에서 새 목록을 만든 뒤 post-frame 스크롤을 예약하는 데 쓴다. 관리자
        // 자신의 발송뿐 아니라 진행자가 보낸 메시지가 SSE로 도착해 재조회될 때도 동일하게
        // 최신 메시지가 화면 밖에 남지 않도록 항상 스크롤한다.
        _scrollToBottomAfterListUpdate = true;
      }
    });

    return Column(
      children: [
        Expanded(
          child: messages.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('대화를 불러오지 못했습니다.\n$error')),
            data: (items) {
              if (items.isEmpty) {
                return const EmptyState(message: '아직 나눈 대화가 없습니다');
              }
              if (_scrollToBottomAfterListUpdate) {
                _scrollToBottomAfterListUpdate = false;
                // ListView가 새 메시지를 포함해 레이아웃한 뒤 maxScrollExtent를 읽는다.
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _scrollToBottom(),
                );
              }
              return ListView.builder(
                key: const Key('admin-direct-message-list'),
                controller: _messageListController,
                padding: const EdgeInsets.all(AppSpacing.space4),
                itemCount: items.length,
                itemBuilder: (context, index) =>
                    _MessageBubble(message: items[index], colors: colors),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: widget.trackDeleted
              ? Text(
                  '삭제된 트랙에는 메시지를 보낼 수 없습니다',
                  style: AppTypography.caption.copyWith(
                    color: colors.textSecondary,
                  ),
                )
              : Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _input,
                        decoration: const InputDecoration(hintText: '메시지 입력'),
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space2),
                    AppButton(
                      variant: AppButtonVariant.iconOnly,
                      size: AppButtonSize.compact,
                      label: '전송',
                      icon: Icons.send_rounded,
                      onPressed: _send,
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.colors});

  final api.Message message;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final isAdmin = message.isFromAdmin;
    final bgColor = isAdmin ? colors.brandPrimary : colors.bgSurfaceRaised;
    final textColor = isAdmin ? colors.bgSurface : colors.textPrimary;

    return Align(
      alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isAdmin
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (message.isQuickReplyTag)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colors.danger.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '빠른 답장 · ${message.content}',
                  style: AppTypography.label.copyWith(color: colors.danger),
                ),
              ),
            ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: AppSpacing.space1),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space4,
              vertical: AppSpacing.space3,
            ),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.6,
            ),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message.content ?? '',
                  style: AppTypography.body.copyWith(color: textColor),
                ),
                const SizedBox(height: AppSpacing.space1),
                if (message.sentAt != null)
                  DefaultTextStyle.merge(
                    style: AppTypography.caption.copyWith(color: textColor),
                    child: LocalTimeLabel(dateTime: message.sentAt!),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
