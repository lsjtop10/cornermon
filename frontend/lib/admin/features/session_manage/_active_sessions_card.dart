import 'package:collection/collection.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/not_implemented_exception.dart';
import 'package:cornermon/shared/api/providers/auth_device_trust_providers.dart';
import 'package:cornermon/shared/api/providers/corner_track_providers.dart';
import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';
import 'package:cornermon/shared/design_system/widgets/empty_state.dart';

/// 잠긴 기기와 달리 활성 세션 자체는 "잘못된 상태"가 아니라 정상 운영 중인 진행자
/// 목록이라, 잠긴 기기 섹션처럼 긴급 톤을 입히지 않는다 — 다만 그 아래 관리자 세션보다는
/// 자주 확인할 목록이라 Card 무게는 유지한다. 목록에 이미 뜬 트랙을 그 자리에서 강제
/// 로그아웃할 수 있으므로, ID를 직접 타이핑해 넣는 별도 입력창은 두지 않는다.
class ActiveSessionsCard extends ConsumerWidget {
  const ActiveSessionsCard({required this.campId, super.key});
  final CampId campId;

  Future<void> _forceLogout(WidgetRef ref, String trackId) async {
    if (trackId.trim().isEmpty) return;
    await ref.read(forceLogoutTrackProvider(TrackId(trackId.trim())).future);
    ref.invalidate(activeSessionListProvider(campId));
  }

  String _trackLabel(String? trackId, List<api.Track> tracks) {
    if (trackId == null) return '-';
    final track = tracks.where((t) => t.id == trackId).firstOrNull;
    return track?.trackNo != null ? '${track!.trackNo}번 트랙' : trackId;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;
    final sessions = ref.watch(activeSessionListProvider(campId));
    final tracks = ref.watch(trackListProvider(campId));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '활성 진행자 세션',
              style: AppTypography.title3.copyWith(color: colors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.space3),
            sessions.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) {
                if (error is NotImplementedException) {
                  return const EmptyState(
                    message: '활성 세션 조회는 백엔드 배포 후 제공됩니다(Issue #70)',
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '활성 세션 목록을 불러오지 못했습니다',
                      style: AppTypography.body.copyWith(color: colors.danger),
                    ),
                    const SizedBox(height: AppSpacing.space2),
                    AppButton(
                      variant: AppButtonVariant.secondary,
                      size: AppButtonSize.compact,
                      label: '재시도',
                      onPressed: () =>
                          ref.invalidate(activeSessionListProvider(campId)),
                    ),
                  ],
                );
              },
              data: (items) {
                if (items.isEmpty) {
                  return const EmptyState(
                    message: '활성 진행자 세션이 없습니다',
                    icon: Icons.phonelink_off,
                  );
                }
                final trackList = tracks.hasValue
                    ? tracks.value ?? const <api.Track>[]
                    : const <api.Track>[];
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
                              child: Text(
                                _trackLabel(session.trackId, trackList),
                                style: AppTypography.bodyEmphasis.copyWith(
                                  color: colors.textPrimary,
                                ),
                              ),
                            ),
                            AppButton(
                              variant: AppButtonVariant.destructive,
                              size: AppButtonSize.compact,
                              label: '강제 로그아웃',
                              onPressed: () =>
                                  _forceLogout(ref, session.trackId ?? ''),
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
