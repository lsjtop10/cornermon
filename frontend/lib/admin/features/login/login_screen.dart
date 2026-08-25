import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cornermon/admin/features/login/state/login_error_state.dart';
import 'package:cornermon/shared/config/active_api_environment_provider.dart';
import 'package:cornermon/shared/config/api_environment.dart';
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

  // App Store 심사/스태프 연습용 히든 진입점. 화면엔 새 UI가 추가되지 않고, 이미 항상 떠
  // 있던 하단 캡션 텍스트를 롱프레스하면 운영↔데모 서버가 토글된다. 로그인 자체는 기존
  // 흐름 그대로이고, 이후 요청이 어느 서버로 나가는지만 바뀐다 — 자세한 배경은
  // frontend/docs/artifacts/plan/20260820_앱스토어_심사용_데모환경_프론트_plan_.md.
  //
  // 전환 결과를 토스트로 따로 알리지 않는다 — 데모 환경으로 전환된 즉시
  // DemoEnvironmentBanner(builder에 항상 떠 있음)가 나타나므로 그것으로 충분한 피드백이고,
  // 토스트를 더하면 오히려 중복이었다.
  void _toggleApiEnvironment() {
    final notifier = ref.read(activeApiEnvironmentProvider.notifier);
    final next = ref.read(activeApiEnvironmentProvider) == ApiEnvironment.demo
        ? ApiEnvironment.production
        : ApiEnvironment.demo;
    notifier.switchTo(next);
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
      // loginErrorProvider가 화면에 보여줄 상태(errorText)와 로그를 이미 남겼다
      // (#131) — 여기서는 finally의 _isSubmitting 해제만 필요해 별도 처리 없이 삼킨다.
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
                        AppButton(
                          variant: AppButtonVariant.primary,
                          size: AppButtonSize.comfortable,
                          width: AppButtonWidth.fill,
                          label: '로그인',
                          disabledReason: 'ID와 비밀번호를 모두 입력하면 로그인할 수 있습니다.',
                          onPressed: canSubmit ? _submit : null,
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
                    GestureDetector(
                      onLongPress: _toggleApiEnvironment,
                      child: Text(
                        '로그인 상태는 안전하게 유지됩니다.',
                        style: AppTypography.caption,
                      ),
                    ),
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
