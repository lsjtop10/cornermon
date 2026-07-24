import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cornermon/admin/session/admin_session_provider.dart';
import 'package:cornermon/shared/api/dio_error.dart';
import 'package:cornermon/shared/api/providers/auth_device_trust_providers.dart';
import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';
import 'package:cornermon/shared/design_system/widgets/confirm_modal.dart';
import '_admin_management_connection_state.dart';

/// 로그인한 관리자 본인의 비밀번호 변경과, CORNER_OPERATOR인 경우의 본인 탈퇴를
/// 담당한다. SYSTEM_ADMIN은 본인 탈퇴가 항상 금지되므로(마지막 시스템 관리자 보호와
/// 무관하게 백엔드가 거부한다) 탈퇴 버튼을 노출하지 않는다.
class MyAccountCard extends ConsumerStatefulWidget {
  const MyAccountCard({required this.admin, super.key});

  final AdminResponse admin;

  @override
  ConsumerState<MyAccountCard> createState() => _MyAccountCardState();
}

class _MyAccountCardState extends ConsumerState<MyAccountCard> {
  final _newPassword = TextEditingController();
  bool _isBusy = false;

  @override
  void dispose() {
    _newPassword.dispose();
    super.dispose();
  }

  /// 승인/거절/회수와 동일한 규칙: 커넥션 유실은 상단 배너, 나머지 API 호출
  /// 에러는 SnackBar로 표시한다. 성공 여부를 반환해 호출부가 후속 동작(비밀번호
  /// 필드 초기화, 탈퇴 후 로그아웃)을 이어갈 수 있게 한다.
  Future<bool> _run(Future<void> Function() action) async {
    if (_isBusy) return false;
    setState(() => _isBusy = true);
    try {
      await action();
      ref.read(adminManagementConnectionLostProvider.notifier).set(false);
      return true;
    } on DioException catch (error, stackTrace) {
      debugPrint(
        '[admin_management] my account action failed: type=${error.type} '
        'statusCode=${error.response?.statusCode}\n$stackTrace',
      );
      if (isConnectionLost(error)) {
        ref.read(adminManagementConnectionLostProvider.notifier).set(true);
      } else {
        _showSnackBar('요청이 실패했습니다. 잠시 후 다시 시도해주세요.');
      }
      return false;
    } catch (error, stackTrace) {
      debugPrint('[admin_management] my account action failed: $error\n$stackTrace');
      _showSnackBar('요청이 실패했습니다. 잠시 후 다시 시도해주세요.');
      return false;
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _changePassword() async {
    if (_newPassword.text.isEmpty) return;
    final adminId = widget.admin.id ?? '';
    final newPassword = _newPassword.text;
    final ok = await _run(() async {
      final provider = changeAdminPasswordProvider(adminId, newPassword);
      final container = ProviderScope.containerOf(context, listen: false);
      final sub = container.listen(provider, (_, _) {});
      await container.read(provider.future).whenComplete(sub.close);
    });
    if (ok && mounted) {
      _newPassword.clear();
      _showSnackBar('비밀번호가 변경되었습니다.');
    }
  }

  Future<void> _withdraw() async {
    final confirmed = await showConfirmModal(
      context,
      kind: ConfirmModalKind.softConfirm,
      title: '정말 탈퇴하시겠습니까?',
      body: '탈퇴 후에는 이 계정으로 다시 로그인할 수 없습니다.',
    );
    if (!confirmed) return;

    final adminId = widget.admin.id ?? '';
    final ok = await _run(() async {
      final provider = deleteAdminAccountProvider(adminId);
      final container = ProviderScope.containerOf(context, listen: false);
      final sub = container.listen(provider, (_, _) {});
      await container.read(provider.future).whenComplete(sub.close);
    });
    if (!ok || !mounted) return;

    // admin_sessions는 admins에 대해 ON DELETE CASCADE라 본인 삭제 시점에 현재 세션도
    // 이미 서버에서 사라진다 — AdminSession.logout()으로 로그아웃 API를 다시 부르면
    // 401만 돌아오므로, 서버 재호출 없이 로컬 상태만 정리하는 invalidate()를 쓴다.
    await ref.read(adminSessionProvider.notifier).invalidate();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;
    final canChangePassword = !_isBusy && _newPassword.text.isNotEmpty;
    final isCornerOperator =
        widget.admin.role == AdminResponseRoleEnum.CORNER_OPERATOR;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '내 계정 (${widget.admin.username ?? ''})',
              style: AppTypography.title3.copyWith(color: colors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.space3),
            TextField(
              controller: _newPassword,
              enabled: !_isBusy,
              obscureText: true,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(labelText: '새 비밀번호'),
            ),
            const SizedBox(height: AppSpacing.space2),
            Align(
              alignment: Alignment.centerRight,
              child: AppButton(
                variant: AppButtonVariant.primary,
                size: AppButtonSize.compact,
                label: '비밀번호 변경',
                onPressed: canChangePassword ? _changePassword : null,
              ),
            ),
            if (isCornerOperator) ...[
              const SizedBox(height: AppSpacing.space4),
              const Divider(height: 1),
              const SizedBox(height: AppSpacing.space4),
              Text(
                '계정을 탈퇴하면 되돌릴 수 없습니다.',
                style: AppTypography.caption.copyWith(color: colors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.space2),
              Align(
                alignment: Alignment.centerRight,
                child: AppButton(
                  variant: AppButtonVariant.destructive,
                  size: AppButtonSize.compact,
                  label: '회원 탈퇴',
                  onPressed: _isBusy ? null : _withdraw,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
