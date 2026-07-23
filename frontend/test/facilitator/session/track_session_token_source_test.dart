import 'package:cornermon/facilitator/session/track_session_provider.dart';
import 'package:cornermon/facilitator/session/track_session_token_source.dart';
import 'package:cornermon/shared/auth/secure_token_store.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// 트랙 세션 저장 키만 다루는 메모리 스토어(플랫폼 채널 회피).
/// device_trust_status를 approved로 채워 TrackSession.build()의 deviceTrustProvider
/// 리스너가 forceLogout을 먼저 걸어버리는 것을 막는다(track_session_provider_test.dart 참고).
class _FakeSecureTokenStore implements SecureTokenStore {
  final Map<String, String> values = {'device_trust_status': 'approved'};

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> delete(String key) async => values.remove(key);
}

final _tokenSourceProvider = Provider(
  (ref) => TrackSessionTokenSource(ref),
);

DioException _errorWithCode(String? code, {int statusCode = 404}) =>
    DioException(
      requestOptions: RequestOptions(path: '/messages/unread-count'),
      response: Response<Map<String, dynamic>>(
        requestOptions: RequestOptions(path: '/messages/unread-count'),
        statusCode: statusCode,
        data: code == null ? <String, dynamic>{} : {'code': code},
      ),
    );

void main() {
  test(
    'ShouldHandleTerminationAndReturnTrueWhenTrackNotFoundDetected',
    () async {
      // arrange
      final store = _FakeSecureTokenStore();
      final container = ProviderContainer(
        overrides: [secureTokenStoreProvider.overrideWithValue(store)],
      );
      addTearDown(container.dispose);
      container.listen(trackSessionProvider, (_, _) {});
      final source = container.read(_tokenSourceProvider);

      // act
      final handled = await source.onResourceNotFound(
        _errorWithCode('TRACK_NOT_FOUND'),
      );

      // assert: 세션이 trackNotFound 사유로 종료되고, 인터셉터에겐 처리됐다고 알린다.
      expect(handled, isTrue);
      final state = container.read(trackSessionProvider);
      expect(state, isA<TrackSessionUnauthenticated>());
      expect(
        (state as TrackSessionUnauthenticated).lastTerminationReason,
        TrackSessionTerminationReason.trackNotFound,
      );
    },
  );

  test(
    'ShouldReturnFalseAndLeaveSessionUntouchedWhenNotTrackNotFoundCode',
    () async {
      // arrange
      final store = _FakeSecureTokenStore();
      final container = ProviderContainer(
        overrides: [secureTokenStoreProvider.overrideWithValue(store)],
      );
      addTearDown(container.dispose);
      container.listen(trackSessionProvider, (_, _) {});
      final source = container.read(_tokenSourceProvider);

      // act: 다른 404(예: BADGE_NOT_ASSIGNED)는 이 훅과 무관하다.
      final handled = await source.onResourceNotFound(
        _errorWithCode('BADGE_NOT_ASSIGNED'),
      );

      // assert
      expect(handled, isFalse);
      expect(
        container.read(trackSessionProvider),
        isA<TrackSessionUnauthenticated>(),
      );
      expect(
        (container.read(trackSessionProvider) as TrackSessionUnauthenticated)
            .lastTerminationReason,
        isNull,
      );
    },
  );
}
