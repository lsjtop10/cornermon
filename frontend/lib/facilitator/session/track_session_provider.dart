import 'dart:async';
import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';

import 'package:cornermon/shared/api/domain_aliases.dart';
import 'package:cornermon/shared/api/providers/auth_device_trust_providers.dart';
import 'package:cornermon/shared/auth/secure_token_store.dart';
import 'device_trust_provider.dart';

part 'track_session_provider.g.dart';

/// §2.4 — B2 안내 문구가 사유별로 갈린다("트랙 삭제됨" / "강제 로그아웃됨" / "캠프 종료됨").
enum TrackSessionTerminationReason { trackDeleted, forceLogout, campEnded }

sealed class TrackSessionState {
  const TrackSessionState();

  String? get accessTokenOrNull => null;
}

/// 아직 로그인하지 않았거나, 세션이 종료된 상태.
class TrackSessionUnauthenticated extends TrackSessionState {
  const TrackSessionUnauthenticated({this.lastTerminationReason});

  final TrackSessionTerminationReason? lastTerminationReason;
}

/// PIN 로그인은 성공했으나 B1-b "이 트랙·코너가 맞습니까?" 확인 전 상태.
class TrackSessionPendingConfirmation extends TrackSessionState {
  const TrackSessionPendingConfirmation({
    required this.trackToken,
    required this.track,
    required this.corner,
  });

  final String trackToken;
  final Track track;
  final AuthTrackLoginPost200ResponseCorner corner;

  @override
  String? get accessTokenOrNull => trackToken;
}

/// B1-b에서 확인까지 완료되어 세션이 확정된 상태(무만료, §2.4).
class TrackSessionAuthenticated extends TrackSessionState {
  const TrackSessionAuthenticated({
    required this.trackToken,
    required this.track,
    required this.corner,
  });

  final String trackToken;
  final Track track;
  final AuthTrackLoginPost200ResponseCorner corner;

  @override
  String? get accessTokenOrNull => trackToken;
}

const _trackSessionStorageKey = 'track_session_login_response';

@riverpod
class TrackSession extends _$TrackSession {
  @override
  TrackSessionState build() {
    unawaited(_restore());
    return const TrackSessionUnauthenticated();
  }

  Future<void> _restore() async {
    final store = ref.read(secureTokenStoreProvider);
    final raw = await store.read(_trackSessionStorageKey);
    if (raw == null) return;

    final response = standardSerializers.deserializeWith(
      AuthTrackLoginPost200Response.serializer,
      jsonDecode(raw),
    );
    final trackToken = response?.trackToken;
    final track = response?.track;
    final corner = response?.corner;
    if (trackToken == null || track == null || corner == null) return;

    // 이미 B1-b 확인을 거쳐 저장된 세션이므로 복원 시 곧바로 Authenticated로 취급한다.
    state = TrackSessionAuthenticated(
      trackToken: trackToken,
      track: track,
      corner: corner,
    );
  }

  /// POST /auth/track/login — 세션 무만료(유휴 타임아웃 없음, §2.4).
  Future<void> loginWithPin(String pin) async {
    final deviceToken = await ref.read(deviceTrustTokenProvider.future);
    if (deviceToken == null) {
      throw Exception('신뢰된 기기가 아닙니다.');
    }

    final api = ref.read(authDeviceTrustApiProvider);
    final response = await api.authTrackLoginPost(
      xDeviceToken: deviceToken,
      request: AuthTrackLoginPostRequest(
        (AuthTrackLoginPostRequestBuilder b) => b..pin = pin,
      ),
    );

    final trackToken = response.data?.trackToken;
    final track = response.data?.track;
    final corner = response.data?.corner;
    if (trackToken == null || track == null || corner == null) {
      throw Exception('로그인 응답이 올바르지 않습니다.');
    }

    state = TrackSessionPendingConfirmation(
      trackToken: trackToken,
      track: track,
      corner: corner,
    );
  }

  /// B1-b "예, 맞습니다" — 별도 API 호출 없이 세션을 확정하고 영구 저장한다.
  Future<void> confirmAssignment() async {
    final current = state;
    if (current is! TrackSessionPendingConfirmation) return;

    final store = ref.read(secureTokenStoreProvider);
    final response = AuthTrackLoginPost200Response(
      (AuthTrackLoginPost200ResponseBuilder b) => b
        ..trackToken = current.trackToken
        ..track = current.track.toBuilder()
        ..corner = current.corner.toBuilder(),
    );
    await store.write(
      _trackSessionStorageKey,
      jsonEncode(
        standardSerializers.serializeWith(
          AuthTrackLoginPost200Response.serializer,
          response,
        ),
      ),
    );

    state = TrackSessionAuthenticated(
      trackToken: current.trackToken,
      track: current.track,
      corner: current.corner,
    );
  }

  /// B1-b "아니요" — 방금 발급된 세션을 즉시 폐기한다(POST /auth/track/logout).
  Future<void> rejectAssignment() async {
    if (state is! TrackSessionPendingConfirmation) return;

    final api = ref.read(authDeviceTrustApiProvider);
    await api.authTrackLogoutPost();

    state = const TrackSessionUnauthenticated();
  }

  /// SSE 감지 또는 401 응답 시 BUSY 여부와 무관하게 즉시 세션을 종료한다(§2.4 "유예 없이").
  void handleTermination(TrackSessionTerminationReason reason) {
    unawaited(
      ref.read(secureTokenStoreProvider).delete(_trackSessionStorageKey),
    );
    state = TrackSessionUnauthenticated(lastTerminationReason: reason);
  }
}
