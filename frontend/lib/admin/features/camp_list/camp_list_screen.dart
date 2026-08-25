import 'package:cornermon/admin/entities/camp_ext.dart';
import 'package:cornermon/admin/session/admin_session_provider.dart';
import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/shared/api/dio_error.dart';
import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/camp_providers.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';
import 'package:cornermon/shared/design_system/widgets/confirm_modal.dart';
import 'package:cornermon/shared/design_system/widgets/empty_state.dart';
import 'package:cornermon/shared/design_system/widgets/app_tag.dart';
import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CampListScreen extends ConsumerWidget {
  const CampListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final camps = ref.watch(campListProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('캠프 목록'),
        // 3단 위계: 계정 관리(아이콘) < QR 배지 관리/새 캠프 시작(1차 버튼 2개) < 로그아웃(아이콘) —
        // QR 배지 관리는 캠프를 정하기도 전에 하는 핵심 준비 작업(screen-spec-admin.md
        // A0-d)이라, "관리자 계정 관리"와 묶여 톱니바퀴 메뉴 뒤에 있으면 처음 쓰는
        // 관리자에게는 계정 설정 정도로만 읽힌다 — "새 캠프 시작"과 동급으로 승격한다
        // (critique frontend-lib-admin 2026-08-25 P2 참고).
        actions: [
          Tooltip(
            message: '관리자 계정 관리',
            child: AppButton(
              variant: AppButtonVariant.iconOnly,
              size: AppButtonSize.compact,
              icon: Icons.admin_panel_settings_outlined,
              label: '관리자 계정 관리',
              onPressed: () => context.push('/admins'),
            ),
          ),
          const SizedBox(width: AppSpacing.space3),
          AppButton(
            variant: AppButtonVariant.secondary,
            size: AppButtonSize.compact,
            icon: Icons.qr_code_2_outlined,
            label: 'QR 배지 관리',
            onPressed: () => context.go('/badges'),
          ),
          const SizedBox(width: AppSpacing.space3),
          AppButton(
            variant: AppButtonVariant.primary,
            size: AppButtonSize.compact,
            icon: Icons.add,
            label: '새 캠프 시작',
            onPressed: () => context.go('/setup-wizard'),
          ),
          const SizedBox(width: AppSpacing.space4),
          Tooltip(
            message: '로그아웃',
            child: AppButton(
              variant: AppButtonVariant.iconOnly,
              size: AppButtonSize.compact,
              icon: Icons.logout,
              label: '로그아웃',
              onPressed: () => _confirmLogout(context, ref),
            ),
          ),
          const SizedBox(width: AppSpacing.space5),
        ],
      ),
      body: camps.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (error, _) => EmptyState(
          message: '캠프를 불러오지 못했습니다.\n$error',
          icon: Icons.error_outline,
          actionLabel: '재시도',
          onAction: () => ref.invalidate(campListProvider),
        ),

        data: (items) {
          if (items.isEmpty) {
            return EmptyState(
              message: '아직 캠프가 없습니다',
              icon: Icons.event_busy,
              actionLabel: '새 캠프 시작',
              onAction: () => context.go('/setup-wizard'),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.space6),
            children: [
              CampSection(
                status: api.CampStatus.ACTIVE,
                camps: items.whereStatus(api.CampStatus.ACTIVE),
              ),
              CampSection(
                status: api.CampStatus.PENDING,
                camps: items.whereStatus(api.CampStatus.PENDING),
              ),
              CampSection(
                status: api.CampStatus.ENDED,
                camps: items.whereStatus(api.CampStatus.ENDED),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// 로그아웃 성공/실패와 무관하게 `AdminSession.logout()`이 로컬 세션을 항상 정리하므로
/// (best-effort 서버 revoke), 라우터가 곧 `/login`으로 리다이렉트한다 — 여기서 직접
/// 내비게이션하지 않는다.
Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
  final confirmed = await showConfirmModal(
    context,
    kind: ConfirmModalKind.softConfirm,
    title: '로그아웃하시겠습니까?',
    body: '다시 사용하려면 로그인이 필요합니다.',
  );
  if (!confirmed) return;

  try {
    await ref.read(adminSessionProvider.notifier).logout();
  } on DioException catch (error) {
    // DioException은 LoggingInterceptor(#131)가 네트워크 계층에서 이미 기록한다.
    if (isConnectionLost(error)) return;
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('로그아웃 처리 중 오류가 발생했습니다.')));
  }
}

class CampSection extends StatelessWidget {
  const CampSection({required this.status, required this.camps, super.key});
  final api.CampStatus status;
  final List<api.Camp> camps;
  @override
  Widget build(BuildContext context) {
    if (camps.isEmpty) return const SizedBox.shrink();
    final title = switch (status) {
      api.CampStatus.ACTIVE => '진행 중',
      api.CampStatus.PENDING => '준비 중',
      api.CampStatus.ENDED => '종료됨',
      _ => '',
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.space3),
          Wrap(
            spacing: AppSpacing.space3,
            runSpacing: AppSpacing.space3,
            children: [for (final camp in camps) CampCard(camp: camp)],
          ),
        ],
      ),
    );
  }
}

class CampCard extends ConsumerWidget {
  const CampCard({required this.camp, super.key});
  final api.Camp camp;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusText = camp.isActive
        ? '진행 중'
        : camp.isPending
        ? '준비 중'
        : '종료됨';
    // PENDING/ACTIVE 모두 대시보드 하나로 들어간다 — 카드형/트랙별 뷰는 그 안의 토글일
    // 뿐 별도 경로가 아니다(critique frontend-lib-admin 2026-08-25 후속 반영).
    final destination = camp.isEnded ? '/report' : '/dashboard';
    final dates = [camp.startAt, camp.endAt]
        .whereType<DateTime>()
        .map(
          (date) =>
              '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}',
        )
        .join(' ~ ');

    return SizedBox(
      width: 280,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            final id = camp.id;
            if (id == null) return;
            ref.read(selectedCampIdProvider.notifier).select(CampId(id));
            context.go(destination);
          },
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.space5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTag(
                  label: statusText,
                  tone: camp.isActive
                      ? AppTagTone.success
                      : camp.isPending
                      ? AppTagTone.warning
                      : AppTagTone.neutral,
                ),
                const SizedBox(height: AppSpacing.space3),
                Text(
                  camp.name ?? '이름 없는 캠프',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (dates.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.space2),
                  Text(dates),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
