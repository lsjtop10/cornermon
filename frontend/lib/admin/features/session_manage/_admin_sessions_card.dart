import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cornermon/shared/api/providers/auth_device_trust_providers.dart';
import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';
import 'package:cornermon/shared/design_system/widgets/confirm_modal.dart';
import 'package:cornermon/shared/design_system/widgets/empty_state.dart';
import 'package:cornermon/shared/widgets/local_time_label.dart';

class AdminSessionsCard extends ConsumerWidget {
  const AdminSessionsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;
    final sessions = ref.watch(adminSessionListProvider);

    Future<void> revoke(String sessionId) async {
      // §2.6 확인 필요 해소 보류 — AdminSessionResponse에 세션 자기 식별 필드가 없어
      // "이 종료가 현재 세션인지"를 계약상 판별할 수 없다. 1차 구현은 모든 행에
      // 동일한 확인 모달만 적용하고, 자기 자신 종료 시 즉시 로그아웃 처리는 생략한다.
      final confirmed = await showConfirmModal(
        context,
        kind: ConfirmModalKind.softConfirm,
        title: '현재 세션을 종료하면 즉시 로그아웃됩니다',
        body: '계속하시겠습니까?',
      );
      if (!confirmed) return;
      await ref.read(revokeAdminSessionProvider(sessionId).future);
      ref.invalidate(adminSessionListProvider);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '③ 관리자 세션',
              style: AppTypography.title3.copyWith(color: colors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.space3),
            sessions.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '관리자 세션 목록을 불러오지 못했습니다',
                    style: AppTypography.body.copyWith(color: colors.danger),
                  ),
                  const SizedBox(height: AppSpacing.space2),
                  AppButton(
                    variant: AppButtonVariant.secondary,
                    label: '재시도',
                    onPressed: () => ref.invalidate(adminSessionListProvider),
                  ),
                ],
              ),
              data: (items) {
                if (items.isEmpty) {
                  return const EmptyState(
                    message: '관리자 세션이 없습니다',
                    icon: Icons.admin_panel_settings_outlined,
                  );
                }
                return Column(
                  children: [
                    for (final session in items)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.space2,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    session.deviceInfo ?? '기기 정보 없음',
                                    style: AppTypography.bodyEmphasis.copyWith(
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                  if (session.lastUsedAt != null)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '마지막 활동 ',
                                          style: AppTypography.caption.copyWith(
                                            color: colors.textSecondary,
                                          ),
                                        ),
                                        DefaultTextStyle.merge(
                                          style: AppTypography.caption.copyWith(
                                            color: colors.textSecondary,
                                          ),
                                          child: LocalTimeLabel(
                                            dateTime: session.lastUsedAt!,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                            AppButton(
                              variant: AppButtonVariant.destructive,
                              label: '세션 종료',
                              onPressed: () => revoke(session.id ?? ''),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
