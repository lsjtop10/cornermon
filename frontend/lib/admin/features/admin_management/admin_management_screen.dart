import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cornermon/shared/api/providers/auth_device_trust_providers.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';
import 'package:cornermon/shared/design_system/widgets/connection_banner.dart';
import 'package:cornermon/shared/design_system/widgets/empty_state.dart';
import '_admin_list_tile.dart';
import '_admin_management_connection_state.dart';
import '_create_admin_dialog.dart';
import '_my_account_card.dart';

/// 캠프와 무관한 전역 화면 — `/camps`, `/badges`처럼 `_campIndependentLocations`에
/// 등록되어 `AdminScaffold`(캠프 사이드바) 없이 독립적으로 라우팅된다.
class AdminManagementScreen extends ConsumerWidget {
  const AdminManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentAdmin = ref.watch(currentAdminProvider);
    final connectionLost = ref.watch(adminManagementConnectionLostProvider);

    return Scaffold(
      // 뒤로가기 버튼은 명시하지 않는다 — 캠프 목록에서 context.push('/admins')로 들어와
      // Navigator 스택이 쌓이므로, AppBar가 Navigator.canPop()을 보고 자동으로 넣어주는
      // 기본 back 버튼(Navigator.pop)이 어디서 진입했든 항상 정확히 돌아간다.
      appBar: AppBar(title: const Text('관리자 계정 관리')),
      body: Column(
        children: [
          ConnectionBanner(
            state: connectionLost
                ? ConnectionBannerState.disconnected
                : ConnectionBannerState.hidden,
          ),
          Expanded(
            child: currentAdmin.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => EmptyState(
                message: '내 정보를 불러오지 못했습니다.\n$error',
                icon: Icons.error_outline,
                actionLabel: '재시도',
                onAction: () => ref.invalidate(currentAdminProvider),
              ),
              data: (me) => ListView(
                padding: const EdgeInsets.all(AppSpacing.space4),
                children: [
                  if (me.role == AdminResponseRoleEnum.SYSTEM_ADMIN)
                    _AdminListSection(currentAdminId: me.id ?? ''),
                  if (me.role == AdminResponseRoleEnum.SYSTEM_ADMIN)
                    const SizedBox(height: AppSpacing.space4),
                  MyAccountCard(admin: me),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminListSection extends ConsumerWidget {
  const _AdminListSection({required this.currentAdminId});

  final String currentAdminId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final admins = ref.watch(adminListProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(child: Text('전체 관리자')),
                AppButton(
                  variant: AppButtonVariant.primary,
                  size: AppButtonSize.compact,
                  icon: Icons.add,
                  label: '운영 관리자 추가',
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => const CreateAdminDialog(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space2),
            admins.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(AppSpacing.space4),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => Padding(
                padding: const EdgeInsets.all(AppSpacing.space4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('관리자 목록을 불러오지 못했습니다.\n$error'),
                    const SizedBox(height: AppSpacing.space2),
                    AppButton(
                      variant: AppButtonVariant.secondary,
                      size: AppButtonSize.compact,
                      label: '재시도',
                      onPressed: () => ref.invalidate(adminListProvider),
                    ),
                  ],
                ),
              ),
              data: (items) => Column(
                children: [
                  for (final admin in items)
                    AdminListTile(
                      admin: admin,
                      isSelf: admin.id == currentAdminId,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
