import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/session_token_source.dart';
import 'api_client.dart';

/// [SessionTokenSource]만 참조한다 — admin/session·facilitator/session을 직접 알지 못한다(00_overview.md §4-a).
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this.ref);

  final Ref ref;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = ref.read(sessionTokenSourceProvider).currentAccessToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final response = err.response;
    // 기기 상태 조회는 트랙 401의 복구 수단이다. 이 요청 자체가 401이면 다시
    // onUnauthorized()를 호출해 같은 `/me` 요청을 재귀적으로 만들지 않는다.
    final isDeviceStatusRequest = err.requestOptions.path.endsWith(
      '/device-registrations/me',
    );
    if (response?.statusCode != 401 || isDeviceStatusRequest) {
      handler.next(err);
      return;
    }

    await ref.read(sessionTokenSourceProvider).onUnauthorized();

    final token = ref.read(sessionTokenSourceProvider).currentAccessToken;
    if (token == null) {
      handler.next(err);
      return;
    }

    try {
      final retryOptions = err.requestOptions.copyWith(
        headers: {
          ...err.requestOptions.headers,
          'Authorization': 'Bearer $token',
        },
      );
      final retryResponse = await ref
          .read(apiClientProvider)
          .fetch<dynamic>(retryOptions);
      handler.resolve(retryResponse);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }
}
