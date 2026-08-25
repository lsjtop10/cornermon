import 'package:cornermon/admin/features/dashboard/state/dashboard_connection_state.dart';
import 'package:cornermon/admin/features/dashboard/state/dashboard_entries.dart';
import 'package:cornermon/shared/api/dio_error.dart';
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/corner_track_providers.dart';
import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';
import 'package:cornermon/shared/design_system/widgets/confirm_modal.dart';
import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// BuildContext로 사용자 확인/입력을 받은 뒤 mutating API(POST/DELETE) provider를
/// 호출하고, 성공 시 관련 목록을 invalidate하는 함수만 이 파일에 둔다. 순수 로직은
/// dashboard_entries.dart, 상태는 dashboard_state.dart로 간다.

/// Riverpod은 조회(GET)와 액션(POST/DELETE)을 똑같이 FutureProvider로 표현하기
/// 때문에 `ref.read(provider.future)`만 보면 "이미 있는 값을 읽는다"인지 "지금
/// 부수효과를 처음 실행시킨다"인지 코드만으로 구분이 안 된다(autoDispose
/// FutureProvider는 listener가 없으면 read하는 순간 처음 build되어 실행된다).
/// 이 헬퍼는 그 실행 의도를 이름으로 드러낸다.
Future<T> runAction<T>(Future<T> Function() invoke) => invoke();

Future<void> showAddCornerDialog(
  BuildContext context,
  WidgetRef ref,
  CampId campId,
) async {
  final nameController = TextEditingController();
  final minutesController = TextEditingController(text: '10');
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final colors = isDark ? AppColors.dark : AppColors.light;
      return AlertDialog(
        title: Text(
          '코너 추가',
          style: AppTypography.title3.copyWith(color: colors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: const InputDecoration(labelText: '코너 이름'),
            ),
            const SizedBox(height: AppSpacing.space3),
            TextField(
              controller: minutesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '목표시간(분)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          AppButton(
            variant: AppButtonVariant.primary,
            size: AppButtonSize.compact,
            label: '추가',
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      );
    },
  );
  if (confirmed != true) return;
  final name = nameController.text.trim();
  final minutes = int.tryParse(minutesController.text) ?? 10;
  if (name.isEmpty) return;
  try {
    await runAction(
      () => ref.read(createCornerProvider(campId, name, minutes).future),
    );
    ref.invalidate(cornerListProvider(campId));
    ref.read(dashboardConnectionLostProvider.notifier).set(false);
  } on DioException catch (error) {
    // DioException은 LoggingInterceptor(#131)가 네트워크 계층에서 이미 기록한다 —
    // 커넥션 유실(dio_error.dart:isConnectionLost)만 상단 배너로, 그 외는 SnackBar로.
    if (isConnectionLost(error)) {
      ref.read(dashboardConnectionLostProvider.notifier).set(true);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('코너 추가에 실패했습니다. 잠시 후 다시 시도해주세요.')),
      );
    }
  }
}

Future<void> deleteCorner(
  BuildContext context,
  WidgetRef ref,
  CampId campId,
  CornerDashboardEntry entry,
) async {
  if (entry.hasBusyTrack) {
    await showConfirmModal(
      context,
      kind: ConfirmModalKind.hardBlock,
      title: '작업할 수 없습니다',
      body: '진행 중인 방문이 있어 삭제할 수 없습니다',
    );
    return;
  }
  final confirmed = await showConfirmModal(
    context,
    kind: ConfirmModalKind.softConfirm,
    title: '코너 "${entry.corner.name ?? entry.corner.id}"를 삭제하시겠습니까?',
    body: '연결된 트랙과 방문 기록도 함께 삭제됩니다.',
  );
  if (!confirmed) return;
  try {
    await runAction(
      () => ref.read(deleteCornerProvider(CornerId(entry.corner.id!)).future),
    );
    ref.invalidate(cornerListProvider(campId));
    ref.read(dashboardConnectionLostProvider.notifier).set(false);
  } on DioException catch (error) {
    if (isConnectionLost(error)) {
      ref.read(dashboardConnectionLostProvider.notifier).set(true);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('코너 삭제에 실패했습니다. 잠시 후 다시 시도해주세요.')),
      );
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('코너 삭제에 실패했습니다. 잠시 후 다시 시도해주세요.')),
      );
    }
  }
}
