import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cornermon/shared/api/domain_aliases.dart';
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/message_providers.dart';
import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';
import 'package:cornermon/shared/design_system/widgets/empty_state.dart';
import 'package:cornermon/facilitator/session/track_session_provider.dart';
import 'package:cornermon/shared/widgets/local_time_label.dart';
import 'track_direct_actions_provider.dart';

const _quickReplies = ['인원부족', '자재부족', '긴급도움요청'];

/// B7 다이렉트 메시지 — 관리자와의 1:1 스레드(screen-spec-facilitator.md B7).
class TrackDirectScreen extends ConsumerStatefulWidget {
  const TrackDirectScreen({super.key});

  @override
  ConsumerState<TrackDirectScreen> createState() => _TrackDirectScreenState();
}

class _TrackDirectScreenState extends ConsumerState<TrackDirectScreen> {
  final _inputController = TextEditingController();
  final _messageListController = ScrollController();
  bool _scrollToBottomAfterSend = false;

  @override
  void dispose() {
    _inputController.dispose();
    _messageListController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (!_messageListController.hasClients) return;

    _messageListController.animateTo(
      _messageListController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;

    final sessionState = ref.watch(trackSessionProvider);
    if (sessionState is! TrackSessionAuthenticated) {
      // 라우터 가드가 인증 후에만 이 화면으로 보내므로 정상 흐름에선 도달하지 않는다.
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final trackId = TrackId(sessionState.track.id!);

    ref.listen(
      trackMessageListProvider(trackId, background: true),
      (_, next) {
        if (next.hasValue) {
          ref.invalidate(unreadDirectMessageCountProvider(trackId));
        }
        if (_scrollToBottomAfterSend && next.hasValue && !next.isLoading) {
          _scrollToBottomAfterSend = false;
          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
        }
      },
    );
    final messagesAsync = ref.watch(
      trackMessageListProvider(trackId, background: true),
    );

    return Scaffold(
      backgroundColor: colors.bgCanvas,
      appBar: AppBar(title: const Text('관리자와의 대화')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: messagesAsync.when(
                data: (messages) {
                  if (messages.isEmpty) {
                    return const EmptyState(
                      message: '아직 나눈 대화가 없습니다 · 도움이 필요하면 먼저 메시지를 보내 보세요',
                    );
                  }

                  // 채팅 스레드는 오래된 메시지가 위, 최신 메시지가 아래로 오도록 정렬한다.
                  final sorted = [...messages]
                    ..sort((a, b) => a.sentAt!.compareTo(b.sentAt!));

                  return ListView.builder(
                    key: const Key('direct-message-list'),
                    controller: _messageListController,
                    padding: const EdgeInsets.all(AppSpacing.space4),
                    itemCount: sorted.length,
                    itemBuilder: (context, index) =>
                        _MessageBubble(message: sorted[index], colors: colors),
                  );
                },
                error: (error, stackTrace) => Center(
                  child: Text(
                    '대화 내역을 불러오지 못했습니다',
                    style: AppTypography.body.copyWith(color: colors.danger),
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
              ),
            ),
            // 빈 스레드여도 입력창은 항상 노출 — 진행자가 먼저 말을 걸 수 있어야 한다.
            _QuickReplyRow(
              trackId: trackId,
              colors: colors,
              onSendSucceeded: () => _scrollToBottomAfterSend = true,
            ),
            _MessageInputRow(
              trackId: trackId,
              controller: _inputController,
              colors: colors,
              onSendSucceeded: () => _scrollToBottomAfterSend = true,
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.colors});

  final Message message;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final isSelf = message.senderRole == MessageSenderRoleEnum.TRACK;
    final bgColor = isSelf ? colors.brandPrimary : colors.bgSurfaceRaised;
    final textColor = isSelf ? colors.bgSurface : colors.textPrimary;

    return Align(
      alignment: isSelf ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.space1),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space4,
          vertical: AppSpacing.space3,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16.0),
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
            DefaultTextStyle.merge(
              style: AppTypography.caption.copyWith(color: textColor),
              child: LocalTimeLabel(dateTime: message.sentAt!),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickReplyRow extends ConsumerWidget {
  const _QuickReplyRow({
    required this.trackId,
    required this.colors,
    required this.onSendSucceeded,
  });

  final TrackId trackId;
  final AppColors colors;
  final VoidCallback onSendSucceeded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space4,
        AppSpacing.space2,
        AppSpacing.space4,
        0,
      ),
      child: Wrap(
        spacing: AppSpacing.space2,
        runSpacing: AppSpacing.space2,
        children: _quickReplies
            .map(
              (label) => ActionChip(
                label: Text(
                  label,
                  style: AppTypography.caption.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                backgroundColor: colors.bgSurfaceRaised,
                side: BorderSide(color: colors.border),
                onPressed: () => _send(
                  context,
                  ref,
                  trackId,
                  label,
                  onSendSucceeded: onSendSucceeded,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _MessageInputRow extends ConsumerWidget {
  const _MessageInputRow({
    required this.trackId,
    required this.controller,
    required this.colors,
    required this.onSendSucceeded,
  });

  final TrackId trackId;
  final TextEditingController controller;
  final AppColors colors;
  final VoidCallback onSendSucceeded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> submit() async {
      final text = controller.text.trim();
      if (text.isEmpty) return;
      controller.clear();
      await _send(
        context,
        ref,
        trackId,
        text,
        onSendSucceeded: onSendSucceeded,
      );
    }

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.space4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: '메시지 입력',
                filled: true,
                fillColor: colors.bgSurface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space4,
                  vertical: AppSpacing.space2,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.0),
                  borderSide: BorderSide(color: colors.border),
                ),
              ),
              onSubmitted: (_) => submit(),
            ),
          ),
          const SizedBox(width: AppSpacing.space2),
          AppButton(
            variant: AppButtonVariant.iconOnly,
            size: AppButtonSize.comfortable,
            label: '전송',
            icon: Icons.send_rounded,
            onPressed: submit,
          ),
        ],
      ),
    );
  }
}

Future<void> _send(
  BuildContext context,
  WidgetRef ref,
  TrackId trackId,
  String content, {
  VoidCallback? onSendSucceeded,
}
) async {
  try {
    await ref.read(trackDirectActionsProvider(trackId).notifier).send(content);
    // 화면의 ref로 invalidate한다 — action notifier는 위젯이 watch하지 않는 autoDispose라
    // 전송 직후 폐기되어 그 안에서 invalidate하면 유실될 수 있다.
    if (!context.mounted) return;
    onSendSucceeded?.call();
    ref.invalidate(trackMessageListProvider(trackId, background: true));
  } catch (_) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('메시지 전송에 실패했습니다')));
  }
}
