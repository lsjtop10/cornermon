import 'package:cornermon/shared/config/app_env.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ShouldReturnLocalhostBaseUrlWhenNoOverrideInjected', () {
    // arrange
    // (컴파일 타임 상수 — 별도 arrange 없음)

    // act
    const baseUrl = AppEnv.apiBaseUrl;

    // assert
    expect(baseUrl, 'http://localhost/api/v1');
  });

  test('ShouldReturnFiveSecondTimeoutsWhenNoOverrideInjected', () {
    // arrange
    // (컴파일 타임 상수 — 별도 arrange 없음)

    // act
    const connectTimeoutMs = AppEnv.apiConnectTimeoutMs;
    const receiveTimeoutMs = AppEnv.apiReceiveTimeoutMs;

    // assert
    expect(connectTimeoutMs, 5000);
    expect(receiveTimeoutMs, 5000);
  });

  test('ShouldReturnFortySecondHeartbeatTimeoutWhenNoOverrideInjected', () {
    // arrange
    // (컴파일 타임 상수 — 별도 arrange 없음)

    // act
    const heartbeatTimeoutSeconds = AppEnv.sseHeartbeatTimeoutSeconds;

    // assert
    expect(heartbeatTimeoutSeconds, 40);
  });
}
