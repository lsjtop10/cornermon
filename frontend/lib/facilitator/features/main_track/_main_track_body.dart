import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cornermon/shared/api/domain_aliases.dart';
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/group_providers.dart';
import 'package:cornermon/shared/api/providers/visit_providers.dart';
import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';
import '../../widgets/double_tap_confirm_button.dart';

/// B2 바디 — IDLE(코너명 + 스캔시작) / BUSY(조번호 + 타이머 + 진행률바 + 종료확인).
class MainTrackBody extends StatelessWidget {
  const MainTrackBody({
    required this.trackId,
    required this.currentVisit,
    required this.cornerName,
    required this.trackNo,
    required this.targetMinutes,
    required this.onVisitEnded,
    super.key,
  });

  final TrackId trackId;
  final VisitSummary? currentVisit;
  final String cornerName;
  final int trackNo;
  final int? targetMinutes;
  final ValueChanged<VisitSummary> onVisitEnded;

  @override
  Widget build(BuildContext context) {
    final visit = currentVisit;
    if (visit == null || visit.status != VisitStatus.IN_PROGRESS) {
      // BUSY가 아니면 시작 액션(스캔 시작)만 노출 — 대기열 없음 규칙의 UI 반영(UC-5).
      return _IdleBody(cornerName: cornerName, trackNo: trackNo);
    }

    return _BusyBody(
      trackId: trackId,
      visit: visit,
      targetMinutes: targetMinutes,
      onVisitEnded: onVisitEnded,
    );
  }
}

class _IdleBody extends StatelessWidget {
  const _IdleBody({required this.cornerName, required this.trackNo});

  final String cornerName;
  final int trackNo;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              cornerName,
              style: AppTypography.display.copyWith(color: colors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.space2),
            Text(
              '$trackNo번 트랙',
              style: AppTypography.caption.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.space10),
            AppButton(
              variant: AppButtonVariant.primary,
              size: AppButtonSize.comfortable,
              width: AppButtonWidth.fill,
              label: '스캔 시작',
              onPressed: () => context.go('/main/scan'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BusyBody extends ConsumerStatefulWidget {
  const _BusyBody({
    required this.trackId,
    required this.visit,
    required this.targetMinutes,
    required this.onVisitEnded,
  });

  final TrackId trackId;
  final VisitSummary visit;
  final int? targetMinutes;
  final ValueChanged<VisitSummary> onVisitEnded;

  @override
  ConsumerState<_BusyBody> createState() => _BusyBodyState();
}

class _BusyBodyState extends ConsumerState<_BusyBody> {
  Timer? _ticker;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateElapsed();
    // 서버 폴링이 아니라 시작시각 기준 로컬 계산 — startedAt/now 모두 같은 절대 순간을
    // 정확히 표현하는 UTC라 타임존 변환 없이도 경과시간은 정확하다(§00 §0-e).
    _ticker = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateElapsed(),
    );
  }

  @override
  void didUpdateWidget(covariant _BusyBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.visit.startedAt != widget.visit.startedAt) {
      _updateElapsed();
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _updateElapsed() {
    if (!mounted) return;
    setState(
      () => _elapsed = DateTime.now().difference(widget.visit.startedAt!),
    );
  }

  Future<void> _endCurrent() async {
    try {
      final summary = await ref
          .read(visitActionsProvider(widget.trackId).notifier)
          .endCurrent();
      widget.onVisitEnded(summary);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('방문 종료에 실패했습니다. 다시 시도해주세요.')),
      );
    }
  }

  String _formatElapsed(Duration elapsed) {
    final totalSeconds = elapsed.inSeconds < 0 ? 0 : elapsed.inSeconds;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;
    // groupDetailProvider(GET /groups/{id})는 admin 전용 라우트라 트랙 토큰으로 호출하면
    // 401을 유발해 세션이 강제 종료된다 — 이미 로그인 시 구독 중인 트랙 스코프 그룹 목록
    // (GET /tracks/{trackId}/groups)에서 같은 조를 찾아 쓴다.
    final groupAsync = ref
        .watch(trackScopedGroupsProvider(widget.trackId))
        .whenData(
          (groups) =>
              groups.firstWhere((g) => g.id == widget.visit.groupId),
        );

    final targetSeconds = widget.targetMinutes != null
        ? widget.targetMinutes! * 60
        : null;
    final elapsedSeconds = _elapsed.inSeconds < 0 ? 0 : _elapsed.inSeconds;
    // 트랙 상태 자체는 여전히 BUSY — 이 색은 진행률 바만의 초과 여부 보조 신호다
    // (design-system.md §1.2 "BUSY와 ALERT를 혼동하지 말 것").
    final isOverTarget =
        targetSeconds != null && elapsedSeconds > targetSeconds;
    final progress = targetSeconds != null && targetSeconds > 0
        ? (elapsedSeconds / targetSeconds).clamp(0.0, 1.0).toDouble()
        : null;
    final progressColor = isOverTarget ? colors.statusAlert : colors.statusIdle;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.space6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          groupAsync.when(
            data: (group) => Text(
              group.name ?? '',
              style: AppTypography.title1.copyWith(color: colors.textPrimary),
              textAlign: TextAlign.center,
            ),
            loading: () => const SizedBox(height: 34.0),
            error: (_, _) => Text(
              '조 정보를 불러오지 못했습니다',
              style: AppTypography.body.copyWith(color: colors.textSecondary),
            ),
          ),
          const SizedBox(height: AppSpacing.space6),
          Text(
            _formatElapsed(_elapsed),
            style: AppTypography.display.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.space4),
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8.0,
              backgroundColor: colors.border,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          const SizedBox(height: AppSpacing.space8),
          DoubleTapConfirmButton(
            label: '종료 확인',
            armedLabel: '다시 탭해 확인',
            onConfirmed: () => unawaited(_endCurrent()),
          ),
        ],
      ),
    );
  }
}
