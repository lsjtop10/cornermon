import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/admin/widgets/track_row_actions.dart';
import 'package:cornermon/admin/features/dashboard/_corner_status_pill.dart';
import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/corner_track_providers.dart';
import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/dimensions.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';
import 'package:cornermon/shared/design_system/widgets/empty_state.dart';
import 'package:cornermon/shared/design_system/widgets/confirm_modal.dart';
import 'package:cornermon/shared/design_system/widgets/status_badge.dart';
import 'package:cornermon/shared/design_system/widgets/responsive_context.dart';
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
      // "트랙" 제목 위(space5)와 아래(예전엔 space3) 여백이 비대칭이라 제목이 아래
      // 카드에 눌린 것처럼 답답해 보였다 — 위와 같은 간격으로 맞춘다.
      const SizedBox(height: AppSpacing.space5),
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
    final presentation = cornerStatusPresentation(status, colors);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '현재 상태',
          style: AppTypography.label.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(width: AppSpacing.space2),
        CornerStatusPill(
          color: presentation.color,
          icon: presentation.icon,
          label: presentation.label,
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
  Widget build(BuildContext context, WidgetRef ref) {
    // DataTable 5열(트랙/상태/현재 조/PIN/액션 — 액션 안에만 아이콘 버튼 4개)은
    // 태블릿/PC 표에선 문제없지만, 폰 콘텐츠 폭(~300px)에서는 가로 스크롤을 감싸도
    // 뒤쪽 열(PIN/액션)이 화면 밖으로 밀려 "잘려 보인다"는 신고가 있었다(#241) —
    // 표를 그대로 욱여넣는 대신 트랙 1개당 카드 1장으로 세로로 펼친다("stretch가
    // 아니라 restructure", adapt.native.md).
    if (context.isPhoneWidth) {
      // 트랙마다 별도 Card(기본 margin 4pt + 테두리/그림자)를 두면 그 반복되는
      // 카드 껍데기 자체가 여백을 먹는다 — device_manage_screen.dart의 기기 목록과
      // 같은 관례(Card 1개 + Divider로 구분되는 행)를 그대로 재사용해 껍데기를
      // 하나로 줄인다(#241 layout 다듬기).
      return Card(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        child: Column(
          children: [
            for (var i = 0; i < tracks.length; i++) ...[
              if (i > 0) const Divider(height: 1),
              _TrackRow(
                campId: campId,
                track: tracks[i],
                siblingCount: tracks.length,
              ),
            ],
          ],
        ),
      );
    }
    return SingleChildScrollView(
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
                DataCell(_TrackStatusBadge(track: track)),
                DataCell(Text(track.currentVisit?.groupId ?? '-')),
                const DataCell(Text('••••••')),
                DataCell(
                  _TrackActionButtons(
                    campId: campId,
                    track: track,
                    siblingCount: tracks.length,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _TrackStatusBadge extends StatelessWidget {
  const _TrackStatusBadge({required this.track});

  final api.Track track;

  @override
  Widget build(BuildContext context) => StatusBadge(
    status: track.operationalStatus == api.TrackOperationalStatus.BUSY
        ? TrackVisualStatus.busy
        : TrackVisualStatus.idle,
  );
}

/// PIN 보기/재발급/트랙 교체/삭제 4개 — 태블릿 표의 액션 열과 폰 카드가 그대로
/// 공유한다(#241, 로직 중복 방지).
class _TrackActionButtons extends ConsumerWidget {
  const _TrackActionButtons({
    required this.campId,
    required this.track,
    required this.siblingCount,
  });

  final CampId campId;
  final api.Track track;
  final int siblingCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 진행 중인 방문이 있는 트랙은 교체/삭제가 하드 블록 대상이다
    // (deleteTrack/openReplaceTrackDialog가 실제로도 이 상태면 거부한다).
    // §design-system.md 4.2가 처방한 대로 "누르고 나서 막기"가 아니라
    // 버튼을 사전 비활성화 + 이유 툴팁으로 안내한다.
    final isBusy = track.operationalStatus == api.TrackOperationalStatus.BUSY;
    return Wrap(
      children: [
        _ActionIconButton(
          tooltip: 'PIN 보기',
          onPressed: () => showTrackPinDialog(context, ref, track),
          icon: Icons.key_outlined,
        ),
        _ActionIconButton(
          tooltip: 'PIN 재발급',
          onPressed: () => regenerateTrackPin(context, ref, campId, track),
          icon: Icons.refresh,
        ),
        _ActionIconButton(
          tooltip: isBusy ? '진행 중인 방문이 완료된 후 다시 시도하세요' : '트랙 교체',
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
                        .where((corner) => corner.id != track.cornerId)
                        .toList(),
                    siblingActiveTrackCount: siblingCount,
                  );
                },
          icon: Icons.swap_horiz,
        ),
        _ActionIconButton(
          tooltip: isBusy ? '진행 중인 방문이 있어 삭제할 수 없습니다' : '삭제',
          onPressed: isBusy
              ? null
              : () => deleteTrack(
                  context,
                  ref,
                  campId,
                  track,
                  siblingActiveTrackCount: siblingCount,
                ),
          icon: Icons.delete_outline,
        ),
      ],
    );
  }
}

/// 기본 `IconButton`(48pt 탭 영역 + 자체 여백)은 4개가 나란히 붙으면 액션 열/행이
/// 실제 필요한 것보다 훨씬 헐렁해진다 — 이 앱의 컴팩트 밀도 컨트롤 표준
/// (`AppDimensions.iconButtonCompact`, 대시보드 코너 카드 삭제 버튼과 동일 패턴)을
/// 그대로 재사용해 여백만 줄인다(#241 layout 다듬기, 44pt라 터치 타겟은 그대로 지킴).
class _ActionIconButton extends StatelessWidget {
  const _ActionIconButton({
    required this.tooltip,
    required this.onPressed,
    required this.icon,
  });

  final String tooltip;
  final VoidCallback? onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: tooltip,
    onPressed: onPressed,
    constraints: const BoxConstraints(
      minWidth: AppDimensions.iconButtonCompact,
      minHeight: AppDimensions.iconButtonCompact,
    ),
    padding: EdgeInsets.zero,
    visualDensity: VisualDensity.compact,
    icon: Icon(icon, size: 20),
  );
}

/// 폰 폭 전용 — DataRow 한 줄이 담던 정보(트랙 번호/상태/현재 조/PIN/액션)를
/// 세로로 펼친 한 행. 카드 껍데기는 [_TrackTable]이 한 번만 두르므로 여기선
/// 안쪽 여백만 책임진다.
class _TrackRow extends StatelessWidget {
  const _TrackRow({
    required this.campId,
    required this.track,
    required this.siblingCount,
  });

  final CampId campId;
  final api.Track track;
  final int siblingCount;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.dark
        ? AppColors.dark
        : AppColors.light;
    return Padding(
      // 밀도를 줄이려고 space1(4pt)까지 좁혔더니 위 _CornerEditor 카드(space3~4 리듬)와
      // 안 맞고 행 자체가 눌려 보였다 — 액션 버튼만 컴팩트로 좁히고, 행 안쪽 여백은
      // 폼 카드와 같은 space3로 되돌린다.
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space4,
        vertical: AppSpacing.space3,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${track.trackNo ?? '-'}번 트랙',
                style: AppTypography.bodyEmphasis.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.space2),
              _TrackStatusBadge(track: track),
            ],
          ),
          const SizedBox(height: AppSpacing.space1),
          Text(
            '현재 조: ${track.currentVisit?.groupId ?? '-'}  ·  PIN: ••••••',
            style: AppTypography.caption.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.space2),
          _TrackActionButtons(
            campId: campId,
            track: track,
            siblingCount: siblingCount,
          ),
        ],
      ),
    );
  }
}

Future<bool> _confirm(BuildContext context, String message) => showConfirmModal(
  context,
  kind: ConfirmModalKind.softConfirm,
  title: message,
);
