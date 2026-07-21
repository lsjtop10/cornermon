import 'package:built_value/serializer.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:dio/dio.dart';

/// 서버까지 요청이 도달했는지로 에러를 두 갈래로 나눈다 — 표시 방식이 다르기 때문이다
/// (connection_banner.dart 사용처의 상단 배너 vs SnackBar).
///
/// true: 커넥션 유실 — 타임아웃/연결 실패 등 서버 응답 자체를 못 받은 경우.
/// false: API 호출 에러(서버가 4xx/5xx로 응답) 또는 그 외 에러.
bool isConnectionLost(DioException error) => switch (error.type) {
  DioExceptionType.connectionTimeout ||
  DioExceptionType.sendTimeout ||
  DioExceptionType.receiveTimeout ||
  DioExceptionType.connectionError => true,
  _ => false,
};

/// 응답 바디의 `ErrorResponse.code`를 [ErrorCode]로 안전하게 변환한다.
/// 문자열 리터럴로 직접 비교하면 백엔드가 코드명을 바꿔도 컴파일러가 못 잡는다
/// (pin_login_error_provider.dart가 겪은 드리프트 참고) — enum 비교로 바꾸면 백엔드가
/// 코드를 없애거나 이름을 바꿨을 때 이 switch의 case가 컴파일 경고 없이 죽지 않는다.
/// 클라이언트가 재생성 전이라 모르는 코드(백엔드가 새로 추가한 값 등)는 null로 취급해
/// 호출부의 기본 분기를 타게 한다.
ErrorCode? errorCodeOf(DioException error) {
  final data = error.response?.data;
  final body = data is Map ? data : null;
  final raw = body?['code'] as String?;
  if (raw == null) return null;
  try {
    return standardSerializers.deserialize(
      raw,
      specifiedType: const FullType(ErrorCode),
    ) as ErrorCode;
  } on Object {
    return null;
  }
}
