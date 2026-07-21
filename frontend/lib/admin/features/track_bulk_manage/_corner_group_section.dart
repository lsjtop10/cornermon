import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:cornermon/shared/design_system/widgets/app_tag.dart';
import 'package:cornermon/shared/design_system/widgets/status_badge.dart';

import 'track_bulk_manage_grouping.dart';

/// 코너 1개 + 그 코너에 속한 트랙 목록을 평면 박스 안에서 접었다 펼 수 있는 순수
/// 조회 항목으로 보여준다. 코너/트랙 생성·삭제·수정은 대시보드(코너)와 코너 상세
/// 화면(트랙)으로 옮겨졌으므로 이 화면에는 어떤 액션도 두지 않는다.
class CornerGroupSection extends StatefulWidget {
  const CornerGroupSection({required this.group, super.key});

  final CornerTrackGroup group;

  @override
  State<CornerGroupSection> createState() => _CornerGroupSectionState();
}

class _CornerGroupSectionState extends State<CornerGroupSection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;
    final group = widget.group;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space3),
      child: Container(
        decoration: BoxDecoration(
          color: colors.bgSurface,
          border: Border.all(color: colors.border),
          borderRadius: BorderRadius.circular(12.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: () =>
                  context.go('/dashboard/corners/${group.corner.id}'),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space4,
                  vertical: AppSpacing.space3,
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => setState(() => _expanded = !_expanded),
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: AnimatedRotation(
                          turns: _expanded ? 0.25 : 0,
                          duration: const Duration(milliseconds: 150),
                          child: Icon(
                            Icons.chevron_right,
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space2),
                    Expanded(
                      child: Text(
                        group.corner.name ?? group.corner.id ?? '코너',
                        style: AppTypography.title3.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    AppTag(label: '트랙 ${group.tracks.length}개'),
                  ],
                ),
              ),
            ),
            if (_expanded) ...[
              Divider(height: 1, color: colors.border),
              if (group.tracks.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space4,
                    vertical: AppSpacing.space4,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.link_off,
                        size: 16,
                        color: colors.textDisabled,
                      ),
                      const SizedBox(width: AppSpacing.space2),
                      Text(
                        '연결된 트랙이 없습니다',
                        style: AppTypography.caption.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              else
                for (final track in group.tracks) _TrackRow(track: track),
            ],
          ],
        ),
      ),
    );
  }
}

class _TrackRow extends StatelessWidget {
  const _TrackRow({required this.track});

  final api.Track track;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;
    final isBusy = track.operationalStatus == api.TrackOperationalStatus.BUSY;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space4,
        vertical: AppSpacing.space2,
      ),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: Row(
        children: [
          Text(
            '${track.trackNo ?? '-'}번 트랙',
            style: AppTypography.bodyEmphasis.copyWith(
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(width: AppSpacing.space3),
          StatusBadge(
            status: isBusy ? TrackVisualStatus.busy : TrackVisualStatus.idle,
          ),
          const Spacer(),
          Text(
            '현재 조: ${track.currentVisit?.groupId ?? '-'}',
            style: AppTypography.caption.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}
