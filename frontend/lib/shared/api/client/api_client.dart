import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../config/app_env.dart';
import 'auth_interceptor.dart';

part 'api_client.g.dart';

@riverpod
Dio apiClient(Ref ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppEnv.apiBaseUrl,
      connectTimeout: const Duration(milliseconds: AppEnv.apiConnectTimeoutMs),
      receiveTimeout: const Duration(milliseconds: AppEnv.apiReceiveTimeoutMs),
    ),
  );
  dio.interceptors.add(AuthInterceptor(ref));

  return dio;
}
