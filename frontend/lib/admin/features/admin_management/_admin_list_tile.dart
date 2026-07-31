import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cornermon/shared/api/dio_error.dart';
import 'package:cornermon/shared/api/providers/auth_device_trust_providers.dart';
import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';
import 'package:cornermon/shared/design_system/widgets/app_tag.dart';
import 'package:cornermon/shared/design_system/widgets/confirm_modal.dart';
import '_admin_management_connection_state.dart';

/// SYSTEM_ADMIN 전용 관리자 목록의 행. 본인 행은 삭제 버튼을 노출하지 않는다 — 본인
/// 탈퇴는 아래 [_MyAccountCard]에서 별도로 처리하며(백엔드는 SYSTEM_ADMIN 본인 삭제를
/// 항상 거부한다), CORNER_OPERATOR 본인 행은 목록 화면 자체가 SYSTEM_ADMIN 전용이라
/// 도달하지 않는다.
class AdminListTile extends ConsumerStatefulWidget {
  const AdminListTile({required this.admin, required this.isSelf, super.key});

  final AdminResponse admin;
  final bool isSelf;

  @override
  ConsumerState<AdminListTile> createState() => _AdminListTileState();
}

class _AdminListTileState extends ConsumerState<AdminListTile> {
  bool _isBusy = false;

  Future<void> _delete() async {
    final confirmed = await showConfirmModal(
      context,
      kind: ConfirmModalKind.softConfirm,
      title: '${widget.admin.username ?? '이 관리자'}를 삭제하시겠습니까?',
      body: '삭제 후에는 이 계정으로 다시 로그인할 수 없습니다.',
    );
    if (!confirmed || !mounted) return;

    setState(() => _isBusy = true);
    try {
      final provider = deleteAdminAccountProvider(widget.admin.id ?? '');
      final container = ProviderScope.containerOf(context, listen: false);
      final sub = container.listen(provider, (_, _) {});
      await container.read(provider.future).whenComplete(sub.close);
      ref.invalidate(adminListProvider);
      ref.read(adminManagementConnectionLostProvider.notifier).set(false);
    } on DioException catch (error, stackTrace) {
      debugPrint(
        '[admin_management] delete admin failed: type=${error.type} '
        'statusCode=${error.response?.statusCode}\n$stackTrace',
      );
      if (isConnectionLost(error)) {
        ref.read(adminManagementConnectionLostProvider.notifier).set(true);
      } else if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('삭제에 실패했습니다. 잠시 후 다시 시도해주세요.')));
      }
    } catch (error, stackTrace) {
      debugPrint('[admin_management] delete admin failed: $error\n$stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('삭제에 실패했습니다. 잠시 후 다시 시도해주세요.')));
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;
    final isSystemAdmin =
        widget.admin.role == AdminResponseRoleEnum.SYSTEM_ADMIN;

    return ListTile(
      title: Text(
        widget.admin.username ?? '이름 없음',
        style: AppTypography.bodyEmphasis.copyWith(color: colors.textPrimary),
      ),
      leading: AppTag(
        label: isSystemAdmin ? '시스템 관리자' : '운영 관리자',
        tone: isSystemAdmin ? AppTagTone.warning : AppTagTone.neutral,
      ),
      trailing: widget.isSelf
          ? Text('나', style: AppTypography.caption.copyWith(color: colors.textSecondary))
          : _isBusy
          ? const SizedBox(
              width: 20.0,
              height: 20.0,
              child: CircularProgressIndicator(strokeWidth: 2.0),
            )
          : AppButton(
              variant: AppButtonVariant.destructive,
              size: AppButtonSize.compact,
              label: '삭제',
              onPressed: _delete,
            ),
    );
  }
}
