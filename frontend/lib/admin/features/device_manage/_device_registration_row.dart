import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cornermon/admin/entities/device_registration_ext.dart';
import 'package:cornermon/shared/api/dio_error.dart';
import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/auth_device_trust_providers.dart';
import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';
import 'package:cornermon/shared/design_system/widgets/confirm_modal.dart';
import 'package:cornermon/shared/widgets/local_time_label.dart';
import '_device_manage_connection_state.dart';

class DeviceRegistrationRow extends ConsumerStatefulWidget {
  const DeviceRegistrationRow({
    required this.campId,
    required this.registration,
    this.isNewArrival = false,
    super.key,
  });

  final CampId campId;
  final api.DeviceRegistration registration;
  final bool isNewArrival;

  @override
  ConsumerState<DeviceRegistrationRow> createState() =>
      _DeviceRegistrationRowState();
}

class _DeviceRegistrationRowState extends ConsumerState<DeviceRegistrationRow> {
  bool _isBusy = false;

  DeviceRegistrationId get _id =>
      DeviceRegistrationId(widget.registration.id ?? '');

  /// 승인/거절/회수 공통 처리 — 규칙: 커넥션 유실(타임아웃 등, 서버 응답 자체를
  /// 못 받음)은 화면 상단 배너로, API 호출 에러(서버가 응답한 4xx/5xx) 및 그 외
  /// 에러는 SnackBar로 표시한다.
  Future<void> _run(Future<void> Function() action) async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    try {
      await action();
      ref.invalidate(deviceRegistrationListProvider(widget.campId));
      ref.read(deviceManageConnectionLostProvider.notifier).set(false);
    } on DioException catch (error, stackTrace) {
      debugPrint(
        '[device_manage] action failed: type=${error.type} '
        'statusCode=${error.response?.statusCode} '
        'body=${error.response?.data}\n$stackTrace',
      );
      if (isConnectionLost(error)) {
        ref.read(deviceManageConnectionLostProvider.notifier).set(true);
      } else {
        _showSnackBar('요청이 실패했습니다. 잠시 후 다시 시도해주세요.');
      }
    } catch (error, stackTrace) {
      debugPrint('[device_manage] action failed: $error\n$stackTrace');
      _showSnackBar('요청이 실패했습니다. 잠시 후 다시 시도해주세요.');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  /// DEVELOPER_GUIDE.md §2.2: autoDispose 액션 provider를 에러로 끝내는 채로
  /// 리스너 없이 read하면, 진짜 예외 대신 Riverpod 내부 "disposed during loading
  /// state" 오류가 뜬다 — 그러면 DioException 분기(연결 유실 vs API 에러)가 전부
  /// 무력화된다. 읽기 직전 임시 리스너를 걸어 이를 막는다. `WidgetRef.listen`은
  /// void를 반환해(위젯 재빌드 트리거 용도) 이 패턴에 못 쓰므로, 구독을 직접
  /// 관리할 수 있는 `ProviderContainer.listen`을 대신 쓴다.
  Future<void> _approve() => _run(() async {
    final provider = approveDeviceRegistrationProvider(widget.campId, _id);
    final container = ProviderScope.containerOf(context, listen: false);
    final sub = container.listen(provider, (_, _) {});
    await container.read(provider.future).whenComplete(sub.close);
  });

  Future<void> _reject() => _run(() async {
    final provider = rejectDeviceRegistrationProvider(widget.campId, _id);
    final container = ProviderScope.containerOf(context, listen: false);
    final sub = container.listen(provider, (_, _) {});
    await container.read(provider.future).whenComplete(sub.close);
  });

  Future<void> _revoke() async {
    final confirmed = await showConfirmModal(
      context,
      kind: ConfirmModalKind.softConfirm,
      title: '기기를 회수하시겠습니까?',
      body: '분실/도난 대응 시 사용하세요. 회수 후 이 기기는 즉시 PIN 화면 접근이 차단됩니다.',
    );
    if (!confirmed) return;
    await _run(() async {
      final provider = revokeDeviceRegistrationProvider(widget.campId, _id);
      final container = ProviderScope.containerOf(context, listen: false);
      final sub = container.listen(provider, (_, _) {});
      await container.read(provider.future).whenComplete(sub.close);
    });
  }

  @override
  Widget build(BuildContext context) {
    final registration = widget.registration;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      color: widget.isNewArrival
          ? colors.brandPrimary.withValues(alpha: .12)
          : null,
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
          if (_isBusy)
            const SizedBox(
              width: 20.0,
              height: 20.0,
              child: CircularProgressIndicator(strokeWidth: 2.0),
            )
          else
            switch (registration.tab) {
              DeviceRegistrationTab.pending => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppButton(
                    variant: AppButtonVariant.primary,
                    size: AppButtonSize.compact,
                    label: '승인',
                    onPressed: _approve,
                  ),
                  const SizedBox(width: AppSpacing.space2),
                  AppButton(
                    variant: AppButtonVariant.secondary,
                    size: AppButtonSize.compact,
                    label: '거절',
                    onPressed: _reject,
                  ),
                ],
              ),
              DeviceRegistrationTab.approved => AppButton(
                variant: AppButtonVariant.destructive,
                size: AppButtonSize.compact,
                label: '회수',
                onPressed: _revoke,
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
