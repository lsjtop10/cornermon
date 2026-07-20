import 'dart:convert';

import 'package:cornermon/facilitator/session/device_trust_provider.dart';
import 'package:cornermon/facilitator/session/track_session_provider.dart';
import 'package:cornermon/shared/api/providers/auth_device_trust_providers.dart';
import 'package:cornermon/shared/auth/secure_token_store.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:dio/dio.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// PENDING 상태로 시작하는 기기 신뢰 토큰 스토리지를 메모리 맵으로 대체한다
/// (플랫폼 채널 회피). track_session_provider.dart의 트랙 세션 저장 키도
/// 미리 채워둘 수 있어 "이미 로그인된 트랙 세션"이 있는 상태를 흉내낼 수 있다.
class _FakePendingTokenStore implements SecureTokenStore {
  final Map<String, String> _values = {
    'device_trust_status': 'pending',
    'device_trust_token': 'fake-device-token',
  };

  void seedTrackSession(String json) =>
      _values['track_session_login_response'] = json;

  @override
  Future<void> write(String key, String value) async => _values[key] = value;

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> delete(String key) async => _values.remove(key);
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

/// GET /device-registrations/me — 호출할 때마다 리스트의 다음 status를 반환해
/// 폴링 도중 발생하는 상태 전이를 흉내낸다.
class _FakeAuthDeviceTrustApi extends AAuthDeviceTrustApi {
  _FakeAuthDeviceTrustApi(this._responses) : super(Dio(), standardSerializers);

  final List<DeviceStatusResponseStatusEnum> _responses;
  int callCount = 0;
  String? lastDeviceToken;

  @override
  Future<Response<DeviceStatusResponse>> deviceRegistrationsMeGet({
    required String xDeviceToken,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    lastDeviceToken = xDeviceToken;
    final index = callCount.clamp(0, _responses.length - 1);
    callCount++;
    const path = '/device-registrations/me';
    return Response<DeviceStatusResponse>(
      requestOptions: RequestOptions(path: path),
      statusCode: 200,
      data: DeviceStatusResponse((b) => b..status = _responses[index]),
    );
  }
}

void main() {
  test(
    'ShouldTransitionToApprovedWhenPollingDetectsStatusChange',
    () => fakeAsync((async) {
      // arrange: PENDING으로 시작, 첫 폴링은 여전히 PENDING, 두 번째 폴링에서 APPROVED로 전이.
      final api = _FakeAuthDeviceTrustApi([
        DeviceStatusResponseStatusEnum.PENDING,
        DeviceStatusResponseStatusEnum.APPROVED,
      ]);
      final container = ProviderContainer(
        overrides: [
          secureTokenStoreProvider.overrideWithValue(_FakePendingTokenStore()),
          authDeviceTrustApiProvider.overrideWithValue(api),
        ],
      );
      addTearDown(container.dispose);

      // act & assert: 초기 빌드 직후엔 스토리지에 저장된 PENDING 그대로.
      container.listen(deviceTrustProvider, (_, _) {});
      async.elapse(Duration.zero);
      expect(container.read(deviceTrustProvider).value, DeviceTrustStatus.pending);

      // 첫 폴링 tick(15초) — 서버가 아직 PENDING이라 상태 유지.
      async.elapse(const Duration(seconds: 15));
      expect(container.read(deviceTrustProvider).value, DeviceTrustStatus.pending);
      expect(api.lastDeviceToken, 'fake-device-token');

      // 두 번째 폴링 tick — 서버가 APPROVED로 전이됨을 감지해야 한다.
      async.elapse(const Duration(seconds: 15));
      expect(container.read(deviceTrustProvider).value, DeviceTrustStatus.approved);
    }),
  );

  test(
    'ShouldStopPollingAfterApprovedDetected',
    () => fakeAsync((async) {
      // arrange
      final api = _FakeAuthDeviceTrustApi([
        DeviceStatusResponseStatusEnum.APPROVED,
      ]);
      final container = ProviderContainer(
        overrides: [
          secureTokenStoreProvider.overrideWithValue(_FakePendingTokenStore()),
          authDeviceTrustApiProvider.overrideWithValue(api),
        ],
      );
      addTearDown(container.dispose);

      container.listen(deviceTrustProvider, (_, _) {});
      async.elapse(Duration.zero);

      // act: 한 번 승인이 감지된 이후로는 추가 폴링 호출이 없어야 한다(타이머 취소 확인).
      async.elapse(const Duration(seconds: 15));
      expect(container.read(deviceTrustProvider).value, DeviceTrustStatus.approved);
      expect(api.callCount, 1);

      async.elapse(const Duration(seconds: 60));

      // assert: 타이머가 취소됐다면 60초가 더 지나도 추가 호출이 없어야 한다.
      expect(api.callCount, 1);
    }),
  );

  test(
    'ShouldTerminateTrackSessionAndWipeDeviceTokenWhenRevoked',
    () => fakeAsync((async) {
      // arrange: 이미 PIN 로그인까지 마쳐 트랙 세션이 저장돼 있는 기기가,
      // 폴링 도중 관리자에 의해 회수(REVOKED)된 상황.
      final store = _FakePendingTokenStore()
        ..seedTrackSession(_serializedAuthenticatedSession());
      final api = _FakeAuthDeviceTrustApi([
        DeviceStatusResponseStatusEnum.REVOKED,
      ]);
      final container = ProviderContainer(
        overrides: [
          secureTokenStoreProvider.overrideWithValue(store),
          authDeviceTrustApiProvider.overrideWithValue(api),
        ],
      );
      addTearDown(container.dispose);

      container.listen(deviceTrustProvider, (_, _) {});
      container.listen(trackSessionProvider, (_, _) {});
      async.elapse(Duration.zero);

      // act: 트랙 세션이 정상 복원됐는지 먼저 확인 — 회수 전에는 인증된 상태여야 한다.
      expect(container.read(trackSessionProvider), isA<TrackSessionAuthenticated>());

      async.elapse(const Duration(seconds: 15));

      // assert: 회수 감지 → 기기 상태 갱신, 트랙 세션 즉시 말소, 기기 토큰 폐기.
      expect(container.read(deviceTrustProvider).value, DeviceTrustStatus.revoked);
      expect(container.read(trackSessionProvider), isA<TrackSessionUnauthenticated>());
      expect(store._values['device_trust_token'], isNull);
      expect(store._values['track_session_login_response'], isNull);
    }),
  );
}
