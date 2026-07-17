import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/not_implemented_exception.dart';
import 'package:cornermon/shared/api/providers/auth_device_trust_providers.dart';
import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';
import 'package:cornermon/shared/design_system/widgets/empty_state.dart';

class LockedDevicesCard extends ConsumerStatefulWidget {
  const LockedDevicesCard({required this.campId, super.key});
  final CampId campId;

  @override
  ConsumerState<LockedDevicesCard> createState() => _LockedDevicesCardState();
}

class _LockedDevicesCardState extends ConsumerState<LockedDevicesCard> {
  final _manualDeviceId = TextEditingController();

  @override
  void dispose() {
    _manualDeviceId.dispose();
    super.dispose();
  }

  Future<void> _release(String deviceId) async {
    if (deviceId.trim().isEmpty) return;
    await ref.read(releaseTrackLockoutProvider(deviceId.trim()).future);
    ref.invalidate(lockedDeviceListProvider(widget.campId));
    if (mounted) _manualDeviceId.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;
    final locked = ref.watch(lockedDeviceListProvider(widget.campId));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '① 잠긴 기기 목록',
              style: AppTypography.title3.copyWith(color: colors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.space3),
            locked.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) {
                if (error is NotImplementedException) {
                  return const EmptyState(
                    message: '기기 잠금 조회는 백엔드 배포 후 제공됩니다(Issue #70)',
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '잠긴 기기 목록을 불러오지 못했습니다',
                      style: AppTypography.body.copyWith(color: colors.danger),
                    ),
                    const SizedBox(height: AppSpacing.space2),
                    AppButton(
                      variant: AppButtonVariant.secondary,
                      size: AppButtonSize.compact,
                      label: '재시도',
                      onPressed: () => ref.invalidate(
                        lockedDeviceListProvider(widget.campId),
                      ),
                    ),
                  ],
                );
              },
              data: (items) {
                if (items.isEmpty) {
                  return const EmptyState(
                    message: '잠긴 기기가 없습니다',
                    icon: Icons.lock_open,
                  );
                }
                return Column(
                  children: [
                    for (final device in items)
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
                                    device.deviceName ?? '기기 이름 없음',
                                    style: AppTypography.bodyEmphasis.copyWith(
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    '실패 ${device.failedPinAttempts ?? 0}회'
                                    '${device.lockedUntil != null ? ' · ${device.lockedUntil!.difference(DateTime.now()).inMinutes.clamp(0, 999)}분 남음' : ''}',
                                    style: AppTypography.caption.copyWith(
                                      color: colors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AppButton(
                              variant: AppButtonVariant.primary,
                              size: AppButtonSize.compact,
                              label: '잠금 해제',
                              onPressed: () => _release(device.id ?? ''),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
            const Divider(height: AppSpacing.space6),
            Text(
              'ID/PIN으로 직접 해제',
              style: AppTypography.caption.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.space2),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _manualDeviceId,
                    decoration: const InputDecoration(hintText: '기기 ID'),
                  ),
                ),
                const SizedBox(width: AppSpacing.space2),
                AppButton(
                  variant: AppButtonVariant.secondary,
                  size: AppButtonSize.compact,
                  label: '해제 실행',
                  onPressed: () => _release(_manualDeviceId.text),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
