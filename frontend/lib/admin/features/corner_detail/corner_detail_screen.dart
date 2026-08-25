import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/admin/widgets/track_row_actions.dart';
import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/corner_track_providers.dart';
import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';
import 'package:cornermon/shared/design_system/widgets/empty_state.dart';
import 'package:cornermon/shared/design_system/widgets/confirm_modal.dart';
import 'package:cornermon/shared/design_system/widgets/status_badge.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// A2. 선택한 코너의 규칙과 ACTIVE 트랙을 관리한다.
class CornerDetailScreen extends ConsumerWidget {
  const CornerDetailScreen({required this.cornerId, super.key});

  final CornerId cornerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campId = ref.watch(selectedCampIdProvider);
    if (campId == null) return const SizedBox.shrink();
    final corner = ref.watch(cornerDetailProvider(cornerId));
    final tracks = ref.watch(trackListProvider(campId));
    // 대시보드의 카드형/트랙별 뷰 어느 쪽에서 들어와도 같은 화면(/dashboard)의 다른
    // 렌더링일 뿐이라 돌아갈 곳은 항상 하나다 — 뷰 선택 상태(dashboardViewProvider)는
    // provider에 남아있으므로 복귀 시 원래 보던 뷰 그대로 돌아간다.
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/dashboard'),
          icon: const Icon(Icons.arrow_back),
          tooltip: '대시보드로 돌아가기',
        ),
        title: const Text('코너 상세'),
      ),
      body: corner.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('코너를 불러오지 못했습니다.\n$error')),
        data: (value) => tracks.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('트랙을 불러오지 못했습니다.\n$error')),
          data: (items) => _CornerBody(
            campId: campId,
            corner: value,
            tracks: items
                .where(
                  (track) =>
                      track.cornerId == value.id &&
                      track.status == api.TrackStatus.ACTIVE,
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _CornerBody extends ConsumerWidget {
  const _CornerBody({
    required this.campId,
    required this.corner,
    required this.tracks,
  });

  final CampId campId;
  final api.Corner corner;
  final List<api.Track> tracks;

  Future<void> _addTrack(WidgetRef ref) async {
    await ref.read(
      createTracksForCornerProvider(campId, CornerId(corner.id!), 1).future,
    );
    ref.invalidate(trackListProvider(campId));
  }

  Future<void> _saveCorner(
    BuildContext context,
    WidgetRef ref,
    String name,
    int targetMinutes,
  ) async {
    await ref.read(
      bulkUpdateCornersProvider([
        CornerUpdateInput(
          id: corner.id!,
          name: name,
          targetMinutes: targetMinutes,
        ),
      ]).future,
    );
    ref.invalidate(cornerDetailProvider(CornerId(corner.id!)));
    ref.invalidate(cornerListProvider(campId));
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('저장되었습니다')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => ListView(
    padding: const EdgeInsets.all(AppSpacing.space6),
    children: [
      _CornerEditor(
        corner: corner,
        onSave: (name, minutes) => _saveCorner(context, ref, name, minutes),
      ),
      const SizedBox(height: AppSpacing.space5),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('트랙', style: Theme.of(context).textTheme.titleLarge),
          AppButton(
            variant: AppButtonVariant.primary,
            size: AppButtonSize.compact,
            icon: Icons.add,
            label: '트랙 추가',
            onPressed: () => _addTrack(ref),
          ),
        ],
      ),
      const SizedBox(height: AppSpacing.space3),
      if (tracks.isEmpty)
        SizedBox(
          height: 220,
          child: EmptyState(
            message: '이 코너에는 트랙이 없습니다',
            icon: Icons.devices_other_outlined,
            actionLabel: '트랙 추가',
            onAction: () => _addTrack(ref),
          ),
        )
      else
        _TrackTable(campId: campId, tracks: tracks),
    ],
  );
}

class _CornerEditor extends StatefulWidget {
  const _CornerEditor({required this.corner, required this.onSave});

  final api.Corner corner;
  final Future<void> Function(String name, int minutes) onSave;

  @override
  State<_CornerEditor> createState() => _CornerEditorState();
}

class _CornerEditorState extends State<_CornerEditor> {
  late final _name = TextEditingController(text: widget.corner.name ?? '');
  late final _minutes = TextEditingController(
    text: '${widget.corner.targetMinutes ?? 0}',
  );

  @override
  void dispose() {
    _name.dispose();
    _minutes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 화면 명세(screen-spec-admin.md A2)는 "상단 코너 요약(이름, 상태, 목표시간)"을
          // 요구하지만 이름·목표시간 입력 필드만 있고 상태가 빠져 있었다 — 대시보드(A1)
          // 카드와 동일한 3색 판정(§design-system.md 1.2-b, 트랙 일부만 가동 중이어도
          // "정상"으로 묶어 보여준다)을 그대로 재사용해 여기서도 한눈에 보이게 한다.
          _CornerStatusRow(status: widget.corner.status),
          const SizedBox(height: AppSpacing.space3),
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: '코너 이름'),
          ),
          const SizedBox(height: AppSpacing.space3),
          TextField(
            controller: _minutes,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: '목표시간(분)'),
          ),
          const SizedBox(height: AppSpacing.space3),
          AppButton(
            variant: AppButtonVariant.primary,
            size: AppButtonSize.compact,
            label: '변경 저장',
            onPressed: () async {
              final minutes = int.tryParse(_minutes.text);
              if (minutes == null || minutes < 1) return;
              final confirmed = await _confirm(
                context,
                '${widget.corner.targetMinutes ?? 0}분 → $minutes분으로 변경합니다',
              );
              if (confirmed) await widget.onSave(_name.text.trim(), minutes);
            },
          ),
        ],
      ),
    ),
  );
}

