import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cornermon/shared/api/domain_aliases.dart';
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/corner_track_providers.dart';
import 'package:cornermon/shared/api/providers/visit_providers.dart';
import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';
import 'package:cornermon/facilitator/session/track_session_provider.dart';
import '../visit_summary/visit_summary_overlay.dart';
import '_main_track_body.dart';
import '_main_track_header.dart';
import 'track_event_coordinator.dart';

/// B2. 진행자 메인 트랙 화면 — IDLE→BUSY→COMPLETED 핵심 루프(scenarios.md Feature 1).
class MainTrackScreen extends ConsumerStatefulWidget {
  const MainTrackScreen({super.key});

  @override
  ConsumerState<MainTrackScreen> createState() => _MainTrackScreenState();
}

class _MainTrackScreenState extends ConsumerState<MainTrackScreen> {
  // B5 오버레이 — 종료확인 성공 응답을 잠시 들고 있다가 VisitSummaryOverlay가 자동으로 닫는다.
  VisitSummary? _visitJustCompleted;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(trackSessionProvider);
    if (session is! TrackSessionAuthenticated) {
      // 라우터 가드가 정상 동작하면 이 상태로 진입하지 않는다(위젯 테스트 등 예외 상황 방어).
      return const SizedBox.shrink();
    }

    final trackId = TrackId(session.track.id!);

    // 코디네이터는 watch만 해서 화면이 떠 있는 동안만 활성화한다 — @riverpod 기본값
    // (autoDispose)이므로 화면이 unmount되면 코디네이터와 그 안의 trackEvents 구독도
    // 함께 dispose된다(§04 plan). 반환값(void)은 쓰지 않는다.
    ref.watch(trackEventCoordinatorProvider(trackId));

    final currentVisit = ref
        .watch(currentVisitProvider(trackId))
        .maybeWhen(data: (v) => v, orElse: () => null);

    // 목표시간(분)은 Track/로그인 응답이 아니라 Corner 엔티티에만 있어 별도 조회가 필요하다.
    final cornerId = session.corner.id;
    final targetMinutes = cornerId == null
        ? null
        : ref
              .watch(cornerDetailProvider(CornerId(cornerId)))
              .maybeWhen(
                data: (corner) => corner.targetMinutes,
                orElse: () => null,
              );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;
    final isIdle = currentVisit == null;

    return Scaffold(
      backgroundColor: colors.bgCanvas,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                MainTrackHeader(trackId: trackId),
                Expanded(
                  child: MainTrackBody(
                    trackId: trackId,
                    currentVisit: currentVisit,
                    cornerName: session.corner.name ?? '',
                    trackNo: session.track.trackNo ?? 0,
                    targetMinutes: targetMinutes,
                    onVisitEnded: (summary) =>
                        setState(() => _visitJustCompleted = summary),
                  ),
                ),
                if (isIdle)
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.space4),
                    child: AppButton(
                      variant: AppButtonVariant.secondary,
                      size: AppButtonSize.comfortable,
                      width: AppButtonWidth.fill,
                      label: '수동으로 처리',
                      onPressed: () => context.go('/main/manual'),
                    ),
                  ),
              ],
            ),
            if (_visitJustCompleted != null)
              Positioned.fill(
                child: VisitSummaryOverlay(
                  visit: _visitJustCompleted!,
                  onDismiss: () => setState(() => _visitJustCompleted = null),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
