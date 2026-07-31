import 'dart:convert';

import 'package:cornermon/facilitator/session/track_session_provider.dart';
import 'package:cornermon/shared/api/providers/auth_device_trust_providers.dart';
import 'package:cornermon/shared/auth/secure_token_store.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// track_session_login_response 저장 키를 메모리 맵으로 대체한다(플랫폼 채널 회피).
/// device_trust_status를 approved로 미리 채워둔다 — 그렇지 않으면 TrackSession.build()의
/// deviceTrustProvider 리스너(track_session_provider.dart 74-78줄)가 "미승인 기기"로 보고
/// 복원된 세션을 즉시 forceLogout으로 말소해버려 이 테스트들이 검증하려는 상태와 충돌한다.
class _FakeSecureTokenStore implements SecureTokenStore {
  final Map<String, String> values = {'device_trust_status': 'approved'};

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> delete(String key) async => values.remove(key);
}

String _serializedAuthenticatedSession() => jsonEncode(
  standardSerializers.serializeWith(
    TrackLoginResponse.serializer,
    TrackLoginResponse(
      (b) => b
        ..trackToken = 'track-token'
        ..track.replace(
          TrackResponse(
            (t) => t
              ..id = 'track-1'
              ..cornerId = 'corner-1'
              ..trackNo = 1
              ..status = TrackResponseStatusEnum.ACTIVE,
          ),
        )
        ..corner.replace(
          CornerResponse(
            (c) => c
              ..id = 'corner-1'
              ..name = '입장',
          ),
        ),
    ),
  ),
);

/// POST /auth/track/logout 호출 여부만 기록하고, 지정된 예외가 있으면 그대로 던진다.
class _FakeAuthDeviceTrustApi extends AAuthDeviceTrustApi {
  _FakeAuthDeviceTrustApi({this.throwOnLogout})
    : super(Dio(), standardSerializers);

  final DioException? throwOnLogout;
  int logoutCallCount = 0;

  @override
  Future<Response<void>> authTrackLogoutPost({
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    logoutCallCount++;
    final exception = throwOnLogout;
    if (exception != null) throw exception;
    return Response<void>(
      requestOptions: RequestOptions(path: '/auth/track/logout'),
      statusCode: 204,
    );
  }
}

ProviderContainer _containerWithAuthenticatedSession(
  _FakeAuthDeviceTrustApi api,
  _FakeSecureTokenStore store,
) {
  store.values['track_session_login_response'] =
      _serializedAuthenticatedSession();
  final container = ProviderContainer(
    overrides: [
      secureTokenStoreProvider.overrideWithValue(store),
      authDeviceTrustApiProvider.overrideWithValue(api),
    ],
  );
  return container;
}

void main() {
  test(
    'ShouldTerminateWithLoggedOutReasonWhenLogoutSucceeds',
    () async {
      // arrange: 이미 인증된 트랙 세션이 저장돼 있는 B2 상태.
      final api = _FakeAuthDeviceTrustApi();
      final store = _FakeSecureTokenStore();
      final container = _containerWithAuthenticatedSession(api, store);
      addTearDown(container.dispose);
      container.listen(trackSessionProvider, (_, _) {});
      await Future<void>.delayed(Duration.zero);
      expect(
        container.read(trackSessionProvider),
        isA<TrackSessionAuthenticated>(),
      );

      // act
      await container.read(trackSessionProvider.notifier).logout();

      // assert: 서버에 로그아웃을 통지하고, 로컬 세션은 loggedOut 사유로 종료된다.
      expect(api.logoutCallCount, 1);
      final state = container.read(trackSessionProvider);
      expect(state, isA<TrackSessionUnauthenticated>());
      expect(
        (state as TrackSessionUnauthenticated).lastTerminationReason,
        TrackSessionTerminationReason.loggedOut,
      );
      expect(store.values['track_session_login_response'], isNull);
    },
  );

  test(
    'ShouldNotChangeStateWhenLogoutRequestFails',
    () async {
      // arrange: 네트워크 오류 등으로 서버 로그아웃 자체가 실패하는 상황.
      final exception = DioException(
        requestOptions: RequestOptions(path: '/auth/track/logout'),
        type: DioExceptionType.connectionError,
      );
      final api = _FakeAuthDeviceTrustApi(throwOnLogout: exception);
      final store = _FakeSecureTokenStore();
      final container = _containerWithAuthenticatedSession(api, store);
      addTearDown(container.dispose);
      container.listen(trackSessionProvider, (_, _) {});
      await Future<void>.delayed(Duration.zero);

      // act & assert: 예외가 호출부로 전파되고, 로컬 세션 상태는 그대로 유지된다.
      await expectLater(
        container.read(trackSessionProvider.notifier).logout(),
        throwsA(isA<DioException>()),
      );
      expect(
        container.read(trackSessionProvider),
        isA<TrackSessionAuthenticated>(),
      );
    },
  );

  test(
    'ShouldTerminateWithTrackNotFoundReasonWhenHandleTerminationCalled',
    () async {
      // arrange
      final api = _FakeAuthDeviceTrustApi();
      final store = _FakeSecureTokenStore();
      final container = _containerWithAuthenticatedSession(api, store);
      addTearDown(container.dispose);
      container.listen(trackSessionProvider, (_, _) {});
      await Future<void>.delayed(Duration.zero);

      // act: track-scope API가 404 TRACK_NOT_FOUND를 감지했을 때의 경로(TrackSessionTokenSource 참고).
      container
          .read(trackSessionProvider.notifier)
          .handleTermination(TrackSessionTerminationReason.trackNotFound);

      // assert
      final state = container.read(trackSessionProvider);
      expect(state, isA<TrackSessionUnauthenticated>());
      expect(
        (state as TrackSessionUnauthenticated).lastTerminationReason,
        TrackSessionTerminationReason.trackNotFound,
      );
      expect(store.values['track_session_login_response'], isNull);
    },
  );
}
