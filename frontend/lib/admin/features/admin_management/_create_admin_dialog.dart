import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cornermon/shared/api/providers/auth_device_trust_providers.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';

class CreateAdminDialog extends ConsumerStatefulWidget {
  const CreateAdminDialog({super.key});

  @override
  ConsumerState<CreateAdminDialog> createState() => _CreateAdminDialogState();
}

class _CreateAdminDialogState extends ConsumerState<CreateAdminDialog> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _errorText;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final username = _username.text.trim();
    final password = _password.text;
    if (username.isEmpty || password.isEmpty) return;

    setState(() {
      _busy = true;
      _errorText = null;
    });
    try {
      final provider = createAdminProvider(username, password);
      final container = ProviderScope.containerOf(context, listen: false);
      final sub = container.listen(provider, (_, _) {});
      await container.read(provider.future).whenComplete(sub.close);
      ref.invalidate(adminListProvider);
      if (mounted) Navigator.pop(context);
    } on DioException catch (error) {
      setState(
        () => _errorText = error.response?.statusCode == 409
            ? '이미 사용 중인 아이디입니다.'
            : '관리자를 추가하지 못했습니다. 잠시 후 다시 시도해주세요.',
      );
    } catch (_) {
      setState(() => _errorText = '관리자를 추가하지 못했습니다. 잠시 후 다시 시도해주세요.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit =
        !_busy && _username.text.trim().isNotEmpty && _password.text.isNotEmpty;
    return AlertDialog(
      title: const Text('운영 관리자 추가'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _username,
              enabled: !_busy,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(labelText: '아이디'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              enabled: !_busy,
              obscureText: true,
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => canSubmit ? _submit() : null,
              decoration: const InputDecoration(labelText: '초기 비밀번호'),
            ),
            if (_errorText != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorText!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        AppButton(
          variant: AppButtonVariant.primary,
          size: AppButtonSize.compact,
          label: '추가',
          onPressed: canSubmit ? _submit : null,
        ),
      ],
    );
  }
}
