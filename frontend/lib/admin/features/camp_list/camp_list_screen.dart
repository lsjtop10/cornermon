import 'package:cornermon/admin/entities/camp_ext.dart';
import 'package:cornermon/admin/session/admin_session_provider.dart';
import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/shared/api/dio_error.dart';
import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/camp_providers.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';
import 'package:cornermon/shared/design_system/widgets/confirm_modal.dart';
import 'package:cornermon/shared/design_system/widgets/empty_state.dart';
import 'package:cornermon/shared/design_system/widgets/app_tag.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
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
        actions: [
          TextButton.icon(
            onPressed: () => context.push('/admins'),
            icon: const Icon(Icons.admin_panel_settings_outlined),
            label: const Text('관리자 계정 관리'),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () => context.go('/badges'),
            icon: const Icon(Icons.qr_code),
            label: const Text('QR 배지 관리'),
          ),
          const SizedBox(width: 8),
          AppButton(
            variant: AppButtonVariant.primary,
            size: AppButtonSize.compact,
            icon: Icons.add,
            label: '새 캠프 시작',
            onPressed: () => context.go('/setup-wizard'),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () => _confirmLogout(context, ref),
            icon: const Icon(Icons.logout),
            label: const Text('로그아웃'),
          ),
          const SizedBox(width: 18),
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
            padding: const EdgeInsets.all(24),
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
  } on DioException catch (error, stackTrace) {
    debugPrint(
      '[camp_list] logout failed: type=${error.type} '
      'statusCode=${error.response?.statusCode}\n$stackTrace',
    );
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
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
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
    final destination = camp.isActive
        ? '/dashboard'
        : camp.isPending
        ? '/corner-track-manage'
        : '/report';
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
            padding: const EdgeInsets.all(20),
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
                const SizedBox(height: 12),
                Text(
                  camp.name ?? '이름 없는 캠프',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (dates.isNotEmpty) ...[
                  const SizedBox(height: 8),
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
