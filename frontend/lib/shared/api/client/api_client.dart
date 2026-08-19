import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../config/app_env.dart';
import 'auth_interceptor.dart';
import 'logging_interceptor.dart';
import 'status_fallback_interceptor.dart';
import 'trace_id_interceptor.dart';

part 'api_client.g.dart';

@Riverpod(keepAlive: true)
Dio apiClient(Ref ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppEnv.apiBaseUrl,
      connectTimeout: const Duration(milliseconds: AppEnv.apiConnectTimeoutMs),
      receiveTimeout: const Duration(milliseconds: AppEnv.apiReceiveTimeoutMs),
    ),
  );
  // 등록 순서 = 요청이 실제로 거치는 순서. LoggingInterceptor를 가장 마지막에 둬서
  // AuthInterceptor의 401/409 재시도가 끝난 뒤 호출부로 나가는 최종 에러만 기록한다
  // (#131 UC-1/UC-2).
  dio.interceptors.add(const TraceIdInterceptor());
  dio.interceptors.add(AuthInterceptor(ref));
  dio.interceptors.add(StatusFallbackInterceptor());
  dio.interceptors.add(LoggingInterceptor(ref));

  return dio;
}
