import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';

import '../../auth/session_token_source.dart';
import '../dio_error.dart';
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

    // 404는 재시도 대상이 아니다 — 각 앱이 필요하면 처리(세션 종료 등)하고 원래 에러는
    // 그대로 호출부에 흘려보낸다(이슈 #200: TRACK_NOT_FOUND).
    if (response?.statusCode == 404) {
      await ref.read(sessionTokenSourceProvider).onResourceNotFound(err);
      handler.next(err);
      return;
    }

    // track_replaced SSE를 놓쳤을 때의 폴백 복구 경로다(이슈 #204) — SSE로 이미 처리됐다면
    // 세션이 새 트랙을 가리키고 있어 이 분기 자체를 안 타지만, 놓쳤을 경우 다음 요청이
    // 여기서 걸려 마이그레이션을 대신 트리거한다. camp_ended가 device-registrations/me로
    // 복구하는 것과 같은 이중 안전망 패턴이다.
    if (response?.statusCode == 409 &&
        errorCodeOf(err) == ErrorCode.CodeSessionMigrationRequired) {
      await ref.read(sessionTokenSourceProvider).onSessionMigrationRequired();
      await _retryWithCurrentToken(err, handler);
      return;
    }

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
    await _retryWithCurrentToken(err, handler);
  }

  Future<void> _retryWithCurrentToken(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
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
