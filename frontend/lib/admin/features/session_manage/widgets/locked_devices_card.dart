import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cornermon/shared/api/domain_aliases.dart';
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/not_implemented_exception.dart';
import 'package:cornermon/shared/api/providers/auth_device_trust_providers.dart';
import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';
import 'package:cornermon/shared/design_system/widgets/empty_state.dart';

/// 이 화면에서 가장 급한 작업 — 잠긴 기기가 있으면 화면 전체에서 가장 눈에 띄어야 하고
/// (§design-system.md 0-7 "평소엔 조용하고 문제 있을 때만 두드러진다"), 없으면 다른
/// 카드와 똑같은 무게의 빈 Card를 차지할 이유가 없다. 그래서 다른 두 섹션과 달리
/// Card로 감싸지 않고, 상태에 따라 완전히 다른 두 모습(조용한 한 줄 / 두드러지는 블록)
/// 중 하나로 렌더링한다. 목록에 이미 뜬 기기를 그 자리에서 해제할 수 있으므로, ID를
/// 직접 타이핑해 넣는 별도 입력창은 두지 않는다.
class LockedDevicesCard extends ConsumerWidget {
  const LockedDevicesCard({required this.campId, super.key});
  final CampId campId;

  Future<void> _release(WidgetRef ref, String deviceId) async {
    if (deviceId.trim().isEmpty) return;
    await ref.read(releaseTrackLockoutProvider(deviceId.trim()).future);
    ref.invalidate(lockedDeviceListProvider(campId));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;
    final locked = ref.watch(lockedDeviceListProvider(campId));

    return locked.when(
      loading: () => Row(
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: AppSpacing.space2),
          Text(
            '잠긴 기기 확인 중…',
            style: AppTypography.caption.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
      error: (error, _) {
        if (error is NotImplementedException) {
          return const EmptyState(
            message: '기기 잠금 조회는 백엔드 배포 후 제공됩니다(Issue #70)',
          );
        }
        return Row(
          children: [
            Expanded(
              child: Text(
                '잠긴 기기 목록을 불러오지 못했습니다',
                style: AppTypography.body.copyWith(color: colors.danger),
              ),
            ),
            AppButton(
              variant: AppButtonVariant.secondary,
              size: AppButtonSize.compact,
              label: '재시도',
              onPressed: () => ref.invalidate(lockedDeviceListProvider(campId)),
            ),
          ],
        );
      },
      data: (items) => items.isEmpty
          ? Row(
              children: [
                Icon(
                  Icons.lock_open_outlined,
                  size: 16,
                  color: colors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.space2),
                Text(
                  '잠긴 기기 없음',
                  style: AppTypography.caption.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            )
          : _UrgentBlock(
              colors: colors,
              isDark: isDark,
              items: items,
              onRelease: (deviceId) => _release(ref, deviceId),
            ),
    );
  }
}

class _UrgentBlock extends StatelessWidget {
  const _UrgentBlock({
    required this.colors,
    required this.isDark,
    required this.items,
    required this.onRelease,
  });

  final AppColors colors;
  final bool isDark;
  final List<DeviceRegistration> items;
  final Future<void> Function(String deviceId) onRelease;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.danger.withValues(alpha: isDark ? .18 : .10),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(AppSpacing.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lock_outline, size: 20, color: colors.danger),
              const SizedBox(width: AppSpacing.space2),
              Text(
                '잠긴 기기 ${items.length}개',
                style: AppTypography.title3.copyWith(color: colors.danger),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space3),
          for (final device in items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.space2),
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
                    onPressed: () => onRelease(device.id ?? ''),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
