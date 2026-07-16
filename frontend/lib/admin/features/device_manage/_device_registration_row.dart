import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cornermon/admin/entities/device_registration_ext.dart';
import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/auth_device_trust_providers.dart';
import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';
import 'package:cornermon/shared/design_system/widgets/confirm_modal.dart';
import 'package:cornermon/shared/widgets/local_time_label.dart';

class DeviceRegistrationRow extends ConsumerWidget {
  const DeviceRegistrationRow({
    required this.registration,
    this.isNewArrival = false,
    super.key,
  });

  final api.DeviceRegistration registration;
  final bool isNewArrival;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;
    final id = DeviceRegistrationId(registration.id ?? '');

    Future<void> approve() async {
      await ref.read(approveDeviceRegistrationProvider(id).future);
      ref.invalidate(deviceRegistrationListProvider);
    }

    Future<void> reject() async {
      await ref.read(rejectDeviceRegistrationProvider(id).future);
      ref.invalidate(deviceRegistrationListProvider);
    }

    Future<void> revoke() async {
      final confirmed = await showConfirmModal(
        context,
        kind: ConfirmModalKind.softConfirm,
        title: '기기를 회수하시겠습니까?',
        body: '분실/도난 대응 시 사용하세요. 회수 후 이 기기는 즉시 PIN 화면 접근이 차단됩니다.',
      );
      if (!confirmed) return;
      await ref.read(revokeDeviceRegistrationProvider(id).future);
      ref.invalidate(deviceRegistrationListProvider);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      color: isNewArrival ? colors.brandPrimary.withValues(alpha: .12) : null,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space4,
        vertical: AppSpacing.space3,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  registration.deviceName ?? '기기 이름 없음',
                  style: AppTypography.bodyEmphasis.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.space1),
                if (registration.createdAt != null)
                  LocalTimeLabel(dateTime: registration.createdAt!)
                else
                  Text(
                    registration.statusLabel,
                    style: AppTypography.caption.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          switch (registration.tab) {
            DeviceRegistrationTab.pending => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppButton(
                  variant: AppButtonVariant.primary,
                  label: '승인',
                  onPressed: approve,
                ),
                const SizedBox(width: AppSpacing.space2),
                AppButton(
                  variant: AppButtonVariant.secondary,
                  label: '거절',
                  onPressed: reject,
                ),
              ],
            ),
            DeviceRegistrationTab.approved => AppButton(
              variant: AppButtonVariant.destructive,
              label: '회수',
              onPressed: revoke,
            ),
            DeviceRegistrationTab.history => Text(
              registration.statusLabel,
              style: AppTypography.body.copyWith(color: colors.textSecondary),
            ),
          },
        ],
      ),
    );
  }
}
