import 'package:cornermon/facilitator/features/pin_login/pin_login_error_provider.dart';
import 'package:cornermon/facilitator/features/pin_login/pin_login_screen.dart';
import 'package:cornermon/facilitator/session/device_trust_provider.dart';
import 'package:cornermon/facilitator/session/track_session_provider.dart';
import 'package:cornermon/facilitator/widgets/pin_otp_input.dart';
import 'package:cornermon/shared/api/domain_aliases.dart';
import 'package:cornermon/shared/api/providers/auth_device_trust_providers.dart';
import 'package:cornermon/shared/auth/secure_token_store.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/widget_test_helpers.dart';

/// AAuthDeviceTrustApi는 생성 코드(concrete class)라 인터페이스가 아니지만,
/// 로그인 실패 응답 매핑 검증에 필요한 authTrackLoginPost만 override한다(나머지는 호출되지 않음).
class _FakeAuthDeviceTrustApi extends AAuthDeviceTrustApi {
  _FakeAuthDeviceTrustApi(this._exception) : super(Dio(), serializers);

  final DioException _exception;

  @override
  Future<Response<AuthTrackLoginPost200Response>> authTrackLoginPost({
    required String xDeviceToken,
    required AuthTrackLoginPostRequest request,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    throw _exception;
  }
}

/// TrackSession._restore()가 건드리는 시큐어스토리지를 메모리 맵으로 대체한다(플랫폼 채널 회피).
class _FakeSecureTokenStore implements SecureTokenStore {
  final Map<String, String> _values = {};

  @override
  Future<void> write(String key, String value) async => _values[key] = value;

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> delete(String key) async => _values.remove(key);
}

/// pinLoginErrorProvider의 상태를 고정값으로 오버라이드한다(위젯 테스트 전용).
class _FixedPinLoginError extends PinLoginError {
  _FixedPinLoginError(this._value);

  final PinLoginUiError? _value;

  @override
  PinLoginUiError? build() => _value;
}

class _RecordingDeviceTrust extends DeviceTrust {
  bool recoveryCalled = false;

  @override
  Future<DeviceTrustStatus> build() async => DeviceTrustStatus.approved;