/// 대시보드(A1)의 코너 카드와 동일한 3색 판정을 재사용한다: 트랙 일부만 가동 중이어도
/// 색으로는 구분하지 않고 "정상"(초록)으로 묶는다 — 여러 트랙을 하나로 요약할 때만
/// 적용되는 §design-system.md 1.2-b 규칙이라, 트랙 단위 상태에 쓰는 [StatusBadge](일부
/// 진행중이면 amber 'BUSY')를 그대로 재사용하면 안 된다.
class _CornerStatusRow extends StatelessWidget {
  const _CornerStatusRow({required this.status});

  final api.CornerOperationalStatus? status;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.dark
        ? AppColors.dark
        : AppColors.light;
    final presentation = switch (status) {
      api.CornerOperationalStatus.BUSY => (
        color: colors.statusIdle,
        icon: '●',
        label: '정상',
      ),
      api.CornerOperationalStatus.IDLE => (
        color: colors.quiet,
        icon: '○',
        label: '유휴',
      ),
      _ => (color: colors.statusInactive, icon: '✕', label: '미가동'),
    };
    final opacity = Theme.of(context).brightness == Brightness.dark
        ? .20
        : .12;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '현재 상태',
          style: AppTypography.label.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(width: AppSpacing.space2),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space2,
            vertical: AppSpacing.space1,
          ),
          decoration: BoxDecoration(
            color: presentation.color.withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            '${presentation.icon}  ${presentation.label}',
            style: AppTypography.label.copyWith(color: presentation.color),
          ),
        ),
      ],
    );
  }
}

class _TrackTable extends ConsumerWidget {
  const _TrackTable({required this.campId, required this.tracks});

  final CampId campId;
  final List<api.Track> tracks;

  @override
  Widget build(BuildContext context, WidgetRef ref) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: DataTable(
      columns: const [
        DataColumn(label: Text('트랙')),
        DataColumn(label: Text('상태')),
        DataColumn(label: Text('현재 조')),
        DataColumn(label: Text('PIN')),
        DataColumn(label: Text('액션')),
      ],
      rows: [
        for (final track in tracks)
          DataRow(
            cells: [
              DataCell(Text('${track.trackNo ?? '-'}번')),
              DataCell(
                StatusBadge(
                  status:
                      track.operationalStatus == api.TrackOperationalStatus.BUSY
                      ? TrackVisualStatus.busy
                      : TrackVisualStatus.idle,
                ),
              ),
              DataCell(Text(track.currentVisit?.groupId ?? '-')),
              const DataCell(Text('••••••')),
              DataCell(
                Builder(
                  builder: (buttonsContext) {
                    // 진행 중인 방문이 있는 트랙은 교체/삭제가 하드 블록 대상이다
                    // (deleteTrack/openReplaceTrackDialog가 실제로도 이 상태면 거부한다).
                    // §design-system.md 4.2가 처방한 대로 "누르고 나서 막기"가 아니라
                    // 버튼을 사전 비활성화 + 이유 툴팁으로 안내한다.
                    final isBusy =
                        track.operationalStatus ==
                        api.TrackOperationalStatus.BUSY;
                    return Wrap(
                      children: [
                        IconButton(
                          tooltip: 'PIN 보기',
                          onPressed: () =>
                              showTrackPinDialog(context, ref, track),
                          icon: const Icon(Icons.key_outlined),
                        ),
                        IconButton(
                          tooltip: 'PIN 재발급',
                          onPressed: () =>
                              regenerateTrackPin(context, ref, campId, track),
                          icon: const Icon(Icons.refresh),
                        ),
                        IconButton(
                          tooltip: isBusy
                              ? '진행 중인 방문이 완료된 후 다시 시도하세요'
                              : '트랙 교체',
                          onPressed: isBusy
                              ? null
                              : () async {
                                  final corners = await ref.read(
                                    cornerListProvider(campId).future,
                                  );
                                  if (!context.mounted) return;
                                  await openReplaceTrackDialog(
                                    context,
                                    ref,
                                    campId,
                                    track,
                                    corners
                                        .where(
                                          (corner) =>
                                              corner.id != track.cornerId,
                                        )
                                        .toList(),
                                    siblingActiveTrackCount: tracks.length,
                                  );
                                },
                          icon: const Icon(Icons.swap_horiz),
                        ),
                        IconButton(
                          tooltip: isBusy
                              ? '진행 중인 방문이 있어 삭제할 수 없습니다'
                              : '삭제',
                          onPressed: isBusy
                              ? null
                              : () => deleteTrack(
                                  context,
                                  ref,
                                  campId,
                                  track,
                                  siblingActiveTrackCount: tracks.length,
                                ),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
      ],
    ),
  );
}

Future<bool> _confirm(BuildContext context, String message) => showConfirmModal(
  context,
  kind: ConfirmModalKind.softConfirm,
  title: message,
);
