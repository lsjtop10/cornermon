/// 앱 전역 네트워크 설정. --dart-define(-from-file)로 컴파일 타임에 주입되며,
/// 값을 넘기지 않으면 로컬 개발 기본값으로 동작한다.
class AppEnv {
  const AppEnv._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost/api/v1',
  );

  static const int apiConnectTimeoutMs = int.fromEnvironment(
    'API_CONNECT_TIMEOUT_MS',
    defaultValue: 5000,
  );

  static const int apiReceiveTimeoutMs = int.fromEnvironment(
    'API_RECEIVE_TIMEOUT_MS',
    defaultValue: 5000,
  );

  static const int sseHeartbeatTimeoutSeconds = int.fromEnvironment(
    'SSE_HEARTBEAT_TIMEOUT_SECONDS',
    defaultValue: 40,
  );
}
