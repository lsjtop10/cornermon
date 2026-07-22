import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../shared/api/ids.dart';
import '../shared/design_system/theme/facilitator_theme.dart';
import 'features/main_track/track_event_coordinator.dart';
import 'router/facilitator_router.dart';
import 'session/track_session_provider.dart';

class FacilitatorApp extends ConsumerWidget {
  const FacilitatorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackSession = ref.watch(trackSessionProvider);
    // SSE 재조회 처리는 특정 화면의 수명에 묶이지 않아야 한다. 대화·공지 등 /main의
    // 하위 라우트로 이동해도 인증된 트랙 세션 동안 동일한 코디네이터를 유지한다.
    if (trackSession is TrackSessionAuthenticated) {
      ref.watch(
        trackEventCoordinatorProvider(TrackId(trackSession.track.id!)),
      );
    }

    return MaterialApp.router(
      routerConfig: ref.watch(facilitatorRouterProvider),
      theme: FacilitatorTheme.lightTheme,
      darkTheme: FacilitatorTheme.darkTheme,
    );
  }
}
