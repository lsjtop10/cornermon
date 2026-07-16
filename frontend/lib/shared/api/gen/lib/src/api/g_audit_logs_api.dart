//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'dart:async';

import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';

import 'package:cornermon_api_gen/src/api_util.dart';
import 'package:cornermon_api_gen/src/model/audit_log_page_response.dart';
import 'package:cornermon_api_gen/src/model/error_response.dart';

class GAuditLogsApi {

  final Dio _dio;

  final Serializers _serializers;

  const GAuditLogsApi(this._dio, this._serializers);

  /// 감사 로그 조회
  /// 시스템에서 발생한 중요 행위(인증, 방문, 예외 처리 등)의 감사 로그를 조회한다.
  ///
  /// Parameters:
  /// * [actor] - 행위자 부분 일치
  /// * [action] - 행위 종류 정확히 일치
  /// * [result] - 처리 결과
  /// * [limit] - 조회 개수
  /// * [before] - 이전 응답의 불투명 nextCursor
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [AuditLogPageResponse] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<AuditLogPageResponse>> auditLogsGet({ 
    String? actor,
    String? action,
    String? result,
    int? limit = 50,
    String? before,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/audit-logs';
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'apiKey',
            'name': 'AdminAuth',
            'keyName': 'Authorization',
            'where': 'header',
          },
        ],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _queryParameters = <String, dynamic>{
      if (actor != null) r'actor': encodeQueryParameter(_serializers, actor, const FullType(String)),
      if (action != null) r'action': encodeQueryParameter(_serializers, action, const FullType(String)),
      if (result != null) r'result': encodeQueryParameter(_serializers, result, const FullType(String)),
      if (limit != null) r'limit': encodeQueryParameter(_serializers, limit, const FullType(int)),
      if (before != null) r'before': encodeQueryParameter(_serializers, before, const FullType(String)),
    };

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      queryParameters: _queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    AuditLogPageResponse? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(AuditLogPageResponse),
      ) as AuditLogPageResponse;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<AuditLogPageResponse>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

}
