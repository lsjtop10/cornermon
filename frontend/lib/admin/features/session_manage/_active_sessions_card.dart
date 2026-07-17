import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
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

class ActiveSessionsCard extends ConsumerStatefulWidget {
  const ActiveSessionsCard({required this.campId, super.key});
  final CampId campId;

  @override
  ConsumerState<ActiveSessionsCard> createState() => _ActiveSessionsCardState();
}

class _ActiveSessionsCardState extends ConsumerState<ActiveSessionsCard> {
  final _manualTrackId = TextEditingController();

  @override
  void dispose() {
    _manualTrackId.dispose();
    super.dispose();
  }

  Future<void> _forceLogout(String trackId) async {
    if (trackId.trim().isEmpty) return;
    await ref.read(forceLogoutTrackProvider(TrackId(trackId.trim())).future);
    ref.invalidate(activeSessionListProvider(widget.campId));
    if (mounted) _manualTrackId.clear();
  }

  String _trackLabel(String? trackId, List<api.Track> tracks) {
    if (trackId == null) return '-';
    final track = tracks.where((t) => t.id == trackId).firstOrNull;
    return track?.trackNo != null ? '${track!.trackNo}번 트랙' : trackId;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;
    final sessions = ref.watch(activeSessionListProvider(widget.campId));
    final tracks = ref.watch(trackListProvider(widget.campId));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '② 활성 진행자 세션',
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
                      onPressed: () => ref.invalidate(
                        activeSessionListProvider(widget.campId),
                      ),
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
                                  _forceLogout(session.trackId ?? ''),
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
              '트랙 ID로 직접 강제 로그아웃',
              style: AppTypography.caption.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.space2),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _manualTrackId,
                    decoration: const InputDecoration(hintText: '트랙 ID'),
                  ),
                ),
                const SizedBox(width: AppSpacing.space2),
                AppButton(
                  variant: AppButtonVariant.secondary,
                  size: AppButtonSize.compact,
                  label: '강제 로그아웃',
                  onPressed: () => _forceLogout(_manualTrackId.text),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
