import 'package:cornermon/admin/features/start_camp/start_camp_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';

class StartCampButton extends ConsumerWidget {
  const StartCampButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => AppButton(
    variant: AppButtonVariant.primary,
    size: AppButtonSize.compact,
    icon: Icons.play_arrow,
    label: '코너학습 시작',
    onPressed: () => showDialog<void>(
      context: context,
      builder: (_) => const StartCampConfirmDialog(),
    ),
  );
}

/// POST start-camp 실패를 사용자 문구로 변환한다(camp_handler.go StartCamp 참고).
/// 인식 못한 코드(네트워크 오류, 5xx 등)는 원문을 로그로만 남기고 일반 문구로 대체한다.
String _describeStartError(Object error, StackTrace stackTrace) {
  if (error is DioException) {
    debugPrint(
      '[start_camp] failed: type=${error.type} '
      'statusCode=${error.response?.statusCode} '
      'body=${error.response?.data}\n$stackTrace',
    );
    final code = (error.response?.data is Map)
        ? (error.response?.data as Map)['code'] as String?
        : null;
    if (code == 'CAMP_STATE_CONFLICT') {
      return '이미 시작되었거나 시작할 수 없는 캠프 상태입니다.';
    }
  } else {
    debugPrint('[start_camp] failed: $error\n$stackTrace');
  }
  return '시작 확정에 실패했습니다. 잠시 후 다시 시도해주세요.';
}

class StartCampConfirmDialog extends ConsumerStatefulWidget {
  const StartCampConfirmDialog({super.key});

  @override
  ConsumerState<StartCampConfirmDialog> createState() =>
      _StartCampConfirmDialogState();
}

class _StartCampConfirmDialogState
    extends ConsumerState<StartCampConfirmDialog> {
  bool _submitting = false;
  String? _error;

  Future<void> _confirm() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(startCampControllerProvider.notifier).confirm();
      final result = ref.read(startCampControllerProvider);
      if (result.hasError) throw result.error!;
      if (mounted) Navigator.pop(context);
    } catch (error, stackTrace) {
      if (mounted) setState(() => _error = _describeStartError(error, stackTrace));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.dark
        ? AppColors.dark
        : AppColors.light;
    return AlertDialog(
      backgroundColor: colors.bgSurfaceRaised,
      constraints: const BoxConstraints(minWidth: 480, maxWidth: 640),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: colors.warning, size: 28),
          const SizedBox(width: AppSpacing.space3),
          Text(
            '코너학습을 시작할까요?',
            style: AppTypography.title3.copyWith(color: colors.textPrimary),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PIN 카드는 이미 발급돼 있으니 시작 전까지는 로그인이 거부됩니다',
            style: AppTypography.body.copyWith(color: colors.textSecondary),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.space3),
              child: Semantics(
                liveRegion: true,
                child: Text(
                  _error!,
                  style: AppTypography.caption.copyWith(color: colors.danger),
                ),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        AppButton(
          variant: AppButtonVariant.primary,
          size: AppButtonSize.compact,
          label: _submitting ? '시작 확정 중…' : '시작 확정',
          onPressed: _submitting ? null : _confirm,
        ),
      ],
    );
  }
}
