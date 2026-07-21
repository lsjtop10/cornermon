import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';
import 'package:cornermon/shared/design_system/widgets/confirm_modal.dart';
import 'package:cornermon/facilitator/session/device_trust_provider.dart';
import 'package:cornermon/facilitator/widgets/pin_otp_input.dart';
import 'pin_login_error_provider.dart';

/// B1. 트랙 PIN 6자리로 트랙 세션 인증.
class PinLoginScreen extends ConsumerWidget {
  const PinLoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;
    final error = ref.watch(pinLoginErrorProvider);

    return Scaffold(
      backgroundColor: colors.bgCanvas,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.space6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '트랙 PIN을 입력하세요',
                  style: AppTypography.title2.copyWith(
                    color: colors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.space8),
                _PinLoginBody(
                  error: error,
                  onSubmitted: (pin) =>
                      ref.read(pinLoginErrorProvider.notifier).submit(pin),
                ),
                const SizedBox(height: AppSpacing.space8),
                AppButton(
                  variant: AppButtonVariant.secondary,
                  size: AppButtonSize.comfortable,
                  label: '기기 등록 취소',
                  onPressed: () => _clearRegistration(context, ref),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _clearRegistration(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmModal(
      context,
      kind: ConfirmModalKind.softConfirm,
      title: '기기 등록을 취소할까요?',
      body: '이 기기의 저장된 등록 정보와 PIN 로그인 정보가 삭제됩니다.',
      buttonSize: AppButtonSize.comfortable,
    );
    if (!confirmed) return;

    await ref.read(deviceTrustProvider.notifier).clearRegistration();
  }
}

/// PinOtpInput + 상태별 안내 텍스트. DEVICE_LOCKED 카운트다운은 서버가 내려준
/// retryAfterSeconds에서 시작해 로컬 타이머로 0까지 줄이고, 0이 되면 입력을 다시 활성화한다.
class _PinLoginBody extends StatefulWidget {
  const _PinLoginBody({required this.error, required this.onSubmitted});

  final PinLoginUiError? error;
  final ValueChanged<String> onSubmitted;

  @override
  State<_PinLoginBody> createState() => _PinLoginBodyState();
}

class _PinLoginBodyState extends State<_PinLoginBody> {
  Timer? _timer;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _syncLockoutTimer();
  }

  @override
  void didUpdateWidget(covariant _PinLoginBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.error != oldWidget.error) {
      _syncLockoutTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _syncLockoutTimer() {
    _timer?.cancel();
    final error = widget.error;
    if (error is PinLocked) {
      _remainingSeconds = error.retryAfterSeconds;
      _timer = Timer.periodic(const Duration(seconds: 1), _tick);
    } else {
      _remainingSeconds = 0;
    }
  }

  void _tick(Timer timer) {
    if (_remainingSeconds <= 1) {
      timer.cancel();
      setState(() => _remainingSeconds = 0);
      return;
    }
    setState(() => _remainingSeconds -= 1);
  }

  bool get _isLocked => widget.error is PinLocked && _remainingSeconds > 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PinOtpInput(enabled: !_isLocked, onSubmitted: widget.onSubmitted),
        const SizedBox(height: AppSpacing.space5),
        _buildMessage(context),
      ],
    );
  }

  Widget _buildMessage(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;

    if (_isLocked) {
      return Text(
        '$_remainingSeconds초 후 다시 시도할 수 있습니다',
        style: AppTypography.body.copyWith(color: colors.textSecondary),
        textAlign: TextAlign.center,
      );
    }

    final error = widget.error;
    switch (error) {
      case null:
        return const SizedBox.shrink();
      case PinInvalid(:final retryAfterSeconds):
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'PIN이 일치하지 않습니다',
              style: AppTypography.bodyEmphasis.copyWith(color: colors.danger),
              textAlign: TextAlign.center,
            ),
            if (retryAfterSeconds != null) ...[
              const SizedBox(height: AppSpacing.space2),
              Text(
                '$retryAfterSeconds초 후 다시 시도할 수 있습니다',
                style: AppTypography.caption.copyWith(
                  color: colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        );
      case PinLocked():
        // _isLocked가 이미 이 케이스를 렌더링하므로 여기 도달하지 않는다(sealed 완전성용).
        return const SizedBox.shrink();
      case DeviceNotTrustedYet():
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '아직 승인되지 않은 기기입니다',
              style: AppTypography.bodyEmphasis.copyWith(color: colors.danger),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.space4),
            AppButton(
              variant: AppButtonVariant.secondary,
              size: AppButtonSize.comfortable,
              label: '기기 등록 화면으로',
              onPressed: () => context.go('/device-pending'),
            ),
          ],
        );
      case CampNotActiveYet():
        return Text(
          '코너학습이 아직 시작되지 않았습니다',
          style: AppTypography.body.copyWith(color: colors.textSecondary),
          textAlign: TextAlign.center,
        );
    }
  }
}
