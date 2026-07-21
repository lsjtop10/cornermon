import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/api/providers/corner_track_providers.dart';
import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';
import 'package:cornermon/shared/design_system/widgets/app_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '_corner_group_section.dart';
import 'track_bulk_manage_grouping.dart';

enum _SortKey { corner, trackNo, status }

/// A2-B. 전체 코너·트랙 상태를 트랙 단위로 훑어보는 순수 조회 화면. 코너/트랙 생성·
/// 삭제·수정 액션은 대시보드(코너)와 코너 상세 화면(트랙)으로 옮겼다.
class TrackBulkManageScreen extends ConsumerStatefulWidget {
  const TrackBulkManageScreen({super.key});
  @override
  ConsumerState<TrackBulkManageScreen> createState() =>
      _TrackBulkManageScreenState();
}

class _TrackBulkManageScreenState extends ConsumerState<TrackBulkManageScreen> {
  api.TrackOperationalStatus? _filter;
  _SortKey _sortKey = _SortKey.corner;
  bool _ascending = true;

  List<CornerTrackGroup> _sortedGroups(
    List<api.Corner> cornerItems,
    List<api.Track> visible,
  ) {
    final groups = [
      for (final group in groupTracksByCorner(cornerItems, visible))
        CornerTrackGroup(
          corner: group.corner,
          tracks: [...group.tracks]
            ..sort((left, right) {
              final compare = switch (_sortKey) {
                _SortKey.trackNo => (left.trackNo ?? 0).compareTo(
                  right.trackNo ?? 0,
                ),
                _SortKey.status =>
                  (left.operationalStatus?.name ?? '').compareTo(
                    right.operationalStatus?.name ?? '',
                  ),
                _SortKey.corner => (left.trackNo ?? 0).compareTo(
                  right.trackNo ?? 0,
                ),
              };
              return _ascending ? compare : -compare;
            }),
        ),
    ];
    if (_sortKey == _SortKey.corner) {
      groups.sort((left, right) {
        final compare = (left.corner.name ?? left.corner.id ?? '').compareTo(
          right.corner.name ?? right.corner.id ?? '',
        );
        return _ascending ? compare : -compare;
      });
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final campId = ref.watch(selectedCampIdProvider);
    if (campId == null) return const SizedBox.shrink();
    final tracks = ref.watch(trackListProvider(campId));
    final corners = ref.watch(cornerListProvider(campId));
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/dashboard'),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('트랙별 보기'),
      ),
      body: corners.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('코너를 불러오지 못했습니다.\n$error')),
        data: (cornerItems) => tracks.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('트랙을 불러오지 못했습니다.\n$error')),
          data: (items) {
            final visible = items
                .where(
                  (track) =>
                      track.status == api.TrackStatus.ACTIVE &&
                      (_filter == null || track.operationalStatus == _filter),
                )
                .toList();
            final groups = _sortedGroups(cornerItems, visible);
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final colors = isDark ? AppColors.dark : AppColors.light;
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.space4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space4,
                      vertical: AppSpacing.space3,
                    ),
                    decoration: BoxDecoration(
                      color: colors.bgSurface,
                      border: Border.all(color: colors.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Wrap(
                      spacing: AppSpacing.space3,
                      runSpacing: AppSpacing.space2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        AppDropdown<api.TrackOperationalStatus?>(
                          value: _filter,
                          hint: '전체 상태',
                          items: const [
                            DropdownMenuItem(value: null, child: Text('전체')),
                            DropdownMenuItem(
                              value: api.TrackOperationalStatus.IDLE,
                              child: Text('유휴만'),
                            ),
                            DropdownMenuItem(
                              value: api.TrackOperationalStatus.BUSY,
                              child: Text('진행중만'),
                            ),
                          ],
                          onChanged: (value) => setState(() => _filter = value),
                        ),
                        AppDropdown<_SortKey>(
                          value: _sortKey,
                          items: const [
                            DropdownMenuItem(
                              value: _SortKey.corner,
                              child: Text('코너순'),
                            ),
                            DropdownMenuItem(
                              value: _SortKey.trackNo,
                              child: Text('트랙번호순'),
                            ),
                            DropdownMenuItem(
                              value: _SortKey.status,
                              child: Text('상태순'),
                            ),
                          ],
                          onChanged: (value) => setState(
                            () => _sortKey = value ?? _SortKey.corner,
                          ),
                        ),
                        Tooltip(
                          message: _ascending ? '오름차순' : '내림차순',
                          child: AppButton(
                            variant: AppButtonVariant.iconOnly,
                            size: AppButtonSize.compact,
                            icon: _ascending
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            label: _ascending ? '오름차순' : '내림차순',
                            onPressed: () =>
                                setState(() => _ascending = !_ascending),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space3),
                  Expanded(
                    child: ListView(
                      children: [
                        for (final group in groups)
                          CornerGroupSection(group: group),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
