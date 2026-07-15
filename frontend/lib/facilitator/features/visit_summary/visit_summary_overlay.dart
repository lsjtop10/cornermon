import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cornermon/shared/api/domain_aliases.dart';
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/group_providers.dart';
import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';

/// B5 — 방문 종료 확인 직후 소요시간/편차를 짧게 보여주고 자동으로 사라지는 오버레이.
class VisitSummaryOverlay extends ConsumerStatefulWidget {
  const VisitSummaryOverlay({
    required this.visit,
    required this.onDismiss,
    super.key,
  });

  final VisitSummary visit;
  final VoidCallback onDismiss;

  @override
  ConsumerState<VisitSummaryOverlay> createState() =>
      _VisitSummaryOverlayState();
}

class _VisitSummaryOverlayState extends ConsumerState<VisitSummaryOverlay> {
  Timer? _autoDismissTimer;
  bool _dismissed = false; // 자동/수동 닫힘이 겹쳐도 onDismiss는 1회만 호출

  @override
  void initState() {
    super.initState();
    _autoDismissTimer = Timer(const Duration(seconds: 3), _dismiss);
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    super.dispose();
  }

  void _dismiss() {
    if (_dismissed) return;
    _dismissed = true;
    _autoDismissTimer?.cancel();
    widget.onDismiss();
  }

  String _formatDuration(int totalSeconds) {
    final clamped = totalSeconds < 0 ? 0 : totalSeconds;
    final minutes = clamped ~/ 60;
    final seconds = clamped % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatSignedDuration(int totalSeconds) {
    final sign = totalSeconds < 0 ? '-' : '+';
    final abs = totalSeconds.abs();
    final minutes = abs ~/ 60;
    final seconds = abs % 60;
    return '$sign${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;

    final groupAsync = ref.watch(
      groupDetailProvider(GroupId(widget.visit.groupId!)),
    );
    final duration = widget.visit.durationSeconds ?? 0;
    final deviation = widget.visit.deviationSeconds ?? 0;
    final deviationColor = deviation > 0
        ? colors.statusAlert
        : colors.statusIdle;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _dismiss,
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        alignment: Alignment.center,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 280.0,
            padding: const EdgeInsets.all(AppSpacing.space6),
            decoration: BoxDecoration(
              color: colors.bgSurfaceRaised,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: _dismiss,
                    child: Icon(
                      Icons.close,
                      color: colors.textSecondary,
                      size: 20.0,
                    ),
                  ),
                ),
                Icon(Icons.check_circle, color: colors.statusIdle, size: 64.0),
                const SizedBox(height: AppSpacing.space4),
                groupAsync.when(
                  data: (group) => Text(
                    '${group.name} 처리 완료',
                    style: AppTypography.title3.copyWith(
                      color: colors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  loading: () => const SizedBox(height: 24.0),
                  error: (_, _) => Text(
                    '처리 완료',
                    style: AppTypography.title3.copyWith(
                      color: colors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: AppSpacing.space4),
                Text(
                  _formatDuration(duration),
                  style: AppTypography.title1.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.space1),
                Text(
                  _formatSignedDuration(deviation),
                  style: AppTypography.bodyEmphasis.copyWith(
                    color: deviationColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
