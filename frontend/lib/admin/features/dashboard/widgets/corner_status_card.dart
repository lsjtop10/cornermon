import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/dimensions.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:material_ui/material_ui.dart';

import 'package:cornermon/admin/features/dashboard/state/dashboard_entries.dart';
import 'corner_status_pill.dart';

class CornerStatusCard extends StatelessWidget {
  const CornerStatusCard({
    required this.entry,
    required this.onTap,
    this.onCreateTrack,
    this.onDelete,
    super.key,
  });

  final CornerDashboardEntry entry;
  final VoidCallback onTap;
  final VoidCallback? onCreateTrack;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.dark
        ? AppColors.dark
        : AppColors.light;
    final presentation = cornerStatusPresentation(entry.corner.status, colors);
    final metric = entry.corner.cornerMetric;
    final List<api.TrackSummary> tracks =
        entry.corner.activeTracks?.toList() ?? [];
    final busyTrackCount = tracks
        .where((track) => track.operationalStatus?.name == 'BUSY')
        .length;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: ValueKey('corner-card-${entry.corner.id}'),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                width: 4,
                color: entry.corner.isBottleneck ?? false
                    ? colors.statusAlert
                    : presentation.color,
              ),
            ),
          ),
          padding: const EdgeInsets.all(AppSpacing.space3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      entry.corner.name ?? '코너',
                      // 코너 이름은 관리자가 자유 입력하는 값이라 길이가 보장되지 않는다 —
                      // 이 카드는 고정 높이(mainAxisExtent: 242)라 줄바꿈을 허용하면
                      // 하단 내용(트랙 생성 버튼 등)이 Card의 clip에 잘려나간다.
                      // "스캔(훑어보기)" 원칙(§design-system.md 0-1)에도 축약이 더 맞다.
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyEmphasis.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  if (entry.corner.isBottleneck ?? false)
                    CornerStatusPill(
                      color: colors.statusAlert,
                      icon: '▲',
                      label: '병목',
                    ),
                  if (onDelete != null)
                    IconButton(
                      // 진행 중인 방문이 있으면 deleteCorner()가 실제로도 하드 블록한다 —
                      // §design-system.md 4.2가 처방한 대로 "누르고 나서 막기"가 아니라
                      // 버튼을 사전 비활성화 + 이유 툴팁으로 안내한다.
                      tooltip: entry.hasBusyTrack
                          ? '진행 중인 방문이 있어 삭제할 수 없습니다'
                          : '코너 삭제',
                      iconSize: 18,
                      // 시각적으로는 컴팩트하게 유지하되, 탭 영역은 이 앱의 컴팩트 밀도
                      // 컨트롤 표준(AppDimensions.iconButtonCompact, 44pt — §design-system.md
                      // 7-3의 관리자 최소 터치 타겟)과 맞춘다.
                      constraints: const BoxConstraints(
                        minWidth: AppDimensions.iconButtonCompact,
                        minHeight: AppDimensions.iconButtonCompact,
                      ),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      onPressed: entry.hasBusyTrack ? null : onDelete,
                      icon: Icon(
                        Icons.delete_outline,
                        color: entry.hasBusyTrack
                            ? colors.textDisabled
                            : colors.textSecondary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.space2),
              CornerStatusPill(
                color: presentation.color,
                icon: presentation.icon,
                label: presentation.label,
              ),
              const SizedBox(height: AppSpacing.space1),
              Text(
                '활성 ${tracks.length}트랙 중 $busyTrackCount 진행중 · 목표 ${entry.corner.targetMinutes ?? 0}분',
                // 이 카드는 GridView mainAxisExtent(242)로 높이가 고정돼 있어, 값이 커져
                // 줄바꿈되면 RenderFlex overflow로 크래시한다 — 1줄로 고정해 방지한다.
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              Text(
                formatCornerCardSubtitle(
                  avgDurationSeconds: metric?.avgDurationSeconds ?? 0,
                  sampleCount: metric?.sampleCount ?? 0,
                  avgDeviationSeconds: entry.avgDeviationSeconds,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption.copyWith(
                  color: entry.corner.isBottleneck ?? false
                      ? colors.statusAlert
                      : colors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (entry.inactive && onCreateTrack != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.space2,
                        vertical: AppSpacing.space1,
                      ),
                    ),
                    onPressed: onCreateTrack,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('트랙 생성'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
