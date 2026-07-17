import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';
import '../../session/device_trust_provider.dart';

/// B0. 신뢰되지 않은 기기는 이 화면만 볼 수 있고 PIN 화면(B1)에 도달하지 못한다.
class DevicePendingScreen extends ConsumerWidget {
  const DevicePendingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;
    final trustState = ref.watch(deviceTrustProvider);

    return Scaffold(
      backgroundColor: colors.bgCanvas,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.space6),
            child: trustState.when(
              data: (status) => switch (status) {
                DeviceTrustStatus.none => const _RegistrationForm(),
                DeviceTrustStatus.pending => const _PendingView(),
                DeviceTrustStatus.rejected => const _RegistrationForm(
                  noticeMessage: '등록이 거절되었습니다',
                ),
                DeviceTrustStatus.revoked => const _RegistrationForm(
                  noticeMessage: '신뢰가 철회되었습니다',
                ),
                // approved는 라우터가 곧바로 /pin-login으로 이동시키므로 실질적으로 잠깐만 보임.
                DeviceTrustStatus.approved => const _PendingView(),
              },
              loading: () => const CircularProgressIndicator(),
              error: (error, stackTrace) =>
                  const _RegistrationForm(noticeMessage: '기기 상태를 확인하지 못했습니다'),
            ),
          ),
        ),
      ),
    );
  }
}

class _PendingView extends StatelessWidget {
  const _PendingView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: AppSpacing.space6),
        Text(
          '승인 대기 중…',
          style: AppTypography.title2.copyWith(color: colors.textPrimary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.space2),
        Text(
          '관리자 승인 후 자동으로 다음 화면으로 이동합니다',
          style: AppTypography.body.copyWith(color: colors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.space8),
        AppButton(
          variant: AppButtonVariant.secondary,
          size: AppButtonSize.comfortable,
          width: AppButtonWidth.fill,
          label: '승인받으셨다면 계속하기',
          onPressed: () => context.go('/pin-login'),
        ),
      ],
    );
  }
}

/// 등록 코드 입력 폼 — none/rejected/revoked 세 상태가 공유한다.
class _RegistrationForm extends ConsumerStatefulWidget {
  const _RegistrationForm({this.noticeMessage});

  final String? noticeMessage;

  @override
  ConsumerState<_RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends ConsumerState<_RegistrationForm> {
  final TextEditingController _codeController = TextEditingController();
  String? _errorText;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _codeController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final code = _codeController.text.trim();
    if (code.isEmpty || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    try {
      await ref.read(deviceTrustProvider.notifier).requestRegistration(code);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorText = '유효하지 않은 등록 코드입니다.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;
    final canSubmit = _codeController.text.trim().isNotEmpty && !_isSubmitting;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.phonelink_lock_outlined,
          size: 64.0,
          color: colors.textDisabled,
        ),
        const SizedBox(height: AppSpacing.space6),
        Text(
          '기기 등록 대기',
          style: AppTypography.title2.copyWith(color: colors.textPrimary),
          textAlign: TextAlign.center,
        ),
        if (widget.noticeMessage != null) ...[
          const SizedBox(height: AppSpacing.space2),
          Text(
            widget.noticeMessage!,
            style: AppTypography.bodyEmphasis.copyWith(color: colors.danger),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: AppSpacing.space2),
        Text(
          '관리자에게 받은 등록 코드를 입력하세요',
          style: AppTypography.body.copyWith(color: colors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.space6),
        TextField(
          controller: _codeController,
          enabled: !_isSubmitting,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            labelText: '등록 코드',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
        if (_errorText != null) ...[
          const SizedBox(height: AppSpacing.space2),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _errorText!,
              style: AppTypography.caption.copyWith(color: colors.danger),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.space6),
        AppButton(
          variant: AppButtonVariant.primary,
          size: AppButtonSize.comfortable,
          width: AppButtonWidth.fill,
          label: '등록 요청',
          onPressed: canSubmit ? _submit : null,
        ),
      ],
    );
  }
}
