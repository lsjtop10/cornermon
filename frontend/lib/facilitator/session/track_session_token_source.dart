import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../shared/auth/session_token_source.dart';
import 'track_session_provider.dart';

/// [SessionTokenSource] 구현체 — 트랙 세션은 유휴 타임아웃이 없어(§2.4) silent refresh
/// 대상이 아니다. 401은 서버측 강제무효화 신호이므로 즉시 종료 처리한다.
class TrackSessionTokenSource implements SessionTokenSource {
  TrackSessionTokenSource(this.ref);

  final Ref ref;

  @override
  String? get currentAccessToken => ref.read(trackSessionProvider).accessTokenOrNull;

  @override
  Future<void> onUnauthorized() async {
    ref
        .read(trackSessionProvider.notifier)
        .handleTermination(TrackSessionTerminationReason.forceLogout);
  }
}
