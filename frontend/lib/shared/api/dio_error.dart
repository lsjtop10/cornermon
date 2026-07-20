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
