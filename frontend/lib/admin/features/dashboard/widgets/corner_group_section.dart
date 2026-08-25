import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:cornermon/shared/design_system/widgets/status_badge.dart';

import 'corner_status_pill.dart';
import 'package:cornermon/admin/features/dashboard/state/dashboard_track_grouping.dart';

/// 코너 1개 + 그 코너에 속한 트랙 목록을 접었다 펼 수 있는 순수 조회 항목으로
/// 보여준다 — 대시보드의 "트랙별" 뷰(카드형과 같은 필터·정렬 결과를 트랙 단위로
/// 펼쳐 보는 것뿐인 같은 화면의 다른 렌더링) 안에서만 쓴다. 코너/트랙 생성·삭제·
/// 수정은 카드형 뷰(코너)와 코너 상세 화면(트랙)에 그대로 남아있다.
///
/// 카드형 뷰의 코너 카드(widgets/corner_status_card.dart의 CornerStatusCard), 코너 상세의
/// 트랙 테이블(corner_detail/widgets/track_table.dart의 TrackTable)과 같은 시각 언어를 쓴다 —
/// Card 컨테이너 + 코너 상태 뱃지는 CornerStatusPill 공유, 트랙 목록은 §design-
/// system.md 4.5가 명시하는 "밀도 높은 테이블(정렬 가능한 컬럼 헤더, 행 높이 48pt)"
/// 패턴을 그대로 따르는 DataTable — 예전엔 이 화면만 테두리 박스+아이콘 뱃지로
/// 만들어져 있어서, 같은 화면에 카드형 뷰와 나란히 놓이니 이질감이 컸다.
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
    final presentation = cornerStatusPresentation(group.corner.status, colors);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space3),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              // 트랙별 뷰도 대시보드 자신이므로(별도 화면이 아니다), 카드형 뷰의 코너
              // 탭과 마찬가지로 돌아갈 곳은 항상 /dashboard 하나뿐이다.
              onTap: () =>
                  context.go('/dashboard/corners/${group.corner.id}'),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.space3),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        group.corner.name ?? group.corner.id ?? '코너',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyEmphasis.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space2),
                    CornerStatusPill(
                      color: presentation.color,
                      icon: presentation.icon,
                      label: presentation.label,
                    ),
                    const SizedBox(width: AppSpacing.space2),
                    // 탭 가능한 영역은 이 행 전체(코너 상세로 이동)지만, 접기/펼치기는
                    // 그 안의 별도 버튼이다 — §design-system.md 0-6(히트박스=시각 신호)에
                    // 따라 별도 InkWell로 분리해 상위 InkWell의 탭과 스플래시가 겹치지
                    // 않게 한다.
                    InkWell(
                      onTap: () => setState(() => _expanded = !_expanded),
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: AnimatedRotation(
                          turns: _expanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 150),
                          child: Icon(
                            Icons.expand_more,
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                    ),
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
                _TrackTable(tracks: group.tracks),
            ],
          ],
        ),
      ),
    );
  }
}

/// §design-system.md 4.5의 관리자 iPad 테이블 규칙(정렬 가능한 컬럼 헤더는 이 뷰
/// 자체가 이미 카드형과 정렬을 공유하므로 생략, 행 높이 48pt, zebra 없이 구분선만)을
/// 따른다 — corner_detail/widgets/track_table.dart의 TrackTable과 같은 시각 언어.
class _TrackTable extends StatelessWidget {
  const _TrackTable({required this.tracks});

  final List<api.Track> tracks;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: DataTable(
      dataRowMinHeight: 48,
      dataRowMaxHeight: 48,
      columns: const [
        DataColumn(label: Text('트랙')),
        DataColumn(label: Text('상태')),
        DataColumn(label: Text('현재 조')),
      ],
      rows: [
        for (final track in tracks)
          DataRow(
            cells: [
              DataCell(Text('${track.trackNo ?? '-'}번')),
              DataCell(
                StatusBadge(
                  status:
                      track.operationalStatus ==
                          api.TrackOperationalStatus.BUSY
                      ? TrackVisualStatus.busy
                      : TrackVisualStatus.idle,
                ),
              ),
              DataCell(Text(track.currentVisit?.groupId ?? '-')),
            ],
          ),
      ],
    ),
  );
}
