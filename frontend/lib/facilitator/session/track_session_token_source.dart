import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../shared/api/dio_error.dart';
import '../../shared/auth/session_token_source.dart';
import 'device_trust_provider.dart';
import 'track_session_provider.dart';

/// [SessionTokenSource] 구현체 — 트랙 세션은 유휴 타임아웃이 없어(§2.4) silent refresh
/// 대상이 아니다. 401은 서버측 강제무효화 신호이므로 즉시 종료 처리한다.
class TrackSessionTokenSource implements SessionTokenSource {
  TrackSessionTokenSource(this.ref);

  final Ref ref;

  @override
  String? get currentAccessToken =>
      ref.read(trackSessionProvider).accessTokenOrNull;

  @override
  Future<void> onUnauthorized() async {
    ref
        .read(trackSessionProvider.notifier)
        .handleTermination(TrackSessionTerminationReason.forceLogout);
    await ref.read(deviceTrustProvider.notifier).recoverFromTrackUnauthorized();
  }

  /// 트랙 삭제 후에도 세션 토큰이 남아있으면 track-scope API가 404 TRACK_NOT_FOUND를
  /// 돌려준다(이슈 #200) — SSE trackDeleted와 달리 이 경로는 REST 호출 시점에만 감지된다.
  @override
  Future<bool> onResourceNotFound(DioException error) async {
    if (errorCodeOf(error) != ErrorCode.CodeTrackNotFound) return false;

    ref
        .read(trackSessionProvider.notifier)
        .handleTermination(TrackSessionTerminationReason.trackNotFound);
    return true;
  }
}
