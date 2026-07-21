import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cornermon/shared/api/dio_error.dart';
import 'package:cornermon/shared/api/domain_aliases.dart';
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/group_providers.dart';
import 'package:cornermon/shared/api/providers/visit_providers.dart';
import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';
import 'package:cornermon/shared/design_system/widgets/confirm_modal.dart';
import 'package:cornermon/shared/design_system/widgets/empty_state.dart';
import 'package:cornermon/facilitator/session/track_session_provider.dart';

/// B4 — 수동 처리(조 선택, 입장 전용). QR 배지 훼손 등 예외 상황에서만 쓰는 저빈도 화면
/// (§domain-model 2.6-b, 퇴장은 배지 상태와 무관하게 항상 B2에서 처리하므로 이 화면의 대상이 아니다).
class ManualCheckinScreen extends ConsumerStatefulWidget {
  const ManualCheckinScreen({super.key});

  @override
  ConsumerState<ManualCheckinScreen> createState() =>
      _ManualCheckinScreenState();
}

class _ManualCheckinScreenState extends ConsumerState<ManualCheckinScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  bool _submitting = false; // 확인 모달 확정 처리 중 카드 중복 탭 방지

  @override
  void initState() {
    super.initState();
    _searchController.addListener(
      () => setState(() => _query = _searchController.text.trim()),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  TrackId get _trackId {
    final session = ref.read(trackSessionProvider);
    if (session is! TrackSessionAuthenticated) {
      throw StateError('수동 처리는 인증된 트랙 세션에서만 가능합니다.');
    }
    return TrackId(session.track.id!);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;

    final session = ref.watch(trackSessionProvider);
    final cornerId = session is TrackSessionAuthenticated
        ? session.corner.id
        : null;
    final groupsAsync = session is TrackSessionAuthenticated
        ? ref.watch(trackScopedGroupsProvider(TrackId(session.track.id!)))
        : const AsyncValue<List<Group>>.data([]);

    return Scaffold(
      backgroundColor: colors.bgCanvas,
      appBar: AppBar(title: const Text('수동 처리')),
      body: Column(
        children: [
          const _WarningBanner(),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.space4,
              AppSpacing.space4,
              AppSpacing.space4,
              AppSpacing.space2,
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '조 이름으로 검색',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: colors.bgSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: colors.border),
                ),
              ),
            ),
          ),
          Expanded(
            child: groupsAsync.when(
              data: (groups) {
                final query = _query.toLowerCase();
                final filtered = query.isEmpty
                    ? groups
                    : groups
                          .where(
                            (g) => (g.name ?? '').toLowerCase().contains(query),
                          )
                          .toList();

                if (filtered.isEmpty) {
                  return const EmptyState(
                    message: '검색 결과가 없습니다',
                    icon: Icons.search_off,
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space4,
                    vertical: AppSpacing.space2,
                  ),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.space3),
                  itemBuilder: (context, index) {
                    final group = filtered[index];
                    // 자기 코너(=현재 로그인한 트랙의 코너)가 이미 COMPLETED면 재시작 자체를 막는다.
                    final completed =
                        cornerId != null &&
                        (group.itinerary ?? const <CornerProgress>[]).any(
                          (p) =>
                              p.cornerId == cornerId &&
                              p.status == VisitStatusPerCorner.COMPLETED,
                        );
                    return _GroupCard(
                      group: group,
                      completed: completed,
                      onTap: completed ? null : () => _onGroupTap(group),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => const EmptyState(
                message: '조 목록을 불러오지 못했습니다',
                icon: Icons.error_outline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onGroupTap(Group group) async {
    if (_submitting) return;

    final confirmed = await showConfirmModal(
      context,
      kind: ConfirmModalKind.softConfirm,
      title: '${group.name}을(를) 시작 처리하시겠습니까?',
      buttonSize: AppButtonSize.comfortable,
    );
    if (!confirmed || !mounted) return;

    setState(() => _submitting = true);
    try {
      await ref
          .read(visitActionsProvider(_trackId).notifier)
          .startManual(GroupId(group.id!));
      if (!mounted) return;
      context.pop(); // 성공 → B2로 복귀
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_messageFor(e))));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  /// ErrorResponse.code → 안내 문구 매핑(B3 QrScanScreen과 동일 규칙, screen-spec B3/B4 공통).
  /// DUPLICATE_VISIT/GROUP_AT_CORNER는 백엔드가 실제로 보내는 코드 목록에 없어 드리프트로
  /// 죽어있던 case였다(qr_scan_screen.dart 주석 참고) — enum 전환 시 컴파일이 안 되므로 제거했다.
  String _messageFor(DioException e) {
    final code = errorCodeOf(e);
    switch (code) {
      case ErrorCode.CodeTrackBusy:
        return '현재 진행중인 조가 있습니다';
      default:
        return '방문을 시작하지 못했습니다';
    }
  }
}

class _WarningBanner extends StatelessWidget {
  const _WarningBanner();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;

    return Container(
      width: double.infinity,
      // ignore: deprecated_member_use
      color: colors.warning.withOpacity(isDark ? 0.25 : 0.15),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space4,
        vertical: AppSpacing.space3,
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: colors.warning, size: 20.0),
          const SizedBox(width: AppSpacing.space2),
          Expanded(
            child: Text(
              'QR 훼손 등으로 인식이 안 되는 경우에만 사용하세요',
              style: AppTypography.caption.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({
    required this.group,
    required this.completed,
    required this.onTap,
  });

  final Group group;
  final bool completed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;

    return Material(
      color: completed ? colors.bgCanvas : colors.bgSurface,
      borderRadius: BorderRadius.circular(16.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
          constraints: const BoxConstraints(minHeight: 64.0),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space4,
            vertical: AppSpacing.space3,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: colors.border),
          ),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  group.name ?? '',
                  style: AppTypography.title3.copyWith(
                    color: completed ? colors.textDisabled : colors.textPrimary,
                  ),
                ),
              ),
              if (completed) ...[
                const SizedBox(width: AppSpacing.space3),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 4.0,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: colors.textDisabled),
                    borderRadius: BorderRadius.circular(100.0),
                  ),
                  child: Text(
                    '완료됨',
                    style: AppTypography.label.copyWith(
                      color: colors.textDisabled,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
