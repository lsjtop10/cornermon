import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cornermon/admin/features/login/login_error_provider.dart';
import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (_idController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      setState(() {});
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(loginErrorProvider.notifier)
          .submit(_idController.text.trim(), _passwordController.text);
    } catch (_) {
      // 오류 문구는 LoginError provider가 관리한다.
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.dark
        ? AppColors.dark
        : AppColors.light;
    final error = ref.watch(loginErrorProvider);
    final errorText = switch (error) {
      AdminLoginInvalidCredentials() => 'ID 또는 비밀번호가 올바르지 않습니다',
      AdminLoginServerError() => '일시적인 오류입니다. 잠시 후 다시 시도해주세요.',
      null => null,
    };
    final canSubmit =
        !_isSubmitting &&
        _idController.text.trim().isNotEmpty &&
        _passwordController.text.isNotEmpty;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.space6),
          child: SizedBox(
            width: 400,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.space6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('코너학습 관리자', style: AppTypography.title1),
                    const SizedBox(height: AppSpacing.space2),
                    Text('관리자 계정으로 로그인하세요.', style: AppTypography.body),
                    const SizedBox(height: AppSpacing.space6),
                    TextField(
                      controller: _idController,
                      enabled: !_isSubmitting,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(labelText: 'ID'),
                    ),
                    const SizedBox(height: AppSpacing.space4),
                    TextField(
                      controller: _passwordController,
                      enabled: !_isSubmitting,
                      obscureText: true,
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (_) => _submit(),
                      decoration: const InputDecoration(labelText: '비밀번호'),
                    ),
                    if (errorText != null) ...[
                      const SizedBox(height: AppSpacing.space2),
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          errorText,
                          style: AppTypography.caption.copyWith(
                            color: colors.danger,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.space5),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: AppButton(
                            variant: AppButtonVariant.primary,
                            label: '로그인',
                            disabledReason: 'ID와 비밀번호를 모두 입력하면 로그인할 수 있습니다.',
                            onPressed: canSubmit ? _submit : null,
                          ),
                        ),
                        if (_isSubmitting)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.space4),
                    Text('로그인 상태는 안전하게 유지됩니다.', style: AppTypography.caption),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