  @override
  Future<DeviceTrustRecovery> recoverFromTrackUnauthorized() async {
    recoveryCalled = true;
    return DeviceTrustRecovery.cleared;
  }
}

DioException _loginError({
  required int statusCode,
  required String code,
  Map<String, dynamic>? details,
}) {
  const path = '/auth/track/login';
  return DioException(
    requestOptions: RequestOptions(path: path),
    response: Response<Object?>(
      requestOptions: RequestOptions(path: path),
      statusCode: statusCode,
      data: <String, dynamic>{'code': code, 'details': ?details},
    ),
  );
}

ProviderContainer _buildContainer(
  DioException exception, {
  DeviceTrust? deviceTrust,
}) => ProviderContainer(
  overrides: [
    authDeviceTrustApiProvider.overrideWithValue(
      _FakeAuthDeviceTrustApi(exception),
    ),
    secureTokenStoreProvider.overrideWithValue(_FakeSecureTokenStore()),
    if (deviceTrust != null)
      deviceTrustProvider.overrideWith(() => deviceTrust),
    // 신뢰기기 토큰이 있어야 loginWithPin이 실제 API 호출(및 그 실패)까지 도달한다.
    deviceTrustTokenProvider.overrideWith((ref) async => 'fake-device-token'),
  ],
);

void main() {
  test('ShouldMapInvalidPinErrorCode', () async {
    // arrange
    final container = _buildContainer(
      _loginError(
        statusCode: 400,
        code: 'INVALID_PIN',
        details: {'retryAfterSeconds': 5},
      ),
    );
    addTearDown(container.dispose);

    // act
    await container.read(pinLoginErrorProvider.notifier).submit('000000');

    // assert
    final state = container.read(pinLoginErrorProvider);
    expect(state, isA<PinInvalid>());
    expect((state as PinInvalid).retryAfterSeconds, 5);
  });

  test('ShouldMapPinLockedErrorCode', () async {
    // arrange
    final container = _buildContainer(
      _loginError(
        statusCode: 429,
        code: 'DEVICE_LOCKED',
        details: {'retryAfterSeconds': 120},
      ),
    );
    addTearDown(container.dispose);

    // act
    await container.read(pinLoginErrorProvider.notifier).submit('000000');

    // assert
    final state = container.read(pinLoginErrorProvider);
    expect(state, isA<PinLocked>());
    expect((state as PinLocked).retryAfterSeconds, 120);
  });

  test('ShouldMapDeviceNotTrustedErrorCode', () async {
    // arrange
    final container = _buildContainer(
      _loginError(statusCode: 403, code: 'DEVICE_NOT_APPROVED'),
    );
    addTearDown(container.dispose);

    // act
    await container.read(pinLoginErrorProvider.notifier).submit('000000');

    // assert
    expect(container.read(pinLoginErrorProvider), isA<DeviceNotTrustedYet>());
  });

  test(
    'ShouldRecoverRegistrationStatusWhenDeviceNotTrustedErrorCode',
    () async {
      // arrange
      final deviceTrust = _RecordingDeviceTrust();
      final container = _buildContainer(
        _loginError(statusCode: 403, code: 'DEVICE_NOT_APPROVED'),
        deviceTrust: deviceTrust,
      );
      addTearDown(container.dispose);

      // act
      await container.read(pinLoginErrorProvider.notifier).submit('000000');

      // assert
      expect(deviceTrust.recoveryCalled, isTrue);
    },
  );

  test('ShouldMapCampNotActiveErrorCode', () async {
    // arrange
    final container = _buildContainer(
      _loginError(statusCode: 403, code: 'CAMP_NOT_AVAILABLE'),
    );
    addTearDown(container.dispose);

    // act
    await container.read(pinLoginErrorProvider.notifier).submit('000000');

    // assert
    expect(container.read(pinLoginErrorProvider), isA<CampNotActiveYet>());
  });

  testWidgets('ShouldDisableInputWhenPinLocked', (tester) async {
    // arrange
    await tester.pumpWidget(
      buildTestable(
        const PinLoginScreen(),
        overrides: [
          pinLoginErrorProvider.overrideWith(
            () => _FixedPinLoginError(const PinLocked(retryAfterSeconds: 30)),
          ),
        ],
      ),
    );
    await tester.pump();

    // act
    final pinOtpInput = tester.widget<PinOtpInput>(find.byType(PinOtpInput));

    // assert
    expect(pinOtpInput.enabled, isFalse);

    // PIN_LOCKED 카운트다운의 Timer.periodic이 살아있으면 테스트 종료 후 pending timer 에러가
    // 나므로, 위젯을 교체해 dispose()가 타이머를 취소하도록 정리한다.
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('ShouldClearRegistrationWhenUserConfirmsCancellation', (
    tester,
  ) async {
    // arrange
    final store = _FakeSecureTokenStore();
    await store.write('device_trust_token', 'device-token');
    await store.write('device_trust_status', 'approved');
    await store.write('device_trust_registration_id', 'registration-1');
    await tester.pumpWidget(
      buildTestable(
        const PinLoginScreen(),
        overrides: [secureTokenStoreProvider.overrideWithValue(store)],
      ),
    );

    // act
    await tester.tap(find.text('기기 등록 취소'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('진행'));
    await tester.pumpAndSettle();

    // assert
    expect(await store.read('device_trust_token'), isNull);
    expect(await store.read('device_trust_status'), isNull);
    expect(await store.read('device_trust_registration_id'), isNull);
  });

  testWidgets('ShouldKeepRegistrationWhenUserCancelsCancellation', (
    tester,
  ) async {
    // arrange
    final store = _FakeSecureTokenStore();
    await store.write('device_trust_token', 'device-token');
    await tester.pumpWidget(
      buildTestable(
        const PinLoginScreen(),
        overrides: [secureTokenStoreProvider.overrideWithValue(store)],
      ),
    );

    // act
    await tester.tap(find.text('기기 등록 취소'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('취소'));
    await tester.pumpAndSettle();

    // assert
    expect(await store.read('device_trust_token'), 'device-token');
  });

  // screen-spec-facilitator.md:45 — 강제종료 사유별 안내 문구가 서로 달라야 한다.
  // trackNotFound는 이슈 #200에서 추가된 사유.
  const bannerCases = {
    TrackSessionTerminationReason.trackDeleted: '이 트랙이 삭제되어 로그아웃되었습니다',
    TrackSessionTerminationReason.forceLogout: '관리자에 의해 로그아웃되었습니다',
    TrackSessionTerminationReason.campEnded: '코너학습이 종료되어 로그아웃되었습니다',
    TrackSessionTerminationReason.trackNotFound: '이 트랙을 찾을 수 없습니다. 다시 로그인해주세요',
  };

  for (final entry in bannerCases.entries) {
    testWidgets(
      'ShouldShowBannerTextWhenTerminationReasonIs${entry.key.name}',
      (tester) async {
        // arrange
        await tester.pumpWidget(
          buildTestable(
            const PinLoginScreen(),
            overrides: [
              trackSessionProvider.overrideWith(
                () => _FixedTrackSession(
                  TrackSessionUnauthenticated(lastTerminationReason: entry.key),
                ),
              ),
            ],
          ),
        );
        await tester.pump();

        // assert
        expect(find.text(entry.value), findsOneWidget);
      },
    );
  }

  testWidgets('ShouldShowNoBannerWhenUserManuallyLoggedOut', (tester) async {
    // arrange: 본인이 누른 로그아웃(loggedOut)은 안내가 필요 없다.
    await tester.pumpWidget(
      buildTestable(
        const PinLoginScreen(),
        overrides: [
          trackSessionProvider.overrideWith(
            () => _FixedTrackSession(
              const TrackSessionUnauthenticated(
                lastTerminationReason: TrackSessionTerminationReason.loggedOut,
              ),
            ),
          ),
        ],
      ),
    );
    await tester.pump();

    // assert
    expect(find.text('트랙 PIN을 입력하세요'), findsOneWidget);
    expect(find.textContaining('로그아웃되었습니다'), findsNothing);
    expect(find.textContaining('찾을 수 없습니다'), findsNothing);
  });
}

/// TrackSession fake — 복원(_restore) 없이 곧바로 원하는 상태로 시작한다.
class _FixedTrackSession extends TrackSession {
  _FixedTrackSession(this._state);

  final TrackSessionState _state;

  @override
  TrackSessionState build() => _state;
}
